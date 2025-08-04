// lib/extension.dart

// Packages
export 'package:flutter/material.dart';
export 'package:google_generative_ai/google_generative_ai.dart';
export 'package:hive/hive.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:provider/provider.dart';
export 'package:shared_preferences/shared_preferences.dart';

// Models
export 'models/ai_analysis.dart';
export 'models/journal_entry.dart';
export 'models/user_profile.dart';
export 'screens/auth_screen.dart';
export 'screens/dashboard_screen.dart';
// Screens
export 'screens/entry_detail_screen.dart';
export 'screens/entry_editor_screen.dart';
export 'screens/home_screen.dart';
export "screens/onboarding_screen.dart";
export 'screens/search_screen.dart';
export 'screens/settings_screen.dart';
// Secrets (optional, but can be convenient)
export 'secrets.dart';
// Services
export 'services/ai_service.dart';
export 'services/lock_service.dart';
export 'services/security_service.dart';
export 'services/theme_provider.dart';
