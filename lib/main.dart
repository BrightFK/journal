// lib/main.dart
import 'package:mindmeld_ai/extentions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool hasOnboarded = prefs.getBool('hasOnboarded') ?? false;

  final bool isSecurityEnabled = await SecurityService.isSecurityEnabled();

  await Hive.initFlutter();
  // Register all your adapters - this part is correct!
  Hive.registerAdapter(JournalEntryAdapter());
  Hive.registerAdapter(AIAnalysisAdapter());
  Hive.registerAdapter(UserProfileAdapter());

  // Open all your boxes - this part is also correct!
  await Hive.openBox<JournalEntry>('journal_entries');
  await Hive.openBox<UserProfile>('user_profile');

  // --- THIS IS THE FIRST FIX: Wrap your app in the Provider ---
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(
          hasOnboarded: hasOnboarded, isSecurityEnabled: isSecurityEnabled),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isSecurityEnabled;
  final bool hasOnboarded;
  const MyApp(
      {super.key, required this.hasOnboarded, required this.isSecurityEnabled});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    const Color darkBackgroundColor = Color(0xFF1C1C1E);
    const Color cardBackgroundColor = Color(0xFF2C2C2E);

    return MaterialApp(
      title: 'MindMeld AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark().copyWith(
          // --- USE THE PROVIDER'S COLOR HERE ---
          primary: themeProvider.primaryColor,
          // --- END OF CHANGE ---
          onPrimary: Colors.white,
          surface: cardBackgroundColor,
          background: darkBackgroundColor,
        ),

        // Propagating Colors to Common Widgets
        scaffoldBackgroundColor: darkBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: cardBackgroundColor,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          // This will now AUTOMATICALLY update because it uses colorScheme.primary
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white.withOpacity(0.1),
          // This will also AUTOMATICALLY update now
          selectedColor: themeProvider.primaryColor,
          labelStyle: const TextStyle(color: Colors.white70),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          shape: const StadiumBorder(
              side: BorderSide(width: 0.5, color: Colors.transparent)),
          showCheckmark: false,
        ),
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    if (!hasOnboarded) {
      return const OnboardingScreen();
    }
    if (isSecurityEnabled) {
      return const AuthScreen();
    }
    return const HomeScreen();
  }
}
