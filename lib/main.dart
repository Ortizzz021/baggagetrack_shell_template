import 'package:baggage_track_shell/database/app_database.dart';
import 'package:baggage_track_shell/local/baggage_event_local_data_source.dart';
import 'package:baggage_track_shell/repositories/baggage_event_repository.dart';
import 'package:flutter/material.dart';

import 'pages/baggage_list_page.dart';
import 'theme/app_theme.dart';

void main() {
  final database = AppDatabase();
  final local = BaggageEventLocalDataSource(database);
  final eventRepository = BaggageEventRepository(local: local);
  runApp(BaggageTrackApp(eventRepository: eventRepository));
}

class BaggageTrackApp extends StatelessWidget {
  final BaggageEventRepository eventRepository;
  const BaggageTrackApp({super.key, required this.eventRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaggageTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BaggageListPage(),
    );
  }
}
