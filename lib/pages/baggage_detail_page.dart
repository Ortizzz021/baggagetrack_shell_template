import 'package:flutter/material.dart';

import '../models/baggage.dart';

class BaggageDetailPage extends StatelessWidget {
  const BaggageDetailPage({
    super.key,
    required this.baggage,
  });

  final Baggage baggage;

  void _showPendingMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad a implementar durante el examen.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(baggage.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BaggageHeader(baggage: baggage),
          const SizedBox(height: 24),
          Text(
            'Historial de eventos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          const _EmptyHistory(),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _showPendingMessage(context),
            icon: const Icon(Icons.add),
            label: const Text('Registrar primer evento'),
          ),
        ],
      ),
    );
  }
}

class _BaggageHeader extends StatelessWidget {
  const _BaggageHeader({required this.baggage});

  final Baggage baggage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.luggage,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baggage.id,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Chip(label: Text('Sin eventos')),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: _InfoField(
                    label: 'Pasajero',
                    value: baggage.passenger,
                  ),
                ),
                Expanded(
                  child: _InfoField(
                    label: 'Vuelo',
                    value: baggage.flight,
                  ),
                ),
                Expanded(
                  child: _InfoField(
                    label: 'Destino',
                    value: baggage.destination,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Este equipaje aun no tiene eventos.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
