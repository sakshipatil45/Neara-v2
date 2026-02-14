# Neara – Voice‑First Hyperlocal Help App

An AI‑powered Flutter application that connects users with nearby service workers (mechanics, plumbers, electricians, cleaners, etc.) through a **voice‑first emergency and assistance experience**, using **Google Gemini** for intent understanding.

---

## 📚 Table of Contents

1. Project Overview
2. Why Neara is Helpful
3. Key Features (Current MVP)
4. How the App Works – User Flows
5. How Gemini Works Inside Neara
6. Architecture & Technologies Used
7. Future Scope (Including Worker App)
8. Mock / Stubbed Parts
9. Running the App
10. Design System
11. Known Issues & Limitations
12. **[Multilingual AI Assistant Guide](MULTILINGUAL_AI_GUIDE.md)** 🌐

---

## 🎯 1. Project Overview

Neara is a **voice‑first emergency help and home‑services discovery app** designed for the Indian hyperlocal context.

Users can simply **speak or type a natural‑language request** like:

> "Geyser is leaking badly in my bathroom, need urgent help"

Neara uses **Google Gemini** to:

- Understand the **intent** (which service is needed – plumber, electrician, cleaner, etc.)
- Extract key **entities** (urgency, issue summary, location hints)
- Build a structured **job request**
- Auto‑filter and show **nearby, verified workers** that match the request.

The current app focuses on the **consumer side** (requesting help and discovering workers) with **mocked workers and no real backend**, but is architected so that a real backend and worker app can plug in later.

---

## 💡 2. Why Neara is Helpful

Neara is built to solve common problems in India with existing local‑service discovery:

- Users often **don’t know the exact category** (“Is geyser a plumber or electrician job?”).
- Existing directories (e.g., generic listing apps) provide **phone numbers only**, not end‑to‑end flow.
- Independent workers rely on **WhatsApp / calls**, making discovery, trust, and tracking difficult.

Neara helps by:

- Letting users **describe problems in their own words** (voice or text) with **Gemini handling intent**, so no manual category picking is required.
- Providing **hyperlocal discovery** and filtering of nearby workers instead of generic city‑wide lists.
- Offering a **single flow from problem description → AI understanding → worker list**, which can later grow into booking, tracking, and payments.
- Laying the foundation for a **worker‑first platform** where local workers can self‑onboard, manage availability, and track their revenue.

---

## ✅ 3. Key Features (Current MVP)

### 3.1 Voice Agent Screen

- **Voice input**
  - Real‑time speech‑to‑text transcription using `speech_to_text`.
  - Animated listening state and clear feedback while recording.
- **Text input**
  - Alternative bottom text bar for users who prefer typing.
  - Glass‑morphic design consistent with the dark gradient theme.
- **Live AI processing**
  - Every few seconds, Neara sends the latest transcript/text to Gemini.
  - The UI shows **live extracted details** (service category, issue summary, urgency, location hint) beside the transcription.
- **Confirmation dialog**
  - When the user taps "Done", they see a structured summary:
    - Service category (mechanic / plumber / electrician / maid / other)
    - Location hint (GPS‑based or spoken location)
    - Urgency level (low / medium / high)
    - Issue summary in plain language
  - Users can confirm or cancel before moving to discovery.
