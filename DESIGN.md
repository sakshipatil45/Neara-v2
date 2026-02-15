# Neara - Technical Design Document

**Version:** 1.0.0  
**Last Updated:** February 15, 2026  
**Project:** Neara - AI-Powered Local Service Matching Platform  
**Document Type:** Technical Design Document (TDD)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Frontend Architecture (Flutter)](#3-frontend-architecture-flutter)
4. [AI Layer Design (OpenRouter Integration)](#4-ai-layer-design-openrouter-integration)
5. [State Management Architecture](#5-state-management-architecture)
6. [Data Models & Domain Logic](#6-data-models--domain-logic)
7. [Fallback & Resilience Mechanisms](#7-fallback--resilience-mechanisms)
8. [Backend Architecture (Future)](#8-backend-architecture-future)
9. [API Design](#9-api-design)
10. [Security Architecture](#10-security-architecture)
11. [Performance Optimization](#11-performance-optimization)
12. [Testing Strategy](#12-testing-strategy)
13. [Deployment Architecture](#13-deployment-architecture)
14. [Monitoring & Observability](#14-monitoring--observability)

---

## 1. Executive Summary

### 1.1 Purpose

This document provides a comprehensive technical design for Neara, an AI-powered mobile application that connects users with local service workers through voice-first interaction and intelligent matching.

### 1.2 Key Design Principles

- **Voice-First:** Prioritize voice interaction with seamless text fallback
- **AI-Driven:** Leverage OpenRouter API for intent understanding and worker matching
- **Resilient:** Implement robust fallback mechanisms for offline/degraded scenarios
- **Scalable:** Design for growth from MVP to production-scale platform
- **Maintainable:** Clean architecture with clear separation of concerns
- **Secure:** Privacy-first approach with data encryption and secure API communication

### 1.3 Technology Stack Summary

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| Mobile Framework | Flutter | 3.9.2+ | Cross-platform UI |
| Language | Dart | 3.0+ | Application logic |
| State Management | Riverpod | 2.5.1+ | Reactive state |
| AI/LLM | OpenRouter API | v1 | Intent extraction & matching |
| Speech Recognition | speech_to_text | 7.3.0+ | Voice input |
| Location Services | Geolocator | 13.0.1+ | GPS positioning |
| Maps | Google Maps Flutter | 2.9.0+ | Map visualization |
| HTTP Client | http | 1.2.0+ | API communication |
| Environment Config | flutter_dotenv | 5.1.0+ | Secure configuration |


---

## 2. System Architecture Overview

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER DEVICE                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    FLUTTER APPLICATION                     │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐   │  │
│  │  │ Presentation│  │   Domain    │  │      Data       │   │  │
│  │  │    Layer    │  │    Layer    │  │     Layer       │   │  │
│  │  │             │  │             │  │                 │   │  │
│  │  │  - Screens  │  │  - Use Cases│  │  - Repositories │   │  │
│  │  │  - Widgets  │  │  - Entities │  │  - Data Sources │   │  │
│  │  │  - UI Logic │  │  - Services │  │  - Models       │   │  │
│  │  └─────────────┘  └─────────────┘  └─────────────────┘   │  │
│  │                                                             │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │              CORE INFRASTRUCTURE                     │  │  │
│  │  │  - State Management (Riverpod)                       │  │  │
│  │  │  - Routing & Navigation                              │  │  │
│  │  │  - Theme & Design System                             │  │  │
│  │  │  - Error Handling & Logging                          │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTPS/TLS
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EXTERNAL SERVICES                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  OpenRouter  │  │ Google Maps  │  │  Device Services     │  │
│  │     API      │  │     API      │  │  - GPS/Location      │  │
│  │              │  │              │  │  - Microphone        │  │
│  │  - GPT-4o    │  │  - Geocoding │  │  - Speech-to-Text    │  │
│  │  - Claude    │  │  - Directions│  │  - Permissions       │  │
│  │  - Mistral   │  │  - Places    │  │                      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ (Future)
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND SERVICES (Future)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   REST API   │  │   Database   │  │   External Services  │  │
│  │              │  │              │  │                      │  │
│  │  - Auth      │  │  PostgreSQL  │  │  - Firebase (FCM)    │  │
│  │  - Workers   │  │  - Redis     │  │  - Payment Gateway   │  │
│  │  - Requests  │  │  - S3/GCS    │  │  - SMS Provider      │  │
│  │  - Payments  │  │              │  │                      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Architecture Patterns

#### 2.2.1 Clean Architecture (Modified)

The application follows a simplified Clean Architecture approach:

- **Presentation Layer:** UI components, screens, widgets
- **Domain Layer:** Business logic, use cases, entities
- **Data Layer:** Data sources, repositories, API clients
- **Core Layer:** Shared utilities, theme, constants

#### 2.2.2 MVVM Pattern

- **Model:** Data models and business entities
- **View:** Flutter widgets and screens
- **ViewModel:** Riverpod providers managing state and business logic

### 2.3 Directory Structure

```
lib/
├── main.dart                          # Application entry point
├── core/                              # Core infrastructure
│   ├── ai/                            # AI service layer
│   │   ├── gemini_service.dart        # OpenRouter API client
│   │   └── ai_providers.dart          # AI state providers
│   ├── controllers/                   # Global controllers
│   ├── enums/                         # Application enums
│   │   └── service_category.dart      # Service type definitions
│   ├── theme/                         # Design system
│   │   └── app_theme.dart             # Theme configuration
│   └── utils/                         # Utility functions
├── features/                          # Feature modules
│   ├── voice_agent/                   # Voice interaction feature
│   │   ├── data/                      # Data layer
│   │   ├── domain/                    # Business logic
│   │   └── presentation/              # UI layer
│   │       └── voice_agent_screen.dart
│   ├── discovery/                     # Worker discovery feature
│   │   ├── data/
│   │   │   ├── worker_models.dart     # Worker data models
│   │   │   └── worker_providers.dart  # Worker state management
│   │   └── presentation/
│   │       └── worker_discovery_screen.dart
│   ├── multilingual/                  # Multilingual support
│   │   └── presentation/
│   │       └── multilingual_demo_screen.dart
│   └── analysis/                      # Analytics feature
└── shared/                            # Shared components
    └── widgets/                       # Reusable widgets
        ├── app_drawer.dart
        └── ...
```


---

## 3. Frontend Architecture (Flutter)

### 3.1 Presentation Layer Design

#### 3.1.1 Screen Architecture

Each screen follows a consistent structure:

```dart
// Screen Widget (Stateless/Stateful)
class VoiceAgentScreen extends ConsumerStatefulWidget {
  // UI rendering and user interaction
}

// State Management via Riverpod Providers
final voiceStateProvider = StateNotifierProvider<VoiceController, VoiceState>(...);

// Business Logic in Controllers
class VoiceController extends StateNotifier<VoiceState> {
  // Handle voice input, AI processing, state updates
}
```

#### 3.1.2 Key Screens

**Voice Agent Screen (Home)**
- Purpose: Primary entry point for voice/text input
- Components:
  - Floating app bar with greeting
  - Central microphone button with animation
  - Live transcription display
  - AI extraction panel (real-time updates)
  - Quick action cards
  - Bottom text input bar
- State Management: `voiceStateProvider`, `emergencyInterpretationProvider`

**Worker Discovery Screen**
- Purpose: Display and filter matched workers
- Components:
  - Filter panel (collapsible)
  - Worker card list
  - Sort controls
  - Empty state handling
- State Management: `workerServiceProvider`, `searchFiltersProvider`

**Multilingual Demo Screen**
- Purpose: Demonstrate multilingual AI capabilities
- Components:
  - Language selector
  - Voice/text input
  - AI response display
- State Management: `multilingualAssistantProvider`

### 3.2 Widget Architecture

#### 3.2.1 Widget Hierarchy

```
MaterialApp
└── _RootShell (Scaffold with Drawer)
    └── IndexedStack
        ├── VoiceAgentScreen
        │   ├── FloatingAppBar
        │   ├── MicrophoneButton (Animated)
        │   ├── TranscriptionDisplay
        │   ├── AIExtractionPanel
        │   ├── QuickActionCards
        │   └── TextInputBar
        ├── WorkerDiscoveryScreen
        │   ├── FilterPanel
        │   ├── WorkerCardList
        │   │   └── WorkerCard (repeated)
        │   └── EmptyState
        └── MultilingualDemoScreen
            ├── LanguageSelector
            ├── InputSection
            └── ResponseDisplay
```

#### 3.2.2 Reusable Components

**Shared Widgets:**
- `AppDrawer`: Navigation drawer
- `GlassMorphicCard`: Card with frosted glass effect
- `AnimatedMicButton`: Pulsing microphone button
- `WorkerCard`: Worker information display
- `FilterChip`: Filter selection chip
- `EmptyStateWidget`: No results placeholder

### 3.3 Navigation Architecture

#### 3.3.1 Navigation Strategy

Current: **IndexedStack** for tab-like navigation
- Maintains state across screen switches
- Fast switching without rebuilding
- Suitable for MVP with 3 main screens

Future: **Named Routes** with deep linking
- Support for complex navigation flows
- Deep linking for notifications
- Better separation of concerns

#### 3.3.2 Navigation Flow

```
Voice Agent (Home)
    │
    ├─→ Worker Discovery (via AI confirmation)
    │       │
    │       └─→ Worker Profile (future)
    │               │
    │               └─→ Request Confirmation (future)
    │
    ├─→ Browse Services (quick action)
    │       └─→ Worker Discovery
    │
    └─→ My Requests (future)
            └─→ Request Details (future)
```

### 3.4 Theme & Design System

#### 3.4.1 Theme Configuration

```dart
// app_theme.dart
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF4F46E5),      // Indigo
      secondary: Color(0xFFEC4899),    // Pink
      tertiary: Color(0xFFFBBF24),     // Yellow
      surface: Color(0xFF1F2937),      // Dark gray
      background: Color(0xFF0F172A),   // Darker slate
    ),
    // ... additional theme properties
  );
}
```

#### 3.4.2 Design Tokens

**Colors:**
```dart
class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const secondary = Color(0xFFEC4899);
  static const tertiary = Color(0xFFFBBF24);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  
  static const backgroundStart = Color(0xFF0F172A);
  static const backgroundEnd = Color(0xFF020617);
  static const cardBackground = Color(0xFF1F2937);
  static const border = Color(0xFF334155);
  
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9CA3AF);
}
```

**Spacing:**
```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}
```

**Typography:**
```dart
class AppTypography {
  static const h1 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
  static const h2 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const h3 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const caption = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const small = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);
}
```


---

## 4. AI Layer Design (OpenRouter Integration)

### 4.1 OpenRouter API Architecture

#### 4.1.1 Service Design

```dart
class GeminiService {
  // Configuration
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String _primaryModel = 'openai/gpt-4o-mini';
  static const String _fallbackModel = 'mistralai/mistral-7b-instruct';
  static const Duration _timeout = Duration(seconds: 10);
  
  // HTTP Client (injectable for testing)
  final http.Client _httpClient;
  
  // Core API call method
  Future<String> _callOpenRouter({
    required String systemPrompt,
    required String userMessage,
    String? model,
    int retryCount = 0,
  }) async {
    // Implementation with retry logic
  }
}
```

#### 4.1.2 API Request Structure

```json
{
  "model": "openai/gpt-4o-mini",
  "messages": [
    {
      "role": "system",
      "content": "You are an AI assistant for..."
    },
    {
      "role": "user",
      "content": "User's request or transcript"
    }
  ],
  "temperature": 0.3
}
```

#### 4.1.3 API Response Structure

```json
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "{\"service_type\": \"plumber\", ...}"
      }
    }
  ],
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 50,
    "total_tokens": 200
  }
}
```

### 4.2 AI Use Cases

#### 4.2.1 Emergency Intent Interpretation

**Purpose:** Extract structured information from natural language

**Input:**
- User transcript (voice or text)
- GPS coordinates (optional)

**Output:**
```dart
class EmergencyInterpretation {
  final String issueSummary;           // "Pipe burst in bathroom"
  final EmergencyUrgency urgency;      // critical, high, medium, low
  final String locationHint;           // "NH4 near City Center"
  final ServiceCategory serviceCategory; // plumber, electrician, etc.
  final String reason;                 // AI's reasoning
  final double confidence;             // 0.0 - 1.0
  final List<String> riskFactors;      // ["water damage", "flooding"]
  final bool needsClarification;       // true if ambiguous
}
```

**Prompt Engineering Strategy:**

```dart
final systemPrompt = '''
You are an advanced AI risk assessment assistant for a home services platform.

Your job is to analyze user service requests and determine:
1. Service type (mechanic, plumber, electrician, maid, roadside assistance, gas service, other)
2. Urgency level (CRITICAL, HIGH, MEDIUM, LOW)
3. Risk factors involved
4. Confidence score (0.0 - 1.0)
5. Whether clarification is required

Context Considerations:
A. Environmental Context
   - Time of day (night increases risk)
   - Location type (highway, rural, isolated areas)
   - Weather conditions if mentioned
   
B. Vulnerability Context
   - User alone
   - Children or elderly present
   - Medical condition mentioned
   
C. Hazard Context
   - Fire risk
   - Gas leakage
   - Electrical short circuit
   - Structural damage
   
D. Severity Context
   - Immediate threat vs inconvenience
   - Potential for escalation

Urgency Classification:
- CRITICAL: Immediate threat to life or major safety hazard
- HIGH: Serious issue with possible safety consequences
- MEDIUM: Repair needed soon but no safety danger
- LOW: Routine or non-urgent request

Respond strictly in JSON format:
{
  "service_type": "...",
  "urgency_level": "...",
  "issue_summary": "...",
  "risk_factors": [...],
  "reason": "...",
  "confidence": 0.0,
  "needs_clarification": false
}
''';
```

**Confidence Thresholds:**
- `>= 0.85`: High confidence - auto-proceed
- `0.65 - 0.84`: Medium confidence - show confirmation
- `< 0.65`: Low confidence - use fallback or ask clarification


#### 4.2.2 Worker Ranking & Matching

**Purpose:** Intelligently rank workers based on context

**Input:**
- Emergency interpretation
- List of candidate workers
- User location

**Output:**
```dart
class WorkerRanking {
  final String workerId;
  final int score;                      // 0-100
  final String reason;                  // AI's reasoning
  final String recommendationLevel;     // PRIMARY, SECONDARY, STANDARD
  final bool highlightMarker;           // true for top match
  final String? badgeLabel;             // "Smart Match", "Best Rated", etc.
  final Worker? worker;                 // Populated worker object
}
```

**Ranking Criteria:**

```dart
final systemPrompt = '''
You are an AI-powered worker matching engine.

Evaluate workers using contextual reasoning:

1. Skill Match
   - Exact skill match for the issue
   - Related skills and experience
   - Specialization relevance

2. Urgency Alignment
   - Response time for urgent requests
   - Availability status
   - Historical responsiveness

3. Quality Indicators
   - Rating and review sentiment
   - Completed jobs count
   - Verification status

4. Proximity
   - Distance from user
   - Service area coverage
   - Travel time estimation

5. Contextual Factors
   - Time of day (24/7 availability)
   - Weather conditions
   - Worker's current load

Output Format:
{
  "ranking_strategy_summary": "...",
  "recommended_worker_id": "...",
  "ranked_workers": [
    {
      "worker_id": "...",
      "ranking_score": 0-100,
      "recommendation_level": "PRIMARY|SECONDARY|STANDARD",
      "highlight_marker": true,
      "badge_label": "...",
      "reason": "..."
    }
  ]
}

Rules:
- Only ONE worker should have highlight_marker = true
- That worker must be the highest ranked
- Provide clear reasoning for each ranking
''';
```

#### 4.2.3 Multilingual Processing

**Purpose:** Understand and respond in multiple languages

**Supported Languages:**
- English (en)
- Hindi (hi)
- Marathi (mr)
- Future: Tamil, Telugu, Bengali, Gujarati

**Input:**
- User transcript
- Selected language (or "auto" for detection)

**Output:**
```dart
class MultilingualResponse {
  final String detectedLanguage;        // "hi", "en", "mr"
  final String selectedLanguage;        // User's preference
  final String normalizedRequest;       // Standardized English intent
  final String serviceType;             // Service category
  final String responseText;            // Response in selected language
  final double confidence;              // 0.0 - 1.0
  final bool needsClarification;        // true if unclear
}
```

**Language Detection Strategy:**

```dart
final systemPrompt = '''
You are a multilingual AI assistant for a voice-first service platform.

Language Selection Priority:
1. If selected_language is provided → ALWAYS respond in that language
2. If selected_language = "auto" → detect user language
3. If detected language is unsupported → default to English

Multilingual Understanding:
- Handle mixed languages (Hinglish, Manglish)
- Tolerate spelling errors
- Handle incomplete sentences
- Correct speech-to-text mistakes
- Understand regional pronunciation variations

Translation Logic:
- Understand original meaning
- Translate internally if needed
- Respond ONLY in selected_language

Response Style:
- Short and clear
- Friendly and conversational
- Voice assistant friendly
- Action oriented

Output Format:
{
  "detected_language": "en|hi|mr",
  "selected_language": "en|hi|mr",
  "service_type": "...",
  "normalized_request": "...",
  "response_text": "...",
  "confidence": 0.0,
  "needs_clarification": false
}
''';
```

### 4.3 Prompt Engineering Best Practices

#### 4.3.1 Prompt Structure

1. **Role Definition:** Clearly define AI's role and purpose
2. **Context Provision:** Provide relevant context and constraints
3. **Task Description:** Explicit instructions on what to do
4. **Output Format:** Strict JSON schema specification
5. **Rules & Constraints:** Edge cases and validation rules
6. **Examples:** Few-shot examples for complex tasks (optional)

#### 4.3.2 JSON Response Parsing

```dart
Map<String, dynamic> _safeDecodeJson(String raw) {
  try {
    // Extract JSON from potential markdown code blocks
    final jsonStart = raw.indexOf('{');
    final jsonEnd = raw.lastIndexOf('}');
    
    if (jsonStart == -1 || jsonEnd == -1) {
      return {};
    }
    
    final json = raw.substring(jsonStart, jsonEnd + 1);
    return Map<String, dynamic>.from(jsonDecode(json) as Map);
  } catch (e) {
    print('JSON parsing error: $e');
    return {};
  }
}
```

#### 4.3.3 Temperature Settings

- **Intent Extraction:** `temperature: 0.3` (deterministic, consistent)
- **Worker Ranking:** `temperature: 0.3` (objective, repeatable)
- **Conversational Responses:** `temperature: 0.7` (natural, varied)

### 4.4 Model Selection Strategy

#### 4.4.1 Primary Model: GPT-4o Mini

**Advantages:**
- High accuracy for intent extraction
- Strong multilingual support
- Fast response times
- Cost-effective for production

**Use Cases:**
- Emergency interpretation
- Worker ranking
- Multilingual processing

#### 4.4.2 Fallback Model: Mistral 7B Instruct

**Advantages:**
- Lower cost
- Good performance for simpler tasks
- Faster response in some cases

**Use Cases:**
- Retry after primary model failure
- Non-critical operations
- Cost optimization

#### 4.4.3 Model Switching Logic

```dart
Future<String> _callOpenRouter({
  required String systemPrompt,
  required String userMessage,
  String? model,
  int retryCount = 0,
}) async {
  final selectedModel = model ?? _primaryModel;
  
  try {
    // Attempt API call
    final response = await _httpClient.post(...);
    
    if (response.statusCode == 200) {
      return extractContent(response);
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  } catch (e) {
    // Retry logic
    if (retryCount == 0 && selectedModel == _primaryModel) {
      // Retry with same model once
      return _callOpenRouter(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        model: selectedModel,
        retryCount: 1,
      );
    } else if (retryCount == 1 && selectedModel == _primaryModel) {
      // Switch to fallback model
      return _callOpenRouter(
        systemPrompt: systemPrompt,
        userMessage: userMessage,
        model: _fallbackModel,
        retryCount: 2,
      );
    }
    
    // All retries exhausted
    rethrow;
  }
}
```


---

## 5. State Management Architecture

### 5.1 Riverpod Provider Hierarchy

#### 5.1.1 Provider Types

**Provider (Immutable):**
```dart
// Service instances (singleton-like)
final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final workerServiceProvider = Provider<WorkerService>((ref) {
  return WorkerService(ref);
});
```

**StateNotifierProvider (Mutable State):**
```dart
// Emergency interpretation state
final emergencyInterpretationProvider = 
  StateNotifierProvider<EmergencyController, AsyncValue<EmergencyInterpretation?>>((ref) {
    return EmergencyController(ref);
  });

// Search filters state
final searchFiltersProvider = 
  StateNotifierProvider<SearchFiltersController, SearchFilters>((ref) {
    return SearchFiltersController(ref);
  });
```

**FutureProvider (Async Data):**
```dart
// Worker list (future implementation)
final workersProvider = FutureProvider<List<Worker>>((ref) async {
  final service = ref.read(workerServiceProvider);
  return service.fetchWorkers();
});
```

**StreamProvider (Real-time Data):**
```dart
// Location updates (future implementation)
final locationStreamProvider = StreamProvider<Position>((ref) {
  return Geolocator.getPositionStream();
});
```

### 5.2 State Flow Architecture

#### 5.2.1 Voice Agent State Flow

```
User Speaks
    │
    ▼
Speech-to-Text (speech_to_text package)
    │
    ▼
Transcript Updated (Local State)
    │
    ▼
AI Processing Triggered (debounced)
    │
    ▼
emergencyInterpretationProvider.interpret(transcript)
    │
    ├─→ Loading State (show spinner)
    │
    ├─→ Success State
    │   │
    │   ├─→ Update UI with extracted details
    │   └─→ Enable "Find Workers" button
    │
    └─→ Error State
        │
        └─→ Show error message + fallback interpretation
```

#### 5.2.2 Worker Discovery State Flow

```
User Confirms Request
    │
    ▼
Navigate to Worker Discovery
    │
    ▼
workerServiceProvider.recommendWorkers(interpretation, allWorkers)
    │
    ├─→ Check Urgency Level
    │   │
    │   ├─→ LOW: Use local fallback ranking
    │   │
    │   └─→ MEDIUM/HIGH/CRITICAL: Attempt AI ranking
    │       │
    │       ├─→ Check Confidence
    │       │   │
    │       │   ├─→ >= 0.65: Call OpenRouter API
    │       │   │   │
    │       │   │   ├─→ Success: Return AI rankings
    │       │   │   │
    │       │   │   └─→ Failure: Fallback to local ranking
    │       │   │
    │       │   └─→ < 0.65: Use local fallback ranking
    │       │
    │       └─→ Display Ranked Workers
    │
    └─→ Apply Filters (searchFiltersProvider)
        │
        └─→ Update Worker List
```

### 5.3 State Persistence

#### 5.3.1 Current Implementation (In-Memory)

```dart
// Mock data stored in memory
final mockWorkersProvider = Provider<List<Worker>>((ref) {
  return [
    Worker(id: 'w1', name: 'Rajesh Kumar', ...),
    Worker(id: 'w2', name: 'Priya Sharma', ...),
    // ... 20+ workers
  ];
});
```

#### 5.3.2 Future Implementation (Local Storage)

```dart
// Using shared_preferences or hive
final userPreferencesProvider = FutureProvider<UserPreferences>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return UserPreferences.fromJson(prefs.getString('user_prefs') ?? '{}');
});

// Cache worker data
final cachedWorkersProvider = FutureProvider<List<Worker>>((ref) async {
  final box = await Hive.openBox<Worker>('workers');
  return box.values.toList();
});
```

### 5.4 Error Handling Strategy

#### 5.4.1 AsyncValue Pattern

```dart
// In UI
ref.watch(emergencyInterpretationProvider).when(
  data: (interpretation) {
    // Show extracted details
    return InterpretationDisplay(interpretation: interpretation);
  },
  loading: () {
    // Show loading indicator
    return CircularProgressIndicator();
  },
  error: (error, stack) {
    // Show error message with retry option
    return ErrorWidget(
      message: 'AI processing failed',
      onRetry: () => ref.refresh(emergencyInterpretationProvider),
    );
  },
);
```

#### 5.4.2 Graceful Degradation

```dart
class EmergencyController extends StateNotifier<AsyncValue<EmergencyInterpretation?>> {
  Future<void> interpret(String transcript) async {
    state = const AsyncValue.loading();
    
    try {
      // Attempt AI interpretation
      final result = await _geminiService.interpretEmergency(...);
      state = AsyncValue.data(result);
    } catch (e, stack) {
      // Log error
      print('AI interpretation failed: $e');
      
      // Use fallback instead of showing error
      final fallback = _getFallbackInterpretation(transcript);
      state = AsyncValue.data(fallback);
      
      // Optionally notify user of degraded mode
      _showDegradedModeNotification();
    }
  }
}
```


---

## 6. Data Models & Domain Logic

### 6.1 Core Domain Models

#### 6.1.1 Service Category Enum

```dart
enum ServiceCategory {
  mechanic,
  plumber,
  electrician,
  maid,
  roadsideAssistance,
  gasService,
  other;
  
  String get displayName {
    switch (this) {
      case ServiceCategory.mechanic:
        return 'Mechanic';
      case ServiceCategory.plumber:
        return 'Plumber';
      case ServiceCategory.electrician:
        return 'Electrician';
      case ServiceCategory.maid:
        return 'Cleaner/Maid';
      case ServiceCategory.roadsideAssistance:
        return 'Roadside Assistance';
      case ServiceCategory.gasService:
        return 'Gas Service';
      case ServiceCategory.other:
        return 'Other';
    }
  }
  
  IconData get icon {
    // Return appropriate icon for each category
  }
}
```

#### 6.1.2 Worker Model

```dart
class Worker {
  final String id;
  final String name;
  final ServiceCategory primaryCategory;
  final List<String> skills;
  final double rating;
  final int totalJobs;
  final bool verified;
  final bool isAvailable;
  final String? profilePhoto;
  final double latitude;
  final double longitude;
  final int responseTimeMinutes;
  final WorkerStatus status;
  final String? phoneNumber;
  final int experienceYears;
  final Map<String, double>? pricing;
  
  Worker({
    required this.id,
    required this.name,
    required this.primaryCategory,
    required this.skills,
    required this.rating,
    required this.totalJobs,
    required this.verified,
    required this.isAvailable,
    this.profilePhoto,
    required this.latitude,
    required this.longitude,
    required this.responseTimeMinutes,
    required this.status,
    this.phoneNumber,
    required this.experienceYears,
    this.pricing,
  });
  
  // Calculate distance from user
  double distanceFrom(double userLat, double userLng) {
    return Geolocator.distanceBetween(
      userLat, userLng, latitude, longitude
    ) / 1000.0; // Convert to km
  }
  
  // Serialization methods
  factory Worker.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}

enum WorkerStatus {
  available,
  busy,
  offline,
}
```

#### 6.1.3 Service Request Model (Future)

```dart
class ServiceRequest {
  final String id;
  final String userId;
  final String? workerId;
  final ServiceCategory category;
  final String issueSummary;
  final EmergencyUrgency urgency;
  final double latitude;
  final double longitude;
  final String locationHint;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? completedAt;
  final double? price;
  final PaymentStatus? paymentStatus;
  
  ServiceRequest({
    required this.id,
    required this.userId,
    this.workerId,
    required this.category,
    required this.issueSummary,
    required this.urgency,
    required this.latitude,
    required this.longitude,
    required this.locationHint,
    required this.status,
    required this.createdAt,
    this.scheduledFor,
    this.completedAt,
    this.price,
    this.paymentStatus,
  });
  
  factory ServiceRequest.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}

enum RequestStatus {
  pending,
  accepted,
  onTheWay,
  arrived,
  inProgress,
  completed,
  cancelled,
}

enum PaymentStatus {
  pending,
  paid,
  refunded,
}
```

#### 6.1.4 User Model (Future)

```dart
class User {
  final String id;
  final String phoneNumber;
  final String name;
  final String? email;
  final double? latitude;
  final double? longitude;
  final String preferredLanguage;
  final DateTime createdAt;
  final bool isVerified;
  final List<String>? emergencyContacts;
  
  User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.email,
    this.latitude,
    this.longitude,
    required this.preferredLanguage,
    required this.createdAt,
    required this.isVerified,
    this.emergencyContacts,
  });
  
  factory User.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 6.2 Business Logic Layer

#### 6.2.1 Worker Service

```dart
class WorkerService {
  final Ref _ref;
  
  WorkerService(this._ref);
  
  /// Recommend workers based on AI interpretation
  Future<List<WorkerRanking>> recommendWorkers({
    required EmergencyInterpretation interpretation,
    required List<Worker> allWorkers,
  }) async {
    // 1. Filter by service category
    final candidates = _filterByCategory(allWorkers, interpretation.serviceCategory);
    
    // 2. Get user location
    final (lat, lng) = await _getUserLocation();
    
    // 3. Decide ranking strategy
    if (interpretation.urgency == EmergencyUrgency.low) {
      // Use local ranking for low urgency (save API costs)
      return _fallbackRanking(candidates, interpretation, lat, lng);
    }
    
    // 4. Check confidence threshold
    if (interpretation.confidence < 0.65) {
      // Low confidence - use fallback
      return _fallbackRanking(candidates, interpretation, lat, lng, isLowConfidence: true);
    }
    
    // 5. Attempt AI ranking
    try {
      final rankings = await _ref.read(geminiServiceProvider).rankWorkers(
        interpretation: interpretation,
        workersJson: _workersToJson(candidates),
        userLat: lat,
        userLng: lng,
      );
      
      // 6. Merge rankings with worker objects
      return _mergeRankingsWithWorkers(rankings, candidates);
    } catch (e) {
      // 7. Fallback on AI failure
      print('AI ranking failed: $e. Using fallback.');
      return _fallbackRanking(candidates, interpretation, lat, lng, error: e.toString());
    }
  }
  
  /// Local fallback ranking algorithm
  List<WorkerRanking> _fallbackRanking(
    List<Worker> workers,
    EmergencyInterpretation interpretation,
    double? userLat,
    double? userLng, {
    bool isLowConfidence = false,
    String? error,
  }) {
    // Calculate scores for each worker
    final scored = workers.map((w) {
      final score = _calculateFallbackScore(w, interpretation, userLat, userLng);
      return MapEntry(w, score);
    }).toList();
    
    // Sort by score (descending)
    scored.sort((a, b) => b.value.compareTo(a.value));
    
    // Convert to WorkerRanking
    return scored.asMap().entries.map((entry) {
      final index = entry.key;
      final worker = entry.value.key;
      final score = entry.value.value;
      
      return WorkerRanking(
        workerId: worker.id,
        score: score.round(),
        reason: _generateFallbackReason(worker, interpretation, isLowConfidence, error),
        recommendationLevel: index == 0 ? 'PRIMARY' : 'STANDARD',
        highlightMarker: index == 0,
        badgeLabel: index == 0 ? 'Smart Match' : null,
        worker: worker,
      );
    }).toList();
  }
  
  /// Calculate fallback score (0-100)
  double _calculateFallbackScore(
    Worker worker,
    EmergencyInterpretation interpretation,
    double? userLat,
    double? userLng,
  ) {
    double score = 50.0; // Base score
    
    // 1. Skill match (high weight)
    final summary = interpretation.issueSummary.toLowerCase();
    int skillMatches = 0;
    for (var skill in worker.skills) {
      if (summary.contains(skill.toLowerCase())) {
        skillMatches++;
      }
    }
    score += (skillMatches * 10.0);
    
    // 2. Rating (moderate weight)
    score += (worker.rating * 5.0); // Max +25
    
    // 3. Verification (critical for high urgency)
    if (interpretation.urgency == EmergencyUrgency.critical && worker.verified) {
      score += 15.0;
    } else if (worker.verified) {
      score += 5.0;
    }
    
    // 4. Response time (faster = better)
    if (worker.responseTimeMinutes < 60) {
      score += (60 - worker.responseTimeMinutes) * 0.5;
    }
    
    // 5. Distance (closer = better)
    if (userLat != null && userLng != null) {
      final distance = worker.distanceFrom(userLat, userLng);
      score -= (distance * 2.0); // -2 points per km
    }
    
    // 6. Availability
    if (worker.isAvailable) {
      score += 10.0;
    }
    
    return score.clamp(0.0, 100.0);
  }
}
```


---

## 7. Fallback & Resilience Mechanisms

### 7.1 Multi-Layer Fallback Strategy

#### 7.1.1 Fallback Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Primary AI (OpenRouter GPT-4o Mini)               │
│ - High accuracy, fast response                              │
│ - Timeout: 10 seconds                                       │
└─────────────────────────────────────────────────────────────┘
                        │
                        │ Failure / Timeout
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Retry with Same Model                             │
│ - Single retry attempt                                      │
│ - Same timeout: 10 seconds                                  │
└─────────────────────────────────────────────────────────────┘
                        │
                        │ Failure / Timeout
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Fallback Model (Mistral 7B)                       │
│ - Lower cost, good performance                              │
│ - Timeout: 10 seconds                                       │
└─────────────────────────────────────────────────────────────┘
                        │
                        │ Failure / Timeout
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Local Keyword-Based Fallback                      │
│ - No network required                                       │
│ - Instant response                                          │
│ - Reduced accuracy but functional                           │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Fallback Implementation

#### 7.2.1 Intent Extraction Fallback

```dart
Future<EmergencyInterpretation> interpretEmergency({
  required String transcript,
  double? lat,
  double? lng,
}) async {
  try {
    // Attempt AI interpretation
    final text = await _callOpenRouter(
      systemPrompt: _buildIntentPrompt(),
      userMessage: transcript,
    );
    
    final map = _safeDecodeJson(text);
    return _parseInterpretation(map, transcript, lat, lng);
    
  } catch (e) {
    print('AI Interpretation failed: $e. Using offline fallback.');
    return _getFallbackInterpretation(transcript, lat, lng);
  }
}

/// Keyword-based fallback interpretation
EmergencyInterpretation _getFallbackInterpretation(
  String transcript,
  double? lat,
  double? lng,
) {
  final t = transcript.toLowerCase();
  ServiceCategory category = ServiceCategory.other;
  
  // Keyword matching for service category
  if (t.contains('mechanic') || t.contains('car') || 
      t.contains('breakdown') || t.contains('tire') || 
      t.contains('battery')) {
    category = ServiceCategory.mechanic;
  } else if (t.contains('plumber') || t.contains('leak') || 
             t.contains('water') || t.contains('pipe') || 
             t.contains('clog')) {
    category = ServiceCategory.plumber;
  } else if (t.contains('electric') || t.contains('power') || 
             t.contains('light') || t.contains('fuse') || 
             t.contains('shock')) {
    category = ServiceCategory.electrician;
  } else if (t.contains('maid') || t.contains('clean') || 
             t.contains('dust') || t.contains('sweep')) {
    category = ServiceCategory.maid;
  } else if (t.contains('roadside') || t.contains('tow') || 
             t.contains('accident') || t.contains('stuck')) {
    category = ServiceCategory.roadsideAssistance;
  } else if (t.contains('gas') || t.contains('leak') || 
             t.contains('lpg')) {
    category = ServiceCategory.gasService;
  }
  
  // Urgency detection
  EmergencyUrgency urgency = EmergencyUrgency.medium;
  if (t.contains('urgent') || t.contains('emergency') || 
      t.contains('fire') || t.contains('danger') || 
      t.contains('critical')) {
    urgency = EmergencyUrgency.high;
  } else if (t.contains('soon') || t.contains('today')) {
    urgency = EmergencyUrgency.medium;
  } else {
    urgency = EmergencyUrgency.low;
  }
  
  return EmergencyInterpretation(
    issueSummary: transcript.length > 50 
        ? '${transcript.substring(0, 47)}...' 
        : transcript,
    urgency: urgency,
    locationHint: lat != null && lng != null 
        ? '$lat, $lng' 
        : 'Unknown',
    serviceCategory: category,
    reason: 'Offline fallback interpretation based on keywords.',
    confidence: 0.5, // Lower confidence for fallback
    riskFactors: [],
    needsClarification: false,
  );
}
```

#### 7.2.2 Worker Ranking Fallback

```dart
Future<List<WorkerRanking>> recommendWorkers({
  required EmergencyInterpretation interpretation,
  required List<Worker> allWorkers,
}) async {
  // ... filtering logic ...
  
  // Opt-out of AI for LOW urgency (cost optimization)
  if (interpretation.urgency == EmergencyUrgency.low) {
    return _fallbackRanking(pool, interpretation, lat, lng);
  }
  
  // Check confidence threshold
  if (interpretation.confidence < 0.65) {
    return _fallbackRanking(pool, interpretation, lat, lng, 
                           isLowConfidence: true);
  }
  
  // Attempt AI ranking with fallback
  try {
    final rankings = await _ref.read(geminiServiceProvider).rankWorkers(...);
    
    if (rankings.isEmpty) {
      throw Exception('AI returned empty rankings');
    }
    
    return _mergeRankingsWithWorkers(rankings, pool);
    
  } catch (e) {
    print('AI Ranking failed: $e. Using local fallback.');
    return _fallbackRanking(pool, interpretation, lat, lng, 
                           error: e.toString());
  }
}
```

### 7.3 Network Resilience

#### 7.3.1 Timeout Configuration

```dart
class GeminiService {
  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxRetries = 2;
  
  Future<String> _callOpenRouter({...}) async {
    try {
      final response = await _httpClient
          .post(Uri.parse(_baseUrl), headers: {...}, body: {...})
          .timeout(_timeout);
      
      // Handle response
      
    } on TimeoutException {
      print('Request timeout after ${_timeout.inSeconds}s');
      throw Exception('Request timeout');
    } catch (e) {
      // Retry logic
      if (retryCount < _maxRetries) {
        return _callOpenRouter(..., retryCount: retryCount + 1);
      }
      rethrow;
    }
  }
}
```

#### 7.3.2 Offline Mode Detection

```dart
class ConnectivityService {
  Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

// Usage in AI service
Future<EmergencyInterpretation> interpretEmergency({...}) async {
  final isOnline = await _connectivityService.isOnline();
  
  if (!isOnline) {
    print('Device is offline. Using local fallback.');
    return _getFallbackInterpretation(transcript, lat, lng);
  }
  
  // Proceed with AI call
  try {
    // ... AI logic ...
  } catch (e) {
    return _getFallbackInterpretation(transcript, lat, lng);
  }
}
```

### 7.4 Error Recovery Strategies

#### 7.4.1 Graceful Degradation

```dart
// Instead of showing error, provide degraded functionality
class EmergencyController extends StateNotifier<AsyncValue<EmergencyInterpretation?>> {
  Future<void> interpret(String transcript) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await _geminiService.interpretEmergency(...);
      state = AsyncValue.data(result);
    } catch (e, stack) {
      // Don't set error state - use fallback instead
      final fallback = _geminiService._getFallbackInterpretation(...);
      state = AsyncValue.data(fallback);
      
      // Notify user of degraded mode (optional)
      _showNotification('Using offline mode due to connectivity issues');
    }
  }
}
```

#### 7.4.2 User Feedback

```dart
// Show degraded mode indicator in UI
Widget build(BuildContext context) {
  final interpretation = ref.watch(emergencyInterpretationProvider).value;
  
  return Column(
    children: [
      if (interpretation?.confidence != null && interpretation!.confidence < 0.65)
        Banner(
          message: 'Limited AI mode - results may be less accurate',
          color: Colors.orange,
        ),
      
      // ... rest of UI ...
    ],
  );
}
```

### 7.5 Caching Strategy (Future)

#### 7.5.1 Response Caching

```dart
class CachedGeminiService extends GeminiService {
  final Map<String, EmergencyInterpretation> _cache = {};
  
  @override
  Future<EmergencyInterpretation> interpretEmergency({
    required String transcript,
    double? lat,
    double? lng,
  }) async {
    // Generate cache key
    final cacheKey = _generateCacheKey(transcript, lat, lng);
    
    // Check cache
    if (_cache.containsKey(cacheKey)) {
      print('Returning cached interpretation');
      return _cache[cacheKey]!;
    }
    
    // Call API
    final result = await super.interpretEmergency(
      transcript: transcript,
      lat: lat,
      lng: lng,
    );
    
    // Cache result
    _cache[cacheKey] = result;
    
    return result;
  }
  
  String _generateCacheKey(String transcript, double? lat, double? lng) {
    return '${transcript.toLowerCase()}_${lat?.toStringAsFixed(2)}_${lng?.toStringAsFixed(2)}';
  }
}
```


---

## 8. Backend Architecture (Future)

### 8.1 Backend Technology Stack

#### 8.1.1 Recommended Stack

**Option 1: Node.js/TypeScript**
```
- Framework: Express.js or NestJS
- Language: TypeScript
- ORM: Prisma or TypeORM
- Validation: Zod or Joi
- Authentication: JWT + Passport.js
```

**Option 2: Python/FastAPI**
```
- Framework: FastAPI
- Language: Python 3.11+
- ORM: SQLAlchemy
- Validation: Pydantic
- Authentication: JWT + OAuth2
```

**Option 3: Go**
```
- Framework: Gin or Fiber
- Language: Go 1.21+
- ORM: GORM
- Validation: validator
- Authentication: JWT
```

#### 8.1.2 Database Architecture

**Primary Database: PostgreSQL**
```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number VARCHAR(15) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  preferred_language VARCHAR(5) DEFAULT 'en',
  created_at TIMESTAMP DEFAULT NOW(),
  is_verified BOOLEAN DEFAULT FALSE,
  INDEX idx_phone (phone_number),
  INDEX idx_location (latitude, longitude)
);

-- Workers table
CREATE TABLE workers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number VARCHAR(15) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  primary_category VARCHAR(50) NOT NULL,
  skills TEXT[], -- PostgreSQL array
  rating DECIMAL(3, 2) DEFAULT 0.0,
  total_jobs INTEGER DEFAULT 0,
  verified BOOLEAN DEFAULT FALSE,
  is_available BOOLEAN DEFAULT TRUE,
  profile_photo VARCHAR(500),
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  response_time_minutes INTEGER DEFAULT 60,
  status VARCHAR(20) DEFAULT 'offline',
  experience_years INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_category (primary_category),
  INDEX idx_location (latitude, longitude),
  INDEX idx_rating (rating),
  INDEX idx_verified (verified)
);

-- Service requests table
CREATE TABLE service_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  worker_id UUID REFERENCES workers(id) ON DELETE SET NULL,
  service_category VARCHAR(50) NOT NULL,
  issue_summary TEXT NOT NULL,
  urgency VARCHAR(20) NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  location_hint VARCHAR(255),
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW(),
  scheduled_for TIMESTAMP,
  completed_at TIMESTAMP,
  price DECIMAL(10, 2),
  payment_status VARCHAR(20),
  INDEX idx_user (user_id),
  INDEX idx_worker (worker_id),
  INDEX idx_status (status),
  INDEX idx_created (created_at)
);

-- Reviews table
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID REFERENCES service_requests(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  worker_id UUID REFERENCES workers(id) ON DELETE CASCADE,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  INDEX idx_worker (worker_id),
  INDEX idx_rating (rating)
);
```

**Caching Layer: Redis**
```
- Session storage
- Worker availability cache
- Rate limiting
- Real-time location updates
- Pub/Sub for notifications
```

**File Storage: AWS S3 / Google Cloud Storage**
```
- Profile photos
- Document uploads (KYC)
- Chat media files
```

### 8.2 Microservices Architecture (Future Scale)

```
┌─────────────────────────────────────────────────────────────┐
│                      API GATEWAY                             │
│  - Authentication                                            │
│  - Rate Limiting                                             │
│  - Request Routing                                           │
└─────────────────────────────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Auth Service │ │ User Service │ │Worker Service│
│              │ │              │ │              │
│ - Login      │ │ - Profile    │ │ - Onboarding │
│ - OTP        │ │ - Preferences│ │ - Availability│
│ - JWT        │ │ - History    │ │ - Earnings   │
└──────────────┘ └──────────────┘ └──────────────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│Request Service│ │ AI Service   │ │Payment Service│
│              │ │              │ │              │
│ - Create     │ │ - Intent     │ │ - Process    │
│ - Track      │ │ - Ranking    │ │ - Escrow     │
│ - Update     │ │ - Multilingual│ │ - Payout     │
└──────────────┘ └──────────────┘ └──────────────┘
        │               │               │
        └───────────────┼───────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│Notification  │ │Analytics     │ │Location      │
│Service       │ │Service       │ │Service       │
│              │ │              │ │              │
│ - FCM        │ │ - Tracking   │ │ - Geocoding  │
│ - SMS        │ │ - Metrics    │ │ - Distance   │
│ - Email      │ │ - Insights   │ │ - Routing    │
└──────────────┘ └──────────────┘ └──────────────┘
```

### 8.3 API Design Patterns

#### 8.3.1 RESTful API Structure

```
Base URL: https://api.neara.app/v1

Authentication:
POST   /auth/register              # Register user/worker
POST   /auth/login                 # Send OTP
POST   /auth/verify                # Verify OTP
POST   /auth/refresh               # Refresh JWT token

Users:
GET    /users/me                   # Get current user profile
PUT    /users/me                   # Update profile
GET    /users/me/requests          # Get user's requests
DELETE /users/me                   # Delete account

Workers:
GET    /workers                    # Search workers
GET    /workers/:id                # Get worker details
POST   /workers                    # Register as worker (admin)
PUT    /workers/:id                # Update worker profile
GET    /workers/:id/reviews        # Get worker reviews
GET    /workers/:id/availability   # Get availability

Service Requests:
POST   /requests                   # Create service request
GET    /requests/:id               # Get request details
PUT    /requests/:id               # Update request
DELETE /requests/:id               # Cancel request
POST   /requests/:id/accept        # Worker accepts request
PUT    /requests/:id/status        # Update request status

AI Services:
POST   /ai/interpret               # Interpret user input
POST   /ai/rank-workers            # Rank workers for request
POST   /ai/multilingual            # Process multilingual input

Reviews:
POST   /reviews                    # Submit review
GET    /reviews/:id                # Get review details
PUT    /reviews/:id                # Update review
DELETE /reviews/:id                # Delete review

Payments:
POST   /payments/initiate          # Initiate payment
POST   /payments/verify            # Verify payment
GET    /payments/:id               # Get payment details
POST   /payments/refund            # Request refund
```

#### 8.3.2 Request/Response Examples

**Create Service Request:**
```http
POST /v1/requests
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "service_category": "plumber",
  "issue_summary": "Pipe burst in bathroom",
  "urgency": "high",
  "latitude": 19.0760,
  "longitude": 72.8777,
  "location_hint": "Andheri West, Mumbai",
  "scheduled_for": null
}

Response 201 Created:
{
  "success": true,
  "data": {
    "id": "req_abc123",
    "user_id": "user_xyz789",
    "service_category": "plumber",
    "issue_summary": "Pipe burst in bathroom",
    "urgency": "high",
    "status": "pending",
    "created_at": "2026-02-15T10:30:00Z",
    "matched_workers": [
      {
        "id": "worker_123",
        "name": "Rajesh Kumar",
        "rating": 4.7,
        "distance_km": 1.2,
        "eta_minutes": 15
      }
    ]
  }
}
```

**Search Workers:**
```http
GET /v1/workers?category=plumber&lat=19.0760&lng=72.8777&radius=5&min_rating=4.0&verified=true
Authorization: Bearer <jwt_token>

Response 200 OK:
{
  "success": true,
  "data": {
    "workers": [
      {
        "id": "worker_123",
        "name": "Rajesh Kumar",
        "primary_category": "plumber",
        "skills": ["pipe fitting", "leak repair", "bathroom plumbing"],
        "rating": 4.7,
        "total_jobs": 234,
        "verified": true,
        "is_available": true,
        "distance_km": 1.2,
        "response_time_minutes": 20,
        "profile_photo": "https://cdn.neara.app/workers/123.jpg"
      }
    ],
    "total": 15,
    "page": 1,
    "limit": 10
  }
}
```

### 8.4 Real-Time Communication

#### 8.4.1 WebSocket Architecture

```dart
// Flutter WebSocket client
class RealtimeService {
  IOWebSocketChannel? _channel;
  
  void connect(String userId, String token) {
    _channel = IOWebSocketChannel.connect(
      'wss://api.neara.app/ws?token=$token',
    );
    
    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      _handleMessage(data);
    });
  }
  
  void _handleMessage(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'request_accepted':
        _handleRequestAccepted(data);
        break;
      case 'worker_location_update':
        _handleLocationUpdate(data);
        break;
      case 'status_update':
        _handleStatusUpdate(data);
        break;
      case 'new_message':
        _handleNewMessage(data);
        break;
    }
  }
  
  void sendMessage(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }
}
```

#### 8.4.2 Push Notifications (Firebase Cloud Messaging)

```dart
class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  Future<void> initialize() async {
    // Request permission
    await _fcm.requestPermission();
    
    // Get FCM token
    final token = await _fcm.getToken();
    print('FCM Token: $token');
    
    // Send token to backend
    await _sendTokenToBackend(token);
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  void _showLocalNotification(RemoteMessage message) {
    // Show local notification
  }
}
```


---

## 9. API Design

### 9.1 API Versioning Strategy

```
Current: /v1/...
Future: /v2/... (breaking changes)

Version in URL path (preferred for mobile apps)
Alternative: Header-based versioning
```

### 9.2 Authentication & Authorization

#### 9.2.1 JWT Token Structure

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "sub": "user_xyz789",
    "role": "user",
    "phone": "+919876543210",
    "iat": 1708000000,
    "exp": 1708086400
  },
  "signature": "..."
}
```

#### 9.2.2 Authentication Flow

```
1. User enters phone number
   POST /auth/login { "phone": "+919876543210" }
   
2. Backend sends OTP via SMS
   Response: { "otp_sent": true, "expires_in": 300 }
   
3. User enters OTP
   POST /auth/verify { "phone": "+919876543210", "otp": "123456" }
   
4. Backend verifies OTP and returns JWT
   Response: {
     "access_token": "eyJhbGc...",
     "refresh_token": "eyJhbGc...",
     "expires_in": 86400
   }
   
5. Client stores tokens securely
   - Access token: In-memory or secure storage
   - Refresh token: Secure storage only
   
6. Client includes token in requests
   Authorization: Bearer eyJhbGc...
   
7. Token refresh when expired
   POST /auth/refresh { "refresh_token": "..." }
```

### 9.3 Error Handling

#### 9.3.1 Standard Error Response

```json
{
  "success": false,
  "error": {
    "code": "WORKER_NOT_FOUND",
    "message": "Worker with ID 'worker_123' not found",
    "details": {
      "worker_id": "worker_123"
    },
    "timestamp": "2026-02-15T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

#### 9.3.2 HTTP Status Codes

```
200 OK                  - Successful GET, PUT, PATCH
201 Created             - Successful POST
204 No Content          - Successful DELETE
400 Bad Request         - Invalid input
401 Unauthorized        - Missing or invalid token
403 Forbidden           - Insufficient permissions
404 Not Found           - Resource not found
409 Conflict            - Resource conflict (e.g., duplicate)
422 Unprocessable       - Validation error
429 Too Many Requests   - Rate limit exceeded
500 Internal Error      - Server error
503 Service Unavailable - Temporary outage
```

#### 9.3.3 Error Codes

```dart
enum ApiErrorCode {
  // Authentication
  INVALID_CREDENTIALS,
  TOKEN_EXPIRED,
  TOKEN_INVALID,
  OTP_EXPIRED,
  OTP_INVALID,
  
  // Authorization
  INSUFFICIENT_PERMISSIONS,
  ACCOUNT_SUSPENDED,
  
  // Validation
  INVALID_INPUT,
  MISSING_REQUIRED_FIELD,
  INVALID_PHONE_NUMBER,
  INVALID_LOCATION,
  
  // Resources
  USER_NOT_FOUND,
  WORKER_NOT_FOUND,
  REQUEST_NOT_FOUND,
  
  // Business Logic
  WORKER_NOT_AVAILABLE,
  REQUEST_ALREADY_ACCEPTED,
  PAYMENT_FAILED,
  
  // System
  INTERNAL_ERROR,
  SERVICE_UNAVAILABLE,
  RATE_LIMIT_EXCEEDED,
}
```

### 9.4 Rate Limiting

```
Strategy: Token bucket algorithm

Limits:
- Anonymous: 10 requests/minute
- Authenticated: 100 requests/minute
- Premium: 1000 requests/minute

Headers:
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1708000000

Response when exceeded:
429 Too Many Requests
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Try again in 30 seconds.",
    "retry_after": 30
  }
}
```

### 9.5 Pagination

```
Query Parameters:
?page=1&limit=20&sort=rating&order=desc

Response:
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "total_pages": 8,
      "has_next": true,
      "has_prev": false
    }
  }
}
```

---

## 10. Security Architecture

### 10.1 Data Security

#### 10.1.1 Encryption

**In Transit:**
- TLS 1.3 for all API communication
- Certificate pinning in mobile app
- HTTPS only (no HTTP fallback)

**At Rest:**
- Database encryption (PostgreSQL encryption)
- Encrypted backups
- Secure key management (AWS KMS / Google Cloud KMS)

**Sensitive Data:**
```dart
// Phone numbers - hashed for search, encrypted for storage
final hashedPhone = sha256.convert(utf8.encode(phoneNumber)).toString();

