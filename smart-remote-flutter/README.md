# SmartNova — Futuristic Smart Home Remote (Flutter Version)

A premium, native smart home remote control application built with Flutter. It implements the high-fidelity **SmartNova** futuristic glassmorphic aesthetic—featuring a dark violet-black theme, interactive neon indicators, geolocation-linked climate widgets, and state-of-the-art interactive dashboards.

---

## ✨ Features & Port Enhancements

- 🌡️ **Interactive Circular Temperature Painters**: Custom linear gradient dial widgets for AC and Room Climate tracking.
- 🌀 **Animated Rotational Vector Fan Visualizer**: A custom-drawn fan widget with dynamic animation speed linked directly to the Speed setting.
- 💡 **Translucent Frosted Smart Light Dashboard**: Interactive hue spectrum and quick-colors matching dynamic frosted container backdrops.
- 📲 **Step-by-Step Wizard Pairing**: 4-step Pairing/Testing wizard.
- ⏱️ **Active Background Countdown Timers**: Functional countdown timers for AC and Fan power scheduling.
- 🎙️ **Mock IR Transmissions**: Interactive SnackBar toast displaying real hexagonal NEC commands.
- 📍 **GPS Geolocation Climate Tracker**: Interacts with Open-Meteo Weather and AQI APIs via live GPS location coordinates, falling back to Delhi/Mumbai coordinates if denied or offline.
- 💾 **State Persistence**: Uses native SQLite/Key-Value `shared_preferences` storage to persist all paired devices and custom configurations.

---

## 📁 File Structure

All newly created native files are placed under the standard Flutter architecture:

```
smart-remote-flutter/
├── pubspec.yaml                 ← Package configuration & asset declarations
├── README.md                    ← Project instructions
└── lib/
    ├── main.dart                ← Initializer & global theme settings
    ├── theme/
    │   └── colors.dart          ← Hex neon color tokens & shadows
    ├── models/
    │   └── device.dart          ← Serialized SmartDevice model
    ├── data/
    │   └── ir_database.dart     ← Full Brand database of NEC codes
    ├── services/
    │   ├── storage_service.dart ← SharedPreferences reader/writer
    │   └── weather_service.dart ← Open-Meteo + GPS locator service
    └── screens/
        ├── dashboard.dart       ← Frosted main dashboard & climate dial
        ├── add_device.dart      ← Step progress pairing pairing wizard
        ├── tv_remote_screen.dart ← Television & STB D-Pad nav controller
        ├── ac_remote_screen.dart ← Circular AC dial & countdown timers
        ├── lights_remote_screen.dart ← Smart Wi-Fi bulb spectrum & scene presets
        └── fan_remote_screen.dart   ← Spinning vector blade animated controller
```

---

## 🚀 How to Run the App

Ensure you have the Flutter SDK installed on your machine.

### 1. Fetch Dependencies
Navigate to the `smart-remote-flutter` directory in your terminal and execute:
```bash
flutter pub get
```

### 2. Run Locally on Chrome (Web)
Run the application in non-secure test-mode on Google Chrome:
```bash
flutter run -d chrome
```

### 3. Run on Mobile (Android / iOS)
Connect an emulator or local Android/iOS hardware and execute:
```bash
flutter run
```

### 4. Build a Release APK (Android)
To compile a fully bundle-optimized release APK:
```bash
flutter build apk --release
```
The resulting installer will be located in: `build/app/outputs/flutter-apk/app-release.apk`.
