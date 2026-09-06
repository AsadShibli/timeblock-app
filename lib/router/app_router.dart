import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pin_login_screen.dart';
import '../features/auth/providers/auth_providers.dart';
import '../features/shell/home_shell.dart';

/// PIN gate -> HomeShell (Brain Dump + Execution).
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(authSessionProvider) != null;
      final onLogin = state.matchedLocation == '/login';
      if (!loggedIn && !onLogin) return '/login';
      if (loggedIn && onLogin) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const PinLoginScreen()),
      // Phase 1 placeholder replaced by HomeShell (tabs) in Phase 3.
      GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
    ],
  );
});

/// Notifies GoRouter when auth session changes.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(authSessionProvider, (previous, next) => notifyListeners());
  }
  final Ref _ref;
}

// Phase 1 unlock placeholder kept as comment for reference:
// class _AuthHomePlaceholder extended ConsumerWidget and showed UID + Lock.
