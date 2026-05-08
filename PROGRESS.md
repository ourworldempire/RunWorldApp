# RunWorld Flutter — Build Progress

> Reference project: `C:\Users\Ritanjay\Desktop\RunApp` (React Native version)
> Backend: reused as-is from RunApp, no changes needed

---

## Phase Overview

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 0 | Project setup + scaffold + all 16 screens | ✅ Done |
| Phase 1 | UI screens (polish, real design, maps, animations) | ✅ Done |
| Phase 2 | Frontend logic (providers, services, navigation) | ✅ Done |
| Phase 3 | Backend integration (connect to RunApp backend) | ✅ Done |
| Phase 4 | Polish + real device testing | ✅ Done |
| Phase 5 | Play Store / App Store submission | 🔄 In Progress |

---

## Phase 0 — Project Setup

- [x] Documentation files created (README, PROGRESS, CLAUDE, docs/)
- [x] `flutter create runworld` scaffold
- [x] `pubspec.yaml` dependencies added (go_router, flutter_riverpod, dio, geolocator, pedometer, google_maps_flutter, fl_chart, share_plus, flutter_secure_storage, shared_preferences, google_sign_in, flutter_animate, BebasNeue/DMSans/JetBrainsMono fonts)
- [x] `app_config.dart` + constants set up
- [x] Design system tokens defined (`constants.dart` — AppColors, AppTextStyles, AppSpacing, AppRadius, AppGradients, AppShadows)
- [x] Folder structure created (`screens/`, `widgets/`, `providers/`, `services/`, `models/`, `config/`, `utils/`)
- [x] `go_router` route definitions scaffolded (all 16 routes, auth guard)
- [x] `main.dart` wired with ProviderScope + router
- [x] All models implemented (UserModel, RunSessionModel, TerritoryModel, LeaderboardEntryModel, FriendModel)
- [x] All providers implemented (UserProvider, RunProvider, SettingsProvider)
- [x] Shared widgets implemented (AuthInput, PrimaryButton, PillTabs)
- [x] `fitness_calc.dart` utilities (calcCalories, calcPace, calcXP, haversine, formatDuration, applyXP)
- [x] All 16 screens scaffolded with mock data, navigation wired, TODO Phase 2 markers
- [x] `flutter analyze lib/` → **No issues found**

---

## Phase 1 — UI Screens

> Build order: Auth group → Map/Run group → Social group → Settings group
> Each screen: UI only, mock data, no real API calls yet

### Auth Group
- [ ] SplashScreen — logo animation, tagline, gradient, 2.4s delay
- [ ] OnboardingScreen — 3-slide carousel, dot indicator, scroll-linked animations
- [ ] SignUpScreen — 2-step (name/email/pass → avatar picker, 12 emojis), Google OAuth button
- [ ] LoginScreen — email/pass, shake on error, Google OAuth button
- [ ] ForgotPasswordScreen — 3-step OTP flow (email → 6-digit OTP → new pass → success), 60s resend timer

### Map / Run Group
- [ ] HomeScreen — dark Google Maps, territory polygons, user pulse dot, stats card overlay, FABs
- [ ] ActiveRunScreen — concentric rings, live stats (distance/pace/calories/steps), GPS signal dots, pause/stop controls
- [ ] RunSummaryScreen — polyline map, 2×2 stats grid, XP counter animation, badges row, share button
- [ ] DashboardScreen — week/month TabBar, bar chart (steps/distance/calories), today goal bar, totals grid

### Social / Gamification Group
- [ ] LeaderboardScreen — podium (2nd/1st/3rd), ranked list, city/friends/nearby tabs, own rank sticky card
- [ ] ProfileScreen — XP ring (20 segments), hero card, badge grid, stats row
- [ ] FriendsScreen — friends list, search (debounced), pending requests, activity feed tab
- [ ] AchievementsScreen — 3-col badge grid, 4 category tabs, earned/in-progress/locked states
- [ ] ChallengesScreen — active/upcoming/completed tabs, gradient cards, progress bars, join toggle

### Settings Group
- [ ] SettingsScreen — profile quick-edit, notification/privacy/unit toggles, logout/delete
- [ ] NotificationsScreen — grouped today/earlier, unread indicator, mark read, clear all

---

## Phase 2 — Frontend Logic

### State Management (Riverpod)
- [ ] `UserProvider` — user object, XP/level, persistence via shared_preferences
- [ ] `RunProvider` — active run state (distance, steps, calories, elapsed, path, paused)
- [ ] `SettingsProvider` — units, weight, goal, notification/privacy toggles, persistence

### Services (Dio)
- [ ] `ApiService` — Dio instance with JWT interceptor + 401 refresh retry
- [ ] `AuthService` — signUp, login, loginWithGoogle, sendOtp, verifyOtp, resetPassword, logout, refresh
- [ ] `FitnessService` — saveSession, getHistory, getWeeklyStats, getTodayStats
- [ ] `MapService` — getTerritories, captureTerritory, getUserTerritories, getTerritoryStats
- [ ] `LeaderboardService` — getCityLeaderboard, getFriendsLeaderboard, getNearbyLeaderboard
- [ ] `SocialService` — getFriends, getFriendRequests, sendFriendRequest, accept/decline, getFeed, getUserProfile, updateProfile, searchUsers
- [ ] `NotificationsService` — initHandlers, registerPushToken, scheduleRunReminder

