# Multilingual AI Assistant Documentation

## Overview

The Multilingual AI Assistant is a voice-first, language-agnostic component that understands and responds to user requests in multiple languages for the Neara hyperlocal service platform.

## Supported Languages

- **English (en)**
- **Hindi (hi)** - हिंदी
- **Marathi (mr)** - मराठी
- **Auto Detection (auto)** - Automatically detects the user's language

## Core Features

### 1. Language Detection & Selection
- Automatically detects the language when set to "auto"
- Supports explicit language selection (en, hi, mr)
- Falls back to English for unsupported languages

### 2. Multilingual Understanding
The AI understands:
- **Code-mixed languages** (Hinglish, Manglish)
- **Spelling errors** from speech-to-text
- **Incomplete sentences**
- **Regional pronunciation variations**

### 3. Smart Normalization
Converts spoken language into standardized request format:
```dart
Input: "mera bike start nahi ho raha"
Output: "Bike not starting"
```

### 4. Translation Logic
- Understands the original request in any supported language
- Translates internally if needed
- **Always responds in the selected language**

## Architecture

### File Structure
```
lib/
├── core/
│   └── ai/
│       ├── gemini_service.dart         # Core AI service
│       └── ai_providers.dart           # Riverpod providers
└── features/
    └── multilingual/
        └── presentation/
            └── multilingual_demo_screen.dart  # Demo UI
```

### Key Components

#### 1. `MultilingualResponse` Class
```dart
class MultilingualResponse {
  final String detectedLanguage;     // Language detected in user input
  final String selectedLanguage;     // Language for AI response
  final String normalizedRequest;    // Clean, standardized request
  final String responseText;         // AI response in selected language
  final double confidence;           // Confidence score (0.0 - 1.0)
  final bool needsClarification;     // Whether AI needs more info
}
```

#### 2. `GeminiService.processUserRequest()`
Main method that processes multilingual requests:

```dart
Future<MultilingualResponse> processUserRequest({
  required String transcript,
  String selectedLanguage = 'auto',
})
```

**Parameters:**
- `transcript` - User's spoken/typed input
- `selectedLanguage` - Target response language ('en', 'hi', 'mr', or 'auto')

**Returns:** `MultilingualResponse` with all processed data

#### 3. `MultilingualController` Provider
Riverpod state management for multilingual processing:

```dart
final multilingualAssistantProvider = StateNotifierProvider<
  MultilingualController,
  AsyncValue<MultilingualResponse?>
>((ref) => MultilingualController(ref));
```

## Usage Examples

### Basic Usage in Widget

```dart
class MyScreen extends ConsumerWidget {
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
                  'मेरा bike खराब हो गया',
                  selectedLanguage: 'hi',
                );
          },
          child: Text('Process Request'),
        ),
        multilingualState.when(
          data: (response) => Text(response?.responseText ?? ''),
          loading: () => CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }
}
```

### Direct Service Usage

```dart
final service = GeminiService();

final response = await service.processUserRequest(
  transcript: 'My bike is not starting',
  selectedLanguage: 'hi',
);

print('Detected: ${response.detectedLanguage}');
print('Response: ${response.responseText}'); // Response in Hindi
```

## Testing

### Running Tests

```bash
cd app
flutter test test/verify_multilingual.dart
```

### Test Cases
The test suite covers:
- Hindi request with Hindi response
- English request with English response
- Marathi request with auto-detection
- Mixed-language (Hinglish) requests
- Error handling and edge cases

### Manual Testing via Demo Screen

1. Run the app: `flutter run`
2. Open the drawer menu
3. Select "Multilingual AI Demo"
4. Test different scenarios:
   - Select language (en/hi/mr/auto)
   - Type or speak your request
   - View the JSON response

## Example Requests

### Hindi Examples
```
"मेरा baike start nahi ho रहा"
"plumber chahiye, pipe leak ho raha hai"
"electric wire kharab ho गया hai"
```

### Marathi Examples
```
"majha gadi band padli"
"पाणी गळत आहे, plumber पाहिजे"
"वीज गेली आहे"
```

### English Examples
```
"I need a plumber for a leaking tap"
"My car broke down near me"
"Water pipe burst in bathroom"
```

## Response Format

The AI returns a JSON structure:

```json
{
  "detected_language": "hi",
  "selected_language": "hi",
  "normalized_request": "Bike not starting",
  "response_text": "मैं आपकी मदद कर सकता हूं। आपकी बाइक स्टार्ट नहीं हो रही है। मैं आपके लिए एक मैकेनिक खोज रहा हूं।",
  "confidence": 0.92,
  "needs_clarification": false
}
```

## Response Confidence Levels

- **≥ 0.7** - High confidence (Green)
- **0.5 - 0.7** - Medium confidence (Orange)
- **< 0.5** - Low confidence (Red)

## Error Handling

### Common Errors

