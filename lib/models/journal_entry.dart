// lib/models/journal_entry.dart
import 'package:mindmeld_ai/extentions.dart';

part 'journal_entry.g.dart'; // We will need to regenerate this

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String body;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  AIAnalysis? analysis;
  @HiveField(5)
  List<String>? imagePaths;

  // The audioPath field at HiveField(6) has been removed.

  JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.analysis,
    this.imagePaths,
    // audioPath has been removed from the constructor.
  });
}