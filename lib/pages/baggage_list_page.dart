import 'package:flutter/material.dart';

import '../data/baggage_seed.dart';
import '../models/baggage.dart';
import '../widgets/baggage_card.dart';
import 'baggage_detail_page.dart';

class BaggageListPage extends StatelessWidget {
  const BaggageListPage({super.key});

  void _openDetail(BuildContext context, Baggage baggage) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BaggageDetailPage(baggage: baggage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: baggageSeed.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final baggage = baggageSeed[index];
            return BaggageCard(
              baggage: baggage,
              onTap: () => _openDetail(context, baggage),
            );
          },
        ),
      ),
    );
  }
}
