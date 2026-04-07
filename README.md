# Breathing Room

<p align="center">
  <img src="app_icon.png" width="120" alt="Breathing Room Logo">
</p>

<p align="center">
  <strong>Your personal companion on the path to a smoke-free life.</strong><br>
  No judgement, just support.
</p>

<p align="center">
  <a href="https://github.com/anindya127/Breathing-Room/releases/latest/download/Breathing-Room-v1.0.0.apk">
    <img src="https://img.shields.io/badge/Download%20APK-v1.0.0-brightgreen?style=for-the-badge&logo=android" alt="Download APK">
  </a>
  <a href="https://github.com/anindya127/Breathing-Room/releases">
    <img src="https://img.shields.io/github/v/release/anindya127/Breathing-Room?style=for-the-badge" alt="Release">
  </a>
  <img src="https://img.shields.io/badge/platform-Android%2013%2B-brightgreen?style=for-the-badge&logo=android" alt="Platform">
  <img src="https://img.shields.io/badge/built%20with-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
</p>

---

## Screenshots

<p align="center">
  <img src="screenshots/home_simple.jpg" width="180" alt="Home - Simple Counter">
  <img src="screenshots/home_coach.jpg" width="180" alt="Home - Coach Mode">
  <img src="screenshots/stats_daily.jpg" width="180" alt="Statistics">
  <img src="screenshots/wallet_coach.jpg" width="180" alt="Wallet">
</p>

<p align="center">
  <img src="screenshots/trophies.jpg" width="180" alt="Trophy Room">
  <img src="screenshots/path.jpg" width="180" alt="Non-Smoker Path">
  <img src="screenshots/wallet_simple.jpg" width="180" alt="Wallet - Simple Mode">
</p>

---

## About

**Breathing Room** is a psychology-based smoking cessation app that combines a simple tracker with smart coaching, financial awareness, and gamification to help you quit smoking at your own pace.

## Features

### Dual-Mode Tracking
- **Simple Counter** -- A clean, pressure-free button to count your daily smokes.
- **Coach Mode** -- The Staircase algorithm gradually reduces your daily limit over time, preventing withdrawal panic.

### Financial Tracker (The Wallet)
- See exactly how much each cigarette costs you.
- Track daily spending and money saved.
- Multi-currency support (USD, EUR, GBP, JPY, INR, and more).

### Statistics (The Time Machine)
- **Daily** -- Hourly bar chart to identify your trigger times.
- **Weekly** -- Monday through Sunday comparison.
- **Monthly** -- 30-day trend line to visualize your progress.

### Achievement System (The Trophy Room)
- 18 badges across 4 categories: Streaks, Reduction, Money, and Milestones.
- Earn rewards like "First Day Under Budget", "Week Warrior", and "Triple Digits".

### Health Journey (The Non-Smoker Path)
- A visual timeline with 12 science-based health milestones.
- From heart rate normalizing (20 minutes) to heart disease risk halved (1 year).
- Progress bar showing your distance to the next milestone.

### Additional
- Light, Dark, and System theme modes.
- Haptic feedback and smooth animations.
- All data stored locally on your device -- your privacy is respected.

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform framework |
| Riverpod | State management |
| sqflite | Local SQLite database |
| fl_chart | Charts and graphs |
| go_router | Navigation and routing |
| shared_preferences | User settings persistence |

## Requirements

- Android 13 (API 33) or higher

## Installation

### Download APK
Download the latest release APK from the [Releases](https://github.com/anindya127/Breathing-Room/releases) page.

### Build from Source
```bash
git clone https://github.com/anindya127/Breathing-Room.git
cd Breathing-Room
flutter pub get
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Project Structure

```
lib/
  main.dart                  # App entry point
  models/                    # Data models (SmokeEntry, Badge, UserSettings, etc.)
  providers/                 # Riverpod state management
  router/                    # GoRouter navigation config
  screens/                   # UI screens
    widgets/                 # Reusable widgets (SmokeButton, IconGrid, etc.)
  services/                  # Database service
  theme/                     # Light and Dark theme definitions
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
