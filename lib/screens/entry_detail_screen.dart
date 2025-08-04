// lib/screens/entry_detail_screen.dart

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mindmeld_ai/extentions.dart';

class EntryDetailScreen extends StatelessWidget {
  final JournalEntry entry;
  const EntryDetailScreen({super.key, required this.entry});

  // --- LOGIC METHODS ---

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Entry?'),
          content: const Text('This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                entry.delete();
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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

  // --- UI BUILDER METHOD ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd MMMM yyyy').format(entry.date)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(20, 0, 20, 120), // Added bottom padding
        children: [
          // --- Entry Title & Body ---
          Text(
            entry.title,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            entry.body,
            style:
                theme.textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),

          // --- Media Section (Images Only) ---
          if (entry.imagePaths != null && entry.imagePaths!.isNotEmpty)
            _buildImageGallery(entry.imagePaths!, theme),

          // --- AI Analysis Section ---
          if (entry.analysis != null) ...[
            const Divider(height: 40, thickness: 0.2),
            _buildSectionHeader("AI Analysis", theme),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.psychology_outlined, 'Sentiment',
                entry.analysis!.sentiment, theme),
            _buildInfoRow(Icons.summarize_outlined, 'Summary',
                entry.analysis!.summary, theme),
            if (entry.analysis?.advice != null &&
                entry.analysis!.advice!.isNotEmpty)
              _buildInfoRow(Icons.lightbulb_outline, 'Helpful Tip',
                  entry.analysis!.advice!, theme),
            if (entry.analysis!.themes.isNotEmpty)
              _buildThemesSection(entry.analysis!.themes, theme),
          ],
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Material(
                color: Colors.grey.shade800,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  tooltip: 'Delete Entry',
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirmation(context),
                ),
              ),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              tooltip: 'Edit Entry',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EntryEditorScreen(entryToEdit: entry),
                ));
              },
              child: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildImageGallery(List<String> imagePaths, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("Photos", theme),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(imagePaths[index]),
                      fit: BoxFit.cover, width: 200, height: 200),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(title,
        style:
            theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildInfoRow(
      IconData icon, String title, String content, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(content,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesSection(List<String> themes, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_offer_outlined, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Key Themes',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: themes
                      .map((themeStr) => Chip(
                            label: Text(themeStr),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
