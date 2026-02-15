import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:app/features/discovery/data/worker_models.dart';
import '../enums/service_category.dart';

/// Get OpenRouter API key from environment variables
String get kOpenRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';

enum EmergencyUrgency { low, medium, high, critical }

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
  final bool womenSafetyMode; // Enhanced safety features
  final bool liveTracking; // Real-time session tracking
  final bool riskMonitoring; // AI-based risk detection
  final bool shareWithPrioritized; // Share location with prioritized contact

  const SearchFilters({
    this.serviceCategory,
    this.categories = const [],
    this.radiusKm = 50,
    this.minRating = 3.5,
    this.verifiedOnly = false,
    this.genderPreference = 'any',
    this.womenSafetyMode = false,
    this.liveTracking = false,
    this.riskMonitoring = false,
    this.shareWithPrioritized = false,
  });

  SearchFilters copyWith({
    ServiceCategory? serviceCategory,
    List<ServiceCategory>? categories,
    double? radiusKm,
    double? minRating,
    bool? verifiedOnly,
    String? genderPreference,
    bool? womenSafetyMode,
    bool? liveTracking,
    bool? riskMonitoring,
    bool? shareWithPrioritized,
  }) {
    return SearchFilters(
      serviceCategory: serviceCategory ?? this.serviceCategory,
      categories: categories ?? this.categories,
      radiusKm: radiusKm ?? this.radiusKm,
      minRating: minRating ?? this.minRating,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      genderPreference: genderPreference ?? this.genderPreference,
      womenSafetyMode: womenSafetyMode ?? this.womenSafetyMode,
      liveTracking: liveTracking ?? this.liveTracking,
      riskMonitoring: riskMonitoring ?? this.riskMonitoring,
      shareWithPrioritized: shareWithPrioritized ?? this.shareWithPrioritized,
    );
  }
}

class MultilingualResponse {
  final String detectedLanguage;
  final String selectedLanguage;
  final String normalizedRequest;
  final String serviceType;
  final String responseText;
  final double confidence;
  final bool needsClarification;

  MultilingualResponse({
    required this.detectedLanguage,
    required this.selectedLanguage,
    required this.normalizedRequest,
    required this.serviceType,
    required this.responseText,
    required this.confidence,
    required this.needsClarification,
  });

  factory MultilingualResponse.fromJson(Map<String, dynamic> json) {
    return MultilingualResponse(
      detectedLanguage: json['detected_language'] as String? ?? 'en',
      selectedLanguage: json['selected_language'] as String? ?? 'en',
      normalizedRequest: json['normalized_request'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? 'other',
      responseText: json['response_text'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      needsClarification: json['needs_clarification'] as bool? ?? false,
    );
  }
}

class GeminiService {
  // OpenRouter API configuration
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _primaryModel = 'openai/gpt-4o-mini';
  static const String _fallbackModel = 'mistralai/mistral-7b-instruct';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _httpClient;

  GeminiService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Helper method to make OpenRouter API calls
  Future<String> _callOpenRouter({
    required String systemPrompt,
    required String userMessage,
    String? model,
    int retryCount = 0,
  }) async {
    final selectedModel = model ?? _primaryModel;

    try {
      print('🔍 Calling OpenRouter with model: $selectedModel');

      final response = await _httpClient
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $kOpenRouterApiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://neara.app',
              'X-Title': 'Neara',
            },
            body: jsonEncode({
              'model': selectedModel,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userMessage},
              ],
              'temperature': 0.3,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        print('✅ OpenRouter response received');
        return content;
      } else {
        throw Exception(
          'OpenRouter API error: ${response.statusCode} - ${response.body}',
        );
      }
    } on TimeoutException {
      print('⏱️ Request timeout');
      throw Exception('Request timeout after ${_timeout.inSeconds}s');
    } catch (e) {
      print('❌ OpenRouter error: $e');

      // Retry logic with fallback model
      if (retryCount == 0 && selectedModel == _primaryModel) {
        print('🔄 Retrying with same model...');
        return _callOpenRouter(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
          model: selectedModel,
          retryCount: 1,
        );
      } else if (retryCount == 1 && selectedModel == _primaryModel) {
        print('🔄 Switching to fallback model: $_fallbackModel');
        return _callOpenRouter(
          systemPrompt: systemPrompt,
          userMessage: userMessage,
          model: _fallbackModel,
          retryCount: 2,
        );
      }

      rethrow;
    }
  }

