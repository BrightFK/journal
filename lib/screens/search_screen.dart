// lib/screens/search_screen.dart
import 'package:intl/intl.dart';
import 'package:mindmeld_ai/extentions.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // --- STATE VARIABLES (Logic is unchanged from before) ---
  final _searchController = TextEditingController();
  final List<JournalEntry> _allEntries =
      Hive.box<JournalEntry>('journal_entries').values.toList();
  List<JournalEntry> _filteredEntries = [];

  String? _selectedSentiment;
  Set<String> _selectedThemes = {};
  DateTimeRange? _selectedDateRange;

  final Set<String> _availableThemes = {};

  @override
  void initState() {
    super.initState();
    _filteredEntries = _allEntries;
    _searchController.addListener(_runFilter);

    for (var entry in _allEntries) {
      if (entry.analysis?.themes != null) {
        _availableThemes.addAll(entry.analysis!.themes);
      }
    }
    // Sort themes alphabetically for a predictable UI
    _availableThemes.toList().sort();
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _runFilter() {
    // This entire search logic function is IDENTICAL to the previous version.
    // ... no changes needed here ...
    List<JournalEntry> results = List.from(_allEntries);
    final searchText = _searchController.text.toLowerCase();

    if (searchText.isNotEmpty) {
      results = results.where((entry) {
        final titleMatch = entry.title.toLowerCase().contains(searchText);
        final bodyMatch = entry.body.toLowerCase().contains(searchText);
        final adviceMatch =
            entry.analysis?.advice?.toLowerCase().contains(searchText) ?? false;
        return titleMatch || bodyMatch || adviceMatch;
      }).toList();
    }

    if (_selectedSentiment != null) {
      results = results
          .where((entry) => entry.analysis?.sentiment == _selectedSentiment)
          .toList();
    }

    if (_selectedThemes.isNotEmpty) {
      results = results.where((entry) {
        final entryThemes = entry.analysis?.themes.toSet() ?? {};
        return _selectedThemes.every((theme) => entryThemes.contains(theme));
      }).toList();
    }

    if (_selectedDateRange != null) {
      results = results.where((entry) {
        final isAfterStart = !entry.date.isBefore(_selectedDateRange!.start);
        final isBeforeEnd = !entry.date
            .isAfter(_selectedDateRange!.end.add(const Duration(days: 1)));
        return isAfterStart && isBeforeEnd;
      }).toList();
    }

    setState(() {
      _filteredEntries = results;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedSentiment = null;
      _selectedThemes.clear();
      _selectedDateRange = null;
    });
  }

  // --- UI-Specific Functions ---

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        // Theme the date picker to match our app
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF007AFF), // The selected day color
              onPrimary: Colors.white,
              surface: Color(0xFF1C1C1E), // The background
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2C2C2E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _runFilter();
    }
  }
// In lib/screens/search_screen.dart

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search & Filter"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: Text("Clear All", style: TextStyle(color: primaryBlue)),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        // --- THE FIX: We use a ListView as the root scrollable element ---
        // We no longer need a Column and Expanded widgets.
        child: ListView(
          padding: const EdgeInsets.only(
              bottom:
                  40), // Add padding to avoid the last item being too close to the edge
          children: [
            // --- Item 1: The Search Bar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search keyword...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // --- Item 2, 3, 4: Filter Sections ---
            _buildSectionHeader("Filter by Date"),
            _buildDateFilterRow(primaryBlue),
            const SizedBox(height: 16),

            _buildSectionHeader("Filter by Mood"),
            _buildFilterRow(
              ["Positive", "Negative", "Neutral", "Reflective"]
                  .map((mood) => _buildChoiceChip(
                          mood, _selectedSentiment == mood, (selected) {
                        setState(
                            () => _selectedSentiment = selected ? mood : null);
                        _runFilter();
                      }))
                  .toList(),
            ),
            const SizedBox(height: 16),

            _buildSectionHeader("Filter by Themes"),
            _buildFilterRow(
              _availableThemes
                  .map((theme) => _buildChoiceChip(
                          theme, _selectedThemes.contains(theme), (selected) {
                        setState(() => selected
                            ? _selectedThemes.add(theme)
                            : _selectedThemes.remove(theme));
                        _runFilter();
                      }))
                  .toList(),
            ),

            // --- Item 5: Divider and Results Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  const Expanded(child: Divider(thickness: 0.2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text("RESULTS",
                        style:
                            TextStyle(color: Colors.grey, letterSpacing: 1.2)),
                  ),
                  const Expanded(child: Divider(thickness: 0.2)),
                ],
              ),
            ),

            // --- Item 6: The Results List ---
            // This ternary operator checks if the list is empty and shows a message
            // if it is. If not, it displays the results.
            _filteredEntries.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text("No entries found.",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  )
                // Use a Column for the list items inside the parent ListView
                // ShrinkWrap and NeverScrollableScrollPhysics are CRUCIAL here to
                // allow a ListView inside a ListView.
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _filteredEntries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(entry.title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat.yMMMd().format(entry.date),
                              style: const TextStyle(color: Colors.grey)),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EntryDetailScreen(entry: entry))),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS FOR A CLEANER UI ---

  /// A styled horizontal scrolling list for filter chips.
  Widget _buildFilterRow(List<Widget> chips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
          children: chips
              .map((c) =>
                  Padding(padding: const EdgeInsets.only(right: 8), child: c))
              .toList()),
    );
  }

  /// The header for each filter section.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white.withOpacity(0.8))),
    );
  }

  /// The styled choice chip used for both Mood and Themes.
  Widget _buildChoiceChip(
      String label, bool isSelected, Function(bool) onSelected) {
    const primaryBlue = Color(0xFF007AFF);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
      selectedColor: primaryBlue,
      backgroundColor: Colors.white.withOpacity(0.1),
      showCheckmark: false,
      shape: StadiumBorder(
          side: isSelected
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade700, width: 0.5)),
    );
  }

  /// A special row widget for displaying and triggering the date picker.
  Widget _buildDateFilterRow(Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ActionChip(
        avatar: Icon(Icons.calendar_today, color: primaryBlue, size: 18),
        label: Text(
          _selectedDateRange == null
              ? 'Select Date Range'
              : '${DateFormat.yMMMd().format(_selectedDateRange!.start)} - ${DateFormat.yMMMd().format(_selectedDateRange!.end)}',
          style: TextStyle(color: primaryBlue),
        ),
        onPressed: _selectDateRange,
        backgroundColor: primaryBlue.withOpacity(0.2),
        shape: StadiumBorder(
            side: BorderSide(color: primaryBlue.withOpacity(0.5))),
      ),
    );
  }
}
