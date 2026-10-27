import 'package:flutter/material.dart';

import '../models/baggage.dart';
import '../models/baggage_event.dart';
import '../models/baggage_status.dart';
import '../repositories/baggage_event_repository.dart';
import '../widgets/status_chip.dart';

class BaggageDetailPage extends StatefulWidget {
  const BaggageDetailPage({
    super.key,
    required this.baggage,
    required this.eventRepository,
  });

  final Baggage baggage;
  final BaggageEventRepository eventRepository;

  @override
  State<BaggageDetailPage> createState() => _BaggageDetailPageState();
}

class _BaggageDetailPageState extends State<BaggageDetailPage> {
  List<BaggageEvent> _events = [];
  bool _loading = true;
  bool _saving = false;
  bool _fromLocal = false;

  BaggageStatus get _status => BaggageStatus.fromEvents(_events);

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    final result =
        await widget.eventRepository.getEventsForBaggage(widget.baggage.id);
    if (!mounted) return;
    setState(() {
      _events = result.events;
      _fromLocal = result.fromLocal;
      _loading = false;
    });
  }

  Future<void> _registerNext() async {
    final target = _status.next;
    if (target == null) return;

    setState(() => _saving = true);
    try {
      await widget.eventRepository.registerEvent(
        baggageId: widget.baggage.id,
        target: target,
      );
      _showMessage('Evento "${target.label}" registrado.');
      await _loadEvents();
    } on InvalidTransitionException catch (e) {
      _showMessage(e.message, isError: true);
    } on RemoteSaveException catch (e) {
      _showMessage('$e El evento no fue confirmado.', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final next = _status.next;

    return Scaffold(
      appBar: AppBar(title: Text(widget.baggage.id)),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_fromLocal) ...[
              const LocalDataBanner(),
              const SizedBox(height: 12),
            ],
            _BaggageHeader(baggage: widget.baggage, status: _status),
            const SizedBox(height: 24),
            Text(
              'Historial de eventos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_events.isEmpty)
              const _EmptyHistory()
            else
              _History(events: _events),
            const SizedBox(height: 18),
            if (next == null)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text('Recorrido finalizado'),
                  subtitle: Text('El equipaje ya fue entregado.'),
                ),
              )
            else
              FilledButton.icon(
                onPressed: _loading || _saving ? null : _registerNext,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text('Registrar: ${next.label}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BaggageHeader extends StatelessWidget {
  const _BaggageHeader({required this.baggage, required this.status});

  final Baggage baggage;
  final BaggageStatus status;

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
                      StatusChip(status: status),
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

class _History extends StatelessWidget {
  const _History({required this.events});

  final List<BaggageEvent> events;

  String _format(DateTime date) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (final event in events)
            Builder(builder: (context) {
              final status = BaggageStatus.fromCode(event.type);
              return ListTile(
                leading: Icon(
                  Icons.radio_button_checked,
                  color: StatusChip.colorFor(status),
                ),
                title: Text(status.label),
                subtitle: Text('${event.type} · ${_format(event.createdAt)}'),
              );
            }),
        ],
      ),
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
