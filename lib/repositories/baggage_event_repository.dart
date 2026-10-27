import 'package:baggage_track_shell/local/baggage_event_local_data_source.dart';

import '../models/baggage_event.dart';

/// Punto de inicio para coordinar las fuentes de datos del examen.
class BaggageEventRepository {
  final BaggageEventLocalDataSource local;

  BaggageEventRepository({required this.local});

  Future<BaggageEvent?> getEventsForBaggage(String baggageId) =>
      local.getEventForBaggage(baggageId);

  Future<void> registerEvent(BaggageEvent event) => local.saveEvent(event);
}
