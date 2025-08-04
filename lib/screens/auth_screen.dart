// lib/screens/auth_screen.dart
import 'package:mindmeld_ai/extentions.dart';

class AuthScreen extends StatefulWidget {
  /// A boolean to determine the navigation behavior on successful authentication.
  /// If true, the screen will pop itself.
  /// If false (default), it will replace the current navigation stack with the HomeScreen.
  final bool isPushedAsOverlay;

  const AuthScreen({super.key, this.isPushedAsOverlay = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  void initState() {
    super.initState();
    // We want to trigger authentication immediately, but only after the first frame has been built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticateUser());
  }

  Future<void> _authenticateUser() async {
    final didAuthenticate = await SecurityService.authenticate();
    if (didAuthenticate && mounted) {
      // --- This is the key logic change ---
      if (widget.isPushedAsOverlay) {
        // If we were pushed on top of another screen, just dismiss ourselves.
        Navigator.of(context).pop();
      } else {
        // If we were the initial screen, replace the entire stack with the HomeScreen.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // You could add logic here for failed auth, e.g., show a message or close the app.
      print("Authentication failed or was cancelled by the user.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            const Text("MindMeld is Locked",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Please authenticate to continue",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _authenticateUser,
              icon: const Icon(Icons.fingerprint),
              label: const Text("Authenticate"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
