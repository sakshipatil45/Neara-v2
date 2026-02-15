# Neara - Requirements Document

**Version:** 1.0.0  
**Last Updated:** February 15, 2026  
**Project Status:** MVP Development  
**Document Type:** Product Requirements Document (PRD)

---

## Executive Summary

Neara is an AI-powered mobile application that revolutionizes how users connect with local service workers in India. By leveraging voice-first interaction and AI-driven intent understanding through OpenRouter API, Neara eliminates the friction of traditional service discovery, enabling users to describe their problems naturally and get matched with nearby verified professionals instantly.

---

## 1. Product Overview

### 1.1 Vision Statement

To become India's most trusted hyperlocal service platform by empowering users to find help through natural conversation and enabling local workers to build sustainable businesses.

### 1.2 Mission

Simplify emergency and routine service discovery by understanding user intent through AI, connecting them with verified nearby workers, and creating a transparent, efficient marketplace for local services.

### 1.3 Target Market

- **Primary:** Urban and semi-urban residents in India aged 25-55
- **Secondary:** Local service workers (plumbers, electricians, mechanics, cleaners, etc.)
- **Geographic Focus:** Tier 1 and Tier 2 cities in India (initial launch)

### 1.4 Problem Statement

Current challenges in local service discovery:

1. Users struggle to identify the correct service category for their problem
2. Existing platforms provide only phone directories without end-to-end workflows
3. Trust and verification of workers is inconsistent
4. Emergency situations require immediate response, not browsing through lists
5. Workers lack a unified platform to manage availability and revenue


---

## 2. Stakeholders

### 2.1 Primary Stakeholders

- **End Users (Consumers):** Individuals seeking local services
- **Service Workers:** Professionals offering plumbing, electrical, mechanical, cleaning, and other services
- **Product Team:** Responsible for feature development and roadmap
- **Development Team:** Flutter developers, backend engineers, AI/ML engineers

### 2.2 Secondary Stakeholders

- **Business Operations:** Customer support, worker verification team
- **Marketing Team:** User acquisition and retention
- **Investors/Management:** Strategic direction and funding

---

## 3. Functional Requirements

### 3.1 User Authentication & Onboarding

#### 3.1.1 User Registration (Future)
- **REQ-AUTH-001:** System shall support phone number-based registration
- **REQ-AUTH-002:** System shall implement OTP verification for phone numbers
- **REQ-AUTH-003:** System shall collect basic user profile (name, location, preferences)
- **REQ-AUTH-004:** System shall support guest mode for browsing (limited features)

#### 3.1.2 Worker Registration (Future)
- **REQ-AUTH-005:** Workers shall register with phone number, name, and service categories
- **REQ-AUTH-006:** System shall require KYC verification (Aadhaar/PAN)
- **REQ-AUTH-007:** Workers shall upload profile photo and service area details
- **REQ-AUTH-008:** System shall verify worker credentials before activation

### 3.2 Voice-First Interaction

#### 3.2.1 Voice Input
- **REQ-VOICE-001:** System shall support real-time speech-to-text conversion
- **REQ-VOICE-002:** System shall provide visual feedback during voice recording
- **REQ-VOICE-003:** System shall support Hindi and English voice input
- **REQ-VOICE-004:** System shall handle background noise with reasonable accuracy
- **REQ-VOICE-005:** System shall allow users to pause and resume voice input


#### 3.2.2 Text Input
- **REQ-TEXT-001:** System shall provide text input as alternative to voice
- **REQ-TEXT-002:** System shall support natural language text descriptions
- **REQ-TEXT-003:** Text input shall trigger same AI processing as voice input

### 3.3 AI-Powered Intent Understanding

#### 3.3.1 Intent Extraction
- **REQ-AI-001:** System shall use OpenRouter API for natural language understanding
- **REQ-AI-002:** System shall extract service category from user description
- **REQ-AI-003:** System shall determine urgency level (low/medium/high)
- **REQ-AI-004:** System shall generate issue summary from user input
- **REQ-AI-005:** System shall extract location hints from conversation
- **REQ-AI-006:** System shall process input in real-time (< 3 seconds response)

#### 3.3.2 Service Categories
- **REQ-AI-007:** System shall support the following service categories:
  - Plumber
  - Electrician
  - Mechanic (vehicle)
  - Carpenter
  - Cleaner/Maid
  - Painter
  - AC/Appliance Repair
  - Pest Control
  - Other/General

#### 3.3.3 Confidence Handling
- **REQ-AI-008:** System shall display confidence level for extracted intent
- **REQ-AI-009:** System shall ask clarifying questions when confidence is low (< 70%)
- **REQ-AI-010:** System shall allow manual category override

### 3.4 Location Services

