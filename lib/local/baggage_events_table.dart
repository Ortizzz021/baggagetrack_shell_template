import 'package:drift/drift.dart';

@DataClassName('BaggageEventRow')
class BaggageEvents extends Table {
  TextColumn get id => text()();
  TextColumn get baggageId => text()();
  TextColumn get type => text()();
  DateTimeColumn get createdAt => dateTime()();

  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {baggageId};
}
