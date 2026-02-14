import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/ai/ai_providers.dart';
import 'package:app/core/ai/gemini_service.dart';

/// Example 1: Basic Usage with Provider (Recommended)
class Example1BasicUsage extends ConsumerWidget {
  const Example1BasicUsage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multilingualState = ref.watch(multilingualAssistantProvider);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            // Process a Hindi request with Hindi response
            await ref
                .read(multilingualAssistantProvider.notifier)
                .processRequest(
                  'mera bike start nahi ho raha',
                  selectedLanguage: 'hi',
                );
          },
          child: const Text('Process Hindi Request'),
        ),
        const SizedBox(height: 16),
        // Display response
        multilingualState.when(
          data: (response) {
            if (response == null) {
              return const Text('No response yet');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detected: ${response.detectedLanguage}'),
                Text('Response: ${response.responseText}'),
                Text('Confidence: ${response.confidence}'),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ],
    );
  }
}

/// Example 2: Auto Language Detection
class Example2AutoDetection extends ConsumerWidget {
  const Example2AutoDetection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        // Let AI detect the language automatically
        await ref.read(multilingualAssistantProvider.notifier).processRequest(
              'majha gadi band padli', // Marathi
              selectedLanguage: 'auto', // Auto-detect
            );
      },
      child: const Text('Process with Auto-Detect'),
    );
  }
}

/// Example 3: Direct Service Usage (Without Provider)
class Example3DirectService {
  Future<void> processWithService() async {
    final service = GeminiService();

    try {
      final response = await service.processUserRequest(
        transcript: 'I need a plumber urgently',
        selectedLanguage: 'en',
      );

      print('Detected Language: ${response.detectedLanguage}');
      print('Selected Language: ${response.selectedLanguage}');
      print('Normalized: ${response.normalizedRequest}');
      print('Response: ${response.responseText}');
      print('Confidence: ${response.confidence}');
      print('Needs Clarification: ${response.needsClarification}');
    } catch (e) {
      print('Error: $e');
    }
  }
}

/// Example 4: Handling Different Languages
class Example4MultipleLanguages extends ConsumerStatefulWidget {
  const Example4MultipleLanguages({super.key});

  @override
  ConsumerState<Example4MultipleLanguages> createState() =>
      _Example4MultipleLanguagesState();
}

class _Example4MultipleLanguagesState
    extends ConsumerState<Example4MultipleLanguages> {
  final TextEditingController _controller = TextEditingController();
  String _selectedLanguage = 'auto';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processRequest() async {
    await ref.read(multilingualAssistantProvider.notifier).processRequest(
          _controller.text,
          selectedLanguage: _selectedLanguage,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Language selector
        DropdownButton<String>(
          value: _selectedLanguage,
          items: const [
            DropdownMenuItem(value: 'auto', child: Text('Auto Detect')),
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'hi', child: Text('Hindi')),
            DropdownMenuItem(value: 'mr', child: Text('Marathi')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedLanguage = value);
            }
          },
        ),
        // Input field
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Enter your request...',
          ),
        ),
        // Process button
        ElevatedButton(
          onPressed: _processRequest,
          child: const Text('Process'),
        ),
      ],
    );
  }
}

/// Example 5: Handling Low Confidence Responses
class Example5ConfidenceHandling extends ConsumerWidget {
  const Example5ConfidenceHandling({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multilingualState = ref.watch(multilingualAssistantProvider);

    return multilingualState.when(
      data: (response) {
        if (response == null) return const SizedBox();

        // Check confidence level
        if (response.confidence < 0.5) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Colors.red),
                  const Text('Low confidence response'),
                  Text('Confidence: ${response.confidence}'),
                  if (response.needsClarification)
                    const Text('AI needs more information'),
                ],
              ),
            ),
          );
        } else if (response.confidence < 0.7) {
          return Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.info, color: Colors.orange),
                  const Text('Medium confidence response'),
                  Text(response.responseText),
                ],
              ),
            ),
          );
        } else {
          return Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const Text('High confidence response'),
                  Text(response.responseText),
                ],
              ),
            ),
          );
        }
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

