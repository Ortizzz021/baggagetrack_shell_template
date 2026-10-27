import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'database/app_database.dart';
import 'firebase_options.dart';
import 'local/baggage_event_local_data_source.dart';
import 'pages/baggage_list_page.dart';
import 'repositories/baggage_event_repository.dart';
import 'services/baggage_event_remote_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(persistenceEnabled: false);

  final database = AppDatabase();
  final eventRepository = BaggageEventRepository(
    local: BaggageEventLocalDataSource(database),
    remote: BaggageEventRemoteService(firestore),
  );

  runApp(BaggageTrackApp(eventRepository: eventRepository));
}

class BaggageTrackApp extends StatelessWidget {
  const BaggageTrackApp({super.key, required this.eventRepository});

  final BaggageEventRepository eventRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaggageTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: BaggageListPage(eventRepository: eventRepository),
    );
  }
}