#### 3.4.1 GPS Integration
- **REQ-LOC-001:** System shall request location permissions on first use
- **REQ-LOC-002:** System shall use GPS to determine user's current location
- **REQ-LOC-003:** System shall allow manual location entry/selection
- **REQ-LOC-004:** System shall cache last known location for offline scenarios
- **REQ-LOC-005:** System shall calculate distance to workers in real-time


#### 3.4.2 Service Area Matching
- **REQ-LOC-006:** System shall match users with workers serving their area
- **REQ-LOC-007:** System shall display distance to each worker
- **REQ-LOC-008:** System shall support radius-based filtering (1km, 3km, 5km, 10km+)

### 3.5 Worker Discovery & Filtering

#### 3.5.1 Worker Listing
- **REQ-DISC-001:** System shall display workers matching service category
- **REQ-DISC-002:** System shall show worker profile with:
  - Name and photo
  - Primary service category
  - Rating (1-5 stars)
  - Distance from user
  - Verification status
  - Availability status
- **REQ-DISC-003:** System shall sort workers by relevance (distance + rating)

#### 3.5.2 Filtering Options
- **REQ-DISC-004:** Users shall filter by service category
- **REQ-DISC-005:** Users shall filter by distance radius
- **REQ-DISC-006:** Users shall filter by minimum rating (3+, 4+, 4.5+)
- **REQ-DISC-007:** Users shall filter by verification status
- **REQ-DISC-008:** Users shall filter by gender preference
- **REQ-DISC-009:** Users shall filter by availability (available now, schedule later)

#### 3.5.3 Worker Profiles
- **REQ-DISC-010:** Users shall view detailed worker profiles including:
  - Full service list
  - Reviews and ratings
  - Years of experience
  - Pricing information (if available)
  - Response time statistics
  - Completed jobs count

### 3.6 Request Management

#### 3.6.1 Service Request Creation
- **REQ-REQ-001:** System shall create structured service request from AI output
- **REQ-REQ-002:** Users shall review and confirm request details before submission
- **REQ-REQ-003:** System shall include:
  - Service category
  - Issue description
  - Urgency level
  - Location
  - Preferred time window
  - Contact information


#### 3.6.2 Request Status Tracking (Future)
- **REQ-REQ-004:** System shall track request status:
  - Pending (sent to workers)
  - Accepted (worker confirmed)
  - On the way (worker traveling)
  - Arrived (worker at location)
  - In progress (work started)
  - Completed (work finished)
  - Cancelled
- **REQ-REQ-005:** Users shall receive real-time status updates
- **REQ-REQ-006:** Users shall view request history

#### 3.6.3 Worker Response (Future)
- **REQ-REQ-007:** Workers shall receive push notifications for new requests
- **REQ-REQ-008:** Workers shall accept or reject requests within 5 minutes
- **REQ-REQ-009:** System shall auto-escalate to next worker if no response
- **REQ-REQ-010:** Workers shall provide estimated arrival time on acceptance

### 3.7 Communication (Future)

#### 3.7.1 In-App Messaging
- **REQ-COMM-001:** Users and workers shall communicate via in-app chat
- **REQ-COMM-002:** System shall support text, images, and location sharing
- **REQ-COMM-003:** System shall maintain chat history for 30 days

#### 3.7.2 Voice Calling
- **REQ-COMM-004:** System shall support in-app voice calling
- **REQ-COMM-005:** System shall mask phone numbers for privacy
- **REQ-COMM-006:** System shall log call duration for quality monitoring

### 3.8 Payment & Pricing (Future)

#### 3.8.1 Payment Methods
- **REQ-PAY-001:** System shall support multiple payment methods:
  - Cash on completion
  - UPI
  - Credit/Debit cards
  - Wallet
- **REQ-PAY-002:** System shall integrate with payment gateway (Razorpay/Paytm)
- **REQ-PAY-003:** System shall support split payments for large jobs

#### 3.8.2 Pricing
- **REQ-PAY-004:** Workers shall set base rates for services
- **REQ-PAY-005:** System shall support dynamic pricing for urgent requests
- **REQ-PAY-006:** Users shall receive price estimates before confirmation
- **REQ-PAY-007:** System shall hold payment in escrow until job completion


### 3.9 Ratings & Reviews

#### 3.9.1 User Reviews
- **REQ-RATE-001:** Users shall rate workers after job completion (1-5 stars)
- **REQ-RATE-002:** Users shall provide written feedback (optional)
- **REQ-RATE-003:** Users shall rate on multiple dimensions:
  - Professionalism
  - Quality of work
  - Timeliness
  - Communication
- **REQ-RATE-004:** System shall prevent fake reviews (verified jobs only)

#### 3.9.2 Worker Reviews
- **REQ-RATE-005:** Workers shall rate users for future reference
- **REQ-RATE-006:** System shall flag problematic users based on worker feedback

### 3.10 Safety & Trust