/// Example 6: Voice Input Integration
class Example6VoiceIntegration extends ConsumerWidget {
  const Example6VoiceIntegration({super.key});

  void _processVoiceInput(WidgetRef ref, String transcript) async {
    // Process the voice transcript with auto language detection
    await ref.read(multilingualAssistantProvider.notifier).processRequest(
          transcript,
          selectedLanguage: 'auto',
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () {
        // Simulate voice input
        // In real app, this would come from speech_to_text package
        final voiceTranscript = 'मुझे plumber चाहिए';
        _processVoiceInput(ref, voiceTranscript);
      },
      icon: const Icon(Icons.mic),
      label: const Text('Start Voice Input'),
    );
  }
}

/// Example 7: Batch Processing Multiple Requests
class Example7BatchProcessing {
  Future<void> processBatch() async {
    final service = GeminiService();
    final requests = [
      'mera bike kharab ho gaya',
      'I need a plumber',
      'majha gadi band padli',
    ];

    for (final request in requests) {
      try {
        final response = await service.processUserRequest(
          transcript: request,
          selectedLanguage: 'auto',
        );
        print('Request: $request');
        print('Response: ${response.responseText}');
        print('---');
      } catch (e) {
        print('Error processing "$request": $e');
      }
    }
  }
}

/// Example 8: Error Handling
class Example8ErrorHandling extends ConsumerWidget {
  const Example8ErrorHandling({super.key});

  Future<void> _processWithErrorHandling(WidgetRef ref, BuildContext context) async {
    try {
      await ref.read(multilingualAssistantProvider.notifier).processRequest(
            'test request',
            selectedLanguage: 'en',
          );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _processWithErrorHandling(ref, context),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _processWithErrorHandling(ref, context),
      child: const Text('Process with Error Handling'),
    );
  }
}

/// Example 9: Translation Between Languages
class Example9Translation extends ConsumerWidget {
  const Example9Translation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            // User speaks in Hindi, but wants response in English
            await ref
                .read(multilingualAssistantProvider.notifier)
                .processRequest(
                  'mera bike start nahi ho raha', // Hindi input
                  selectedLanguage: 'en', // English output
                );
          },
          child: const Text('Hindi → English'),
        ),
        ElevatedButton(
          onPressed: () async {
            // User speaks in English, but wants response in Hindi
            await ref
                .read(multilingualAssistantProvider.notifier)
                .processRequest(
                  'My bike is not starting', // English input
                  selectedLanguage: 'hi', // Hindi output
                );
          },
          child: const Text('English → Hindi'),
        ),
      ],
    );
  }
}

/// Example 10: Custom Response Handler
class Example10CustomHandler extends ConsumerWidget {
  const Example10CustomHandler({super.key});

  void _handleResponse(MultilingualResponse response, BuildContext context) {
    // Custom logic based on response
    if (response.needsClarification) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Need More Information'),
          content: Text(response.responseText),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else if (response.normalizedRequest.toLowerCase().contains('urgent')) {
      // Handle urgent requests
      _handleUrgentRequest(context, response);
    } else {
      // Normal flow
      _showNormalResponse(context, response);
    }
  }

  void _handleUrgentRequest(BuildContext context, MultilingualResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Urgent Request Detected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(response.responseText),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Find Help Now'),
          ),
        ],
      ),
    );
  }

  void _showNormalResponse(BuildContext context, MultilingualResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.responseText)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multilingualState = ref.watch(multilingualAssistantProvider);

    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await ref
                .read(multilingualAssistantProvider.notifier)
                .processRequest(
                  'urgent help needed for water leakage',
                  selectedLanguage: 'en',
                );
          },
          child: const Text('Send Request'),
        ),
        multilingualState.whenData((response) {
          if (response != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleResponse(response, context);
            });
          }
          return const SizedBox();
        }),
      ],
    );
  }
}