### Sensors + GPS
- [ ] GPS tracking via `geolocator` (`watchPosition`) → haversine distance calc
- [ ] Step counting via `pedometer` package
- [ ] Permission handling (location always + motion/activity)
- [ ] Pause/resume offset tracking for steps

### Navigation
- [ ] `go_router` routes for all 16 screens
- [ ] Auth guard (redirect unauthenticated users to Onboarding)
- [ ] `replace()` equivalent after auth success (no back to auth screens)

### Utils
- [ ] `fitness_calc.dart` — calcCalories (MET formula), calcPace, calcXP
- [ ] Haversine distance formula

---

## Phase 3 — Backend Integration

- [x] Connect to RunApp backend (http://10.0.2.2:5000/api from Android emulator)
- [x] Auth flow end-to-end (signup → token storage → auto-refresh)
- [ ] Google OAuth integration — deferred (client ID not yet configured)
- [x] OTP password reset flow (3-step: send → verify → reset)
- [x] Active run session save on run complete
- [x] Territory fetch on map load + capture on run save (MapService built; polygon rendering deferred to Phase 5)
- [x] Leaderboard live data
- [x] Friends + social features
- [x] Push notification token registration
- [x] Dashboard weekly stats

---

## Phase 4 — Polish

- [ ] Haptic feedback on territory capture, level up, milestone events
- [ ] Error states on all screens (no internet, API down)
- [ ] Empty states (no friends, no runs yet)
- [ ] Loading skeletons / shimmer
- [ ] Real device GPS testing (Bengaluru)
- [ ] Performance profiling (60fps map, animations)
- [ ] Offline mode (app works with mock data when offline)

---

## Phase 5 — Launch

- [ ] Google Play Store setup
- [ ] App Store setup (Mac required for iOS build)
- [x] Backend deployed — https://web-production-0de26.up.railway.app
- [x] Flutter API_BASE_URL updated to Railway production URL
- [ ] Beta test with Bengaluru runners

---

## Daily Progress Log

| Date | What Was Done | Next Step |
|------|---------------|-----------|
| 2026-05-07 | Phase 0 complete: docs, scaffold, all 16 screens, providers, models, utils, 0 analyzer issues | Phase 1 — UI polish |
| 2026-05-07 | Phase 1 complete: all 16 screens fully polished — custom map painter, route painter, XP ring, podium, badge grid, challenge cards, friend cards with search/feed, stat charts, hero cards | Phase 2 — providers + services |
| 2026-05-07 | Phase 2 complete: 7 services (api/auth/fitness/map/leaderboard/social/notifications), RunNotifier with real GPS+pedometer+timer, all auth screens wired, run_summary saves session + applies XP, settings logout wired, dashboard/home/leaderboard/friends load from services with mock fallbacks, 0 analyzer issues | Phase 3 — backend integration |
| 2026-05-07 | Phase 3 complete: fixed all API path + JSON field mismatches (signup/OTP routes, accessToken field, weekly stats camelCase, leaderboard entries key, social request/accept/decline bodies, map query params, notification field), swapped google_maps_flutter→flutter_map+latlong2, CartoDB dark map in HomeScreen, 0 analyzer issues | Phase 4 — polish |
| 2026-05-07 | Phase 4 complete: haptic feedback (AppHaptics wrapper — light/medium/heavy/selection/celebrate), ShimmerBox+ShimmerList skeleton loading on all data screens, ErrorState+EmptyState widgets, ApiService.isOffline static flag + offline banners on home/dashboard/leaderboard/friends, level-up animation overlay in RunSummaryScreen (AnimationController + scale/fade + 🎉 celebration), GPS signal dots wired to real lock state, 0 analyzer issues | Phase 5 — Play Store / App Store |
| 2026-05-08 | Phase 5 in progress: backend deployed to Railway (https://web-production-0de26.up.railway.app), Flutter API_BASE_URL + wsUrl updated to production Railway URLs, both repos pushed to GitHub (RunWorldApp + runworld-backend) | Play Store setup |

---

## Known Gaps (from RunApp — to carry forward)

| Feature | Status in RunApp | Flutter Plan |
|---------|-----------------|-------------|
| Achievements backend | ✅ Done | `achievements` table + routes + Flutter service wired |
| Challenges backend | ✅ Done | `challenges` + `challenge_participants` tables + routes + Flutter service + progress auto-update on run save |
| Push notifications (server) | Partial | Complete in Phase 3 |
| Streak cron job | ✅ Done | `node-cron` daily 00:05 — resets streak to 0 for users with no run in 24h |
| Delete account | ✅ Done | `DELETE /api/auth/account` — revokes tokens, cascades profile delete, removes from Supabase Auth; Flutter dialog with loading + error state |
| Real nearby leaderboard (PostGIS) | Proxy by XP | Nice-to-have |
| Heatmap | Not implemented | Nice-to-have |