// Passwords (if used) - bcrypt with salt rounds >= 12
final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

// API keys - environment variables, never in code
final apiKey = dotenv.env['OPENROUTER_API_KEY'];
```

#### 10.1.2 PII Protection

```dart
class User {
  final String id;
  final String phoneNumber;  // Encrypted
  final String name;         // Encrypted
  final String? email;       // Encrypted
  
  // Anonymized for analytics
  String get anonymizedId => sha256.convert(utf8.encode(id)).toString();
}
```

### 10.2 API Security

#### 10.2.1 Input Validation

```dart
// Backend validation example (Node.js/Zod)
const createRequestSchema = z.object({
  service_category: z.enum(['mechanic', 'plumber', 'electrician', ...]),
  issue_summary: z.string().min(10).max(500),
  urgency: z.enum(['low', 'medium', 'high', 'critical']),
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  location_hint: z.string().max(255).optional(),
});

// Validate request
const validated = createRequestSchema.parse(req.body);
```

#### 10.2.2 SQL Injection Prevention

```sql
-- Use parameterized queries
SELECT * FROM workers 
WHERE primary_category = $1 
  AND latitude BETWEEN $2 AND $3 
  AND longitude BETWEEN $4 AND $5;

-- Never concatenate user input
-- BAD: `SELECT * FROM workers WHERE name = '${userName}'`
```

#### 10.2.3 XSS Prevention

```dart
// Sanitize user input before display
String sanitizeHtml(String input) {
  return input
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;');
}
```

### 10.3 Authentication Security

#### 10.3.1 OTP Security

```
- 6-digit numeric OTP
- Valid for 5 minutes
- Max 3 attempts
- Rate limiting: 1 OTP per minute per phone
- SMS provider: Twilio / AWS SNS
```

#### 10.3.2 Token Security

```dart
// Secure token storage (Flutter)
class SecureStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }
}
```

### 10.4 Privacy Compliance

#### 10.4.1 Data Collection Transparency

```
Privacy Policy must disclose:
- What data is collected (phone, location, usage)
- Why it's collected (service matching, analytics)
- How it's used (AI processing, worker matching)
- Who it's shared with (workers, payment processors)
- How long it's retained (active users: indefinitely, deleted users: 30 days)
- User rights (access, deletion, portability)
```

#### 10.4.2 User Consent

```dart
class ConsentManager {
  Future<void> requestConsent() async {
    final consents = {
      'location': 'Required for finding nearby workers',
      'microphone': 'Required for voice input',
      'notifications': 'Optional for request updates',
      'analytics': 'Optional for improving app experience',
    };
    
    for (var entry in consents.entries) {
      final granted = await _showConsentDialog(entry.key, entry.value);
      await _saveConsent(entry.key, granted);
    }
  }
}
```

#### 10.4.3 Right to be Forgotten

```sql
-- Anonymize user data instead of hard delete
UPDATE users 
SET 
  phone_number = 'DELETED',
  name = 'Deleted User',
  email = NULL,
  latitude = NULL,
  longitude = NULL,
  deleted_at = NOW()
