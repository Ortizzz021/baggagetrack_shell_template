import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../local/baggage_events_table.dart';

part 'app_database.g.dart';

/// Punto de inicio para la persistencia local del examen.
///
/// La shell no incluye Drift como dependencia. Este archivo compila sin Drift
/// para que la aplicacion inicial pueda ejecutarse. Durante el examen se debe
/// transformar esta clase en la base de datos requerida por el enunciado.

@DriftDatabase(tables: [BaggageEvents])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.deleteTable(baggageEvents.actualTableName);
            await m.createTable(baggageEvents);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'baggage.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
