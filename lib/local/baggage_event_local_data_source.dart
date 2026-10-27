import 'package:baggage_track_shell/database/app_database.dart';
import 'package:drift/drift.dart';
import '../models/baggage_event.dart';

class BaggageEventLocalDataSource {
  final AppDatabase db;

  BaggageEventLocalDataSource(this.db);
  BaggageEvent _toDomain(BaggageEventRow row) {
    return BaggageEvent(
        id: row.id,
        baggageId: row.baggageId,
        type: row.type,
        createdAt: row.createdAt);
  }

  Future<BaggageEvent?> getEventForBaggage(String baggageId) async {
    final query = db.select(db.baggageEvents)..where((t) => t.baggageId.equals(baggageId));

    final row = await query.getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Future<void> saveEvent(BaggageEvent event) async {
    await db.into(db.baggageEvents).insertOnConflictUpdate(
        BaggageEventsCompanion.insert(
            id: event.id,
            baggageId: event.baggageId,
            type: event.type,
            createdAt: event.createdAt,
            pendingSync: const Value(true)));
  }

  Future<List<BaggageEvent>> getPendingEvents() async {
    final rows = await (db.select(db.baggageEvents)
          ..where((t) => t.pendingSync.equals(true)))
        .get();

    return rows.map(_toDomain).toList();
  }

  Future<void> markSynced(String baggageId) async {
    await (db.update(db.baggageEvents)..where((t) => t.baggageId.equals(baggageId)))
        .write(const BaggageEventsCompanion(pendingSync: Value(false)));
  }
}
