// lib/screens/home_screen.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mindmeld_ai/extentions.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// CORRECT: Added WidgetsBindingObserver to the state class
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // CORRECT: Register this class as a lifecycle observer.
    WidgetsBinding.instance.addObserver(this);
    // CORRECT: Listen for authentication requests from our LockService.
    LockService.instance.requiresAuth.addListener(_handleAuthRequest);
  }

  @override
  void dispose() {
    // CORRECT: It's crucial to remove observers and listeners to prevent memory leaks.
    WidgetsBinding.instance.removeObserver(this);
    LockService.instance.requiresAuth.removeListener(_handleAuthRequest);
    super.dispose();
  }

  // CORRECT: This new method handles showing the lock screen.
  void _handleAuthRequest() {
    if (LockService.instance.requiresAuth.value && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const AuthScreen(isPushedAsOverlay: true)),
      );
      LockService.instance.requiresAuth.value = false;
    }
  }

  // CORRECT: This method from WidgetsBindingObserver correctly delegates to our service.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (kDebugMode) print("App Lifecycle State Changed to: $state");
    switch (state) {
      case AppLifecycleState.resumed:
        LockService.instance.onResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        LockService.instance.onPaused();
        break;
    }
  }

  final List<Map<String, dynamic>> _navDestinations = [
    {
      'icon': Icons.home_filled,
      'label': 'Home',
      'screen': const SizedBox.shrink()
    },
    {
      'icon': Icons.search_outlined,
      'label': 'Search',
      'screen': const SearchScreen()
    },
    {
      'icon': Icons.bar_chart_outlined,
      'label': 'Dashboard',
      'screen': const DashboardScreen()
    },
    {
      'icon': Icons.person_outline,
      'label': 'Profile',
      'screen': const SettingsScreen()
    },
  ];

  void _onDestinationSelected(int index) {
    if (index == 0) {
      setState(() => _selectedIndex = 0);
      return;
    }
    Navigator.of(context)
        .push(
      MaterialPageRoute(
          builder: (context) => _navDestinations[index]['screen'] as Widget),
    )
        .then((_) {
      setState(() => _selectedIndex = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useSideNav = constraints.maxWidth >= 600;
        return Scaffold(
          body: Row(
            children: [
              if (useSideNav) _buildSideNavigationBar(),
              Expanded(
                child: SafeArea(
                  left: !useSideNav,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ListView(
                      children: [
                        const SizedBox(height: 16),
                        // MODIFIED: Removed the boolean parameter which was not needed.
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildCalendar(),
                        const SizedBox(height: 20),
                        const Text("Daily Journal",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildJournalList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: useSideNav ? null : _buildBottomAppBar(),
          floatingActionButton:
              useSideNav ? null : _buildFloatingActionButton(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildSideNavigationBar() {
    return SafeArea(
      right: false,
      child: Container(
        width: 88,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildFloatingActionButton(),
            ),
            const SizedBox(height: 24),
            _buildRailDestinationItem(index: 0),
            _buildRailDestinationItem(index: 1),
            _buildRailDestinationItem(index: 2),
            const Expanded(child: SizedBox()),
            _buildRailDestinationItem(index: 3),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRailDestinationItem({required int index}) {
    final dest = _navDestinations[index];
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _onDestinationSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(dest['icon'],
                color: isSelected ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(height: 4),
            Text(
              dest['label'],
              style: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : Colors.grey,
                  fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // MODIFIED: Removed duplicated search button and fixed logic
  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: const Color(0xFF2C2C2E),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavIcon(index: 0),
          _buildNavIcon(index: 1), // Search
          const SizedBox(width: 40),
          _buildNavIcon(index: 2), // Dashboard
          _buildNavIcon(index: 3), // Profile
        ],
      ),
    );
  }

  Widget _buildNavIcon({required int index}) {
    return IconButton(
      tooltip: _navDestinations[index]['label'],
      icon: Icon(_navDestinations[index]['icon']),
      color: _selectedIndex == index
          ? Theme.of(context).colorScheme.primary
          : Colors.grey,
      onPressed: () => _onDestinationSelected(index),
    );
  }

  // CORRECT: Complete and correct implementation of _buildJournalList
  Widget _buildJournalList() {
    return ValueListenableBuilder<Box<JournalEntry>>(
      valueListenable: Hive.box<JournalEntry>('journal_entries').listenable(),
      builder: (context, box, _) {
        final entries = box.values
            .where((entry) => isSameDay(entry.date, _selectedDay))
            .toList();
        if (entries.isEmpty) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: Text("No entries for this day.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => EntryDetailScreen(entry: entry))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(entry.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (entry.analysis != null)
                            Icon(_getSentimentIcon(entry.analysis!.sentiment),
                                color: Theme.of(context).colorScheme.primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Last Update: ${DateFormat.jm().format(entry.date)}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EntryEditorScreen())),
      tooltip: 'New Entry',
      child: const Icon(Icons.add),
    );
  }

  IconData _getSentimentIcon(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return Icons.sentiment_very_satisfied;
      case 'negative':
        return Icons.sentiment_very_dissatisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'reflective':
        return Icons.psychology;
      default:
        return Icons.insights;
    }
  }

  // MODIFIED: Corrected and cleaned up the _buildHeader method.
  Widget _buildHeader() {
    return ValueListenableBuilder<Box<UserProfile>>(
      valueListenable: Hive.box<UserProfile>('user_profile').listenable(),
      builder: (context, box, _) {
        final userProfile =
            box.get(UserProfile.singletonKey) ?? UserProfile(name: 'Welcome');
        final name = userProfile.name.split(' ').first;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormat('MMMM yyyy').format(_focusedDay),
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text("Hi $name, What are\nyou thinking? ✏️",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () =>
                  _onDestinationSelected(3), // Tap avatar to go to Profile
              child: CircleAvatar(
                radius: 25,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                backgroundImage: userProfile.imagePath != null
                    ? FileImage(File(userProfile.imagePath!))
                    : null,
                child: userProfile.imagePath == null
                    ? Icon(Icons.person,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendar() {
    final theme = Theme.of(context);
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.week,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
      },
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronVisible: false,
        rightChevronVisible: false,
        headerPadding: EdgeInsets.zero,
        titleTextStyle: TextStyle(fontSize: 0),
      ),
      calendarStyle: CalendarStyle(
        defaultDecoration: BoxDecoration(
            shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8)),
        weekendDecoration: BoxDecoration(
            shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8)),
        selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8)),
        todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.5),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8)),
        outsideDecoration: BoxDecoration(
            shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(8)),
        defaultTextStyle: const TextStyle(color: Colors.white70),
        weekendTextStyle: const TextStyle(color: Colors.white),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.grey),
        weekendStyle: TextStyle(color: Colors.grey),
      ),
    );
  }
}
