import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/ai/ai_providers.dart';
import '../../discovery/presentation/worker_discovery_screen.dart';
import '../../discovery/data/worker_providers.dart';

class AIAnalysisScreen extends ConsumerStatefulWidget {
  final EmergencyInterpretation interpretation;
  final String userMessage;

  const AIAnalysisScreen({
    super.key,
    required this.interpretation,
    required this.userMessage,
  });

  @override
  ConsumerState<AIAnalysisScreen> createState() => _AIAnalysisScreenState();
}

class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
  bool _isRanking = false;

  @override
  void initState() {
    super.initState();
    // User will manually trigger worker ranking by clicking "Continue" button
  }

  Future<void> _startWorkerRanking() async {
    print('🔍 Starting worker ranking...');
    if (!mounted) {
      print('❌ Widget not mounted, aborting');
      return;
    }

    setState(() => _isRanking = true);
    print('✅ Set ranking state to true');

    try {
      // Safely read providers with disposal check
      final allWorkers = ref.read(workersProvider);
      print('📋 Got ${allWorkers.length} workers');

      final rankings = await ref.read(workerServiceProvider).recommendWorkers(
            interpretation: widget.interpretation,
            allWorkers: allWorkers,
          );
      print('🎯 Got ${rankings.length} ranked workers');

      if (!mounted) {
        print('❌ Widget disposed during ranking');
        return;
      }

      print('🚀 Navigating to WorkerDiscoveryScreen...');
      // Navigate to worker discovery with rankings
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WorkerDiscoveryScreen(recommendations: rankings),
        ),
      );
      print('✅ Navigation complete');
    } catch (e, stackTrace) {
      print('❌ Worker ranking error: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;

      // Show error but still navigate (fallback mode)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Using fallback ranking'),
          backgroundColor: Color(0xFFF97316),
        ),
      );

      print('🔄 Navigating with fallback...');
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WorkerDiscoveryScreen()),
      );
      print('✅ Fallback navigation complete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Analysis',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Understanding your request...',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // User Message
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(width: 6),
                          const Text(
                            'Your Request',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"${widget.userMessage}"',
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Analysis Results
                _buildAnalysisCard(
                  'Service Type',
                  widget.interpretation.serviceCategory.name.toUpperCase(),
                  Icons.build_circle,
                  const Color(0xFF6366F1),
                ),

                const SizedBox(height: 12),

                _buildAnalysisCard(
                  'Urgency Level',
                  widget.interpretation.urgency.name.toUpperCase(),
                  Icons.priority_high,
                  _getUrgencyColor(widget.interpretation.urgency),
                ),

                const SizedBox(height: 12),

                _buildAnalysisCard(
                  'AI Confidence',
                  '${(widget.interpretation.confidence * 100).toStringAsFixed(0)}%',
                  Icons.analytics_outlined,
                  const Color(0xFF10B981),
                ),

                if (widget.interpretation.riskFactors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildRiskFactorsCard(),
                ],

                const SizedBox(height: 40), // Large spacing instead of Spacer

                // Continue button or loading indicator
                if (_isRanking)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF8FAFC),
                          const Color(0xFFF8FAFC).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Finding Best Matches',
                                style: TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Ranking workers by skills, distance & availability',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _startWorkerRanking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: const Color(0xFF6366F1).withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 24),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFECACA),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Risk Factors Detected',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.interpretation.riskFactors
                .map(
                  (risk) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      risk,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(EmergencyUrgency urgency) {
    return switch (urgency) {
      EmergencyUrgency.critical => const Color(0xFFEF4444),
      EmergencyUrgency.high => const Color(0xFFF97316),
      EmergencyUrgency.medium => const Color(0xFFFBBF24),
      EmergencyUrgency.low => const Color(0xFF10B981),
    };
  }
}