  Future<EmergencyInterpretation> interpretEmergency({
    required String transcript,
    double? lat,
    double? lng,
  }) async {
    try {
      // Build system prompt
      final systemPrompt = StringBuffer()
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
          'Note: Use "Gas Service" for gas leaks, LPG issues, gas line problems, or gas appliance emergencies.',
        )
        ..writeln(
          '  "service_type": "mechanic | plumber | electrician | maid | roadside assistance | gas service | other",',
        )
        ..writeln('  "urgency_level": "CRITICAL | HIGH | MEDIUM | LOW",')
        ..writeln('  "issue_summary": "Short 3-5 word title",')
        ..writeln('  "risk_factors": ["risk1", "risk2"],')
        ..writeln('  "reason": "One sentence explanation",')
        ..writeln('  "confidence": 0.0,')
        ..writeln('  "needs_clarification": false')
        ..writeln('}')
        ..writeln('Rules:')
        ..writeln('- service_type MUST be one of the English labels above.')
        ..writeln('- Confidence must be between 0.0 and 1.0.')
        ..writeln('- Confidence below 0.6 means ambiguity.')
        ..writeln('- Do not output anything outside JSON.');

      // Build user message
      final userMessage = StringBuffer()
        ..writeln('User speech transcript: "$transcript"')
        ..writeln(
          lat != null && lng != null
              ? 'User GPS coordinates (lat,lng): $lat,$lng. Use these only to refine the locationHint (e.g., nearby area name) and to assess safety ONLY IF the user is stranded or in danger.'
              : 'No GPS coordinates available for this request.',
        );

      // Call OpenRouter
      final text = await _callOpenRouter(
        systemPrompt: systemPrompt.toString(),
        userMessage: userMessage.toString(),
      );

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
        'gas service' => ServiceCategory.gasService,
        'gasservice' => ServiceCategory.gasService,
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
        riskFactors: (map['risk_factors'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        needsClarification: map['needs_clarification'] == true,
      );
    } catch (e) {
      print('AI Interpretation failed: $e. Using offline fallback.');
      return _getFallbackInterpretation(transcript, lat, lng);
    }
  }

  EmergencyInterpretation _getFallbackInterpretation(
    String transcript,
    double? lat,
    double? lng,
  ) {
    final t = transcript.toLowerCase();
    ServiceCategory category = ServiceCategory.other;

    if (t.contains('mechanic') ||
        t.contains('car') ||
        t.contains('breakdown') ||
        t.contains('tire') ||
        t.contains('battery')) {
      category = ServiceCategory.mechanic;
    } else if (t.contains('plumber') ||
        t.contains('leak') ||
        t.contains('water') ||
        t.contains('pipe') ||
        t.contains('clog')) {
      category = ServiceCategory.plumber;
    } else if (t.contains('electric') ||
        t.contains('power') ||
        t.contains('light') ||
        t.contains('fuse') ||
        t.contains('shock')) {
      category = ServiceCategory.electrician;
    } else if (t.contains('maid') ||
        t.contains('clean') ||
        t.contains('dust') ||
        t.contains('sweep') ||
        t.contains('mop')) {
      category = ServiceCategory.maid;
    } else if (t.contains('roadside') ||
        t.contains('tow') ||
        t.contains('accident') ||
        t.contains('stuck')) {
      category = ServiceCategory.roadsideAssistance;
    } else if (t.contains('gas') || t.contains('leak') || t.contains('lpg')) {
      category = ServiceCategory.gasService;
    }

    return EmergencyInterpretation(
      issueSummary: transcript.length > 50
          ? '${transcript.substring(0, 47)}...'
          : transcript,
      urgency:
          t.contains('urgent') ||
              t.contains('emergency') ||
              t.contains('fire') ||
              t.contains('danger')
          ? EmergencyUrgency.high
          : EmergencyUrgency.medium,
      locationHint: lat != null && lng != null ? '$lat, $lng' : 'Unknown',
      serviceCategory: category,
      reason: 'Offline fallback interpretation based on keywords.',
      confidence: 0.5,
      riskFactors: [],
      needsClarification: false,
    );
  }

