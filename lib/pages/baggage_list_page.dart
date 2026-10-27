import 'package:flutter/material.dart';

import '../data/baggage_seed.dart';
import '../models/baggage.dart';
import '../models/baggage_status.dart';
import '../repositories/baggage_event_repository.dart';
import '../widgets/baggage_card.dart';
import '../widgets/status_chip.dart';
import 'baggage_detail_page.dart';

class BaggageListPage extends StatefulWidget {
  const BaggageListPage({super.key, required this.eventRepository});

  final BaggageEventRepository eventRepository;

  @override
  State<BaggageListPage> createState() => _BaggageListPageState();
}

class _BaggageListPageState extends State<BaggageListPage> {
  Map<String, BaggageStatus> _statuses = {};
  bool _loading = true;
  bool _fromLocal = false;

  BaggageStatus? _filter;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    setState(() => _loading = true);
    final result = await widget.eventRepository.getAllEvents();
    final statuses = <String, BaggageStatus>{
      for (final baggage in baggageSeed)
        baggage.id: BaggageStatus.fromEvents(
          result.events.where((e) => e.baggageId == baggage.id).toList(),
        ),
    };
    if (!mounted) return;
    setState(() {
      _statuses = statuses;
      _fromLocal = result.fromLocal;
      _loading = false;
    });
  }

  BaggageStatus _statusOf(Baggage baggage) =>
      _statuses[baggage.id] ?? BaggageStatus.none;

  List<Baggage> get _visibleBaggage => _filter == null
      ? baggageSeed
      : baggageSeed.where((b) => _statusOf(b) == _filter).toList();

  int _countFor(BaggageStatus? status) => status == null
      ? baggageSeed.length
      : baggageSeed.where((b) => _statusOf(b) == status).length;

  Future<void> _openDetail(Baggage baggage) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BaggageDetailPage(
          baggage: baggage,
          eventRepository: widget.eventRepository,
        ),
      ),
    );
    _loadStatuses();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleBaggage;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.luggage_outlined),
            SizedBox(width: 10),
            Text('BaggageTrack'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _loadStatuses,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_fromLocal) const LocalDataBanner(),
            _StatusFilterBar(
              selected: _filter,
              countFor: _countFor,
              onSelected: (status) => setState(() => _filter = status),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mostrando ${visible.length} de ${baggageSeed.length} '
                  'equipajes'
                  '${_filter == null ? '' : ' · ${_filter!.label}'}',
                  key: const Key('visible-counter'),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadStatuses,
                child: visible.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(32),
                        children: const [
                          Icon(Icons.filter_alt_off, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'No hay equipajes con este estado.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final baggage = visible[index];
                          return BaggageCard(
                            baggage: baggage,
                            status: _statusOf(baggage),
                            onTap: () => _openDetail(baggage),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({
    required this.selected,
    required this.countFor,
    required this.onSelected,
  });

  final BaggageStatus? selected;
  final int Function(BaggageStatus?) countFor;
  final ValueChanged<BaggageStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <BaggageStatus?>[null, ...BaggageStatus.values];
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = options[index];
          final label = status?.label ?? 'Todos';
          return ChoiceChip(
            label: Text('$label (${countFor(status)})'),
            selected: selected == status,
            onSelected: (_) => onSelected(status),
          );
        },
      ),
    );
  }
}
