import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Maps a 3-char PIN -> stable Firestore profile UID via Anonymous Auth.
class PinAuthRepository {
  PinAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  static const _prefsUserIdKey = 'profile_user_id';
  static const _pinCollection = 'pin_auth'; // pin_auth/{PIN} -> { uid }

  /// Validates 3 alphanumeric characters (letters or digits).
  bool isValidPin(String pin) =>
      RegExp(r'^[A-Za-z0-9]{3}$').hasMatch(pin);

  /// Returns cached profile UID if the device already unlocked once.
  Future<String?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsUserIdKey);
  }

  /// Signs in anonymously, then resolves (or creates) PIN -> UID mapping.
  Future<String> signInWithPin(String rawPin) async {
    final pin = rawPin.trim().toUpperCase();
    if (!isValidPin(pin)) {
      throw ArgumentError('PIN must be exactly 3 letters or digits.');
    }

    // Frictionless Firebase session (no email/password).
    final credential = await _auth.signInAnonymously();
    final anonUid = credential.user?.uid;
    if (anonUid == null) throw StateError('Anonymous sign-in failed.');

    final docRef = _db.collection(_pinCollection).doc(pin);
    final snap = await docRef.get();

    // Existing PIN keeps its fixed profile UID; first use claims this PIN.
    final profileUid = snap.exists
        ? (snap.data()?['uid'] as String? ?? anonUid)
        : anonUid;

    if (!snap.exists) {
      await docRef.set({
        'uid': profileUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsUserIdKey, profileUid);
    return profileUid;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsUserIdKey);
    await _auth.signOut();
  }
}
