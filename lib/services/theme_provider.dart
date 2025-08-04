// lib/services/theme_provider.dart
import 'package:mindmeld_ai/extentions.dart';

// The default color if none is saved.
const Color defaultPrimaryColor = Color(0xFF007AFF);

/// Handles saving and loading the theme color from the Hive database.
class ThemeService {
  static const _boxName = 'theme_box';
  static const _key = 'primary_color';

  // Save the color as an integer
  Future<void> saveTheme(Color color) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, color.value);
  }

  // Load the color as an integer and convert it back to a Color object
  Future<Color> loadTheme() async {
    final box = await Hive.openBox(_boxName);
    final colorValue = box.get(_key) as int?;
    if (colorValue == null) return defaultPrimaryColor;
    return Color(colorValue);
  }
}


/// Manages the theme state for the entire application using ChangeNotifier.
class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  late Color _primaryColor;

  ThemeProvider() {
    _primaryColor = defaultPrimaryColor;
    // Load the saved theme when the provider is created.
    _loadTheme();
  }

  // Getter to allow other parts of the app to read the current color.
  Color get primaryColor => _primaryColor;

  void _loadTheme() async {
    _primaryColor = await _themeService.loadTheme();
    // Notify widgets that the theme has been loaded from storage.
    notifyListeners();
  }

  /// Updates the application's primary color and saves it to storage.
  void updateTheme(Color newColor) {
    if (_primaryColor == newColor) return; // No need to update if it's the same color

    _primaryColor = newColor;
    _themeService.saveTheme(newColor);
    // This is the magic line that tells all listening widgets to rebuild.
    notifyListeners();
  }
}