#### 3.10.1 Verification
- **REQ-SAFE-001:** System shall verify worker identity through KYC
- **REQ-SAFE-002:** System shall display verification badge on profiles
- **REQ-SAFE-003:** System shall conduct background checks for high-trust categories

#### 3.10.2 Emergency Features
- **REQ-SAFE-004:** System shall provide SOS button for emergencies
- **REQ-SAFE-005:** Users shall share live location with emergency contacts
- **REQ-SAFE-006:** System shall enable session sharing with trusted contacts
- **REQ-SAFE-007:** System shall provide 24/7 support helpline

#### 3.10.3 Insurance & Guarantees
- **REQ-SAFE-008:** System shall offer work guarantee for verified workers
- **REQ-SAFE-009:** System shall provide insurance coverage for damages (future)

### 3.11 Worker App Features (Future)

#### 3.11.1 Worker Dashboard
- **REQ-WORK-001:** Workers shall view daily/weekly/monthly earnings
- **REQ-WORK-002:** Workers shall track completed jobs and ratings
- **REQ-WORK-003:** Workers shall manage availability status
- **REQ-WORK-004:** Workers shall set service areas and categories

#### 3.11.2 Job Management
- **REQ-WORK-005:** Workers shall view incoming service requests
- **REQ-WORK-006:** Workers shall accept/reject requests with reasons
- **REQ-WORK-007:** Workers shall update job status in real-time
- **REQ-WORK-008:** Workers shall navigate to user location via maps


#### 3.11.3 Revenue Management
- **REQ-WORK-009:** Workers shall view payment history and pending amounts
- **REQ-WORK-010:** Workers shall request payout to bank account
- **REQ-WORK-011:** System shall provide tax documentation (future)

---

## 4. Non-Functional Requirements

### 4.1 Performance

- **REQ-PERF-001:** App shall launch within 3 seconds on mid-range devices
- **REQ-PERF-002:** Voice-to-text conversion shall have < 500ms latency
- **REQ-PERF-003:** AI intent extraction shall complete within 3 seconds
- **REQ-PERF-004:** Worker list shall load within 2 seconds
- **REQ-PERF-005:** App shall support 10,000+ concurrent users
- **REQ-PERF-006:** API response time shall be < 1 second for 95% of requests

### 4.2 Scalability

- **REQ-SCALE-001:** System shall scale to support 1 million users
- **REQ-SCALE-002:** System shall handle 100,000+ workers
- **REQ-SCALE-003:** Database shall support 10 million+ service requests
- **REQ-SCALE-004:** System shall auto-scale based on traffic patterns

### 4.3 Reliability & Availability

- **REQ-REL-001:** System shall maintain 99.5% uptime
- **REQ-REL-002:** System shall implement automatic failover for critical services
- **REQ-REL-003:** System shall backup data daily
- **REQ-REL-004:** System shall recover from crashes without data loss
- **REQ-REL-005:** App shall function in offline mode with cached data

### 4.4 Security

- **REQ-SEC-001:** All API communications shall use HTTPS/TLS 1.3
- **REQ-SEC-002:** User passwords shall be hashed using bcrypt (salt rounds ≥ 10)
- **REQ-SEC-003:** API keys shall be stored securely (environment variables, not in code)
- **REQ-SEC-004:** System shall implement rate limiting to prevent abuse
- **REQ-SEC-005:** Personal data shall be encrypted at rest
- **REQ-SEC-006:** System shall comply with data protection regulations
- **REQ-SEC-007:** System shall implement session timeout (30 minutes inactivity)
- **REQ-SEC-008:** Payment information shall never be stored locally


### 4.5 Usability

- **REQ-USE-001:** App shall support users with minimal technical literacy
- **REQ-USE-002:** Voice interface shall be primary interaction method
- **REQ-USE-003:** UI shall follow Material Design 3 guidelines
- **REQ-USE-004:** App shall provide contextual help and tooltips
- **REQ-USE-005:** Error messages shall be clear and actionable
- **REQ-USE-006:** App shall support accessibility features (screen readers, high contrast)
- **REQ-USE-007:** Font sizes shall be adjustable for readability

### 4.6 Compatibility

- **REQ-COMP-001:** App shall support Android 8.0 (API 26) and above
- **REQ-COMP-002:** App shall support iOS 13.0 and above
- **REQ-COMP-003:** App shall support screen sizes from 4.5" to 7" (phones and small tablets)
- **REQ-COMP-004:** App shall work on devices with 2GB+ RAM
- **REQ-COMP-005:** App shall support both portrait and landscape orientations

### 4.7 Localization

- **REQ-LOC-001:** App shall support English and Hindi languages
- **REQ-LOC-002:** App shall support regional languages (future): Tamil, Telugu, Bengali, Marathi
- **REQ-LOC-003:** Currency shall be displayed in INR (₹)
- **REQ-LOC-004:** Date/time formats shall follow Indian standards
- **REQ-LOC-005:** Voice input shall support code-mixing (Hinglish)

