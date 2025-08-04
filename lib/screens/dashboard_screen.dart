// lib/screens/dashboard_screen.dart

import 'package:collection/collection.dart'; // Add 'package:collection/collection.dart'
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mindmeld_ai/extentions.dart';

enum ChartPeriod { week, month, all }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<JournalEntry> _allEntries =
      Hive.box<JournalEntry>('journal_entries').values.toList();
  List<FlSpot> _moodDataPoints = [];
  List<JournalEntry> _chartEntries = [];

  ChartPeriod _selectedPeriod = ChartPeriod.month;

  @override
  void initState() {
    super.initState();
    _allEntries.sort((a, b) => a.date.compareTo(b.date));
    _filterEntriesForChart();
  }

  // _getSentimentScore and other logic methods remain unchanged...
  // ... Paste your existing _getSentimentScore, _filterEntriesForChart, and _processEntriesToSpots methods here ...
  double _getSentimentScore(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return 1.0;
      case 'neutral':
        return 0.0;
      case 'reflective':
        return 0.5;
      case 'negative':
        return -1.0;
      default:
        return 0.0;
    }
  }

  void _filterEntriesForChart() {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case ChartPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case ChartPeriod.month:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case ChartPeriod.all:
        _chartEntries = _allEntries.where((e) => e.analysis != null).toList();
        _processEntriesToSpots();
        return;
    }

    _chartEntries = _allEntries
        .where((e) => e.analysis != null && !e.date.isBefore(startDate))
        .toList();

    _processEntriesToSpots();
  }

  void _processEntriesToSpots() {
    if (_chartEntries.length < 2) {
      setState(() => _moodDataPoints = []);
      return;
    }

    final firstDate = _chartEntries.first.date;
    List<FlSpot> spots = [];
    for (var entry in _chartEntries) {
      final x = entry.date.difference(firstDate).inDays.toDouble();
      final y = _getSentimentScore(entry.analysis!.sentiment);
      spots.add(FlSpot(x, y));
    }

    setState(() {
      _moodDataPoints = spots;
    });
  }

  // --- NEW: Interpretation Logic ---
  String _interpretMoodTrend() {
    if (_moodDataPoints.length < 2) {
      return "Keep journaling to see your mood trends over time.";
    }

    final startValue = _moodDataPoints.first.y;
    final endValue = _moodDataPoints.last.y;

    if (endValue > startValue + 0.5) {
      return "It looks like your mood has been trending upwards recently. That's a great sign!";
    }
    if (endValue < startValue - 0.5) {
      return "Your mood seems to be trending downwards lately. It might be helpful to reflect on what's changed.";
    }
    if ((endValue - startValue).abs() < 0.2 && _moodDataPoints.length > 5) {
      return "Your mood appears to be quite stable and consistent during this period.";
    }
    return "You've had some ups and downs lately, which is a normal part of life's journey.";
  }

  double _calculateAverageMood() {
    if (_chartEntries.isEmpty) return 0;
    final sum =
        _chartEntries.map((e) => _getSentimentScore(e.analysis!.sentiment)).sum;
    return sum / _chartEntries.length;
  }

  Map<String, int> _getThemeCounts() {
    final counts = <String, int>{};
    for (var entry in _chartEntries) {
      for (var theme in entry.analysis!.themes) {
        counts[theme] = (counts[theme] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final averageMood = _calculateAverageMood();

    return Scaffold(
      appBar: AppBar(title: const Text("Your Dashboard")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- Main Chart and Filter Section ---
          Text("Mood Over Time",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildPeriodSelector(),
          const SizedBox(height: 15),
          _moodDataPoints.length < 2
              ? const Center(
                  child: Text("Not enough data for this period.",
                      style: TextStyle(color: Colors.grey)))
              : _buildMoodChart(theme),

          const Divider(height: 40, thickness: 0.2),

          // --- NEW: Statistics Section ---
          _buildSectionHeader("Key Statistics"),
          GridView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5, // Taller cards
            ),
            children: [
              _buildStatCard(Icons.article_outlined, "Entries",
                  _chartEntries.length.toString()),
              _buildStatCard(
                averageMood > 0.3
                    ? Icons.sentiment_very_satisfied
                    : (averageMood < -0.3
                        ? Icons.sentiment_very_dissatisfied
                        : Icons.sentiment_neutral),
                "Avg. Mood",
                averageMood > 0.3
                    ? "Positive"
                    : (averageMood < -0.3 ? "Negative" : "Neutral"),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Insight Summary"),
          _buildInsightCard(_interpretMoodTrend()), // AI Interpretation
        ],
      ),
    );
  }

  // Your existing _buildPeriodSelector and _buildMoodChart methods...
  // ... Paste them here without changes ...

  // --- NEW: Helper widgets for the new UI sections ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

// In lib/screens/dashboard_screen.dart
// In lib/screens/dashboard_screen.dart

  Widget _buildStatCard(IconData icon, String title, String value) {
    // We wrap the entire content in LayoutBuilder to get the available height
    return LayoutBuilder(
      builder: (context, constraints) {
        // constraints.maxHeight gives us the exact height the GridView has allocated for this card.
        // We calculate a dynamic font size based on this height.
        // This is a "magic number" formula: a base size plus a proportion of the available height.
        // It ensures the font scales nicely on different screen sizes.
        final double dynamicFontSize = 20 + (constraints.maxHeight * 0.2);

        return Container(
          padding: const EdgeInsets.all(
              10), // Slightly reduce padding for more content space
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row (Title and Icon)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: MediaQuery.of(context).size.width >= 600
                              ? dynamicFontSize
                              : 10)),
                  Icon(icon, color: Colors.grey, size: 20),
                ],
              ),

              // Bottom Row (The large value)
              // No need for FittedBox anymore because we are controlling the font size directly.
              Text(
                value,
                style: TextStyle(
                  // Use our calculated dynamic font size.
                  fontSize: MediaQuery.of(context).size.width >= 600
                      ? dynamicFontSize - 20
                      : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1, // Crucial to prevent wrapping
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3))),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)))),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedButton<ChartPeriod>(
      segments: const <ButtonSegment<ChartPeriod>>[
        ButtonSegment(
            value: ChartPeriod.week,
            label: Text('7D'),
            icon: Icon(Icons.calendar_view_week)),
        ButtonSegment(
            value: ChartPeriod.month,
            label: Text('30D'),
            icon: Icon(Icons.calendar_view_month)),
        ButtonSegment(
            value: ChartPeriod.all,
            label: Text('All'),
            icon: Icon(Icons.inventory_2_outlined)),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<ChartPeriod> newSelection) {
        setState(() {
          _selectedPeriod = newSelection.first;
          _filterEntriesForChart(); // Re-run the data processing
        });
      },
      style: SegmentedButton.styleFrom(
        foregroundColor: Colors.grey,
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: Theme.of(context).colorScheme.primary,
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }

  /// The new and improved chart widget with tooltips and better visuals.
  Widget _buildMoodChart(ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          // --- NEW: Tooltip Customization ---
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => Colors.black.withOpacity(0.8),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  // Find the corresponding journal entry for the tapped spot
                  final entryIndex = _chartEntries.indexWhere((entry) =>
                      entry.date
                          .difference(_chartEntries.first.date)
                          .inDays
                          .toDouble() ==
                      spot.x);

                  if (entryIndex == -1) return null;

                  final entry = _chartEntries[entryIndex];
                  final dateStr = DateFormat('dd MMM yyyy').format(entry.date);
                  final sentimentStr = entry.analysis!.sentiment;

                  return LineTooltipItem(
                    '$dateStr\n',
                    TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: sentimentStr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),

          // --- Enhanced Line and Grid Styling ---
          lineBarsData: [
            LineChartBarData(
              spots: _moodDataPoints,
              isCurved: true,
              color: primaryColor,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              // Show dots on each data point
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.4),
                    primaryColor.withOpacity(0.0)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],

          gridData: const FlGridData(show: false),
          // A cleaner look without the grid
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(
                    showTitles:
                        false)), // Simplified: Y-axis is self-explanatory
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(
                sideTitles: SideTitles(
                    showTitles: false)), // Simplified: Tooltips show dates now
          ),

          minY: -1.2,
          // Give a little extra space on the Y-axis
          maxY: 1.2,
        ),
      ),
    );
  }
}
