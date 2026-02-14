import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:app/features/discovery/data/worker_models.dart';
import '../enums/service_category.dart';

/// Get Gemini API key from environment variables
String get kGeminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

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
      final response = await _model
          .generateContent([Content.text(prompt.toString())])
          .timeout(const Duration(seconds: 15));

      final text = response.text ?? '{}';
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