### 4.8 Maintainability

- **REQ-MAINT-001:** Code shall follow Flutter best practices and style guide
- **REQ-MAINT-002:** Code shall maintain 80%+ test coverage
- **REQ-MAINT-003:** System shall implement comprehensive logging
- **REQ-MAINT-004:** System shall support A/B testing for features
- **REQ-MAINT-005:** System shall provide admin dashboard for monitoring

### 4.9 Legal & Compliance

- **REQ-LEGAL-001:** System shall comply with IT Act 2000 (India)
- **REQ-LEGAL-002:** System shall implement GDPR-like data protection
- **REQ-LEGAL-003:** System shall provide terms of service and privacy policy
- **REQ-LEGAL-004:** System shall obtain user consent for data collection
- **REQ-LEGAL-005:** System shall support data deletion requests (right to be forgotten)

---

## 5. Technical Architecture

### 5.1 Technology Stack

#### 5.1.1 Mobile Application
- **Framework:** Flutter 3.9.2+
- **Language:** Dart 3.0+
- **State Management:** Riverpod 2.5.1+
- **UI Components:** Material Design 3


#### 5.1.2 AI & ML Services
- **Primary AI:** OpenRouter API (multi-model support)
- **Speech Recognition:** speech_to_text package (7.3.0+)
- **Natural Language Processing:** OpenRouter-compatible models (GPT-4, Claude, etc.)

#### 5.1.3 Backend Services (Future)
- **API Framework:** Node.js/Express or Python/FastAPI
- **Database:** PostgreSQL (primary), Redis (caching)
- **File Storage:** AWS S3 or Google Cloud Storage
- **Real-time:** WebSockets or Firebase Realtime Database
- **Push Notifications:** Firebase Cloud Messaging (FCM)

#### 5.1.4 Third-Party Integrations
- **Maps:** Google Maps Flutter (2.9.0+)
- **Location:** Geolocator (13.0.1+)
- **Payments:** Razorpay/Paytm SDK (future)
- **Analytics:** Firebase Analytics, Mixpanel
- **Crash Reporting:** Firebase Crashlytics

### 5.2 System Architecture

#### 5.2.1 Architecture Pattern
- **Client:** MVVM (Model-View-ViewModel) with Riverpod
- **Backend:** Microservices architecture (future)
- **API:** RESTful with GraphQL consideration for complex queries

#### 5.2.2 Key Components
1. **Presentation Layer:** UI screens and widgets
2. **Business Logic Layer:** Providers, services, and use cases
3. **Data Layer:** Repositories, API clients, local storage
4. **Core Layer:** Utilities, constants, theme, and configuration

#### 5.2.3 Data Flow
```
User Input → Voice/Text Processing → AI Service (OpenRouter) 
→ Intent Extraction → Worker Matching → Display Results 
→ User Selection → Request Creation → Worker Notification
```

### 5.3 API Design

#### 5.3.1 Core Endpoints (Future Backend)
- `POST /api/v1/auth/register` - User/worker registration
- `POST /api/v1/auth/login` - Authentication
- `POST /api/v1/requests/create` - Create service request
- `GET /api/v1/workers/search` - Search workers by criteria
- `GET /api/v1/workers/{id}` - Get worker details
- `POST /api/v1/requests/{id}/accept` - Worker accepts request
- `PUT /api/v1/requests/{id}/status` - Update request status
- `POST /api/v1/reviews/create` - Submit review
- `GET /api/v1/users/{id}/requests` - Get user request history


#### 5.3.2 AI Integration
- **OpenRouter API Configuration:**
  - Model selection: GPT-4, Claude 3, or other supported models
  - Prompt engineering for intent extraction
  - Structured JSON response parsing
  - Fallback handling for API failures

### 5.4 Data Models

#### 5.4.1 User Model
```dart
{
  id: String,
  phoneNumber: String,
  name: String,
  email: String?,
  location: GeoPoint,
  preferredLanguage: String,
  createdAt: DateTime,
  isVerified: bool
}
```

#### 5.4.2 Worker Model
```dart
{
  id: String,
  phoneNumber: String,
  name: String,
  services: List<String>,
  location: GeoPoint,
  serviceRadius: double,
  rating: double,
  totalJobs: int,
  isVerified: bool,
  isAvailable: bool,
  profilePhoto: String?,
  experience: int,
  pricing: Map<String, double>?
}
```

#### 5.4.3 Service Request Model
```dart
{
  id: String,
  userId: String,
  workerId: String?,
  serviceCategory: String,
  issueSummary: String,
  urgency: String, // low, medium, high
  location: GeoPoint,
  locationHint: String?,
  status: String,
  createdAt: DateTime,
  scheduledFor: DateTime?,
  completedAt: DateTime?,
  price: double?,
  paymentStatus: String?
}
```

