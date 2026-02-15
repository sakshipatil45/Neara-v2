import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'gemini_service.dart';
import '../enums/service_category.dart';
import '../../features/discovery/data/worker_models.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final emergencyInterpretationProvider =
    StateNotifierProvider<
      EmergencyController,
      AsyncValue<EmergencyInterpretation?>
    >((ref) => EmergencyController(ref));

class EmergencyController
    extends StateNotifier<AsyncValue<EmergencyInterpretation?>> {
  EmergencyController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> interpret(String transcript) async {
    state = const AsyncValue.loading();
    try {
      double? lat;
      double? lng;

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(const Duration(seconds: 5));
          lat = position.latitude;
          lng = position.longitude;
        }
      } catch (_) {
        // Silently ignore location errors; interpretation will still work.
      }

      final result = await _ref
          .read(geminiServiceProvider)
          .interpretEmergency(transcript: transcript, lat: lat, lng: lng);

      // Always provide location hint - use GPS if Gemini didn't provide one
      String locationHint = result.locationHint;
      if (locationHint.isEmpty && lat != null && lng != null) {
        locationHint =
            'Current location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
      } else if (locationHint.isEmpty) {
        locationHint = 'Location not available';
      } else if (locationHint == 'Unknown' && lat != null && lng != null) {
        locationHint = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }

      final augmented = EmergencyInterpretation(
        issueSummary: result.issueSummary,
        urgency: result.urgency,
        locationHint: locationHint,
        serviceCategory: result.serviceCategory,
        reason: result.reason,
        confidence: result.confidence,
        riskFactors: result.riskFactors,
        needsClarification: result.needsClarification,
      );

      state = AsyncValue.data(augmented);
    } catch (e, stack) {
      // Log the actual error for debugging
      print('Gemini API Error: $e');
      print('Stack trace: $stack');

      // Set error state instead of fallback so we can see what went wrong
      state = AsyncValue.error(e, stack);
    }
  }
}

final searchFiltersProvider =
    StateNotifierProvider<SearchFiltersController, SearchFilters>((ref) {
      return SearchFiltersController(ref);
    });

class SearchFiltersController extends StateNotifier<SearchFilters> {
  SearchFiltersController(this._ref) : super(const SearchFilters());

  final Ref _ref;

  Future<void> fromQuery(String query) async {
    try {
      final aiFilters = await _ref
          .read(geminiServiceProvider)
          .interpretSearch(query);
      state = aiFilters;
    } catch (_) {
      // Keep existing filters on failure.
    }
  }

  void update(SearchFilters filters) => state = filters;
}

<<<<<<< HEAD
=======
final multilingualAssistantProvider =
    StateNotifierProvider<
      MultilingualController,
      AsyncValue<MultilingualResponse?>
    >((ref) => MultilingualController(ref));

