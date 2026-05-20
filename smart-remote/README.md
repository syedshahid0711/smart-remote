# SmartNova — Futuristic Smart Home Remote

> A premium, mobile-first smart home remote control web app built with HTML, CSS, and Vanilla JavaScript. Designed to feel like Samsung SmartThings — dark mode, neon glow, glassmorphism UI.

---

## ✨ Features

- 📺 **TV Remote** — Power, Volume, Channel, D-Pad, Netflix/YouTube/Prime/Hotstar shortcuts
- ❄️ **AC Remote** — Temperature control, Cool/Heat/Dry/Fan modes, speed, swing, sleep, timer
- 🌀 **Fan Control** — 5-speed control, swing, breeze mode, night mode, timer
- 💡 **Smart Lights** — ON/OFF, brightness slider, RGB color picker, 6 scene presets
- 🎙️ **Voice Commands** — Tap to speak (Web Speech API)
- 🎬 **Scene Modes** — Movie, Sleep, AI Scene
- 💾 **State Persistence** — All device states saved via localStorage
- ⚡ **ESP32 Ready** — IR and WiFi command placeholders for future hardware integration

---

## 📁 Folder Structure

```
smart-remote/
│
├── index.html          ← Main dashboard (homepage)
├── style.css           ← All styles (dark theme, animations, glassmorphism)
├── script.js           ← Main JS (state, voice, scenes, settings)
│
├── pages/
│   ├── tv.html         ← Full TV remote
│   ├── ac.html         ← AC controller
│   ├── fan.html        ← Fan controller
│   └── lights.html     ← Smart lights controller
│
├── assets/
│   ├── icons/          ← Custom icons (add your own SVGs here)
│   ├── sounds/         ← Sound files (optional)
│   └── images/         ← App images / splash screens
│
└── README.md
```

---

## 🚀 How to Run in VS Code

### Option 1 — Live Server (Recommended)

1. Open VS Code
2. Install the **Live Server** extension (by Ritwick Dey)
3. Open the `smart-remote/` folder in VS Code
4. Right-click `index.html` → **"Open with Live Server"**
5. App opens at: `http://127.0.0.1:5500`

### Option 2 — Direct Browser

1. Navigate to `smart-remote/` folder
2. Double-click `index.html`
3. Opens in your default browser

> ⚠️ Voice commands require Chrome or Edge (Web Speech API support).

---

## 📱 Convert to Android APK using Capacitor

### Prerequisites

- Node.js (https://nodejs.org)
- Android Studio (https://developer.android.com/studio)
- Java JDK 17+

### Step-by-Step

```bash
# 1. Open terminal inside smart-remote/ folder

# 2. Initialize npm
npm init -y

# 3. Install Capacitor
npm install @capacitor/core @capacitor/cli

# 4. Install Android platform
npm install @capacitor/android

# 5. Initialize Capacitor (answer the prompts)
npx cap init SmartNova com.smartnova.remote --web-dir .

# 6. Add Android platform
npx cap add android

# 7. Copy web files to native project
npx cap copy android

# 8. Open in Android Studio
npx cap open android
```

### In Android Studio

1. Wait for Gradle sync to finish
2. Click **Build → Build Bundle(s)/APK(s) → Build APK(s)**
3. APK will be in: `android/app/build/outputs/apk/debug/`
4. Transfer to your phone and install!

> 💡 For release APK, generate a signing keystore in Android Studio → Build → Generate Signed Bundle/APK.

---

## 🔌 Future ESP32 Integration Guide

The app is already structured for ESP32 WiFi integration.

### How it works

Every button in the app calls one of two functions (defined in `script.js` and each page):

```javascript
// Send Infrared command (TV, AC, Fan remotes)
sendIRCommand(device, command)

// Send WiFi HTTP command (Smart bulbs, direct WiFi devices)
sendWifiCommand(device, command, value)
```

### ESP32 Setup Steps

1. Flash your ESP32 with an HTTP server sketch (Arduino IDE)
2. Connect ESP32 to the same WiFi as your phone
3. Open the app → Settings → Enter the ESP32 IP address
4. Uncomment the `fetch()` lines in `script.js`:

```javascript
// In sendWifiCommand():
fetch(`http://${state.settings.esp32ip}/cmd`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ device, command, value })
});

// In sendIRCommand():
fetch(`http://${state.settings.esp32ip}/ir?device=${device}&cmd=${command}`);
```

### Example ESP32 Arduino Sketch (basic HTTP server)

```cpp
#include <WiFi.h>
#include <WebServer.h>
#include <IRremote.h>

WebServer server(80);
IRsend irsend;

void setup() {
  WiFi.begin("YOUR_SSID", "YOUR_PASSWORD");
  server.on("/ir", HTTP_GET, []() {
    String device = server.arg("device");
    String cmd = server.arg("cmd");
    // Send IR codes based on device + cmd
    server.send(200, "text/plain", "OK");
  });
  server.begin();
}

void loop() {
  server.handleClient();
}
```

---

## 🎨 Tech Stack

| Layer | Tech |
|-------|------|
| Structure | HTML5 |
| Styling | CSS3 (Glassmorphism, Animations) |
| Logic | Vanilla JavaScript |
| Fonts | Google Fonts — Orbitron + Inter |
| Storage | localStorage |
| Voice | Web Speech API |
| APK | Capacitor + Android Studio |
| Hardware (future) | ESP32 + IR Transmitter |

---

## 📸 UI Highlights

- 🌑 Pure dark background (`#0a0a0f`)
- 💠 Blue neon accents (`#00d4ff`)
- 🪟 Glassmorphism cards
- 🌀 Animated fan and loading screen
- 💫 Ripple click effects on every button
- 📳 Haptic vibration feedback (Android)
- 🔊 Audio click feedback via Web Audio API

---

## 🛠️ Customization

- Change accent color: Edit `--blue` in `style.css`
- Add new devices: Copy a page from `pages/`, link it from `index.html`
- Add real IR codes: Fill in the `sendIRCommand()` function with your device's hex codes

---

## 📄 License

MIT License — Free to use, modify, and distribute.

---

*Built with ❤️ by SmartNova | Version 1.0.0*