#### 5.4.4 AI Intent Model
```dart
{
  serviceCategory: String,
  issueSummary: String,
  urgency: String,
  locationHint: String?,
  confidence: double,
  extractedEntities: Map<String, dynamic>
}
```

---

## 6. User Interface Requirements

### 6.1 Design Principles

- **Voice-First:** Prioritize voice interaction over traditional UI
- **Minimal Friction:** Reduce steps from problem to solution
- **Trust & Safety:** Prominently display verification and safety features
- **Accessibility:** Support users with varying technical abilities
- **Localization:** Design for multilingual content


### 6.2 Key Screens

#### 6.2.1 Voice Agent Screen (Home)
- Floating app bar with greeting and user status
- Large central microphone button with animation
- Live transcription display
- AI-extracted details panel (service, urgency, location)
- Quick action cards (Emergency, Browse, My Requests, Safety)
- Bottom text input bar as alternative

#### 6.2.2 Worker Discovery Screen
- Filter panel (collapsible)
- Worker cards with key information
- Sort options (distance, rating, availability)
- Map view toggle
- Empty state for no results

#### 6.2.3 Worker Profile Screen (Future)
- Profile header (photo, name, rating, verification)
- Service list with pricing
- Reviews and ratings
- Availability calendar
- Contact buttons (call, message, request service)

#### 6.2.4 Request Confirmation Dialog
- Service category icon
- Issue summary
- Urgency indicator
- Location display
- Edit and confirm buttons

#### 6.2.5 Request Tracking Screen (Future)
- Status timeline
- Worker information
- Live location map
- ETA display
- Communication buttons
- Cancel/report options

#### 6.2.6 My Requests Screen (Future)
- Tabs: Active, Completed, Cancelled
- Request cards with status
- Quick actions (view details, contact worker, review)

### 6.3 Design System

#### 6.3.1 Color Palette
- **Background Gradient:** #0F172A → #020617 (dark slate)
- **Primary:** #4F46E5 (indigo) - main actions
- **Secondary:** #EC4899 (pink) - accents
- **Tertiary:** #FBBF24 (yellow) - warnings/urgency
- **Success:** #10B981 (green)
- **Error:** #EF4444 (red)
- **Text Primary:** #FFFFFF
- **Text Secondary:** #9CA3AF
- **Card Background:** #1F2937 with glass-morphism effect
- **Border:** #334155

#### 6.3.2 Typography
- **Font Family:** Google Fonts (Inter or Poppins recommended)
- **Heading 1:** 24px, Bold
- **Heading 2:** 20px, Semi-Bold
- **Heading 3:** 18px, Semi-Bold
- **Body:** 16px, Regular
- **Caption:** 14px, Regular
- **Small:** 12px, Regular


#### 6.3.3 Spacing & Layout
- **Base Unit:** 8px
- **Padding:** 16px (standard), 24px (large)
- **Border Radius:** 12px (cards), 24px (buttons), 50% (circular)
- **Card Elevation:** Subtle shadow with glass-morphism

#### 6.3.4 Animations
- **Microphone:** Pulsing animation during recording
- **Transitions:** 300ms ease-in-out
- **Loading:** Shimmer effect for content loading
- **Success:** Checkmark animation on confirmation

---

## 7. Development Phases & Roadmap

### 7.1 Phase 1: MVP (Current - Q1 2026)

**Status:** In Development

**Features:**
- ✅ Voice-first interface with speech-to-text
- ✅ Text input alternative
- ✅ AI intent extraction using OpenRouter
- ✅ Mock worker data (20+ workers)
- ✅ Worker discovery with filtering
- ✅ GPS location integration
- ✅ Basic UI/UX with dark theme
- ⏳ Request confirmation flow
- ⏳ Worker profile view (basic)

**Deliverables:**
- Functional Android/iOS app
- Demo-ready prototype
- Technical documentation

### 7.2 Phase 2: Backend Integration (Q2 2026)

**Features:**
- Real backend API development
- User authentication (phone OTP)
- Worker registration and verification
- Real worker data and profiles
- Service request creation and storage
- Push notifications
- Basic analytics

**Deliverables:**
- Production-ready backend
- API documentation
- Admin dashboard (basic)

### 7.3 Phase 3: Worker App & Core Features (Q3 2026)

**Features:**
- Dedicated worker mobile app
- Request acceptance/rejection workflow
- Real-time status updates
- In-app messaging
- Worker availability management
- Revenue dashboard for workers
- Enhanced user profiles

**Deliverables:**
- Worker app (Android/iOS)
- Two-sided marketplace functionality
- Worker onboarding process


### 7.4 Phase 4: Payments & Advanced Features (Q4 2026)

