import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/ai/ai_providers.dart';
import '../../../core/ai/gemini_service.dart';

class MultilingualDemoScreen extends ConsumerStatefulWidget {
  const MultilingualDemoScreen({super.key});

  @override
  ConsumerState<MultilingualDemoScreen> createState() =>
      _MultilingualDemoScreenState();
}

class _MultilingualDemoScreenState
    extends ConsumerState<MultilingualDemoScreen> {
  final TextEditingController _textController = TextEditingController();
  String _selectedLanguage = 'auto';

  final List<Map<String, String>> _exampleInputs = [
    {'text': 'mera bike start nahi ho raha', 'lang': 'hi'},
    {'text': 'I need a plumber for a leaking tap', 'lang': 'en'},
    {'text': 'majha gadi band padli', 'lang': 'mr'},
    {'text': 'electric wire kharab ho gaya hai', 'lang': 'hi'},
    {'text': 'पानी का नल ठीक करवाना है', 'lang': 'hi'},
    {'text': 'गाडी दुरुस्त करायची आहे', 'lang': 'mr'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _processRequest() async {
    final transcript = _textController.text.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter some text')));
      return;
    }

    await ref
        .read(multilingualAssistantProvider.notifier)
        .processRequest(transcript, selectedLanguage: _selectedLanguage);
  }

  void _openVoiceInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _VoiceListeningPanel(
        onTranscriptComplete: (transcript) {
          Navigator.of(context).pop();
          _textController.text = transcript;
          _processRequest();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final multilingualState = ref.watch(multilingualAssistantProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Multilingual AI Demo'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLanguageSelector(theme),
            const SizedBox(height: 24),
            _buildInputSection(theme),
            const SizedBox(height: 24),
            _buildExamplesSection(theme),
            const SizedBox(height: 24),
            _buildResponseSection(theme, multilingualState),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Auto Detect'),
                  selected: _selectedLanguage == 'auto',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLanguage = 'auto');
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('English'),
                  selected: _selectedLanguage == 'en',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLanguage = 'en');
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('हिंदी'),
                  selected: _selectedLanguage == 'hi',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLanguage = 'hi');
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('मराठी'),
                  selected: _selectedLanguage == 'mr',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedLanguage = 'mr');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Input',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type or speak your request...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _processRequest,
                    icon: const Icon(Icons.send),
                    label: const Text('Process Request'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _openVoiceInput,
                  icon: const Icon(Icons.mic),
                  label: const Text('Voice'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Example Inputs',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _exampleInputs.map((example) {
                return ActionChip(
                  label: Text(
                    example['text']!,
                    style: const TextStyle(fontSize: 12),
                  ),
                  onPressed: () {
                    _textController.text = example['text']!;
                    _processRequest();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseSection(
    ThemeData theme,
    AsyncValue<MultilingualResponse?> state,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Response',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.value != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      final response = state.value!;
                      final jsonText =
                          '''
{
  "detected_language": "${response.detectedLanguage}",
  "selected_language": "${response.selectedLanguage}",
  "normalized_request": "${response.normalizedRequest}",
  "response_text": "${response.responseText}",
  "confidence": ${response.confidence},
  "needs_clarification": ${response.needsClarification}
}''';
                      Clipboard.setData(ClipboardData(text: jsonText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('JSON copied to clipboard'),
                        ),
                      );
                    },
                    tooltip: 'Copy JSON',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            state.when(
              data: (response) {
                if (response == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Enter a request to see AI response',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  );
                }
                return _buildResponseDetails(theme, response);
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error: ${error.toString()}',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseDetails(ThemeData theme, MultilingualResponse response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(theme, 'Detected Language', response.detectedLanguage),
        const Divider(),
        _buildInfoRow(theme, 'Selected Language', response.selectedLanguage),
        const Divider(),
        _buildInfoRow(theme, 'Normalized Request', response.normalizedRequest),
        const Divider(),
        _buildResponseTextRow(theme, response.responseText),
        const Divider(),
        _buildInfoRow(
          theme,
          'Confidence',
          '${(response.confidence * 100).toStringAsFixed(1)}%',
          valueColor: response.confidence >= 0.7
              ? Colors.green
              : response.confidence >= 0.5
              ? Colors.orange
              : Colors.red,
        ),
        const Divider(),
        _buildInfoRow(
          theme,
          'Needs Clarification',
          response.needsClarification ? 'Yes' : 'No',
          valueColor: response.needsClarification
              ? Colors.orange
              : Colors.green,
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTextRow(ThemeData theme, String responseText) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Response Text',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            responseText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Voice Listening Panel
class _VoiceListeningPanel extends StatefulWidget {
  final Function(String) onTranscriptComplete;

  const _VoiceListeningPanel({required this.onTranscriptComplete});

  @override
  State<_VoiceListeningPanel> createState() => _VoiceListeningPanelState();
}

class _VoiceListeningPanelState extends State<_VoiceListeningPanel> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcript = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onError: (error) => setState(() => _error = error.errorMsg),
        onStatus: (status) {
          if (status == 'done' && _transcript.isNotEmpty) {
            widget.onTranscriptComplete(_transcript);
          }
        },
      );

      if (available && mounted) {
        _startListening();
      } else if (mounted) {
        setState(() => _error = 'Speech recognition not available');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  void _startListening() async {
    if (!_speech.isAvailable) return;

    setState(() {
      _isListening = true;
      _transcript = '';
      _error = null;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcript = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
    if (_transcript.isNotEmpty) {
      widget.onTranscriptComplete(_transcript);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  )
                else ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : theme.colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 80,
                      color: _isListening
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _isListening ? 'Listening...' : 'Initializing...',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (_transcript.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _transcript,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                if (_isListening)
                  ElevatedButton(
                    onPressed: _stopListening,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text('Done'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