class MultilingualController
    extends StateNotifier<AsyncValue<MultilingualResponse?>> {
  MultilingualController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> processRequest(
    String transcript, {
    String selectedLanguage = 'auto',
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ref
          .read(geminiServiceProvider)
          .processUserRequest(
            transcript: transcript,
            selectedLanguage: selectedLanguage,
          );
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

>>>>>>> 9bd3e140705023388089eef5a89e20d2fc885764
final workerServiceProvider = Provider<WorkerService>(
  (ref) => WorkerService(ref),
);

class WorkerService {
  final Ref _ref;

  WorkerService(this._ref);

  Future<List<WorkerRanking>> recommendWorkers({
    required EmergencyInterpretation interpretation,
    required List<Worker> allWorkers,
  }) async {
    // 1. Initial Filtering
    final candidates = allWorkers.where((w) {
      if (w.primaryCategory == interpretation.serviceCategory) return true;
      if (w.primaryCategory == ServiceCategory.other) return true;
      if (interpretation.serviceCategory == ServiceCategory.other) return true;
      return false;
    }).toList();

    final pool = candidates.isNotEmpty ? candidates : allWorkers;
    print('DEBUG: Default All Workers: ${allWorkers.length}');
    print('DEBUG: Interpretation Category: ${interpretation.serviceCategory}');
    print('DEBUG: Candidates found: ${candidates.length}');
    print('DEBUG: Backup Pool Size: ${pool.length}');

    // Get User Location
    double? lat, lng;
    try {
      final pos = await Geolocator.getCurrentPosition();
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (_) {}

    // 2. Opt-out of AI for LOW urgency to save quota/latency
    if (interpretation.urgency == EmergencyUrgency.low) {
      print('Urgency is LOW. Using local fallback ranking.');
      return _fallbackRanking(pool, interpretation, lat, lng);
    }

    // 3. AI Ranking with Fallback Mechanism
    try {
      // Check confidence before verifying (User requirement: < 0.65 -> fallback)
      if (interpretation.confidence < 0.65) {
        print(
          'AI Confidence low (${interpretation.confidence}). Using fallback.',
        );
        return _fallbackRanking(
          pool,
          interpretation,
          lat,
          lng,
          isLowConfidence: true,
        );
      }

      final workersJson = pool.map((w) {
        return {
          'worker_id': w.id,
          'category': w.primaryCategory.name,
          'skills': w.skills,
          'rating': w.rating,
          'verified': w.verified,
          'responsiveness': w.responseTimeMinutes,
          'location': '${w.latitude}, ${w.longitude}',
          'status': w.status.toString(),
        };
      }).toList();

      final rankings = await _ref
          .read(geminiServiceProvider)
          .rankWorkers(
            interpretation: interpretation,
            workersJson: workersJson,
            userLat: lat,
            userLng: lng,
          );

      if (rankings.isEmpty) {
        throw Exception('AI returned empty rankings');
      }

      // Merge and Sort
      final workerMap = {for (var w in pool) w.id: w};
      final finalRankings = <WorkerRanking>[];

      for (var r in rankings) {
        final worker = workerMap[r.workerId];
        if (worker != null) {
          finalRankings.add(r.copyWith(worker: worker));
        }
      }

      return finalRankings;
    } catch (e) {
      print('AI Ranking failed: $e. Using local fallback.');
      return _fallbackRanking(
        pool,
        interpretation,
        lat,
        lng,
        error: e.toString(),
      );
    }
  }

  List<WorkerRanking> _fallbackRanking(
    List<Worker> workers,
    EmergencyInterpretation interpretation,
    double? userLat,
    double? userLng, {
    bool isLowConfidence = false,
    String? error,
  }) {
    // Calculate scores
    final scored = workers.map((w) {
      final score = _calculateFallbackScore(
        w,
        interpretation,
        userLat,
        userLng,
      );
      return MapEntry(w, score);
    }).toList();

    // Sort descending
    scored.sort((a, b) => b.value.compareTo(a.value));

    // Convert to WorkerRanking
    print('DEBUG: Fallback ranking returned ${scored.length} workers');
    return scored.asMap().entries.map((entry) {
      final index = entry.key;
      final worker = entry.value.key;
      final score = entry.value.value;

      final isTop = index == 0;

      String reason = 'Matched based on skills and rating.';
      if (isLowConfidence) reason += ' (AI Confidence Low)';
      if (error != null) reason += ' (Offline Mode)';

      return WorkerRanking(
        workerId: worker.id,
        score: score.round(), // Scale 0-100
        reason: reason,
        recommendationLevel: isTop ? 'PRIMARY' : 'STANDARD',
        highlightMarker: isTop,
        badgeLabel: isTop ? 'Smart Match' : null,
        worker: worker,
      );
    }).toList();
  }

  double _calculateFallbackScore(
    Worker worker,
    EmergencyInterpretation interpretation,
    double? userLat,
    double? userLng,
  ) {
    double score = 50.0; // Base score

    // 1. Skill Match (High Weight)
    final summary = interpretation.issueSummary.toLowerCase();
    int matches = 0;
    for (var skill in worker.skills) {
      if (summary.contains(skill.toLowerCase())) matches++;
    }
    score += (matches * 10.0);

    // 2. Rating (Moderate)
    score += (worker.rating * 5.0); // max 25

    // 3. Verified (Critical only)
    if (interpretation.urgency == EmergencyUrgency.critical &&
        worker.verified) {
      score += 15.0;
    } else if (worker.verified) {
      score += 5.0;
    }

    // 4. Response Time (Faster = Higher)
    // Assume 60 mins is standard. < 60 gives bonus.
    if (worker.responseTimeMinutes < 60) {
      score += (60 - worker.responseTimeMinutes) * 0.5;
    }

    // 5. Distance (Inverse)
    if (userLat != null && userLng != null) {
      final dist =
          Geolocator.distanceBetween(
            userLat,
            userLng,
            worker.latitude,
            worker.longitude,
          ) /
          1000.0; // km

      // Penalty: -2 per km
      score -= (dist * 2.0);
    }

    return score.clamp(0.0, 100.0);
  }
}
<<<<<<< HEAD

final multilingualAssistantProvider =
    StateNotifierProvider<
      MultilingualController,
      AsyncValue<MultilingualResponse?>
    >((ref) => MultilingualController(ref));

class MultilingualController
    extends StateNotifier<AsyncValue<MultilingualResponse?>> {
  MultilingualController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> processRequest(
    String transcript, {
    String selectedLanguage = 'auto',
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _ref
          .read(geminiServiceProvider)
          .processUserRequest(
            transcript: transcript,
            selectedLanguage: selectedLanguage,
          );
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
=======
>>>>>>> 9bd3e140705023388089eef5a89e20d2fc885764