**Features:**
- Payment gateway integration
- Escrow system
- Dynamic pricing
- In-app voice calling
- Advanced filtering and search
- Map-based worker discovery
- Review and rating system
- Referral program

**Deliverables:**
- Full payment flow
- Enhanced discovery features
- Marketing tools

### 7.5 Phase 5: Scale & Optimization (Q1 2027)

**Features:**
- Multi-language support (Hindi, regional languages)
- AI improvements (better intent understanding)
- Predictive worker matching
- Subscription plans for workers
- Insurance and guarantees
- Advanced analytics and insights
- Performance optimization
- Tier 2/3 city expansion

**Deliverables:**
- Scalable infrastructure
- Regional language support
- Growth metrics dashboard

---

## 8. Success Metrics & KPIs

### 8.1 User Acquisition
- **Target:** 100,000 downloads in first 6 months
- **CAC (Customer Acquisition Cost):** < ₹200 per user
- **Organic vs Paid:** 60% organic, 40% paid

### 8.2 User Engagement
- **DAU/MAU Ratio:** > 25%
- **Session Duration:** > 5 minutes average
- **Voice Usage Rate:** > 60% of requests via voice
- **Request Completion Rate:** > 70%

### 8.3 Worker Metrics
- **Worker Onboarding:** 10,000 verified workers in first year
- **Worker Retention:** > 80% monthly retention
- **Average Jobs per Worker:** > 15 per month
- **Worker Satisfaction:** > 4.0/5.0 rating

### 8.4 Business Metrics
- **GMV (Gross Merchandise Value):** ₹10 Cr in first year
- **Take Rate:** 15-20% commission
- **Revenue per User:** ₹500 annually
- **Repeat Usage Rate:** > 40% users make 2+ requests


### 8.5 Quality Metrics
- **AI Accuracy:** > 85% correct service category identification
- **Response Time:** < 3 seconds for AI processing
- **App Crash Rate:** < 0.5%
- **API Uptime:** > 99.5%
- **User Satisfaction:** > 4.2/5.0 app rating

---

## 9. Risk Assessment & Mitigation

### 9.1 Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| OpenRouter API downtime | High | Medium | Implement fallback AI service, cache responses |
| Voice recognition accuracy issues | High | Medium | Provide text alternative, improve prompts |
| GPS inaccuracy in dense areas | Medium | High | Allow manual location entry, use network location |
| Scalability challenges | High | Low | Design for scale from start, load testing |
| Data privacy breaches | Critical | Low | Implement security best practices, regular audits |

### 9.2 Business Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Low worker adoption | Critical | Medium | Incentivize early adopters, reduce onboarding friction |
| Competition from established players | High | High | Focus on AI differentiation, superior UX |
| Regulatory compliance issues | High | Low | Legal consultation, proactive compliance |
| User trust concerns | High | Medium | Robust verification, insurance, transparent policies |
| Payment fraud | Medium | Medium | Escrow system, fraud detection algorithms |

### 9.3 Market Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Market saturation | Medium | Medium | Focus on underserved segments, unique features |
| Economic downturn | Medium | Low | Flexible pricing, essential services focus |
| Technology adoption barriers | Medium | Medium | Simple UX, regional language support, education |

---

## 10. Constraints & Assumptions

### 10.1 Constraints

- **Budget:** Limited funding for MVP phase
- **Timeline:** 6 months to market-ready product
- **Team Size:** Small development team (2-4 developers)
- **Technology:** Must use Flutter for cross-platform development
- **Compliance:** Must adhere to Indian data protection laws

### 10.2 Assumptions

- Users have smartphones with Android 8.0+ or iOS 13.0+
- Users have internet connectivity (3G minimum)
- Workers are willing to adopt digital platforms
- Users are comfortable with voice interaction
- OpenRouter API will remain available and affordable
- GPS accuracy is sufficient for distance calculations
- Payment gateway integration will be straightforward


---

## 11. Dependencies & Integrations

### 11.1 Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | ^3.9.2 | Framework |
| flutter_riverpod | ^2.5.1 | State management |
| speech_to_text | ^7.3.0 | Voice recognition |
| geolocator | ^13.0.1 | Location services |
| google_maps_flutter | ^2.9.0 | Maps integration |
| http | ^1.2.0 | API communication |
| flutter_dotenv | ^5.1.0 | Environment configuration |
| google_fonts | ^6.2.1 | Typography |

### 11.2 Future Dependencies

- **firebase_core:** Firebase initialization
- **firebase_auth:** Phone authentication
- **firebase_messaging:** Push notifications
- **firebase_analytics:** Analytics tracking
- **firebase_crashlytics:** Crash reporting
- **razorpay_flutter:** Payment processing
- **image_picker:** Photo uploads
- **cached_network_image:** Image caching
- **flutter_local_notifications:** Local notifications
- **url_launcher:** External links and calls
- **share_plus:** Content sharing

