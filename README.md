# 🌌 SmartNova - Futuristic Smart Home Remote Workspace

Welcome to **SmartNova**, a premium, high-fidelity smart home remote control system designed with a cutting-edge dark glassmorphic user interface, neon accents, and interactive visual feedback. 

This repository contains two fully-implemented versions of the SmartNova remote application:
1. **Native Flutter Version (`/smart-remote-flutter`)** - Pure Dart & Flutter port offering native cross-platform capabilities.
2. **Web & Capacitor Version (`/smart-remote`)** - Original HTML/CSS/JS mobile-first implementation.

---

## 📱 1. SmartNova Flutter (`smart-remote-flutter`)
A highly optimized, state-of-the-art Flutter port that brings premium desktop/mobile glassmorphic visual aesthetics and interactive animations to life using native widgets.

### Core Features:
- **Environment & Weather Sync**: Fetches real-time temperature, humidity, and Air Quality Index (AQI) based on your geolocation via the **Open-Meteo API**.
- **Interactive Temperature Indicator**: A beautiful vector-drawn circular custom arc painter that dynamically maps room climate conditions.
- **Wizard Pairing Flow**: A clean 4-step interactive guide to pair new Smart TVs, Air Conditioners, Lights, and Fan brands.
- **Specialized Remote Control Panels**:
  - 📺 **TV Remote**: D-Pad control, volume keys, and full numerical pad.
  - ❄️ **AC Remote**: Gorgeous temperature dial and custom scheduling timers.
  - 💡 **Smart Lights**: Real-time Hue color spectrum slider and a neon pulsing visualizer.
  - 🌀 **Smart Fan**: Multi-speed controller (1-5) that rotates a custom vector-drawn fan blade anim via matching velocities.

### How to Run:
```bash
cd smart-remote-flutter
flutter pub get
flutter run -d chrome
```

---

## 🌐 2. SmartNova Web (`smart-remote`)
The original responsive web app designed with rich glassmorphism effects, dynamic shadows, and CSS3 animations.

### How to Run:
```bash
cd smart-remote
npm install
npm run dev
```

---

## 🎨 UI & Design Tokens
Both applications strictly follow the custom-built **SmartNova Cyber Theme** design tokens:
- **Primary Background**: `#0A0A0F` (ultra-dark deep space blue)
- **Glass Panel**: HSL translucent card layer backed by backdrop blur filter effects.
- **Accents**:
  - 💜 Neon Purple (`#A165FF`)
  - 💙 Electric Cyan (`#00E5FF`)
  - 💚 Cyber Green (`#00F5A0`)
  - ❤️ Neon Red (`#FF5B80`)

---

Developed with 💜 by [Ali](mailto:syedshahid0711@gmail.com).