  Future<List<WorkerRanking>> rankWorkers({
    required EmergencyInterpretation interpretation,
    required List<Map<String, dynamic>> workersJson,
    double? userLat,
    double? userLng,
  }) async {
    final prompt = StringBuffer()
      ..writeln(
        'You are an AI-powered worker matching and ranking engine for a hyperlocal service platform.',
      )
      ..writeln(
        'Your task is to intelligently rank available workers for a given service request.',
      )
      ..writeln(
        'You must evaluate workers using contextual reasoning, not simple sorting or keyword matching.',
      )
      ..writeln('Service Request Context:')
      ..writeln('- Type: ${interpretation.serviceCategory.name}')
      ..writeln('- Urgency: ${interpretation.urgency.name}')
      ..writeln('- Issue: ${interpretation.issueSummary}')
      ..writeln('- User Location: $userLat, $userLng')
      ..writeln('Available Workers:')
      ..writeln(jsonEncode(workersJson))
      ..writeln('Respond strictly in JSON:')
      ..writeln('{')
      ..writeln('  "ranking_strategy_summary": "",')
      ..writeln('  "recommended_worker_id": "",')
      ..writeln('  "ranked_workers": [')
      ..writeln('    {')
      ..writeln('      "worker_id": "",')
      ..writeln('      "ranking_score": 0,')
      ..writeln(
        '      "recommendation_level": "PRIMARY | SECONDARY | STANDARD",',
      )
      ..writeln('      "highlight_marker": true,')
      ..writeln('      "badge_label": "",')
      ..writeln('      "reason": ""')
      ..writeln('    }')
      ..writeln('  ]')
      ..writeln('}')
      ..writeln('Rules:')
      ..writeln('- Only ONE worker should have highlight_marker = true.')
      ..writeln('- That worker must be the highest ranked.')
      ..writeln(
        '- recommendation_level: PRIMARY = top, SECONDARY = strong alternative, STANDARD = normal.',
      )
      ..writeln('- Do not output text outside JSON.');

    try {
      // Build system prompt for worker ranking
      final systemPrompt = prompt.toString();

      // Build user message (empty for this use case, all context in system)
      final userMessage =
          'Please rank these workers based on the criteria provided.';

      // Call OpenRouter
      final text = await _callOpenRouter(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
      );

      final map = _safeDecodeJson(text);
      final list = (map['ranked_workers'] as List<dynamic>?) ?? [];

      return list
          .map(
            (e) => WorkerRanking(
              workerId: e['worker_id'].toString(),
              score: (e['ranking_score'] as num).toInt(),
              reason: e['reason'].toString(),
              recommendationLevel:
                  e['recommendation_level']?.toString() ?? 'STANDARD',
              highlightMarker: e['highlight_marker'] == true,
              badgeLabel: e['badge_label']?.toString(),
            ),
          )
          .toList();
    } catch (e) {
      print('Ranking error: $e');
      rethrow;
    }
  }

  // ... rest of the file ... (ensure interpretSearch remains intact)

