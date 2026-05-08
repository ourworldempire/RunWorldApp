# CLAUDE.md — RunWorld Flutter

> Claude working rules for ALL sessions on this project.
> Read this file + PROGRESS.md before starting any session.

---

## Project Structure

**Flutter app:** `C:\Users\Ritanjay\Desktop\RunWorld\lib\`
**Backend (Node.js/Express):** `C:\Users\Ritanjay\Desktop\RunWorld\backend\`
**Legal pages:** `C:\Users\Ritanjay\Desktop\RunWorld\legal\`

**Docs folder:** `C:\Users\Ritanjay\Desktop\RunWorld\docs\`
- `BACKEND_DOCS.md` — all API endpoints + request/response shapes
- `FRONTEND_DOCS.md` — all screens, widgets, services, providers in Flutter
- `DESIGN_SYSTEM.md` — colors, fonts, spacing constants
- `DATABASE_SCHEMA.md` — full DB schema

---

## Access & Permissions

- Full blanket permission for all file access, folder creation, code generation, and tool usage.
- No need to ask permission for reading/writing files, creating screens, modifying widgets, running code.
- Autonomously take all access needed — file system, code execution, artifact creation.

---

## Token Efficiency (CRITICAL)

- **Minimum output tokens** — be terse.
- **Never repeat unchanged code.** Only output the changed section with `// ... rest unchanged` markers.
- **No filler phrases** — no "Great!", "Sure!", "Here's what I did…"
- **No summaries after code blocks** unless asked.
- **Bullet points** over paragraphs for explanations.
- **Backend logic must be COMPLETE** — never truncate for token savings.

---

## Code Quality Rules

- All code must be **production-grade** — no placeholder logic.
- All service files must have **real function signatures** even before backend wiring.
- Every screen must have **GoRouter navigation** wired from day one.
- Use **async/await** everywhere in Dart — never `.then()` chains.
- Always add **error handling** in service files (try/catch → return mock fallback).
- Comment only **non-obvious logic** — no over-commenting.
- Use **const** constructors wherever possible in Flutter widgets.

---

## Flutter-Specific Rules

- State management: **Riverpod** (`flutter_riverpod`) — no setState except for trivial local UI state
- Navigation: **go_router** — never use Navigator directly
- HTTP: **Dio** with interceptor — never use http package
- Token storage: **flutter_secure_storage** for JWT tokens
- Persistence: **shared_preferences** for user/settings (not Hive, not Sqflite)
- File naming: **snake_case.dart** for all Dart files
- Widget naming: **PascalCase** for widget classes
- Folder structure follows `/lib/screens/`, `/lib/widgets/`, `/lib/providers/`, `/lib/services/`, `/lib/models/`, `/lib/config/`, `/lib/utils/`
- Always use `package:runworld/...` absolute imports
- Prefer `StatelessWidget` + Riverpod over `StatefulWidget` wherever possible
- Use `ConsumerWidget` or `ConsumerStatefulWidget` when reading providers
- Keep build methods lean — extract complex subtrees into private widget methods or separate widget files

---

## UI / Design Rules

- Follow the **RunWorld Design System** in `docs/DESIGN_SYSTEM.md`
- Color palette: Deep Navy + Midnight Blue + Crimson Red + Warm Amber (see constants.dart)
- **Dark-first design always** — no light theme
- Fonts: Bebas Neue (display), DM Sans (body), JetBrains Mono (numbers/stats)
- Use **BackdropFilter + glassmorphism** for overlay cards on map
- Every screen must feel **cohesive** — same spacing, radius, shadow system
- Micro-animations required on: territory capture, XP gain, badge unlock
- Rounded corners: 16px standard (use `AppRadius.md`)
- Haptic feedback on milestone events

---

## File & Folder Conventions

| Type | Pattern | Location |
|------|---------|---------|
| Screen | `snake_case_screen.dart` | `lib/screens/` |
| Widget | `snake_case_widget.dart` | `lib/widgets/` |
| Provider | `snake_case_provider.dart` | `lib/providers/` |
| Service | `snake_case_service.dart` | `lib/services/` |
| Model | `snake_case_model.dart` | `lib/models/` |
| Utils | `snake_case.dart` | `lib/utils/` |

---

## Session Start Checklist

Every new session for RunWorld:
1. Read `CLAUDE.md` (this file) for rules
2. Read `PROGRESS.md` for current phase and last checkpoint
3. Check the **Daily Progress Log** in PROGRESS.md
4. Resume exactly from last checkpoint

---

## End of Session Rules

At end of every session, Claude must:
- Update the **Daily Progress Log** in `PROGRESS.md`
- Mark completed checklist items with `[x]` in PROGRESS.md
- Note next step clearly
- Update `FRONTEND_DOCS.md` if new screens/widgets/services were built

---

## Claude Must Never
- Ask "Should I proceed?" for standard dev tasks — just do it
- Repeat full files when only a section changed
- Add filler phrases
- Skip error handling in service files
- Use light theme for any UI screen
- Use generic fonts (Roboto default, Arial, etc.)
- Break the established color system without being asked
- Use `Navigator.push()` directly (always use go_router)
- Use `setState` when a Riverpod provider should own the state
- Use `.then()` chains instead of async/await

---

## Claude Must Always
- Keep UI dark-themed and cohesive
- Wire go_router navigation from day one
- Keep service files fully functional with real logic + mock fallbacks
- Use the MET formula for calorie calculation: `Calories = MET × weight_kg × duration_hours`
  - Running MET = 9.8, Walking MET = 3.5
- Use the XP formula: `XP = (duration_minutes × 10) + (distance_km × 20)`
- XP leveling: `xp_to_next grows ×1.3 per level` starting at 1000
- Keep mock data available as fallback when backend unreachable
- Backend source is at `backend/` inside this project — check it before making API/logic decisions

---

*This file is the source of truth for all Claude sessions on RunWorld Flutter.*
