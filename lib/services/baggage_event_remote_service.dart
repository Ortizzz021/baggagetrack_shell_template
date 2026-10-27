import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/baggage_event.dart';

/// Punto de inicio para la fuente remota.
///
/// La shell no incluye Firebase ni Cloud Firestore como dependencias.
class BaggageEventRemoteService {
  BaggageEventRemoteService(this.firestore);

  final FirebaseFirestore firestore;

  static const _timeout = Duration(seconds: 8);

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('baggage_events');

  static const _serverOnly = GetOptions(source: Source.server);

  Future<List<BaggageEvent>> getEvents() async {
    // TODO: implementar lectura remota.
    final snapshot = await _collection.get(_serverOnly).timeout(_timeout);
    return snapshot.docs.map(_fromDoc).toList();
  }

  Future<List<BaggageEvent>> getEventsForBaggage(String baggageId) async {
    final snapshot = await _collection
        .where('baggageId', isEqualTo: baggageId)
        .get(_serverOnly)
        .timeout(_timeout);
    return snapshot.docs.map(_fromDoc).toList();
  }

  Future<void> saveEvent(BaggageEvent event) async {
    // TODO: implementar escritura remota.
    await _collection.doc(event.id).set({
      'id': event.id,
      'baggageId': event.baggageId,
      'type': event.type,
      'createdAt': Timestamp.fromDate(event.createdAt),
    }).timeout(_timeout);
  }

  BaggageEvent _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final rawDate = data['createdAt'];
    final createdAt = rawDate is Timestamp
        ? rawDate.toDate()
        : DateTime.parse(rawDate as String);
    return BaggageEvent(
      id: (data['id'] as String?) ?? doc.id,
      baggageId: data['baggageId'] as String,
      type: data['type'] as String,
      createdAt: createdAt,
    );
  }
}
