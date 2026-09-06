import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/pin_auth_repository.dart';

part 'auth_providers.g.dart';

/// Provides the PIN auth repository (singleton for the app lifetime).
@Riverpod(keepAlive: true)
PinAuthRepository pinAuthRepository(Ref ref) {
  return PinAuthRepository();
}

/// Holds the resolved profile UID after a successful 3-char PIN login.
/// null = locked / not authenticated.
@Riverpod(keepAlive: true)
class AuthSession extends _$AuthSession {
  @override
  String? build() => null;

  /// Tries restoring a previous unlock from local storage.
  Future<void> restore() async {
    final uid = await ref.read(pinAuthRepositoryProvider).restoreSession();
    state = uid;
  }

  /// Unlocks the app with a 3-character PIN.
  Future<void> unlockWithPin(String pin) async {
    final uid = await ref.read(pinAuthRepositoryProvider).signInWithPin(pin);
    state = uid;
  }

  Future<void> lock() async {
    await ref.read(pinAuthRepositoryProvider).signOut();
    state = null;
  }
}