WHERE id = $1;

-- Delete associated data after 30 days
DELETE FROM service_requests 
WHERE user_id = $1 
  AND created_at < NOW() - INTERVAL '30 days';
```

---

## 11. Performance Optimization

### 11.1 Frontend Performance

#### 11.1.1 Widget Optimization

```dart
// Use const constructors
const Text('Hello', style: TextStyle(fontSize: 16));

// Avoid rebuilding entire tree
class WorkerCard extends StatelessWidget {
  const WorkerCard({Key? key, required this.worker}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Only this widget rebuilds when worker changes
    return Card(...);
  }
}

// Use RepaintBoundary for expensive widgets
RepaintBoundary(
  child: ComplexAnimatedWidget(),
)
```

#### 11.1.2 Image Optimization

```dart
// Use cached_network_image
CachedNetworkImage(
  imageUrl: worker.profilePhoto,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  memCacheWidth: 200, // Resize for memory efficiency
  memCacheHeight: 200,
)

// Lazy load images
ListView.builder(
  itemCount: workers.length,
  itemBuilder: (context, index) {
    return WorkerCard(worker: workers[index]);
  },
)
```

#### 11.1.3 State Management Optimization

```dart
// Use select to listen to specific fields
final workerName = ref.watch(
  workerProvider.select((worker) => worker.name)
);

