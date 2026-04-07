# Breathing Room - Project Status

## What We Have

### Project Skeleton
- Flutter project initialized and runnable
- Standard folder structure: `lib/`, `test/`, `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/`

### Dependencies Installed (pubspec.yaml)
| Package              | Version  | Purpose                  |
|----------------------|----------|--------------------------|
| `flutter`            | SDK      | Framework                |
| `cupertino_icons`    | ^1.0.8   | iOS-style icons          |
| `shared_preferences` | ^2.5.5   | Simple key-value storage |
| `riverpod`           | ^3.2.1   | State management (core)  |
| `flutter_riverpod`   | ^3.3.1   | Riverpod Flutter widgets |

### Code Files
| File | Status |
|------|--------|
| `lib/main.dart` | **Default Flutter template** - generic counter demo, no custom code |
| `test/widget_test.dart` | Default counter test - no custom tests |
| `App_Blueprint.md` | Full architectural spec and 6-phase roadmap |

### What This Means
The project is a **blank slate**. Riverpod and shared_preferences are added to `pubspec.yaml` but **not used anywhere** in the code. `main.dart` is still the default "You have pushed the button this many times" demo.

---

## What We Need To Do

### Missing Dependencies (Need to Add)
| Package    | Purpose                              | Needed In |
|------------|--------------------------------------|-----------|
| `isar` or `sqflite` | Real database for smoke entries | Phase 2 |
| `fl_chart`  | Bar charts for statistics           | Phase 4 |
| `go_router` (optional) | Navigation/routing          | Phase 1 |
| `intl` (optional) | Date/number formatting          | Phase 2+ |

---

### Phase 1: Foundation & Settings - COMPLETE
- [x] Replace default `main.dart` with app entry point using `ProviderScope`
- [x] Create app routing/navigation structure (`go_router`)
- [x] Build **Settings Screen** (pack cost, cigarettes per pack, currency dropdown)
- [x] Build **Mode Selection** (Simple Counter vs Coach Mode)
- [x] Save user preferences with `shared_preferences`
- [x] Set up Light/Dark theme with `ThemeData`
- [x] Design the Home Screen layout
- [x] Build **Onboarding Screen** (3-page setup wizard)

### Phase 2: Tracker & Database - COMPLETE
- [x] Add database package (`sqflite`) to pubspec (replaced `isar`)
- [x] Create data models: `SmokeEntry` (timestamp, cost)
- [x] Build database service (CRUD operations)
- [x] Build **Simple Counter UI** - tap button to log a smoke
- [x] Each tap saves exact timestamp + calculated cost to database
- [x] Display today's count and "Spent Today" total on Home Screen (live)
- [x] Build Riverpod providers for smoke data (`todayEntriesProvider`, `todayCountProvider`, `todaySpentProvider`)
- [x] Undo last entry button
- [x] Haptic feedback on smoke button

### Phase 3: Coach Logic (The Staircase Algorithm) - COMPLETE
- [x] Write the Staircase algorithm: baseline - (steps × reduction) with min 0
- [x] Build the **Icon Grid** showing daily allowance (filled vs empty icons, red for excess)
- [x] Show visual progress: remaining count, near-limit warning, over-limit banner
- [x] Handle edge cases: first day (uses baseline), going over limit (encouraging message)
- [x] Calculate "Money Saved" (baseline vs actual in Coach Mode)
- [x] Onboarding page 4: baseline, reduction amount, reduction interval setup
- [x] Settings screen: editable coach parameters (baseline, reduction, interval)

### Phase 4: Money & Charts (Analytics) - COMPLETE
- [x] `fl_chart` already in pubspec
- [x] Build **Wallet Screen** - total spent, total saved, today breakdown, pack cost info
- [x] Build **Daily View** - hourly bar chart showing when you smoked (trigger patterns)
- [x] Build **Weekly Bar Chart** - Monday through Sunday, today highlighted
- [x] Build **Monthly View** - 30-day line chart with trend + average
- [x] Analytics providers: weekly/monthly counts, hourly breakdown, totals
- [x] Bottom navigation bar (Home, Stats, Wallet) with `StatefulShellRoute`

### Phase 5: Gamification (Rewards & Path) - COMPLETE
- [x] 18 badges across 4 categories: Streaks, Reduction, Money, Milestones
- [x] Badge unlock logic: checks streaks, avoided smokes, money saved, daily averages
- [x] **Trophy Room Screen** — grid of earned/locked badges with progress ring, tap for details
- [x] **Non-Smoker Path Screen** — timeline with 12 science-based health milestones
- [x] Health milestones: heart rate (20 min) through heart disease risk halved (1 year)
- [x] Progress bar showing distance to next milestone
- [x] Added Trophies and Path tabs to bottom navigation (5 tabs total)

### Phase 6: Polish & Launch - COMPLETE
- [x] Refined Light/Dark theme: flat cards, polished nav bar, segmented buttons, snackbar styling
- [x] Added platform-specific page transitions (predictive back on Android, Cupertino on iOS)
- [x] Haptic feedback on smoke button, undo, settings
- [x] Animated smoke button with scale press effect
- [x] Animated counter with fade+slide transitions
- [x] Smooth slide-up transition for settings screen
- [x] Fade transition for onboarding
- [x] App name set to "Breathing Room" in Android manifest and iOS Info.plist
- [ ] Custom app icon (requires design asset — use `flutter_launcher_icons` package when ready)
- [ ] App store preparation (screenshots, description, metadata)

---

## Summary

| Phase | Description              | Status          |
|-------|--------------------------|-----------------|
| 1     | Foundation & Settings    | COMPLETE        |
| 2     | Tracker & Database       | COMPLETE        |
| 3     | Coach Logic (Staircase)  | COMPLETE        |
| 4     | Money & Charts           | COMPLETE        |
| 5     | Gamification & Path      | COMPLETE        |
| 6     | Polish & Launch          | COMPLETE        |

**Current state:** All 6 phases complete. App is fully functional with polished UI, animations, and haptics. Remaining: custom app icon asset and app store metadata.
