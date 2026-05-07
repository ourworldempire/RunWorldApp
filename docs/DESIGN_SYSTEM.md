# RunWorld Design System

> Source of truth for all UI decisions.
> Flutter implementation: `lib/utils/constants.dart`
> Reference (React Native): `RunApp/app/config/app.config.js`

---

## Color Palette

```dart
class AppColors {
  // Backgrounds
  static const Color primary   = Color(0xFF1A1A2E);  // Deep Navy — main background
  static const Color secondary = Color(0xFF16213E);  // Midnight Blue — card background
  static const Color surface   = Color(0xFF0F3460);  // Dark Sapphire — elevated surface

  // Brand
  static const Color accent    = Color(0xFFE94560);  // Crimson Red — CTAs, active states, own territory
  static const Color highlight = Color(0xFFF5A623);  // Warm Amber — walking mode, secondary highlight

  // Semantic
  static const Color success   = Color(0xFF27C93F);  // Green
  static const Color error     = Color(0xFFFF4444);  // Red

  // Text
  static const Color textLight = Color(0xFFEAEAEA);  // Primary text
  static const Color textMuted = Color(0xFF8892A4);  // Secondary/hint text
  static const Color white     = Color(0xFFFFFFFF);

  // Overlays
  static Color cardGlass = Colors.white.withOpacity(0.05);
  static Color cardGlassBorder = Colors.white.withOpacity(0.1);
}
```

---

## Typography

### Font Families

| Family | Weight | Usage |
|--------|--------|-------|
| Bebas Neue | Regular (400) | Screen titles, logo, display headers |
| DM Sans | Regular (400) | Body text, labels, descriptions |
| DM Sans | Medium (500) | Emphasis, subheadings |
| DM Sans | Bold (700) | Strong text, stats labels |
| JetBrains Mono | Regular (400) | Numbers, stats values, timers, distances |
| JetBrains Mono | Bold (700) | Large number displays (run distance, XP) |

### Text Styles (Flutter)

```dart
class AppTextStyles {
  static const TextStyle displayXL = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 48,
    color: AppColors.textLight,
    letterSpacing: 2,
  );

  static const TextStyle displayLG = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 36,
    color: AppColors.textLight,
    letterSpacing: 1.5,
  );

  static const TextStyle displayMD = TextStyle(
    fontFamily: 'BebasNeue',
    fontSize: 28,
    color: AppColors.textLight,
    letterSpacing: 1,
  );

  static const TextStyle bodyLG = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle bodySM = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'DMSans',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static const TextStyle statXL = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static const TextStyle statLG = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  static const TextStyle statMD = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle statSM = TextStyle(
    fontFamily: 'JetBrainsMono',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}
```

---

## Spacing

```dart
class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}
```

---

## Border Radius

```dart
class AppRadius {
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 16;   // standard card radius
  static const double lg   = 24;
  static const double full = 9999; // pill/circle

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(AppRadius.md));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(AppRadius.full));
}
```

---

## Shadows

```dart
class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
```

---

## Gradients

```dart
class AppGradients {
  static const LinearGradient background = LinearGradient(
    colors: [AppColors.primary, AppColors.secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient card = LinearGradient(
    colors: [Color(0xFF1E2A45), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accent = LinearGradient(
    colors: [AppColors.accent, Color(0xFFB83050)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient highlight = LinearGradient(
    colors: [AppColors.highlight, Color(0xFFD4891F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
```

---

## Glassmorphism Card Pattern

Used for map overlay cards and any overlay on the map.

```dart
Widget glassCard({required Widget child, double? blur}) {
  return ClipRRect(
    borderRadius: AppRadius.cardRadius,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur ?? 10, sigmaY: blur ?? 10),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardGlass,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.cardGlassBorder, width: 1),
        ),
        child: child,
      ),
    ),
  );
}
```

---

## Component Patterns

### Primary Button
```dart
// Full-width, gradient background, Bebas Neue label
Container(
  width: double.infinity,
  height: 54,
  decoration: BoxDecoration(
    gradient: AppGradients.accent,
    borderRadius: AppRadius.cardRadius,
    boxShadow: AppShadows.glow(AppColors.accent),
  ),
  child: TextButton(
    onPressed: onPressed,
    child: Text('LABEL', style: AppTextStyles.displayMD.copyWith(fontSize: 18)),
  ),
)
```

### Secondary Button
```dart
// Outlined, no fill
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.accent),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.cardRadius),
    minimumSize: Size(double.infinity, 54),
  ),
  onPressed: onPressed,
  child: Text('LABEL', style: AppTextStyles.bodyBold.copyWith(color: AppColors.accent)),
)
```

### Card
```dart
Container(
  padding: EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    color: AppColors.secondary,
    borderRadius: AppRadius.cardRadius,
    boxShadow: AppShadows.card,
  ),
  child: child,
)
```

### Input Field
```dart
TextField(
  style: AppTextStyles.bodyLG,
  decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: AppRadius.cardRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.cardRadius,
      borderSide: BorderSide(color: AppColors.accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.cardRadius,
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    prefixIcon: Icon(icon, color: AppColors.textMuted),
    hintStyle: AppTextStyles.bodyLG.copyWith(color: AppColors.textMuted),
    labelStyle: AppTextStyles.bodySM,
  ),
)
```

### Pill TabBar
```dart
// Segmented control — accent fill for active, transparent for inactive
Row(
  children: tabs.map((tab) => Expanded(
    child: GestureDetector(
      onTap: () => onTabChange(tab),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selectedTab == tab ? AppColors.accent : Colors.transparent,
          borderRadius: AppRadius.pillRadius,
        ),
        child: Text(tab, textAlign: TextAlign.center, style: AppTextStyles.bodyBold),
      ),
    ),
  )).toList(),
)
```

---

## Google Maps Dark Style

Apply via `mapStyle` property of `GoogleMap` widget. Full JSON is in `RunApp/app/config/mapStyle.js`. Key settings:
- All geometry fill: `#1A1A2E` (primary)
- Road strokes: `#2A2A4E`
- Labels: `#8892A4` (muted)
- Water: `#0F3460` (surface)
- Parks: `#1E2A3E`

---

## Animation Timings

| Animation | Duration | Easing |
|-----------|----------|--------|
| Screen transition | 300ms | easeInOut |
| Button press scale | 100ms | easeIn |
| Logo entrance | 800ms | easeOut |
| Bar chart bars | 600ms | easeOut |
| XP counter | 1500ms | linear |
| Territory capture ring | 800ms | easeOut |
| Pulse (user location) | 1500ms | easeInOut, repeating |
| Tab switch | 200ms | easeInOut |
| Form shake | 400ms | bouncing |

---

## Icon System

Use `Icons` (Material) for UI icons. For custom/brand icons, use emoji directly in `Text` widget.

Common icons used:
- Location: `Icons.my_location`
- Run: `Icons.directions_run`
- Walk: `Icons.directions_walk`
- Steps: `Icons.directions_walk`
- Calories: `Icons.local_fire_department`
- Distance: `Icons.straighten`
- Time: `Icons.timer`
- Trophy: `Icons.emoji_events`
- Friends: `Icons.people`
- Settings: `Icons.settings`
- Notification: `Icons.notifications`
- Back: `Icons.arrow_back_ios`
- Map: `Icons.map`

---

## Screen Scaffold Pattern

Every screen uses this base pattern:

```dart
Scaffold(
  backgroundColor: AppColors.primary,
  body: SafeArea(
    child: // screen content
  ),
)
```

No `AppBar` — custom top bars built inline for full design control.
