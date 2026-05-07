# RunWorld — Flutter

> A gamified GPS territory-capture fitness app for Bengaluru runners and walkers.
> **Flutter rewrite of the React Native version at `C:\Users\Ritanjay\Desktop\RunApp`.**

---

## Build Status

### Phases
- [x] **Phase 0** — Project setup, scaffold, all 16 screens, models, providers, utils
- [x] **Phase 1** — UI polish: custom map painter, XP ring, podium, badge grid, charts, animations
- [x] **Phase 2** — Frontend logic: 7 services, GPS + pedometer tracking, Riverpod providers, go_router auth guard
- [x] **Phase 3** — Backend integration: auth flow, OTP reset, run session save, leaderboard, friends, push tokens
- [x] **Phase 4** — Polish: shimmer loading, offline detection, empty states, haptic feedback, level-up overlay
- [ ] **Phase 5** — Launch: Play Store, App Store, backend deployment, beta test

---

### Screens (16 total)
- [x] SplashScreen — logo animation, auth redirect
- [x] OnboardingScreen — 3-slide carousel, dot indicator
- [x] SignUpScreen — 2-step (details → avatar), Google OAuth button
- [x] LoginScreen — email/pass, shake on error, Google OAuth button
- [x] ForgotPasswordScreen — 3-step OTP flow (email → OTP → reset → success)
- [x] HomeScreen — CartoDB dark map, user pulse dot, today stats card, offline banner
- [x] ActiveRunScreen — concentric rings, live GPS + pedometer, haptics, pause/stop
- [x] RunSummaryScreen — polyline map, XP animation, level-up overlay, badges, share
- [x] DashboardScreen — bar chart, metric tabs, shimmer loading, empty state
- [x] LeaderboardScreen — podium, ranked list, shimmer, offline banner
- [x] ProfileScreen — XP ring (20 segments), hero card, badge grid, stats row
- [x] FriendsScreen — friends list, search, pending requests, activity feed, empty states
- [x] AchievementsScreen — 3-col badge grid, 4 category tabs, earned/in-progress/locked
- [x] ChallengesScreen — active/upcoming/completed tabs, gradient cards, progress bars
- [x] SettingsScreen — profile edit, toggles, logout, delete account
- [x] NotificationsScreen — grouped today/earlier, unread indicator, clear all

---

### Features
- [x] GPS run tracking (geolocator) with haversine distance
- [x] Step counting (pedometer) with pause/resume offset
- [x] Real-time calorie calculation (MET formula)
- [x] XP + leveling system (×1.3 per level, level-up overlay)
- [x] Territory system (MapService built; polygon rendering ready)
- [x] JWT auth with auto-refresh interceptor
- [x] OTP password reset (3-step flow)
- [x] Offline detection + cached data fallback
- [x] Shimmer skeleton loading on all data screens
- [x] Haptic feedback (start/stop/pause/level-up/badge)
- [x] Push notification token registration
- [x] Friends + activity feed
- [x] Leaderboard (city / friends / nearby)
- [ ] Google OAuth *(needs `google-services.json` from Google Cloud Console)*
- [ ] Achievements backend *(mock only)*
- [ ] Challenges backend *(mock only)*
- [ ] Streak cron job *(not implemented on backend)*
- [ ] Delete account endpoint *(backend missing)*

---

## What Is RunWorld?

RunWorld turns everyday running and walking into a city-wide territory capture game. Users move through Bengaluru's real streets, claim map zones as their own, and compete with other users to dominate the city — while tracking steps, distance, and calories burned.

---

## Tech Stack

### Frontend
| Tool | Purpose |
|------|---------|
| Flutter (Dart) | Cross-platform iOS + Android |
| `go_router` | Declarative screen routing |
| `flutter_riverpod` | State management |
| `flutter_map` + `latlong2` | Map rendering (CartoDB Dark Matter, no API key) |
| `geolocator` | GPS location tracking |
| `pedometer` | Step counting via phone sensors |
| `dio` | HTTP API calls with JWT interceptor |
| `flutter_secure_storage` | JWT token storage |
| `shared_preferences` | User/settings persistence |

### Backend (unchanged from RunApp)
| Tool | Purpose |
|------|---------|
| Node.js + Express | REST API |
| Supabase PostgreSQL | Database |
| Supabase Auth | User management |
| SendGrid | OTP emails |
| Expo Push API | Push notifications |