### 11.3 External Services

- **OpenRouter API:** AI/LLM services
- **Google Maps API:** Maps and geocoding
- **Firebase:** Authentication, notifications, analytics
- **Razorpay/Paytm:** Payment processing
- **AWS S3/GCS:** File storage
- **Twilio:** SMS/voice (optional)
- **Sentry:** Error tracking (optional)

---

## 12. Testing Requirements

### 12.1 Unit Testing

- **Coverage Target:** 80%+
- **Focus Areas:**
  - AI response parsing
  - Data models and validation
  - Business logic in providers
  - Utility functions

### 12.2 Integration Testing

- **API Integration:** Mock API responses for testing
- **Database Operations:** Test CRUD operations
- **Third-party Services:** Test with sandbox environments

### 12.3 Widget Testing

- **UI Components:** Test all custom widgets
- **Screen Flows:** Test navigation and state changes
- **User Interactions:** Test button taps, form inputs

### 12.4 End-to-End Testing

- **Critical Flows:**
  - Voice request → worker discovery → selection
  - Text request → worker discovery → selection
  - Worker filtering and sorting
  - Location permission handling


### 12.5 Performance Testing

- **Load Testing:** Simulate 1000+ concurrent users
- **Stress Testing:** Test system limits
- **Response Time:** Measure API and UI response times
- **Memory Usage:** Monitor memory leaks

### 12.6 Security Testing

- **Penetration Testing:** Identify vulnerabilities
- **Authentication Testing:** Test auth flows
- **Data Encryption:** Verify encryption implementation
- **API Security:** Test rate limiting and authorization

### 12.7 Usability Testing

- **User Interviews:** 10+ users per iteration
- **A/B Testing:** Test UI variations
- **Accessibility Testing:** Screen reader compatibility
- **Localization Testing:** Test all supported languages

---

## 13. Documentation Requirements

### 13.1 Technical Documentation

- **Architecture Document:** System design and components
- **API Documentation:** Endpoint specifications (OpenAPI/Swagger)
- **Database Schema:** Entity relationships and indexes
- **Deployment Guide:** Infrastructure setup and deployment
- **Code Documentation:** Inline comments and dartdoc

### 13.2 User Documentation

- **User Guide:** How to use the app
- **FAQ:** Common questions and answers
- **Video Tutorials:** Screen recordings for key flows
- **Help Center:** In-app help articles

### 13.3 Worker Documentation

- **Onboarding Guide:** How to register and get verified
- **Best Practices:** Tips for success on the platform
- **Policy Documents:** Terms, pricing, and guidelines

### 13.4 Business Documentation

- **Product Requirements (this document)**
- **Market Research:** User personas and competitive analysis
- **Business Model:** Revenue streams and unit economics
- **Go-to-Market Strategy:** Launch plan and marketing

---

## 14. Compliance & Legal

### 14.1 Data Protection

- Comply with IT Act 2000 and proposed Personal Data Protection Bill
- Implement data minimization principles
- Provide clear privacy policy
- Enable user data export and deletion
- Obtain explicit consent for data collection

### 14.2 Terms of Service

- Define user and worker responsibilities
- Clarify liability and dispute resolution
- Specify payment terms and refund policy
- Address intellectual property rights


### 14.3 Worker Compliance

- Verify worker credentials and licenses
- Ensure workers have necessary insurance
- Comply with labor laws and contractor classification
- Implement background check procedures

### 14.4 Payment Compliance

- PCI DSS compliance for payment processing
- GST registration and invoicing
- TDS deduction for worker payments
- Financial reporting and audit trails

---

## 15. Support & Maintenance

### 15.1 Customer Support

- **Channels:** In-app chat, email, phone
- **Response Time:** < 2 hours for critical issues
- **Support Hours:** 9 AM - 9 PM IST (Phase 1), 24/7 (Phase 3)
- **Languages:** English and Hindi

### 15.2 Maintenance Windows

- **Scheduled Maintenance:** Weekly, off-peak hours (2-4 AM IST)
- **Emergency Maintenance:** As needed with user notification
- **Update Frequency:** Bi-weekly app updates, daily backend deployments

### 15.3 Monitoring & Alerts

- **Application Monitoring:** Real-time performance metrics
- **Error Tracking:** Automatic crash reporting
- **User Analytics:** Behavior tracking and funnels
- **Infrastructure Monitoring:** Server health and uptime

---

## 16. Glossary

