import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'gemini_service.dart';

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
