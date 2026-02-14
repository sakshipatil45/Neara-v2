import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Get Gemini API key from environment variables
String get kGeminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

enum EmergencyUrgency { low, medium, high, critical }

enum ServiceCategory {
  mechanic,
  plumber,
  electrician,
  maid,
  roadsideAssistance, // New category
  other,
}

class EmergencyInterpretation {
  final String issueSummary;
  final EmergencyUrgency urgency;
  final String locationHint;
  final ServiceCategory serviceCategory;
  final String reason;
  final double confidence;
  final List<String> riskFactors;
  final bool needsClarification;

  EmergencyInterpretation({
    required this.issueSummary,
    required this.urgency,
    required this.locationHint,
    required this.serviceCategory,
    required this.reason,
    required this.confidence,
    this.riskFactors = const [],
    this.needsClarification = false,
  });
}

class SearchFilters {
  final ServiceCategory? serviceCategory;
  final List<ServiceCategory> categories; // optional multi-select
  final double radiusKm;
  final double minRating;
  final bool verifiedOnly;
  final String genderPreference; // any / female / male

  const SearchFilters({
    this.serviceCategory,
    this.categories = const [],
    this.radiusKm = 50,
    this.minRating = 3.5,
    this.verifiedOnly = false,
    this.genderPreference = 'any',
  });

  SearchFilters copyWith({
    ServiceCategory? serviceCategory,
    List<ServiceCategory>? categories,
    double? radiusKm,
    double? minRating,
    bool? verifiedOnly,
    String? genderPreference,
  }) {
    return SearchFilters(
      serviceCategory: serviceCategory ?? this.serviceCategory,
      categories: categories ?? this.categories,
      radiusKm: radiusKm ?? this.radiusKm,
      minRating: minRating ?? this.minRating,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      genderPreference: genderPreference ?? this.genderPreference,
    );
  }
}

class MultilingualResponse {
  final String detectedLanguage;
  final String selectedLanguage;
  final String normalizedRequest;
  final String responseText;
  final double confidence;
  final bool needsClarification;

  MultilingualResponse({
    required this.detectedLanguage,
    required this.selectedLanguage,
    required this.normalizedRequest,
    required this.responseText,
    required this.confidence,
    required this.needsClarification,
  });

  factory MultilingualResponse.fromJson(Map<String, dynamic> json) {
    return MultilingualResponse(
      detectedLanguage: json['detected_language'] as String? ?? 'en',
      selectedLanguage: json['selected_language'] as String? ?? 'en',
      normalizedRequest: json['normalized_request'] as String? ?? '',
      responseText: json['response_text'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      needsClarification: json['needs_clarification'] as bool? ?? false,
    );
  }
}

class GeminiService {
  GeminiService()
    // Use gemini-2.5-flash which is the latest fast model
    : _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: kGeminiApiKey,
      );

  final GenerativeModel _model;

  /// Lists all available models for debugging
  Future<void> listAvailableModels() async {
    try {
      final response = await _model.generateContent([
        Content.text('List available models'),
      ]);
      print('Available models check: ${response.text}');
    } catch (e) {
      print('Error checking models: $e');
    }
  }

