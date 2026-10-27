import '../local/baggage_event_local_data_source.dart';
import '../models/baggage_event.dart';
import '../models/baggage_status.dart';
import '../services/baggage_event_remote_service.dart';

class EventsResult {
  const EventsResult({required this.events, required this.fromLocal});

  final List<BaggageEvent> events;
  final bool fromLocal;
}

class InvalidTransitionException implements Exception {
  InvalidTransitionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RemoteSaveException implements Exception {
  RemoteSaveException(this.cause);

  final Object cause;

  @override
  String toString() => 'No se pudo guardar el evento en Firestore.';
}

/// Punto de inicio para coordinar las fuentes de datos del examen.
class BaggageEventRepository {
  BaggageEventRepository({required this.local, required this.remote});

  final BaggageEventLocalDataSource local;
  final BaggageEventRemoteService remote;

  Future<EventsResult> getEventsForBaggage(String baggageId) async {
    try {
      final events = await remote.getEventsForBaggage(baggageId);
      await local.saveEvents(events);
      return EventsResult(events: _sorted(events), fromLocal: false);
    } catch (_) {
      final cached = await local.getEventsForBaggage(baggageId);
      return EventsResult(events: cached, fromLocal: true);
    }
  }

  Future<EventsResult> getAllEvents() async {
    try {
      final events = await remote.getEvents();
      await local.saveEvents(events);
      return EventsResult(events: _sorted(events), fromLocal: false);
    } catch (_) {
      final cached = await local.getAllEvents();
      return EventsResult(events: cached, fromLocal: true);
    }
  }

  Future<BaggageEvent> registerEvent({
    required String baggageId,
    required BaggageStatus target,
  }) async {
    final history = await getEventsForBaggage(baggageId);
    final current = BaggageStatus.fromEvents(history.events);
    if (!current.canTransitionTo(target)) {
      final expected = current.next;
      throw InvalidTransitionException(
        expected == null
            ? 'El equipaje ya fue entregado; no admite mas eventos.'
            : 'Transicion invalida: de "${current.label}" solo se puede '
                'pasar a "${expected.label}".',
      );
    }

    final now = DateTime.now();
    final event = BaggageEvent(
      id: '${baggageId}_${now.microsecondsSinceEpoch}',
      baggageId: baggageId,
      type: target.code!,
      createdAt: now,
    );

    try {
      await remote.saveEvent(event);
    } catch (e) {
      throw RemoteSaveException(e);
    }
    await local.saveEvent(event);
    return event;
  }

  List<BaggageEvent> _sorted(List<BaggageEvent> events) =>
      [...events]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
}
