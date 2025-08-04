// lib/models/ai_analysis.dart
import 'package:mindmeld_ai/extentions.dart'; // Corrected file name

part 'ai_analysis.g.dart';

@HiveType(typeId: 1)
class AIAnalysis extends HiveObject {
  @HiveField(0)
  String sentiment;

  @HiveField(1)
  List<String> themes;

  @HiveField(2)
  String summary;

  // --- ADD THIS NEW FIELD ---
  @HiveField(3)
  String advice;

  AIAnalysis({
    required this.sentiment,
    required this.themes,
    required this.summary,
    required this.advice, // Add to constructor
  });
}