- **UI/UX highlights**
  - Dark gradient theme (#0F172A → #020617)
  - Floating app bar with greeting and status
  - 2×2 quick action cards (Emergency help, Browse services, My requests, Safety & SOS)
  - Bottom input bar with integrated mic button

### 3.2 Worker Discovery Screen

- **Mock worker list**
  - 20+ pre‑populated workers with realistic names, ratings, services, and distances.
- **Filtering system**
  - Service category (auto‑applied from Gemini’s interpretation)
  - Distance radius (km)
  - Minimum rating
  - Verified‑only toggle
  - Gender preference
- **Worker cards**
  - Show avatar, name, primary service, ratings, distance, verification badge.
- **Navigation**
  - Smooth flow: Voice/Text request → AI interpretation → Confirmation → Filtered worker list.

### 3.3 Location & Context

- **GPS integration** using `geolocator` to get user’s current location.
- Location is passed to the AI and used to interpret spoken hints like "near City Center".

---

## 🔄 4. How the App Works – User Flows

### 4.1 Emergency Voice‑First Flow

1. User opens the app (Voice Agent is the home screen).
2. User taps mic and speaks the problem.
3. Speech‑to‑text generates live transcription.
4. Gemini processes the text and current GPS data to extract:
   - Service category
   - Issue summary
   - Urgency level
   - Location hint
5. Neara shows a confirmation sheet with the extracted data.
6. User taps **Find Workers**.
7. Worker Discovery Screen opens, already filtered by service category.
8. User scrolls and selects a worker (future: open profile → book → track).

### 4.2 Text Input Flow

1. User types a message such as "need electrician for fan repair tonight".
2. On send, Gemini is called with the text.
3. Gemini returns structured fields (service, urgency, issue summary, location hint).
4. The worker list is shown with filters auto‑applied.

### 4.3 Browse‑Only Flow (Non‑AI)

1. User taps **Browse services** from quick actions.
2. Worker Discovery Screen opens with all workers.
3. User manually filters by service, rating, distance, and other filters.

---

## 🤖 5. How Gemini Works Inside Neara

### 5.1 Model & Integration

- Uses **`google_generative_ai`** package.
- Primary model: **`gemini-pro`** for text‑only understanding.
- API key stored securely in `.env` and loaded with `flutter_dotenv`.

### 5.2 Intent & Entity Extraction

Neara sends the current transcription/text to Gemini with a prompt instructing it to output structured JSON with fields like:

```dart
{
  "issueSummary": "pipe burst in bathroom",
  "urgency": "high",
  "locationHint": "NH4 near City Center",
  "serviceCategory": "plumber"
}
```

The response is parsed into a Dart model and propagated through Riverpod providers.

### 5.3 Handling Uncertainty (Conceptual)

- If Gemini is **confident**, Neara auto‑applies filters and skips extra questions.
- If confidence is low or fields are missing, the UI can:
  - Ask **follow‑up questions** (planned in future versions).
  - Fall back to **manual category selection** while still using Gemini’s best guess.

### 5.4 Why This is Gemini‑Style Intent Handling

- Users **do not need to explicitly pick the service** from a menu.
- The model infers the correct category, urgency, and rough location from natural language.
- This mimics how products like Gemini chat understand free‑form queries and return structured understanding under the hood.

---

## 🏗️ 6. Architecture & Technologies Used

### 6.1 High‑Level Architecture

- **Presentation Layer**
  - Voice Agent screen (voice_agent_screen.dart)
  - Worker Discovery screen (worker_discovery_screen.dart)
  - Shared widgets for cards, buttons, and theming.
- **Domain / Logic Layer**
  - AI interpretation logic (Gemini prompts and parsing)
  - Filtering logic for worker lists.
- **Data Layer**
  - Mock worker repository using in‑memory lists.

### 6.2 File Structure (Simplified)

```text
lib/
├── core/
│   ├── ai/
│   │   ├── gemini_service.dart      // Gemini API, prompts, parsing
│   │   └── ai_providers.dart        // Riverpod providers for AI state
│   └── theme/
│       └── app_theme.dart           // App‑wide theming
├── features/
│   ├── voice_agent/
│   │   └── presentation/
│   │       └── voice_agent_screen.dart
│   └── discovery/
│       ├── data/
│       │   └── worker_providers.dart // Mock worker data + filters
│       └── presentation/
│           └── worker_discovery_screen.dart
└── shared/
    └── widgets/                     // Reusable UI components
```

### 6.3 Tech Stack

- **Framework**: Flutter ^3.9.2
- **State Management**: `flutter_riverpod` ^2.5.1
- **AI / LLM**: `google_generative_ai` ^0.4.6 (Gemini)
- **Voice Recognition**: `speech_to_text` ^7.3.0
- **Location**: `geolocator` ^13.0.1
- **Env Management**: `flutter_dotenv` ^5.1.0
- **Maps**: `google_maps_flutter` ^2.9.0 (currently stubbed for pins)
- **Typography**: `google_fonts` ^6.2.1

### 6.4 Configuration

- `.env` – contains `GEMINI_API_KEY` (git‑ignored).
- `pubspec.yaml` – dependencies and assets.
- `analysis_options.yaml` – Dart lints.

---

## 🚀 7. Future Scope (Including Worker App)

The current build is **consumer‑side MVP**. Planned enhancements include:

### 7.1 Worker App (Future)

- Separate **Worker App** (or mode) where workers can:
  - Register with phone/KYC and get verified.
  - Set services offered, serviceable areas, and availability (Available / Busy / Offline).
  - Receive service requests from Neara users.
  - **Accept / Reject** requests and view job details.
  - Update job status: On the way → Arrived → In progress → Completed.
  - Maintain a **revenue dashboard** (daily, weekly, monthly earnings and job history).

### 7.2 Platform Features

- Real backend API and database.
- Phone‑OTP authentication.
- Real‑time chat and in‑app voice calling.
- Map‑based view with live worker locations.
- Escrow or in‑app payments with payment gateway integration.
- Push notifications for job updates.
- Worker availability calendar.
- Quotes, price negotiation, and coupons.
- Review and rating system backed by real data.
- Multi‑language support (Hindi and regional languages).
- Safety & SOS workflows and trusted‑worker filters.

---

## 🧪 8. Mock / Stubbed Parts (Current State)

The following are **mocked or not yet implemented**:

1. Worker data (20+ workers) is hardcoded in `worker_providers.dart`.
2. Worker detail/profile screen is minimal or absent.
3. Job request creation and tracking is not connected to a backend.
4. Live tracking and navigation are just placeholders.
5. Safety features (SOS, share session, high‑trust filters) are stubs.
6. Worker onboarding/registration is not implemented.
7. No payment integration (on‑site payment implied only in UX).
8. No in‑app chat or messaging.
9. No push notifications or real‑time updates.
10. Map view exists but worker pins and live positions are not wired.

---

## 🛠️ 9. Running the App

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure environment**

   - Create a `.env` file in the project root.
   - Add your Gemini API key:

     ```text
     GEMINI_API_KEY=your_api_key_here
     ```

4. **Run the app**

   ```bash
   flutter run
   ```

### Supported Platforms

- ✅ Android
- ✅ iOS
- ⚠️ Web (voice input may be limited)
- ⚠️ Desktop (not fully tested)

---

## 🎨 10. Design System

### Colors

- Background gradient: `#0F172A` → `#020617`
- Primary accent: `#4F46E5` (Indigo)
- Secondary accent: `#EC4899` (Pink)
- Tertiary accent: `#FBBF24` (Yellow)
- Text primary: `#FFFFFF`
- Text secondary: `#9CA3AF`
- Card background: `#1F2937` / `#1E293B`
- Border: `#334155`

### Typography

- Google Fonts (system defaults acceptable for now).
- Title: 18–20 px, bold.
- Body: 14–16 px, regular.
- Caption: 12–13 px, regular.

---

## 🐛 11. Known Issues & Limitations

1. Voice recognition may stop early on some devices depending on `speech_to_text` behavior.
2. Gemini API rate limits can cause transient failures during heavy testing.
3. GPS permissions must sometimes be granted manually in system settings.
4. Distances to workers are **hardcoded**, not computed from real GPS.
5. All data is local/mock – there is **no real backend** yet.

---

## 🤝 Contributing

This is currently an internal prototype. For questions or contributions, contact the development team.

---

**Last Updated**: January 11, 2026  
**Version**: 0.2.0  
**Status**: MVP / Prototype