> Backend source: `C:\Users\Ritanjay\Desktop\RunApp\backend`

---

## Prerequisites

- Flutter SDK 3.x (`flutter --version` to check)
- Dart SDK 3.x (bundled with Flutter)
- Android Studio or VS Code with Flutter extension
- Node.js 18+ (for backend)
- A Supabase project (reuse from RunApp)

---

## Project Structure

```
RunWorld/
├── lib/
│   ├── main.dart
│   ├── router/
│   │   └── app_router.dart
│   ├── screens/              # 16 screens
│   ├── widgets/
│   │   ├── auth_input.dart
│   │   ├── otp_input.dart
│   │   ├── pill_tabs.dart
│   │   ├── shimmer_box.dart  # skeleton loading
│   │   ├── empty_state.dart
│   │   └── error_state.dart
│   ├── providers/
│   │   ├── user_provider.dart
│   │   ├── run_provider.dart
│   │   └── settings_provider.dart
│   ├── services/
│   │   ├── api_service.dart       # Dio + JWT interceptor + offline flag
│   │   ├── auth_service.dart
│   │   ├── fitness_service.dart
│   │   ├── map_service.dart
│   │   ├── leaderboard_service.dart
│   │   ├── social_service.dart
│   │   └── notifications_service.dart
│   ├── models/
│   ├── config/
│   │   └── app_config.dart
│   └── utils/
│       ├── constants.dart    # AppColors, AppTextStyles, AppSpacing, AppRadius
│       ├── fitness_calc.dart # MET calories, pace, XP, haversine
│       └── haptics.dart      # HapticFeedback wrapper
├── assets/fonts/             # BebasNeue, DM Sans, JetBrains Mono
├── android/
├── ios/
├── docs/
│   ├── BACKEND_DOCS.md
│   ├── FRONTEND_DOCS.md
│   ├── DESIGN_SYSTEM.md
│   └── DATABASE_SCHEMA.md
├── pubspec.yaml
├── CLAUDE.md
├── PROGRESS.md
└── README.md
```

---

## Running the App

### 1. Install dependencies
```bash
cd C:\Users\Ritanjay\Desktop\RunWorld
flutter pub get
```

### 2. Run on Android emulator
```bash
flutter run
# API base URL is hardcoded to http://10.0.2.2:5000/api for emulator
```

### 3. Run backend
```bash
cd C:\Users\Ritanjay\Desktop\RunApp\backend
npm install
node index.js
# API running at http://localhost:5000
```

---

## Environment Variables

### Backend (`C:\Users\Ritanjay\Desktop\RunApp\backend\.env`)
```
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_KEY=your_service_key
JWT_SECRET=your_jwt_secret
SENDGRID_API_KEY=your_sendgrid_key
SENDGRID_FROM_EMAIL=no-reply@runworld.app
PORT=5000
```

### Flutter app
API base URL is set in `lib/config/app_config.dart`:
```dart
// Android emulator
static const apiBaseUrl = 'http://10.0.2.2:5000/api';
// Real device on same network
// static const apiBaseUrl = 'http://192.168.x.x:5000/api';
// Production
// static const apiBaseUrl = 'https://your-backend.railway.app/api';
```

---

## Pending — Requires Your Action

| Task | What's needed |
|------|--------------|
| Google OAuth | Create project in Google Cloud Console → enable Google Sign-In → download `google-services.json` |
| Package name | Change `com.example.runworld` to your real package name before Play Store submission |
| Play Store | Google Play Developer account ($25 one-time) + app icon 1024×1024 + screenshots |
| App Store | Mac + Apple Developer account ($99/year) |
| Backend deployment | Railway or Render account → connect backend repo → set env vars |
| Beta test | Real Android device GPS testing in Bengaluru |

---

## Docs

| File | Contents |
|------|----------|
| [PROGRESS.md](PROGRESS.md) | Phase-by-phase build tracker with daily log |
| [CLAUDE.md](CLAUDE.md) | Claude working rules for this project |
| [docs/BACKEND_DOCS.md](docs/BACKEND_DOCS.md) | All API endpoints + request/response shapes |
| [docs/FRONTEND_DOCS.md](docs/FRONTEND_DOCS.md) | All screens, widgets, services, providers |
| [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Colors, fonts, spacing, component patterns |
| [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) | Full Supabase DB schema |
