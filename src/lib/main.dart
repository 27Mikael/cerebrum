import 'package:flutter/material.dart';
// import './responsive_layout.dart';
import 'package:cerebrum_app/api/api_config.dart';
import 'package:cerebrum_app/services/sync_service.dart';
import 'package:cerebrum_app/services/engram_sync_service.dart';
import 'package:cerebrum_app/ui/app_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hydrate the daemon base URL / mode from storage before any request runs.
  await ApiConfig.init();
  // Retry anything queued while offline (fire-and-forget; safe if none): note
  // pushes/images/deletes, and engram answers awaiting submit/grade.
  SyncService.drainOutbox();
  EngramSyncService.drain();
  // Show a badge for any grade that landed in a previous session.
  EngramSyncService.refreshBadge();
  runApp(const CerebrumApp());
}

class CerebrumApp extends StatefulWidget {
  const CerebrumApp({super.key});

  @override
  State<CerebrumApp> createState() => _CerebrumAppState();
}

class _CerebrumAppState extends State<CerebrumApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back to the foreground retries anything queued while we were away.
    // While foregrounded, SyncService's own auto-drain poll keeps retrying until
    // the outboxes clear, so a note saved offline syncs once the daemon is back
    // even without a dedicated OS connectivity listener.
    if (state == AppLifecycleState.resumed) {
      SyncService.drainOutbox();
      EngramSyncService.drain();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AppEntryPoint(),
      // TODO: tablet: const TabletUI()
    );
  }
}
