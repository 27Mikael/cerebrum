import 'package:flutter/material.dart';
// import './responsive_layout.dart';
import 'package:cerebrum_app/api/api_config.dart';
import 'package:cerebrum_app/services/sync_service.dart';
import 'package:cerebrum_app/ui/app_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hydrate the daemon base URL / mode from storage before any request runs.
  await ApiConfig.init();
  // Retry any note pushes queued while offline (fire-and-forget; safe if none).
  SyncService.drainOutbox();
  runApp(const CerebrumApp());
}

class CerebrumApp extends StatelessWidget {
  const CerebrumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppEntryPoint(),
      // TODO: tablet: const TabletUI()
    );
  }
}