| Term | Definition |
|------|------------|
| **AI Intent** | Structured understanding of user's service request extracted by AI |
| **Hyperlocal** | Services available within a small geographic area (typically < 5km) |
| **Service Category** | Type of service (plumber, electrician, mechanic, etc.) |
| **Urgency Level** | Priority of request (low, medium, high) |
| **Verified Worker** | Worker who has completed KYC and background verification |
| **GMV** | Gross Merchandise Value - total transaction value on platform |
| **Take Rate** | Percentage commission charged on transactions |
| **DAU/MAU** | Daily Active Users / Monthly Active Users ratio |
| **CAC** | Customer Acquisition Cost |
| **Escrow** | Payment held by platform until service completion |
| **OTP** | One-Time Password for authentication |
| **KYC** | Know Your Customer - identity verification process |

---

## 17. Appendices

### Appendix A: User Personas

**Persona 1: Urgent Uma**
- Age: 32, working professional
- Location: Bangalore
- Pain Point: Pipe burst at 11 PM, needs immediate help
- Tech Savvy: Medium
- Preferred Interaction: Voice

**Persona 2: Planning Priya**
- Age: 45, homemaker
- Location: Mumbai
- Pain Point: Needs AC servicing before summer
- Tech Savvy: Low
- Preferred Interaction: Text with guidance


**Persona 3: Skilled Suresh (Worker)**
- Age: 38, electrician
- Location: Delhi
- Pain Point: Inconsistent work, relies on word-of-mouth
- Tech Savvy: Medium
- Goal: Steady income, digital presence

### Appendix B: Competitive Analysis

| Platform | Strengths | Weaknesses | Differentiation |
|----------|-----------|------------|-----------------|
| Urban Company | Established brand, wide coverage | High prices, limited emergency support | Neara: Voice-first, AI-powered, faster response |
| Justdial | Large database, trusted | Directory only, no booking flow | Neara: End-to-end flow, AI matching |
| Local WhatsApp Groups | Community trust, free | Unverified, no tracking | Neara: Verification, transparency, tracking |
| Dunzo/Swiggy Genie | Fast delivery | Not specialized for services | Neara: Service-specific, skilled workers |

### Appendix C: Sample AI Prompts

**Intent Extraction Prompt:**
```
You are an AI assistant helping users find local service workers in India.

User's message: "{user_input}"
User's location: {latitude}, {longitude}

Extract the following information and respond ONLY with valid JSON:
{
  "serviceCategory": "plumber|electrician|mechanic|carpenter|cleaner|painter|ac_repair|pest_control|other",
  "issueSummary": "brief description of the problem",
  "urgency": "low|medium|high",
  "locationHint": "any location mentioned by user or null",
  "confidence": 0.0-1.0
}

Rules:
- If unclear, set confidence < 0.7
- Use "other" for unrecognized services
- Extract urgency from words like "urgent", "emergency", "ASAP"
- Keep issueSummary under 100 characters
```

### Appendix D: Sample API Responses

**Worker Search Response:**
```json
{
  "success": true,
  "data": {
    "workers": [
      {
        "id": "w_12345",
        "name": "Rajesh Kumar",
        "services": ["plumber", "pipe_fitting"],
        "rating": 4.7,
        "totalJobs": 234,
        "distance": 1.2,
        "isVerified": true,
        "isAvailable": true,
        "profilePhoto": "https://...",
        "pricing": {
          "baseRate": 300,
          "urgentSurcharge": 150
        }
      }
    ],
    "total": 15,
    "page": 1,
    "limit": 10
  }
}
```

### Appendix E: Error Codes

| Code | Message | Action |
|------|---------|--------|
| E001 | Location permission denied | Prompt user to enable location |
| E002 | AI service unavailable | Fallback to manual category selection |
| E003 | No workers found | Suggest expanding search radius |
| E004 | Network error | Retry with cached data |
| E005 | Invalid phone number | Show format example |
| E006 | OTP verification failed | Resend OTP option |
| E007 | Payment failed | Retry or use alternative method |


---

## 18. Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | Feb 15, 2026 | Product Team | Initial requirements document |

---

## 19. Approval & Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Manager | | | |
| Technical Lead | | | |
| Business Owner | | | |
| QA Lead | | | |

---

## 20. References

1. **Flutter Documentation:** https://flutter.dev/docs
2. **OpenRouter API:** https://openrouter.ai/docs
3. **Material Design 3:** https://m3.material.io/
4. **Google Maps Platform:** https://developers.google.com/maps
5. **IT Act 2000:** https://www.meity.gov.in/content/information-technology-act
6. **PCI DSS Standards:** https://www.pcisecuritystandards.org/

---

## Contact Information

**Product Team:**  
Email: product@neara.app  
Slack: #neara-product

**Development Team:**  
Email: dev@neara.app  
Slack: #neara-dev

**Support:**  
Email: support@neara.app  
Phone: +91-XXXX-XXXXXX

---

**Document Status:** DRAFT  
**Next Review Date:** March 15, 2026  
**Distribution:** Internal - Product, Engineering, Business Teams

---

*This document is confidential and proprietary to Neara. Unauthorized distribution is prohibited.*
