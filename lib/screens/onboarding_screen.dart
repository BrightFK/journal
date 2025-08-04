// lib/screens/onboarding_screen.dart
import 'package:mindmeld_ai/extentions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define the content for each onboarding page
  static const List<Map<String, dynamic>> _onboardingData = [
    {
      'icon': Icons.edit_note_outlined,
      'title': 'Capture Your Thoughts Instantly',
      'description':
          'Welcome to MindMeld! A secure and intelligent space to document your ideas, feelings, and daily progress without friction.',
    },
    {
      'icon': Icons.auto_awesome_outlined,
      'title': 'Discover Deeper Insights',
      'description':
          'Our legit AI analyzes your entries to reveal your mood trends and key life themes, offering compassionate, actionable advice to help you grow.',
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Private, Personal, and Yours',
      'description':
          'Your journal is end-to-end secured on your device. Customize the app with your own profile and theme colors to make it truly feel like home.',
    }
  ];

  // This function is called when the user finishes onboarding
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOnboarded', true);

    if (mounted) {
      // Use pushReplacement to go to the HomeScreen so the user can't press "back"
      // and return to the onboarding screen.
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // This is the main swiping area for the pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _onboardingData.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(
                        data: _onboardingData[index], theme: theme);
                  },
                ),
              ),

              // --- Dot Indicators ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => _buildDot(index: index, theme: theme),
                ),
              ),
              const SizedBox(height: 50),

              // --- Action Button ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to build a single dot indicator
  Widget _buildDot({required int index, required ThemeData theme}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? theme.colorScheme.primary : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  /// Helper to build the content of a single onboarding page
  Widget _buildOnboardingPage(
      {required Map<String, dynamic> data, required ThemeData theme}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(data['icon'], size: 120, color: theme.colorScheme.primary),
        const SizedBox(height: 40),
        Text(
          data['title'],
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          data['description'],
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
