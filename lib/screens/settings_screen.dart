// lib/screens/settings_screen.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindmeld_ai/extentions.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // In lib/screens/settings_screen.dart, inside the _SettingsScreenState class

  /// A debug-only function to add sample entries for testing the dashboard.
  Future<void> _addSampleEntries() async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final aiService = AIService();
    final journalBox = Hive.box<JournalEntry>('journal_entries');

    final sampleData = [
      {
        'date': DateTime.now().subtract(const Duration(days: 4)), // Monday
        'title': 'Overwhelmed at Work',
        'body':
            'Kicked off the week feeling completely overwhelmed. I have three major deadlines approaching. It feels impossible to catch up and the stress is building.'
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 3)), // Tuesday
        'title': 'A Small Win',
        'body':
            'Today was still stressful, but I managed to finish one of the smaller reports and get some positive feedback. It didn\'t solve the bigger problem, but it felt good.'
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 2)), // Wednesday
        'title': 'Just a Regular Day',
        'body':
            'Nothing special happened today. I spent most of the day in meetings. I wasn\'t particularly happy or sad, just present. Watched a bit of TV.'
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 1)), // Thursday
        'title': 'Light at the End of the Tunnel',
        'body':
            'Had a really productive session this morning and made a huge breakthrough on the main project! My mood has improved dramatically. Feeling very optimistic.'
      },
      {
        'date': DateTime.now(), // Friday
        'title': 'Finished!',
        'body':
            'I did it! Submitted the final project this afternoon. The sense of relief is incredible. The whole team celebrated. Heading into the weekend feeling on top of the world.'
      },
    ];

    for (var data in sampleData) {
      final entryTextForAI = "${data['title']}\n\n${data['body']}";
      // Get AI analysis for each entry
      final analysis = await aiService.analyzeEntry(entryTextForAI);

      final newEntry = JournalEntry(
        id: data['date'].toString(),
        title: data['title'] as String,
        body: data['body'] as String,
        date: data['date'] as DateTime,
        analysis: analysis,
      );
      // Use put instead of add to avoid duplicate entries on repeated taps
      await journalBox.put(newEntry.id, newEntry);
    }

    // Hide loading dialog
    if (mounted) Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("5 sample entries added!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  final _profileBox = Hive.box<UserProfile>('user_profile');
  late UserProfile _userProfile;
  late TextEditingController _nameController;

  final ValueNotifier<bool> _isSecurityEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // Get the user profile, or create a default one if it doesn't exist.
    _userProfile =
        _profileBox.get(UserProfile.singletonKey) ?? UserProfile(name: 'User');
    _nameController = TextEditingController(text: _userProfile.name);
    _loadSecuritySetting();
  }

  void _loadSecuritySetting() async {
    _isSecurityEnabled.value = await SecurityService.isSecurityEnabled();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _userProfile.imagePath = pickedFile.path;
      });
    }
  }

  void _saveProfile() {
    _userProfile.name = _nameController.text;
    _profileBox.put(UserProfile.singletonKey, _userProfile);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Profile Saved!"), backgroundColor: Colors.green));
    // Optionally pop, or let the user stay on the screen.
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final List<Color> themeColors = [
      const Color(0xFF007AFF), // Professional Blue (Default)
      const Color(0xFFF97233), // Original Orange
      const Color(0xFF34C759), // Green
      const Color(0xFFAF52DE), // Purple
      const Color(0xFFFF9500), // Gold
      const Color(0xFF5AC8FA), // Light Blue
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveProfile,
            tooltip: "Save Profile",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Profile Picture Section ---
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.2),
                      backgroundImage: _userProfile.imagePath != null
                          ? FileImage(File(_userProfile.imagePath!))
                          : null,
                      child: _userProfile.imagePath == null
                          ? Icon(Icons.person,
                              size: 60, color: theme.colorScheme.primary)
                          : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.edit, size: 20, color: Colors.white),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            // --- Name Editor Section ---
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),

            const SizedBox(height: 32),

            // --- START: NEW THEME SELECTOR UI ---
            const Divider(height: 40, thickness: 0.2),
            Text(
              "App Accent Color",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: themeColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    // Get the provider (listen: false) and call the update method.
                    context.read<ThemeProvider>().updateTheme(color);
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: color,
                    // Show a checkmark on the currently selected color.
                    child: themeProvider.primaryColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 40, thickness: 0.2),
            // --- NEW: Security Settings UI ---
            ValueListenableBuilder<bool>(
              valueListenable: _isSecurityEnabled,
              builder: (context, isEnabled, child) {
                return ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text("App Lock"),
                  subtitle: Text(isEnabled ? "Enabled" : "Disabled"),
                  trailing: Switch(
                    value: isEnabled,
                    onChanged: (newValue) async {
                      await SecurityService.setSecurity(newValue);
                      _isSecurityEnabled.value = newValue;
                    },
                  ),
                );
              },
            ),

            // Can add more settings here in the future

            const Divider(height: 40, thickness: 0.2),
            // ... your existing App Accent Color section ...

            // --- START: NEW DEBUG-ONLY SECTION ---
            // Import 'package:flutter/foundation.dart'; to use kDebugMode
            if (kDebugMode) ...[
              const Divider(height: 40, thickness: 0.2),
              Text(
                "Developer Tools",
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.note_add_outlined),
                label: const Text("Add 5 Sample Entries"),
                onPressed: _addSampleEntries,
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber,
                    side: const BorderSide(color: Colors.amber),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12)),
              ),
              const SizedBox(height: 8),
              const Text(
                "Use this to test the dashboard chart.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            ],
          ],
        ),
      ),
    );
  }
}