1. **API Key Missing**
```dart
// Ensure .env file has GEMINI_API_KEY
GEMINI_API_KEY=your_api_key_here
```

2. **Timeout**
```dart
try {
  await processRequest(...);
} catch (e) {
  if (e.toString().contains('timeout')) {
    // Handle timeout
  }
}
```

3. **Network Error**
```dart
multilingualState.when(
  data: (response) => ...,
  loading: () => ...,
  error: (error, stack) {
    // Handle network errors
    return Text('Error: ${error.toString()}');
  },
)
```

## Best Practices

### 1. Always Handle Loading States
```dart
multilingualState.when(
  data: (response) => response != null 
      ? Text(response.responseText) 
      : Text('Enter a request'),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
)
```

### 2. Validate Confidence Scores
```dart
if (response.confidence < 0.6) {
  // Show warning or ask for clarification
  showWarning('Low confidence. Please provide more details.');
}
```

### 3. Handle Clarification Needs
```dart
if (response.needsClarification) {
  // Ask user for more information
  askForClarification(response.responseText);
}
```

### 4. Use Language Codes Consistently
```dart
const validLanguages = ['en', 'hi', 'mr', 'auto'];

void setLanguage(String lang) {
  if (validLanguages.contains(lang)) {
    selectedLanguage = lang;
  }
}
```

## Performance Considerations

### 1. Timeout Configuration
Default timeout is 10 seconds. Adjust if needed:

```dart
// In gemini_service.dart
final response = await _model
    .generateContent([Content.text(prompt.toString())])
    .timeout(const Duration(seconds: 15)); // Increased for slower networks
```

### 2. Caching
Consider caching common requests:

```dart
final _cache = <String, MultilingualResponse>{};

Future<MultilingualResponse> processWithCache(String transcript) async {
  if (_cache.containsKey(transcript)) {
    return _cache[transcript]!;
  }
  final response = await processUserRequest(transcript: transcript);
  _cache[transcript] = response;
  return response;
}
```

## Integration with Other Features

### Voice-to-Text Integration
```dart
// Voice input flows directly to multilingual processor
void onVoiceComplete(String transcript) async {
  await ref
      .read(multilingualAssistantProvider.notifier)
      .processRequest(transcript, selectedLanguage: 'auto');
}
```

### Service Discovery Integration
```dart
// Use normalized_request for service categorization
if (response.normalizedRequest.contains('plumber')) {
  navigateToServiceCategory(ServiceCategory.plumber);
}
```

## API Reference

### GeminiService

#### Methods

**processUserRequest**
```dart
Future<MultilingualResponse> processUserRequest({
  required String transcript,
  String selectedLanguage = 'auto',
})
```

Processes a user request in any supported language.

**Parameters:**
- `transcript` (String, required): The user's input text
- `selectedLanguage` (String, optional): Target response language
  - Default: 'auto'
  - Valid values: 'en', 'hi', 'mr', 'auto'

**Returns:** `Future<MultilingualResponse>`

**Throws:** 
- `TimeoutException` if request takes > 10 seconds
- `Exception` for API errors

### MultilingualController

#### Methods

**processRequest**
```dart
Future<void> processRequest(
  String transcript, {
  String selectedLanguage = 'auto',
})
```

State-managed version that updates provider state.

## Configuration

### Environment Variables
Required in `.env` file:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### Model Configuration
Currently using: `gemini-2.5-flash`

To change model:
```dart
// In gemini_service.dart
GenerativeModel(
  model: 'gemini-pro', // Change model here
  apiKey: kGeminiApiKey,
)
```

## Troubleshooting

### Issue: Hindi/Marathi text not displaying
**Solution:** Ensure your app supports UTF-8 and includes appropriate fonts.

### Issue: Low confidence scores
**Solution:** 
- Check if input is clear and complete
- Verify the language is supported
- Consider asking for clarification

### Issue: Timeout errors
**Solution:**
- Check internet connection
- Increase timeout duration
- Verify API key is valid

### Issue: Wrong language detection
**Solution:**
- Use explicit language selection instead of 'auto'
- Ensure input text has enough context

## Future Enhancements

- [ ] Support for more Indian languages (Tamil, Telugu, Bengali)
- [ ] Voice output (text-to-speech) in native languages
- [ ] Context-aware conversations (multi-turn dialogue)
- [ ] Offline mode with cached responses
- [ ] Custom language models for domain-specific vocabulary

## Support

For issues or questions:
1. Check existing error logs in the console
2. Review the test files for usage examples
3. Verify API key and network connectivity
4. Check Gemini API status

## Version History

### v1.0.0 (Current)
- Initial implementation
- Support for English, Hindi, Marathi
- Auto language detection
- Demo UI screen
- Test suite

---

**Built with:** Google Gemini AI, Flutter, Riverpod
**License:** [Your License]
**Last Updated:** February 2026
