# Flutter Frontend Documentation

> Reference React Native screens: `C:\Users\Ritanjay\Desktop\RunApp\app\screens\`
> Reference components: `C:\Users\Ritanjay\Desktop\RunApp\app\components\`
> Reference hooks/logic: `C:\Users\Ritanjay\Desktop\RunApp\app\hooks\`

---

## Navigation (go_router)

All routes defined in `lib/router/app_router.dart`.

| Route Name | Path | Screen |
|-----------|------|--------|
| splash | `/` | SplashScreen |
| onboarding | `/onboarding` | OnboardingScreen |
| signup | `/signup` | SignUpScreen |
| login | `/login` | LoginScreen |
| forgotPassword | `/forgot-password` | ForgotPasswordScreen |
| home | `/home` | HomeScreen |
| activeRun | `/run/active` | ActiveRunScreen |
| runSummary | `/run/summary` | RunSummaryScreen |
| dashboard | `/dashboard` | DashboardScreen |
| leaderboard | `/leaderboard` | LeaderboardScreen |
| profile | `/profile` | ProfileScreen |
| friends | `/friends` | FriendsScreen |
| achievements | `/achievements` | AchievementsScreen |
| challenges | `/challenges` | ChallengesScreen |
| settings | `/settings` | SettingsScreen |
| notifications | `/notifications` | NotificationsScreen |

Auth guard: If no access token in SecureStorage → redirect to `/onboarding`.
After successful auth: use `context.go('/home')` (equivalent to replace — no back stack).

---

## Screens

### SplashScreen (`lib/screens/splash_screen.dart`)

**Reference:** `RunApp/app/screens/SplashScreen.jsx`

**Purpose:** Animated entry point. Checks auth state and routes accordingly.

**Animations (use `AnimationController` + `Tween`):**
- Logo: scale 0.5→1.0 + opacity 0→1, 800ms ease-out
- Tagline: fade in, 600ms, delayed 400ms
- Accent line: width sweep, 400ms, delayed 800ms
- Version text: fade in, delayed 1200ms
- White flash overlay: opacity 0→1→0 at ~2000ms

**Logic:**
1. On initState: start animations + parallel load of UserProvider + SettingsProvider from SharedPreferences
2. After 2400ms: check if user is logged in (`userProvider.user != null`)
3. If logged in → `context.go('/home')`
4. If not → `context.go('/onboarding')`

**Layout:** Stack — full screen gradient background (primary → secondary), centered Column with logo, tagline, accent line, version text.

---

### OnboardingScreen (`lib/screens/onboarding_screen.dart`)

**Reference:** `RunApp/app/screens/OnboardingScreen.jsx`

**Purpose:** 3-slide feature walkthrough before signup.

**Slides:**
1. "Own the Map" — 🗺️ — "Run through streets to claim territories as your own"
2. "Earn XP" — ⚡ — "Every step earns XP. Level up and unlock achievements"
3. "Dominate the City" — 🏆 — "Compete with runners across Bengaluru"

**Animations:** Use `PageView` + `PageController`. Listen to scroll position to animate:
- Icon + text opacity/scale for current vs adjacent slides
- Dot indicator: active dot wider (24px), others narrow (8px)

**Controls:**
- Skip button (top right) → `context.go('/signup')`
- Next button (changes to "LET'S GO" on slide 3) → advances pages or goes to signup
- `context.go('/signup')` (never push — prevent back to onboarding)

---

### SignUpScreen (`lib/screens/signup_screen.dart`)

**Reference:** `RunApp/app/screens/SignUpScreen.jsx`

**Purpose:** 2-step account creation.

**Step 0 — Details:**
- Name field (min 2 chars)
- Email field (regex validation)
- Password field (min 8 chars, obscured)
- Confirm password field (must match)
- Validation error: shake animation on the form column
- "Next" button → validates → advances to Step 1

**Step 1 — Avatar:**
- 12 emoji avatars in a GridView (4 columns): 🏃 ⚡ 🦅 🔥 🐺 💎 🌙 🎯 🦁 ⚔️ 👑 🌊
- Selected avatar: `accent` colored border + checkmark overlay
- Google Sign-In button (bottom)
- "Create Account" button → calls `AuthService.signUp()` → on success: `UserProvider.setUser()` → `context.go('/home')`

**Error handling:** Show red error box if API returns error. Shake animation on validation failure.

**Offline fallback:** If API unreachable, create local user object and proceed.

---

### LoginScreen (`lib/screens/login_screen.dart`)

**Reference:** `RunApp/app/screens/LoginScreen.jsx`

**Purpose:** Email/password sign in.

**Fields:** Email, Password (obscured, toggle visibility)
**Validation:** Email regex, password min 8 chars
**Shake animation:** On validation failure or 401 from server
**Error box:** Red container with icon + message
**Google Sign-In:** Same button as SignUpScreen
**Forgot password link:** → `context.push('/forgot-password')`
**On success:** `context.go('/home')`

---

### ForgotPasswordScreen (`lib/screens/forgot_password_screen.dart`)

**Reference:** `RunApp/app/screens/ForgotPasswordScreen.jsx`

**Purpose:** 3-step OTP-based password reset.

**Step indicator:** 3 dots at top — active (accent, large), completed (success, medium), pending (muted, small)

**Step 0 — Email:**
- Email input + validation
- "Send OTP" → `AuthService.sendOtp()` → advance to step 1

**Step 1 — OTP:**
- Shows masked email (e.g., r***@gmail.com)
- 6 single-character text fields (OtpInput widget)
- 60s resend timer countdown
- "Verify" → `AuthService.verifyOtp()` → store `resetToken` → advance to step 2

**Step 2 — New Password:**
- Password + confirm fields
- Password strength bar: 4 segments, fills based on: length≥8, uppercase, number, symbol
- "Reset Password" → `AuthService.resetPassword()` → advance to step 3

**Step 3 — Success:**
- Animated checkmark (scale in)
- "Back to Login" → `context.go('/login')`

---

### HomeScreen (`lib/screens/home_screen.dart`)

**Reference:** `RunApp/app/screens/HomeScreen.jsx`

**Purpose:** Main map view with territories and today's stats.

**Layout:** Stack
- Full-screen `GoogleMap` widget (dark style)
- Territory `Polygon`s from API
- Animated user location marker (pulse ring)
- Top bar overlay: profile avatar button, "RUNWORLD" chip, notification bell
- Bottom overlay: `MapOverlayCard` widget

**Map config:**
- Initial position: Bengaluru center (12.9716, 77.5946), zoom 13
- Map type: normal, dark style JSON applied
- Disable default UI (myLocationButton, etc.)
- `onCameraMove` → update bounding box → debounced fetch of territories

**Territory polygons:**
- `Polygon` with `fillColor: ownerColor.withOpacity(0.3)` + `strokeColor: ownerColor`
- Own territory: accent color, others: their assigned color

**User location:** Custom `Marker` with animated outer ring (repeat loop, scale 1.0→2.0→1.0, fade out).

**FABs:** Recenter button (bottom right), Leaderboard button (above recenter)

**MapOverlayCard:** Shows steps, distance (km), calories, active minutes, "START RUN" button

**API calls:**
- On init: `Geolocator.getCurrentPosition()` → center map
- `MapService.getTerritories(bounds)` → draw polygons
- `FitnessService.getTodayStats()` → show in overlay card

---

### ActiveRunScreen (`lib/screens/active_run_screen.dart`)

**Reference:** `RunApp/app/screens/ActiveRunScreen.jsx`

**Purpose:** Real-time GPS run tracker.

**Layout:**
- Top bar: back/close button, activity toggle (Running/Walking), GPS signal dots
- Center: Concentric ring display — 3 decorative rings + inner circle showing distance value + "KILOMETERS" label + timer box
- Stats row: Steps / Pace / Calories (3 columns)
- Controls: Stop button (left), Pause/Resume (center large), Lap (right)

**GPS tracking:**
```dart
// geolocator
StreamSubscription _positionStream = Geolocator.getPositionStream(
  locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
).listen((position) {
  // haversine distance to last coordinate
  // update distanceKm in RunProvider
  // append to pathCoordinates
});
```

**Step counting:**
```dart
// pedometer
Pedometer.stepCountStream.listen((event) {
  // event.steps - _stepOffset
});
```

**GPS fallback:** If no GPS permission, use `Timer.periodic(1s)` incrementing mock distance.
**Step fallback:** ~1300 steps/km for running, 1400 for walking.

**GPS signal indicator:** 3 dots. Green = all 3 (accuracy < 10m). 2 = accuracy < 30m. 1 = has position. 0 = no GPS.

**Pause/Resume:**
- Pause: cancel position stream + step stream, record `_pausedAt`
- Resume: restart streams, set step offset to current step count

**Stop:** Show `AlertDialog` confirmation → navigate to RunSummaryScreen with all stats as `extra`:
```dart
context.go('/run/summary', extra: RunSummaryParams(...))
```

**Activity toggle:** Changes MET value for calorie calc, updates GPS calibration for step fallback.

**Animations:** `AnimationController` repeating for ring pulse. Timer updates every second via `Timer.periodic`.

---

### RunSummaryScreen (`lib/screens/run_summary_screen.dart`)

**Reference:** `RunApp/app/screens/RunSummaryScreen.jsx`

**Purpose:** Post-run stats + XP celebration.

**Data source:** Route `extra` params from ActiveRunScreen (or mock data if missing).

**Layout:**
- Dark map snippet (200px height) with `Polyline` of run path
- XP counter: animated from 0 to earned value over 1500ms using `Tween<int>`
- Stats 2×2 grid: Distance / Duration / Pace / Calories
- Badges row: earned badges (emoji + title) with `ZoomIn` animation
- Buttons: "View Dashboard" → `/dashboard`, "Share" → native share sheet

**On init:** Call `FitnessService.saveSession(session)` → backend updates XP/level → update UserProvider.

**Animations:** Stagger `FadeTransition` for each stat card (offset by 100ms each).

---

### DashboardScreen (`lib/screens/dashboard_screen.dart`)

**Reference:** `RunApp/app/screens/DashboardScreen.jsx`

**Purpose:** Weekly fitness stats.

**Layout:**
- TabBar pill: Week / Month
- Metric tabs: Steps / Distance / Calories
- `WeeklyBarChart` widget — 7 bars (Mon–Sun), current day in accent color
- Today goal progress bar
- Totals grid: 4 cells (runs, steps, distance, calories)

**Data:**
- `FitnessService.getWeeklyStats()` → populate chart
- `FitnessService.getTodayStats()` → today progress bar

**Loading:** `ShimmerBox` placeholders for label + chart. Empty state (🏃 "No runs yet") when all weekly steps = 0. Offline banner shown when `ApiService.isOffline`.

---

### LeaderboardScreen (`lib/screens/leaderboard_screen.dart`)

**Reference:** `RunApp/app/screens/LeaderboardScreen.jsx`

**Layout:**
- TabBar: City / Friends / Nearby
- Period toggle: This Week / All Time (pill buttons)
- Podium: 2nd (left, shorter), 1st (center, taller), 3rd (right)
  - Each: avatar, name, level chip, XP value
- Ranked list (rank 4+): `ListView.builder` with RankRow widget
- Own rank sticky card at bottom (shows user's own rank regardless of position)

**API:** `LeaderboardService.getCityLeaderboard()`, `getFriendsLeaderboard()`, `getNearbyLeaderboard()` — `Future.wait([...])` on mount.

**Optimization:** Use `const` constructors, `ListView` with `itemExtent` for performance.

---

### ProfileScreen (`lib/screens/profile_screen.dart`)

**Reference:** `RunApp/app/screens/ProfileScreen.jsx`

**Layout:**
- Hero card: avatar (large emoji), name, level badge, XP ring (20 segments painted via `CustomPainter`)
- XP text: "800 / 1300 XP"
- Stats row: Territory % / Total Distance / Total Steps / Streak
- Badges section: 3-col GridView, earned = full color, locked = greyscale
- Navigation buttons: Achievements, Settings, Dashboard

**XP Ring:** `CustomPainter` drawing 20 arc segments. Filled segments = `(xp / xp_to_next * 20).floor()`. Active segment has glow.

**API:** `SocialService.getUserProfile(userId)` (for viewing others), own profile from `UserProvider`.

---

### FriendsScreen (`lib/screens/friends_screen.dart`)

**Reference:** `RunApp/app/screens/FriendsScreen.jsx`

**Tabs:** Friends / Activity Feed

**Friends tab:**
- Search `TextField` with 300ms debounce → `SocialService.searchUsers(query)`
- Pending requests section: each with avatar, name, Accept / Decline buttons
- Friends list: `FriendCard` widget (avatar, name, level, streak, territory %, online dot)

**Activity Feed tab:**
- `ListView` of `ActivityFeedItem` (friend avatar, name, run type, distance, XP, timestamp)

**API:** `Future.wait([getFriends(), getFriendRequests(), getActivityFeed()])` on init.

**Debounce:** Use `Timer` + cancel-on-change pattern in `dispose`.

---

### AchievementsScreen (`lib/screens/achievements_screen.dart`)

**Reference:** `RunApp/app/screens/AchievementsScreen.jsx`

**24 badges across 4 categories:**
- Running: First Run, 5K, 10K, 50K, Morning Runner, Speed Demon
- Territory: First Capture, Zone Lord, District King, City Dominator, Night Raider, Comeback King
- Social: First Friend, Squad Up, Social Butterfly, Community Leader, Rival, Mentor
- Streaks: 3-Day, 7-Day, 30-Day, 100-Day, Unstoppable, Legend

**Badge states:**
- Earned: Full color emoji, name visible
- In-progress: Grey, progress % shown (e.g., "3/5km")
- Locked: Grey, lock icon overlay

**Layout:** Category `TabBar` pill + 3-column `GridView` + summary card (earned/total/%).

**Data:** Mock only for now (no backend table).

---

### ChallengesScreen (`lib/screens/challenges_screen.dart`)

**Reference:** `RunApp/app/screens/ChallengesScreen.jsx`

**Tabs:** Active / Upcoming / Completed

**Card layout:** Gradient background, challenge name, description, progress bar, days remaining, join toggle

**Stats strip:** Total challenges / Active this month / All-time completed

**Data:** Mock only for now (no backend table).

---

### SettingsScreen (`lib/screens/settings_screen.dart`)

**Reference:** `RunApp/app/screens/SettingsScreen.jsx`

**Sections:**
- Profile quick-edit: avatar grid + name field, "Save" button → `SocialService.updateProfile()`
- Notifications: `Switch` → `SettingsProvider.toggleNotifications()`
- Privacy: Public/Private `Switch` → `SettingsProvider.togglePrivacy()`
- Units: km / mi pill toggle → `SettingsProvider.setUnits()`
- Weight: `TextField` (numeric) → `SettingsProvider.setWeightKg()`
- Logout: `TextButton` with red color → `AlertDialog` confirmation → `AuthService.logout()` → clear providers → `context.go('/onboarding')`
- Delete Account: red `TextButton` → `AlertDialog` with destructive styling → API call (not yet implemented on backend)

---

### NotificationsScreen (`lib/screens/notifications_screen.dart`)

**Reference:** `RunApp/app/screens/NotificationsScreen.jsx`

**Layout:**
- "Clear all" button (top right)
- Grouped sections: "Today" + "Earlier"
- Each item: left accent bar (if unread) + unread dot + icon + title + body + timestamp
- Tap → mark as read (local state)
- Empty state: icon + "No notifications yet"

**Notification types + icons:** Capture 🚩, Friend request 👥, Achievement 🏆, Challenge ⚡, Level-up ⬆️

**Data:** Mock for now (no server notification fetching).

---

## Widgets

### ShimmerBox (`lib/widgets/shimmer_box.dart`)

Animated loading skeleton. No external package — pure `AnimationController` + `LinearGradient` sweep.

```dart
ShimmerBox(height: 120, borderRadius: AppRadius.card)          // full-width
ShimmerBox(width: 80, height: 16, borderRadius: AppRadius.sm_) // fixed width
ShimmerList(count: 5, itemHeight: 60)                          // column of N shimmer rows
```

---

### ErrorState (`lib/widgets/error_state.dart`)

Full-area error display with ⚠️, message text, and a pill RETRY button.

```dart
ErrorState(message: 'Could not load data', onRetry: _load)
```

---

### EmptyState (`lib/widgets/empty_state.dart`)

Full-area empty display with emoji, title, subtitle, and optional gradient action button.

```dart
EmptyState(
  emoji: '👥',
  title: 'No friends yet',
  subtitle: 'Search for runners to add',
  actionLabel: 'Find Runners',    // optional
  onAction: () => ...,            // optional
)
```

---

### AuthInput (`lib/widgets/auth_input.dart`)

**Ref:** `RunApp/app/components/AuthInput.jsx`

```dart
class AuthInput extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final String? errorText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  // ...
}
```

Dark filled `TextField` with icon prefix. Error state changes border to `AppColors.error`.

---

### OtpInput (`lib/widgets/otp_input.dart`)

**Ref:** `RunApp/app/components/OtpInput.jsx`

6 individual `TextField` boxes in a `Row`. Auto-focus advances on digit entry. Backspace focuses previous.

---

### StatBadge (`lib/widgets/stat_badge.dart`)

**Ref:** `RunApp/app/components/StatBadge.jsx`

Small pill showing XP or badge info. Used in activity feeds + run summaries.

---

### TabBarPill (`lib/widgets/tab_bar_pill.dart`)

**Ref:** `RunApp/app/components/TabBar.jsx`

Segmented pill control. Selected tab: accent background + white text. Unselected: transparent + muted text.

---

### WeeklyBarChart (`lib/widgets/weekly_bar_chart.dart`)

**Ref:** `RunApp/app/components/WeeklyBarChart.jsx`

7-bar animated chart painted via `CustomPainter` or `fl_chart` package. Today's bar in accent color. Bars animate height from 0 on appear.

---

### MapOverlayCard (`lib/widgets/map_overlay_card.dart`)

**Ref:** `RunApp/app/components/MapOverlayCard.jsx`

Glassmorphism card (`BackdropFilter` + `ClipRRect`). Shows 4 today stats + "START RUN" button. Positioned at bottom of HomeScreen stack.

---

## Providers (Riverpod)

### UserProvider (`lib/providers/user_provider.dart`)

```dart
class UserNotifier extends StateNotifier<UserModel?> {
  // Persists to SharedPreferences
  void setUser(UserModel user)
  void logout()
  void addXP(int amount)  // handles leveling: xp_to_next * 1.3 loop
  Future<void> hydrate()  // load from SharedPreferences on app start
}
```

### RunProvider (`lib/providers/run_provider.dart`)

```dart
class RunState {
  double distanceKm;
  int steps;
  int calories;
  int xp;
  int elapsedSeconds;
  bool isRunning;
  bool isPaused;
  List<LatLng> pathCoordinates;
}
// NOT persisted — in-memory only
```

### SettingsProvider (`lib/providers/settings_provider.dart`)

```dart
class SettingsState {
  String units; // 'km' | 'mi'
  int dailyStepGoal; // default 8000
  double weightKg; // default 70.0
  bool notificationsEnabled;
  bool privacyPublic;
}
// Persisted via SharedPreferences
```

---

## Services

### ApiService (`lib/services/api_service.dart`)

Dio instance with:
- `BaseOptions(baseUrl: AppConfig.apiBaseUrl)`
- `InterceptorsWrapper`:
  - `onRequest`: add `Authorization: Bearer <token>` from SecureStorage
  - `onError`: if 401 → call `/auth/refresh` → store new tokens → retry original request
- Singleton pattern

---

### AuthService (`lib/services/auth_service.dart`)

```dart
Future<AuthResult> signUp(SignUpParams params)
Future<AuthResult> login(String email, String password)
Future<AuthResult> loginWithGoogle(String googleAccessToken)
Future<void> sendOtp(String email)
Future<String> verifyOtp(String email, String otp)  // returns resetToken
Future<void> resetPassword(String resetToken, String newPassword)
Future<void> logout()
Future<void> refreshAccessToken()
Future<bool> hasSession()
Future<String?> getAccessToken()
```

Token storage: `flutter_secure_storage` keys `runworld_access_token` + `runworld_refresh_token`.

---

### FitnessService (`lib/services/fitness_service.dart`)

```dart
Future<RunSession> saveSession(SaveSessionParams params)
Future<List<RunSession>> getHistory({int limit = 20, int offset = 0})
Future<WeeklyStats> getWeeklyStats()
Future<TodayStats> getTodayStats()
```

---

### MapService (`lib/services/map_service.dart`)

```dart
Future<List<Territory>> getTerritories({MapBounds? bounds})
Future<Territory> captureTerritory(String zoneId)
Future<List<Territory>> getUserTerritories(String userId)
Future<TerritoryStats> getTerritoryStats(String userId)
MapBounds regionToBounds(CameraPosition camera)
```

---

### LeaderboardService (`lib/services/leaderboard_service.dart`)

```dart
Future<List<LeaderboardEntry>> getCityLeaderboard(String period)  // 'week' | 'all'
Future<List<LeaderboardEntry>> getFriendsLeaderboard(String period)
Future<List<LeaderboardEntry>> getNearbyLeaderboard()
```

---

### SocialService (`lib/services/social_service.dart`)

```dart
Future<List<Friend>> getFriends()
Future<List<FriendRequest>> getFriendRequests()
Future<void> sendFriendRequest(String toId)
Future<void> acceptFriendRequest(String requestId)
Future<void> declineFriendRequest(String requestId)
Future<List<FeedItem>> getActivityFeed()
Future<UserProfile> getUserProfile(String userId)
Future<UserProfile> updateProfile(String userId, UpdateProfileParams params)
Future<List<UserProfile>> searchUsers(String query)
```

---

### NotificationsService (`lib/services/notifications_service.dart`)

```dart
Future<void> initialize()
Future<void> registerPushToken(String token)
Future<void> scheduleRunReminder()
```

---

## Utils

### haptics.dart (`lib/utils/haptics.dart`)

Thin wrapper around Flutter's built-in `HapticFeedback`. No new package — uses `VIBRATE` permission already in manifest.

```dart
AppHaptics.light()       // tab changes, selection
AppHaptics.medium()      // run start/resume
AppHaptics.heavy()       // run stop, major events
AppHaptics.selection()   // pause
AppHaptics.celebrate()   // double-heavy burst for level-up / badge unlock
```

---

### fitness_calc.dart (`lib/utils/fitness_calc.dart`)

```dart
// MET formula: Calories = MET × weightKg × durationHours
int calcCalories({required String activityType, required double weightKg, required int durationSeconds}) {
  final met = activityType == 'running' ? 9.8 : 3.5;
  final durationHours = durationSeconds / 3600;
  return (weightKg * met * durationHours).round();
}

