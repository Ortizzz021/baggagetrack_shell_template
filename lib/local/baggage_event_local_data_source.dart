import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/baggage_event.dart';

class BaggageEventLocalDataSource {
  final AppDatabase db;

  BaggageEventLocalDataSource(this.db);

  BaggageEvent _toDomain(BaggageEventRow row) {
    return BaggageEvent(
      id: row.id,
      baggageId: row.baggageId,
      type: row.type,
      createdAt: row.createdAt,
    );
  }

  BaggageEventsCompanion _toCompanion(BaggageEvent event) {
    return BaggageEventsCompanion.insert(
      id: event.id,
      baggageId: event.baggageId,
      type: event.type,
      createdAt: event.createdAt,
    );
  }

  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    final rows = await (db.select(db.baggageEvents)
          ..where((t) => t.baggageId.equals(baggageId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  Future<List<BaggageEvent>> getAllEvents() async {
    final rows = await (db.select(db.baggageEvents)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    return rows.map(_toDomain).toList();
  }

  Future<void> saveEvent(BaggageEvent event) async {
    await db.into(db.baggageEvents).insertOnConflictUpdate(_toCompanion(event));
  }

  Future<void> saveEvents(List<BaggageEvent> events) async {
    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        db.baggageEvents,
        events.map(_toCompanion).toList(),
      );
    });
  }
}