// Debounce expensive operations
Timer? _debounce;

void onSearchChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(Duration(milliseconds: 500), () {
    ref.read(searchProvider.notifier).search(query);
  });
}
```

### 11.2 Backend Performance

#### 11.2.1 Database Optimization

```sql
-- Indexes for common queries
CREATE INDEX idx_workers_category_location 
ON workers(primary_category, latitude, longitude);

CREATE INDEX idx_requests_user_status 
ON service_requests(user_id, status);

-- Materialized view for worker rankings
CREATE MATERIALIZED VIEW worker_rankings AS
SELECT 
  w.id,
  w.name,
  w.rating,
  COUNT(r.id) as total_reviews,
  AVG(r.rating) as avg_rating
FROM workers w
LEFT JOIN reviews r ON w.id = r.worker_id
GROUP BY w.id;

-- Refresh periodically
REFRESH MATERIALIZED VIEW worker_rankings;
```

#### 11.2.2 Caching Strategy

```
Redis Cache Layers:

1. Worker Availability (TTL: 1 minute)
   Key: worker:{id}:available
   Value: true/false

2. Worker Details (TTL: 5 minutes)
   Key: worker:{id}:details
   Value: JSON

3. Search Results (TTL: 2 minutes)
   Key: search:{category}:{lat}:{lng}:{radius}
   Value: [worker_ids]