// minutes per km
String calcPace({required double distanceKm, required int durationSeconds}) {
  if (distanceKm == 0) return '--:--';
  final pace = (durationSeconds / 60) / distanceKm;
  final mins = pace.floor();
  final secs = ((pace - mins) * 60).round();
  return '$mins:${secs.toString().padLeft(2, '0')}';
}

// XP formula
int calcXP({required int durationSeconds, required double distanceKm}) {
  final baseXP = (durationSeconds / 60) * 10;
  final distanceBonus = distanceKm * 20;
  return (baseXP + distanceBonus).round();
}

// Haversine distance between two GPS points (meters)
double haversineDistance(double lat1, double lon1, double lat2, double lon2)
```

---

## Models

All models have `fromJson(Map<String, dynamic>)` + `toJson()` methods.

| Model | Key Fields |
|-------|-----------|
| `UserModel` | id, name, email, avatar, level, xp, xp_to_next, streak, territory_percent, total_distance_km, total_steps, push_token |
| `RunSessionModel` | id, user_id, activity_type, distance_km, duration_seconds, steps, calories, xp_earned, territory_captured, path_coordinates, badges_unlocked, created_at |
| `TerritoryModel` | id, name, ownerColor, coordinates, owner_id, isOwn |
| `FriendModel` | id, name, avatar, level, streak, territory_percent |
| `LeaderboardEntryModel` | id, rank, name, avatar, level, xp, distanceKm, territoryPercent, isYou |
| `FeedItemModel` | id, friendName, friendAvatar, type, distanceKm, xpEarned, when |

---

## pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^13.0.0
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0
  google_maps_flutter: ^2.6.0
  geolocator: ^11.0.0
  pedometer: ^4.0.0
  google_sign_in: ^6.2.0
  flutter_animate: ^4.5.0
  fl_chart: ^0.68.0
  share_plus: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  flutter_lints: ^3.0.0
```

**Fonts (pubspec.yaml assets):**
```yaml
fonts:
  - family: BebasNeue
    fonts:
      - asset: assets/fonts/BebasNeue-Regular.ttf
  - family: DMSans
    fonts:
      - asset: assets/fonts/DMSans-Regular.ttf
      - asset: assets/fonts/DMSans-Medium.ttf
        weight: 500
      - asset: assets/fonts/DMSans-Bold.ttf
        weight: 700
  - family: JetBrainsMono
    fonts:
      - asset: assets/fonts/JetBrainsMono-Regular.ttf
      - asset: assets/fonts/JetBrainsMono-Bold.ttf
        weight: 700
```
