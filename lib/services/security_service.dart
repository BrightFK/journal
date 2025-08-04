// lib/services/security_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const _prefKey = 'isSecurityEnabled';

  static Future<bool> isSecurityEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> setSecurity(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, isEnabled);
  }

  static Future<bool> authenticate() async {
    try {
      // First, check if biometrics are even available on the device.
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics)
        return true; // If no biometrics, we can't lock, so let them in.

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access your journal',
        options: const AuthenticationOptions(
          biometricOnly: true, // This requires biometrics
          stickyAuth: true, // Keep the prompt active until resolved
        ),
      );
    } catch (e) {
      print("Authentication error: $e");
      return false; // Fail securely if there's an error.
    }
  }
}
