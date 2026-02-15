import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/emergency/emergency_providers.dart';
import '../../../core/theme/app_theme.dart';

import '../discovery/data/worker_models.dart';

class SOSConfirmationScreen extends ConsumerStatefulWidget {
  final Worker? activeWorker;
  final String? sessionId;

  const SOSConfirmationScreen({
    super.key,
    this.activeWorker,
    this.sessionId,
  });

  @override
  ConsumerState<SOSConfirmationScreen> createState() =>
      _SOSConfirmationScreenState();
}

class _SOSConfirmationScreenState extends ConsumerState<SOSConfirmationScreen>
    with SingleTickerProviderStateMixin {
  int _countdown = 5;
  Timer? _timer;
  late AnimationController _pulseController;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        _triggerSOS();
      }
    });
  }

  void _triggerSOS() async {
    if (_cancelled) return;

    final contacts = ref.read(emergencyContactsProvider);
    final primaryContact =
        ref.read(emergencyContactsProvider.notifier).primaryContact;

    if (primaryContact == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No emergency contacts configured!'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Log the activation with session context
    final sessionData = {
      'workerId': widget.activeWorker?.id ?? 'N/A',
      'workerName': widget.activeWorker?.name ?? 'N/A',
      'sessionId': widget.sessionId ??
          'ADHOC_SOS_${DateTime.now().millisecondsSinceEpoch}',
      'location': 'Mock GPS: 16.705, 74.243',
    };

    await ref.read(sosLogProvider.notifier).logActivation(
          primaryContact.name,
          metadata: sessionData,
        );

    // Make the call
    final phoneUrl = Uri.parse('tel:${primaryContact.phoneNumber}');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling ${primaryContact.name}...'),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _cancel() {
    setState(() {
      _cancelled = true;
    });
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryContact =
        ref.watch(emergencyContactsProvider.notifier).primaryContact;

    return Scaffold(
      backgroundColor: const Color(0xFFDC2626),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EMERGENCY SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_countdown}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Pulsing Emergency Icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = 1.0 + (_pulseController.value * 0.2);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      size: 100,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // Countdown Display
            Text(
              _countdown > 0 ? 'Calling in $_countdown...' : 'Calling now...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            // Contact Info
            if (primaryContact != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Primary Contact',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      primaryContact.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      primaryContact.phoneNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Cancel Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _cancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),

            // Warning Text
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Text(
                'Misuse of emergency services may result in penalties',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
