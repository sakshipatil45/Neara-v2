import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/core/ai/gemini_service.dart';

void main() {
  test('Verify Multilingual AI Logic', () async {
    // Manually load .env content
    final envFile = File('.env');
    if (!envFile.existsSync()) {
      print('Warning: .env file not found at ${envFile.absolute.path}');
      // Try jumping up directories if needed, or just let it fail/warn
      // For now, assume running from app/ or project root
    } else {
      final envContent = await envFile.readAsString();
      dotenv.testLoad(fileInput: envContent);
      print('Environment loaded via testLoad.');
    }

    if (dotenv.env['OPENROUTER_API_KEY'] == null ||
        dotenv.env['OPENROUTER_API_KEY']!.isEmpty) {
      print('Warning: OPENROUTER_API_KEY not found in .env');
      return;
    }

    final service = GeminiService();

    print('\n--- Testing Voice Interpretation Layer ---');
    await testVoiceInterpretation(service, "माझा पंखा चालत नाही");
    await Future.delayed(const Duration(seconds: 20));
    await testVoiceInterpretation(service, "mera tyre puncture ho gaya");
    await Future.delayed(const Duration(seconds: 20));
    await testVoiceInterpretation(service, "bike start nahi ho rahi");
    await Future.delayed(const Duration(seconds: 20));
    await testVoiceInterpretation(
      service,
      "There is a fire in the kitchen! Help!",
    );
  }, timeout: const Timeout(Duration(minutes: 5)));
}

Future<void> testRequest(
  GeminiService service,
  String transcript,
  String lang,
) async {
  try {
    print('Input: "$transcript" (Selected: $lang)');
    final response = await service.processUserRequest(
      transcript: transcript,
      selectedLanguage: lang,
    );

    print('Detected Language: ${response.detectedLanguage}');
    print('Selected Language: ${response.selectedLanguage}');
    print('Service Type: ${response.serviceType}');
    print('Normalized: ${response.normalizedRequest}');
    print('Response: ${response.responseText}');
    print('Confidence: ${response.confidence}');
    print('Needs Clarification: ${response.needsClarification}');
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> testVoiceInterpretation(
  GeminiService service,
  String transcript,
) async {
  int retries = 0;
  while (retries < 3) {
    try {
      print('\nInput: "$transcript"');
      final response = await service.interpretVoiceCommand(transcript);

      print('Detected Language: ${response.detectedLanguage}');
      print('Service Type: ${response.serviceType}');
      print('Normalized Intent: ${response.normalizedIntent}');
      print('Urgency Level: ${response.urgencyLevel}');
      print('Confidence: ${response.confidence}');
      return; // Success
    } catch (e) {
      print('Error: $e');
      if (e.toString().contains('quota') || e.toString().contains('429')) {
        print('Quota exceeded, waiting 30s before retry ${retries + 1}...');
        await Future.delayed(const Duration(seconds: 30));
        retries++;
      } else {
        break; // Other error
      }
    }
  }
  print('Failed after retries.');
}
