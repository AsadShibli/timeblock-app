import 'dart:async';

/// Firestore write Futures wait for the **server**. Offline, that hangs the UI.
///
/// The write is already applied to the local cache (list updates instantly).
/// [ignore] lets us return immediately; Firestore syncs when internet returns.
void queueWrite(Future<void> write) {
  write.ignore();
}
