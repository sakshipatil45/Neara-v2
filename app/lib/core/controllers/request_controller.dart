import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai/ai_providers.dart';
import '../ai/gemini_service.dart';
import '../../features/analysis/presentation/ai_analysis_screen.dart';
import '../../features/discovery/presentation/worker_discovery_screen.dart';
import '../enums/service_category.dart';

/// Unified controller for handling ALL user requests (text or voice)
/// This ensures consistent UX by routing both input types through AI analysis
class RequestController {
  final WidgetRef ref;
  final BuildContext context;

  RequestController(this.ref, this.context);

  /// Unified handler for ALL user requests (text or voice)
  ///
  /// Flow:
  /// 1. Run AI Analysis (interpretEmergency)
  /// 2. Navigate to AI Analysis Screen
  /// 3. Analysis screen auto-triggers worker ranking
  /// 4. Navigate to Worker Discovery with recommendations
  Future<void> handleUserRequest(String userMessage) async {
    print('🎯 RequestController: Starting handleUserRequest');

    EmergencyInterpretation? interpretation;

    try {
      // Step 1: Run AI Analysis
      print('🔍 Running AI interpretation...');
      await ref
          .read(emergencyInterpretationProvider.notifier)
          .interpret(userMessage);

      // Capture the interpretation IMMEDIATELY after await, before any navigation
      interpretation = ref.read(emergencyInterpretationProvider).value;
      print('✅ Got interpretation: ${interpretation?.serviceCategory.name}');

      if (interpretation == null) {
        throw Exception('AI analysis returned null');
      }

      // Step 2: Navigate to AI Analysis Screen
      // Check mounted AFTER we have the interpretation data
      if (!context.mounted) {
        print('⚠️ Context not mounted after interpretation');
        return;
      }

      print('🚀 Navigating to AI Analysis Screen...');
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AIAnalysisScreen(
            interpretation:
                interpretation!, // Safe because we checked null above
            userMessage: userMessage,
          ),
        ),
      );
      print('✅ Navigation completed');
    } catch (e) {
      // Error handling with fallback
      print('RequestController error: $e');

      if (!context.mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('AI unavailable. Showing all workers.'),
          backgroundColor: const Color(0xFFEF4444),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => handleUserRequest(userMessage),
          ),
        ),
      );

      // Fallback: Navigate to worker discovery with wildcard filter
      // Only update filters if context is still mounted
      try {
        if (context.mounted) {
          ref
              .read(searchFiltersProvider.notifier)
              .update(
                const SearchFilters(serviceCategory: ServiceCategory.other),
              );
        }
      } catch (refError) {
        print('Could not update filters (widget disposed): $refError');
      }

      // Navigate even if filter update failed
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorkerDiscoveryScreen()),
        );
      }
    }
  }
}

/// Helper function to create RequestController with proper WidgetRef
RequestController createRequestController(WidgetRef ref, BuildContext context) {
  return RequestController(ref, context);
}
