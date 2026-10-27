import 'baggage_event.dart';

enum BaggageStatus {
  none(null, 'Sin eventos'),
  checkedIn('CHECKED_IN', 'Registrado en aeropuerto'),
  security('SECURITY', 'Inspeccion de seguridad'),
  loaded('LOADED', 'Cargado en aeronave'),
  inTransit('IN_TRANSIT', 'En transito'),
  delivered('DELIVERED', 'Entregado');

  const BaggageStatus(this.code, this.label);

  final String? code;
  final String label;

  static BaggageStatus fromCode(String code) {
    return BaggageStatus.values.firstWhere(
      (s) => s.code == code,
      orElse: () => throw ArgumentError('Tipo de evento desconocido: $code'),
    );
  }

  static BaggageStatus fromEvents(List<BaggageEvent> events) {
    if (events.isEmpty) return BaggageStatus.none;
    final latest = events.reduce(
      (a, b) => b.createdAt.isAfter(a.createdAt) ? b : a,
    );
    return BaggageStatus.fromCode(latest.type);
  }

  BaggageStatus? get next {
    if (this == BaggageStatus.delivered) return null;
    return BaggageStatus.values[index + 1];
  }

  bool canTransitionTo(BaggageStatus target) => next == target;
}
