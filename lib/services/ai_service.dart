// lib/services/ai_service.dart

import 'dart:convert'; // Needed to decode the AI's JSON response

import 'package:mindmeld_ai/extentions.dart';

class AIService {
  // Setup our connection to the Gemini AI model
  final GenerativeModel _model =
      GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: geminiApiKey);

  // This function takes a user's text and returns an AIAnalysis object.
  // It's a `Future` because it has to wait for the internet.
// In lib/services/ai_service.dart

  Future<AIAnalysis?> analyzeEntry(String text) async {
    print("➡️ AI Service: Starting analysis...");
    // The prompt remains the same
    // In lib/services/ai_service.dart

    const prompt = '''
Analyze the following journal entry. Provide your analysis ONLY as a valid JSON object.
Do not include any other text, just the JSON.
The JSON object must have four keys:
1. "sentiment": A single word (e.g., "Positive", "Negative", "Neutral", "Reflective").
2. "themes": A JSON array of 1 to 3 strings (e.g., ["Work", "Personal Growth"]).
3. "summary": A one-sentence summary of the entry.
4. "advice": A short, compassionate, and actionable tip or piece of advice (2-3 sentences) based on the entry, aimed at improving the user's well-being.

Here is the journal entry:
---
''';

    try {
      final content = [Content.text(prompt + text)];
      print("➡️ AI Service: Sending prompt to Gemini API...");
      final response = await _model.generateContent(content);
      print("✅ AI Service: Received RAW response: ${response.text}");

      // --- START: THE NEW, ROBUST FIX ---
      final rawResponseText = response.text ?? '';

      // Use a Regular Expression to find the JSON block.
      final jsonMatch =
          RegExp(r'\{.*\}', dotAll: true).firstMatch(rawResponseText);

      if (jsonMatch == null) {
        print(
            "🔴🔴🔴 AI SERVICE FAILED: Could not find a valid JSON object in the response.");
        return null;
      }

      final cleanedJsonString = jsonMatch.group(0)!;
      final jsonResponse =
          jsonDecode(cleanedJsonString) as Map<String, dynamic>;
      // --- END: THE NEW, ROBUST FIX ---

      print("✅ AI Service: Successfully parsed JSON.");

      // In lib/services/ai_service.dart -> analyzeEntry() -> try block

// ... after parsing jsonResponse

      return AIAnalysis(
        sentiment: jsonResponse['sentiment'] ?? 'Unknown',
        themes: List<String>.from(jsonResponse['themes'] ?? []),
        summary: jsonResponse['summary'] ?? 'No summary available.',
        // --- ADD THIS LINE ---
        advice: jsonResponse['advice'] ?? 'No advice available.',
      );
    } catch (e) {
      print("🔴🔴🔴 AI SERVICE FAILED: $e");
      return null;
    }
  }
}