  Future<EmergencyInterpretation> interpretEmergency({
    required String transcript,
    double? lat,
    double? lng,
  }) async {
    final prompt = StringBuffer()
      ..writeln(
        'You are an advanced AI risk assessment assistant for a home services and roadside assistance platform.',
      )
      ..writeln('Your job is to analyze user service requests and determine:')
      ..writeln('1. Service type')
      ..writeln('2. Urgency level')
      ..writeln('3. Risk factors involved')
      ..writeln('4. A confidence score')
      ..writeln('5. Whether clarification is required')
      ..writeln('You must use contextual reasoning, not keyword matching.')
      ..writeln('User speech transcript: "$transcript"')
      ..writeln(
        lat != null && lng != null
            ? 'User GPS coordinates (lat,lng): $lat,$lng. Use these only to refine the locationHint (e.g., nearby area name) and to assess safety ONLY IF the user is stranded or in danger.'
            : 'No GPS coordinates available for this request.',
      )
      ..writeln('While analyzing, consider:')
      ..writeln('A. Environmental Context')
      ..writeln('- Time of day (night increases risk)')
      ..writeln(
        '- Location type (highway, rural, isolated areas increase risk)',
      )
      ..writeln('- Weather conditions if mentioned')
      ..writeln('- Traffic exposure')
      ..writeln('B. Vulnerability Context')
      ..writeln('- User alone')
      ..writeln('- Children or elderly present')
      ..writeln('- Medical condition mentioned')
      ..writeln('C. Hazard Context')
      ..writeln('- Fire risk')
      ..writeln('- Gas leakage')
      ..writeln('- Electrical short circuit')
      ..writeln('- Structural damage')
      ..writeln('- Vehicle immobility in unsafe location')
      ..writeln('D. Severity Context')
      ..writeln('- Immediate threat vs inconvenience')
      ..writeln('- Potential for escalation')
      ..writeln('Urgency must be classified as:')
      ..writeln('CRITICAL:')
      ..writeln('Immediate threat to life or major safety hazard.')
      ..writeln('HIGH:')
      ..writeln(
        'Serious issue with possible safety consequences but not immediately life-threatening.',
      )
      ..writeln('MEDIUM:')
      ..writeln('Repair needed soon but no safety danger.')
      ..writeln('LOW:')
      ..writeln('Routine or non-urgent request.')
      ..writeln(
        'If context is insufficient or ambiguous, reduce confidence score.',
      )
      ..writeln('If uncertainty is high, set "needs_clarification" to true.')
      ..writeln('Respond strictly in JSON:')
      ..writeln('{')
      ..writeln(
        '  "service_type": "Mechanic | Plumber | Electrician | Maid | Roadside Assistance | Other",',
      )
      ..writeln('  "urgency_level": "CRITICAL | HIGH | MEDIUM | LOW",')
      ..writeln('  "issue_summary": "Short 3-5 word title",')
      ..writeln('  "risk_factors": ["risk1", "risk2"],')
      ..writeln('  "reason": "One sentence explanation",')
      ..writeln('  "confidence": 0.0,')
      ..writeln('  "needs_clarification": false')
      ..writeln('}')
      ..writeln('Rules:')
      ..writeln('- Confidence must be between 0.0 and 1.0.')
      ..writeln('- Confidence below 0.6 means ambiguity.')
      ..writeln('- Do not output anything outside JSON.');

    try {
      final response = await _model
          .generateContent([Content.text(prompt.toString())])
          .timeout(const Duration(seconds: 10));
      final text = response.text ?? '{}';
      final map = _safeDecodeJson(text);

      final urgency = switch (map['urgency_level']?.toString().toUpperCase()) {
        'CRITICAL' => EmergencyUrgency.critical,
        'HIGH' => EmergencyUrgency.high,
        'MEDIUM' => EmergencyUrgency.medium,
        'LOW' => EmergencyUrgency.low,
        _ => EmergencyUrgency.medium,
      };

      final serviceStr = map['service_type']?.toString().toLowerCase();
      final service = switch (serviceStr) {
        'mechanic' => ServiceCategory.mechanic,
        'plumber' => ServiceCategory.plumber,
        'electrician' => ServiceCategory.electrician,
        'maid' => ServiceCategory.maid,
        'roadside assistance' => ServiceCategory.roadsideAssistance,
        'roadsideassistance' => ServiceCategory.roadsideAssistance,
        _ => ServiceCategory.other,
      };

      return EmergencyInterpretation(
        issueSummary: map['issue_summary']?.toString() ?? transcript,
        urgency: urgency,
        locationHint: lat != null && lng != null
            ? '$lat, $lng' // Simple fallback since prompt doesn't extract location
            : 'Unknown',
        serviceCategory: service,
        reason: map['reason']?.toString() ?? 'No reason provided',
        confidence: (map['confidence'] is num)
            ? (map['confidence'] as num).toDouble()
            : 0.0,
        riskFactors:
            (map['risk_factors'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        needsClarification: map['needs_clarification'] == true,
      );
    } on TimeoutException {
      // Surface a clear, fast-failing error so the UI can show feedback
      throw Exception('AI response took too long. Please try again.');
    }
  }

  Future<SearchFilters> interpretSearch(String query) async {
    final prompt = StringBuffer()
      ..writeln(
        'You help map natural language to filters for an Indian local worker app.',
      )
      ..writeln('User query: "$query"')
      ..writeln('Respond ONLY as compact JSON with keys:')
      ..writeln(
        '{"serviceCategory": "mechanic"|"plumber"|"electrician"|"maid"|"other"|null,',
      )
      ..writeln(
        ' "radiusKm": number, "minRating": number, "verifiedOnly": boolean,',
      )
      ..writeln(' "genderPreference": "any"|"female"|"male" }');

    try {
      final response = await _model
          .generateContent([Content.text(prompt.toString())])
          .timeout(const Duration(seconds: 8));
      final text = response.text ?? '{}';
      final map = _safeDecodeJson(text);

      ServiceCategory? service;
      switch (map['serviceCategory']) {
        case 'mechanic':
          service = ServiceCategory.mechanic;
          break;
        case 'plumber':
          service = ServiceCategory.plumber;
          break;
        case 'electrician':
          service = ServiceCategory.electrician;
          break;
        case 'maid':
          service = ServiceCategory.maid;
          break;
        case 'roadside assistance':
        case 'roadsideassistance':
          service = ServiceCategory.roadsideAssistance;
          break;
        default:
          service = null;
      }

      return SearchFilters(
        serviceCategory: service,
        radiusKm: (map['radiusKm'] is num)
            ? (map['radiusKm'] as num).toDouble()
            : 5,
        minRating: (map['minRating'] is num)
            ? (map['minRating'] as num).toDouble()
            : 4.0,
        verifiedOnly: map['verifiedOnly'] is bool
            ? map['verifiedOnly'] as bool
            : true,
        genderPreference: map['genderPreference']?.toString() ?? 'any',
      );
    } on TimeoutException {
      // Fall back quickly to current/default filters if AI is slow
      return const SearchFilters();
    }
  }

  Future<MultilingualResponse> processUserRequest({
    required String transcript,
    String selectedLanguage = 'auto',
  }) async {
    final prompt = StringBuffer()
      ..writeln(
        'You are a multilingual AI assistant for a voice-first hyperlocal service platform.',
      )
      ..writeln(
        'Your role is to understand user requests spoken in natural language and respond in the user\'s selected language.',
      )
      ..writeln('Supported Languages:')
      ..writeln('- English (en)')
      ..writeln('- Hindi (hi)')
      ..writeln('- Marathi (mr)')
      ..writeln()
      ..writeln('Core Responsibilities:')
      ..writeln('1. Language Selection Priority')
      ..writeln(
        '- If selected_language is provided ("$selectedLanguage") -> ALWAYS respond in that language.',
      )
      ..writeln('- If selected_language = "auto" -> detect user language.')
      ..writeln('- If detected language is unsupported -> default to English.')
      ..writeln()
      ..writeln('2. Multilingual Understanding')
      ..writeln('You must understand requests even if they contain:')
      ..writeln('- Mixed languages (Hinglish / Manglish / code-mixed)')
      ..writeln('- Spelling errors')
      ..writeln('- Incomplete sentences')
      ..writeln('- Speech-to-text mistakes')
      ..writeln('- Regional pronunciation variations')
      ..writeln()
      ..writeln('3. Normalization')
      ..writeln('Convert user speech into a clean standardized request meaning.')
      ..writeln('Example:')
      ..writeln('"mera bike start nahi ho raha"')
      ..writeln('-> normalized_request = "Bike not starting"')
      ..writeln()
      ..writeln('4. Translation Logic')
      ..writeln('If spoken language != selected_language:')
      ..writeln('- Understand original meaning')
      ..writeln('- Translate internally')
      ..writeln('- Respond only in selected_language')
      ..writeln()
      ..writeln('5. Response Style')
      ..writeln('Responses must be:')
      ..writeln('- Short')
      ..writeln('- Clear')
      ..writeln('- Friendly')
      ..writeln('- Voice assistant friendly')
      ..writeln('- Action oriented')
      ..writeln()
      ..writeln('6. Safety & Clarity Rule')
      ..writeln(
        'If request is unclear -> ask clarification question in selected_language.',
      )
      ..writeln()
      ..writeln('7. Output Format')
      ..writeln('Return ONLY JSON:')
      ..writeln('{')
      ..writeln('  "detected_language": "en | hi | mr",')
      ..writeln('  "selected_language": "en | hi | mr",')
      ..writeln('  "normalized_request": "",')
      ..writeln('  "response_text": "",')
      ..writeln('  "confidence": 0.0,')
      ..writeln('  "needs_clarification": false')
      ..writeln('}')
      ..writeln()
      ..writeln('Rules:')
      ..writeln('- confidence must be between 0.0 and 1.0')
      ..writeln('- response_text must always be in selected_language')
      ..writeln('- never output text outside JSON')
      ..writeln()
      ..writeln('User Transcript: "$transcript"');

    try {
      final response = await _model
          .generateContent([Content.text(prompt.toString())])
          .timeout(const Duration(seconds: 10));
      final text = response.text ?? '{}';
      final map = _safeDecodeJson(text);
      return MultilingualResponse.fromJson(map);
    } on TimeoutException {
      throw Exception('AI response took too long. Please try again.');
    }
  }
  Future<VoiceCommandInterpretation> interpretVoiceCommand(String transcript) async {
    final prompt = StringBuffer()
      ..writeln('You are a multilingual voice interpretation layer for an AI assistant.')
      ..writeln('Your job is NOT to answer the user.')
      ..writeln('Your job is to convert speech input into a standardized English intent so that downstream systems can process it.')
      ..writeln()
      ..writeln('Supported Input Languages:')
      ..writeln('- English')
      ..writeln('- Hindi')
      ..writeln('- Marathi')
      ..writeln()
      ..writeln('TASKS')
      ..writeln('1. Detect spoken language.')
      ..writeln('2. Understand user intent even if:')
      ..writeln('- grammar incorrect')
      ..writeln('- mixed language')
      ..writeln('- phonetic spelling')
      ..writeln('- incomplete sentences')
      ..writeln('- speech recognition mistakes')
      ..writeln('3. Convert request into normalized English intent.')
      ..writeln('Examples:')
      ..writeln('"माझा पंखा चालत नाही" -> "Fan not working"')
      ..writeln('"mera tyre puncture ho gaya" -> "Tyre puncture"')
      ..writeln('"bike start nahi ho rahi" -> "Bike not starting"')
      ..writeln('4. Extract emotional urgency tone from wording:')
      ..writeln('Indicators: panic words, danger words, stress words, urgent phrases')
      ..writeln('Return urgency_level: CRITICAL, HIGH, MEDIUM, LOW')
      ..writeln('5. Keep normalized request short and structured.')
      ..writeln('6. Do NOT respond conversationally.')
      ..writeln('Do NOT answer user.')
      ..writeln('Do NOT generate explanations.')
      ..writeln()
      ..writeln('OUTPUT FORMAT')
      ..writeln('Return JSON only:')
      ..writeln('{')
      ..writeln('  "detected_language": "",')
      ..writeln('  "normalized_intent": "",')
      ..writeln('  "urgency_level": "",')
      ..writeln('  "confidence": 0.0')
      ..writeln('}')
      ..writeln()
      ..writeln('Rules:')
      ..writeln('- normalized_intent MUST be in English')
      ..writeln('- confidence must be 0.0–1.0')
      ..writeln('- No extra text outside JSON')
      ..writeln()
      ..writeln('Input transcript: "$transcript"');

    try {
      final response = await _model
          .generateContent([Content.text(prompt.toString())])
          .timeout(const Duration(seconds: 10));
      final text = response.text ?? '{}';
      final map = _safeDecodeJson(text);
      return VoiceCommandInterpretation.fromJson(map);
    } on TimeoutException {
      throw Exception('AI response took too long. Please try again.');
    }
  }
}

class VoiceCommandInterpretation {
  final String detectedLanguage;
  final String normalizedIntent;
  final String urgencyLevel;
  final double confidence;

  VoiceCommandInterpretation({
    required this.detectedLanguage,
    required this.normalizedIntent,
    required this.urgencyLevel,
    required this.confidence,
  });

  factory VoiceCommandInterpretation.fromJson(Map<String, dynamic> json) {
    return VoiceCommandInterpretation(
      detectedLanguage: json['detected_language'] as String? ?? 'en',
      normalizedIntent: json['normalized_intent'] as String? ?? '',
      urgencyLevel: json['urgency_level'] as String? ?? 'LOW',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

Map<String, dynamic> _safeDecodeJson(String raw) {
  try {
    // Gemini sometimes wraps JSON in code fences or extra text; try to extract the JSON substring.
    final jsonStart = raw.indexOf('{');
    final jsonEnd = raw.lastIndexOf('}');
    if (jsonStart == -1 || jsonEnd == -1) return {};
    final json = raw.substring(jsonStart, jsonEnd + 1);
    return Map<String, dynamic>.from(jsonDecode(json) as Map);
  } catch (_) {
    return {};
  }
}
