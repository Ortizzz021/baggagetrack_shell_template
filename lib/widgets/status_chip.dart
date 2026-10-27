import 'package:flutter/material.dart';

import '../models/baggage_status.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final BaggageStatus status;

  static Color colorFor(BaggageStatus status) {
    switch (status) {
      case BaggageStatus.none:
        return Colors.grey;
      case BaggageStatus.checkedIn:
        return Colors.blue;
      case BaggageStatus.security:
        return Colors.orange;
      case BaggageStatus.loaded:
        return Colors.purple;
      case BaggageStatus.inTransit:
        return Colors.teal;
      case BaggageStatus.delivered:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class LocalDataBanner extends StatelessWidget {
  const LocalDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      backgroundColor: Colors.amber.shade100,
      leading: const Icon(Icons.cloud_off, color: Colors.brown),
      content: const Text(
        'Sin conexion con Firestore. Mostrando el ultimo estado conocido '
        'guardado localmente.',
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}