4. User Session (TTL: 24 hours)
   Key: session:{user_id}
   Value: JWT payload
```

#### 11.2.3 API Response Optimization

```javascript
// Pagination
app.get('/workers', async (req, res) => {
  const { page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;
  
  const workers = await db.workers.findMany({
    skip: offset,
    take: limit,
    select: {
      id: true,
      name: true,
      rating: true,
      // Only return needed fields
    },
  });
  
  res.json({ data: workers });
});

// Compression
app.use(compression());

// Response caching
app.use(cacheControl({ maxAge: 60 }));
```

### 11.3 AI Performance Optimization

#### 11.3.1 Prompt Optimization

```dart
// Shorter prompts = faster response + lower cost
// Before: 500 tokens
// After: 200 tokens (optimized)

final optimizedPrompt = '''
Extract service info from user request.
Output JSON: {"service": "...", "urgency": "...", "summary": "..."}
Request: "$transcript"
''';
```

#### 11.3.2 Selective AI Usage

```dart
// Only use AI when necessary
if (urgency == EmergencyUrgency.low) {
  // Use local ranking (free, instant)
  return _fallbackRanking(...);
}

if (confidence < 0.65) {
  // Low confidence - skip AI ranking
  return _fallbackRanking(...);
}

// High urgency + high confidence - use AI
return await _aiRanking(...);
```

#### 11.3.3 Batch Processing

```dart
// Process multiple requests in one API call
Future<List<EmergencyInterpretation>> interpretBatch(
  List<String> transcripts,
) async {
  final prompt = '''
  Process these requests and return array of JSON objects:
  ${transcripts.map((t) => '"$t"').join(', ')}
  ''';
  
  // Single API call for multiple interpretations
  final response = await _callOpenRouter(...);
  return _parseMultipleInterpretations(response);
}
```


---

## 12. Testing Strategy

### 12.1 Testing Pyramid

```
                    ▲
                   / \
                  /   \
                 /  E2E \
                /  Tests \
               /-----------\
              /             \
             / Integration   \
            /     Tests       \
           /-------------------\
          /                     \
         /      Unit Tests       \
        /                         \
       /___________________________\
       
       70% Unit | 20% Integration | 10% E2E
```

### 12.2 Unit Testing

#### 12.2.1 AI Service Tests

```dart
// test/core/ai/gemini_service_test.dart
void main() {
  group('GeminiService', () {
    late GeminiService service;
    late MockHttpClient mockClient;
    
    setUp(() {
      mockClient = MockHttpClient();
      service = GeminiService(httpClient: mockClient);
    });
    
    test('interpretEmergency returns valid interpretation', () async {
      // Arrange
      final mockResponse = {
        'choices': [
 