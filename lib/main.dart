import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:kalender/kalender.dart';

import 'firebase_options.dart';
import 'features/auth/providers/auth_providers.dart';
import 'router/app_router.dart';

// Phase 1 bootstrap: Firebase + Riverpod + PIN auth gate.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Remove legacy `#/` hash URLs on Flutter Web / PWA.
  usePathUrlStrategy();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Keep-style offline: cache data on this device (IndexedDB on web).
  // Must be set before any other Firestore call. Writes still queue locally
  // and sync to the cloud when the internet returns.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final container = ProviderContainer();
  // Restore prior unlock so Safari PWA doesn't ask PIN every cold start.
  await container.read(authSessionProvider.notifier).restore();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TimeblockApp(),
    ),
  );
}

class TimeblockApp extends ConsumerWidget {
  const TimeblockApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Timeblock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF121212),
          primary: Color(0xFFB39DDB), // Lavender (Google Calendar-ish)
        ),
        // Soft grid lines against true-black OLED background.
        extensions: const [
          KalenderThemeData(
            hourLinesStyle: HourLinesStyle(
              color: Color(0xFF2A2A2A),
              thickness: 1,
            ),
            daySeparatorStyle: DaySeparatorStyle(
              color: Color(0xFF2A2A2A),
            ),
          ),
        ],
      ),
      routerConfig: router,
    );
  }
}
