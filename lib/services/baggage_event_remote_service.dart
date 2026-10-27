import '../models/baggage_event.dart';

/// Punto de inicio para la fuente remota.
///
/// La shell no incluye Firebase ni Cloud Firestore como dependencias.
class BaggageEventRemoteService {
  Future<List<BaggageEvent>> getEvents() async {
    // TODO: implementar lectura remota.
    throw UnimplementedError();
  }

  Future<void> saveEvent(BaggageEvent event) async {
    // TODO: implementar escritura remota.
    throw UnimplementedError();
  }
}