  Future<SearchFilters> interpretSearch(String query) async {
    // ... interpretSearch implementation ...
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
          .generateContent([Content.text(prompt.toString())]).timeout(
              const Duration(seconds: 8));
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
        radiusKm:
            (map['radiusKm'] is num) ? (map['radiusKm'] as num).toDouble() : 5,
        minRating: (map['minRating'] is num)
            ? (map['minRating'] as num).toDouble()
            : 4.0,
        verifiedOnly:
            map['verifiedOnly'] is bool ? map['verifiedOnly'] as bool : true,
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
      ..writeln(
        'Convert user speech into a clean standardized request meaning.',
      )
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
      ..writeln(
        '  "service_type": "mechanic | plumber | electrician | maid | roadside assistance | gas service | other",',
      )
      ..writeln('  "normalized_request": "",')
      ..writeln('  "response_text": "",')
      ..writeln('  "confidence": 0.0,')
      ..writeln('  "needs_clarification": false')
      ..writeln('}')
      ..writeln()
      ..writeln('Rules:')
      ..writeln('- service_type MUST be one of the English labels above.')
      ..writeln('- confidence must be between 0.0 and 1.0')
      ..writeln('- response_text must always be in selected_language')
      ..writeln('- never output text outside JSON')
      ..writeln()
      ..writeln('User Transcript: "$transcript"');

    try {
      final text = await _callOpenRouter(
        systemPrompt: prompt.toString(),
        userMessage: 'Interpret this request: "$transcript"',
      );
      final map = _safeDecodeJson(text);
      return MultilingualResponse.fromJson(map);
    } catch (e) {
      throw Exception('AI response failed: $e');
    }
  }

  Future<VoiceCommandInterpretation> interpretVoiceCommand(
    String transcript,
  ) async {
    final prompt = StringBuffer()
      ..writeln(
        'You are a multilingual voice interpretation layer for an AI assistant.',
      )
      ..writeln('Your job is NOT to answer the user.')
      ..writeln(
        'Your job is to convert speech input into a standardized English intent so that downstream systems can process it.',
      )
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
      ..writeln(
        'Indicators: panic words, danger words, stress words, urgent phrases',
      )
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
      ..writeln(
        '  "service_type": "mechanic | plumber | electrician | maid | roadside assistance | gas service | other",',
      )
      ..writeln('  "normalized_intent": "",')
      ..writeln('  "urgency_level": "",')
      ..writeln('  "confidence": 0.0')
      ..writeln('}')
      ..writeln()
      ..writeln('Rules:')
      ..writeln('- service_type MUST be one of the English labels above.')
      ..writeln('- normalized_intent MUST be in English')
      ..writeln('- confidence must be 0.0–1.0')
      ..writeln('- No extra text outside JSON')
      ..writeln()
      ..writeln('Input transcript: "$transcript"');

    try {
      final text = await _callOpenRouter(
        systemPrompt: prompt.toString(),
        userMessage: 'Normalize this transcript: "$transcript"',
      );
      final map = _safeDecodeJson(text);
      return VoiceCommandInterpretation.fromJson(map);
    } catch (e) {
      throw Exception('AI response failed: $e');
    }
  }
}

class VoiceCommandInterpretation {
  final String detectedLanguage;
  final String serviceType;
  final String normalizedIntent;
  final String urgencyLevel;
  final double confidence;

  VoiceCommandInterpretation({
    required this.detectedLanguage,
    required this.serviceType,
    required this.normalizedIntent,
    required this.urgencyLevel,
    required this.confidence,
  });

  factory VoiceCommandInterpretation.fromJson(Map<String, dynamic> json) {
    return VoiceCommandInterpretation(
      detectedLanguage: json['detected_language'] as String? ?? 'en',
      serviceType: json['service_type'] as String? ?? 'other',
      normalizedIntent: json['normalized_intent'] as String? ?? '',
      urgencyLevel: json['urgency_level'] as String? ?? 'LOW',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class WorkerRanking {
  final String workerId;
  final int score;
  final String reason;
  final String recommendationLevel;
  final bool highlightMarker;
  final String? badgeLabel;
  final Worker? worker;

  WorkerRanking({
    required this.workerId,
    required this.score,
    required this.reason,
    this.recommendationLevel = 'STANDARD',
    this.highlightMarker = false,
    this.badgeLabel,
    this.worker,
  });

  WorkerRanking copyWith({
    String? workerId,
    int? score,
    String? reason,
    String? recommendationLevel,
    bool? highlightMarker,
    String? badgeLabel,
    Worker? worker,
  }) {
    return WorkerRanking(
      workerId: workerId ?? this.workerId,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      recommendationLevel: recommendationLevel ?? this.recommendationLevel,
      highlightMarker: highlightMarker ?? this.highlightMarker,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      worker: worker ?? this.worker,
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
