// lib/services/lock_service.dart
import 'package:mindmeld_ai/extentions.dart';

/// A service to manage the app's lock state based on its lifecycle.
class LockService {
  // Singleton pattern ensures we only have one instance of this service.
  LockService._privateConstructor();
  static final LockService instance = LockService._privateConstructor();

  /// The duration the app can be in the background before a lock is required.
  static const lockTimeout = Duration(seconds: 15);

  // A notifier that our UI will listen to for lock requests.
  final ValueNotifier<bool> requiresAuth = ValueNotifier(false);

  // Stores the timestamp of when the app was last paused.
  DateTime? _lastPausedTime;

  /// Call this when the app's lifecycle state changes to `paused` or `inactive`.
  void onPaused() {
    _lastPausedTime = DateTime.now();
  }

  /// Call this when the app's lifecycle state changes to `resumed`.
  void onResumed() async {
    // Made this async
    // First, robustly check if security is even enabled. If not, do nothing.
    final bool isSecurityOn = await SecurityService.isSecurityEnabled();
    if (!isSecurityOn) {
      _lastPausedTime = null; // Still reset the timer
      return;
    }

    if (_lastPausedTime == null) {
      return; // Nothing to check if it was never paused.
    }

    final now = DateTime.now();
    final difference = now.difference(_lastPausedTime!);

    // If the app was paused for longer than our timeout, trigger authentication.
    if (difference > lockTimeout) {
      // We set the notifier to true, which will trigger the UI to show the lock screen.
      requiresAuth.value = true;
    }

    // Reset the paused time regardless of the outcome.
    _lastPausedTime = null;
  }
}
