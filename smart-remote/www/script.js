// ============================================
// SMARTNOVA - Deep Purple AC Dashboard JS
// ============================================

// ---------- App State ----------
const state = {
  devices: {
    ac: { on: false, temp: 24, mode: 'cool', fanSpeed: 'auto', swing: false, timerOff: 0, timerOn: 0, displayOn: true },
  },
  settings: { sound: true, vibration: true }
};

// ---------- Init ----------
window.addEventListener('load', () => {
  loadState();
  syncDashboard();
});

// ---------- State Persistence ----------
function loadState() {
  try {
    const saved = localStorage.getItem('smartnova_state');
    if (saved) {
      const parsed = JSON.parse(saved);
      if (parsed.devices && parsed.devices.ac) Object.assign(state.devices.ac, parsed.devices.ac);
      if (parsed.settings) Object.assign(state.settings, parsed.settings);
    }
  } catch(e) {}
}

function saveState() {
  try { localStorage.setItem('smartnova_state', JSON.stringify(state)); } catch(e) {}
}

// ---------- Dashboard Sync ----------
function syncDashboard() {
  const ac = state.devices.ac;
  
  // Power Button & Status
  const pBtn = document.getElementById('dash-power-btn');
  const statusTxt = document.getElementById('dash-ac-status-text');
  const tempTxt = document.getElementById('dash-ac-temp');
  
  if (pBtn && statusTxt && tempTxt) {
    if (ac.on) {
      pBtn.classList.remove('off');
      pBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18.36 6.64a9 9 0 1 1-12.73 0"/><line x1="12" y1="2" x2="12" y2="12"/></svg> POWER ON`;
      statusTxt.textContent = "ON";
      statusTxt.style.color = "var(--primary-blue)";
      tempTxt.textContent = `${ac.temp}°C`;
    } else {
      pBtn.classList.add('off');
      pBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18.36 6.64a9 9 0 1 1-12.73 0"/><line x1="12" y1="2" x2="12" y2="12"/></svg> POWER OFF`;
      statusTxt.textContent = "OFF";
      statusTxt.style.color = "var(--text-dim)";
      tempTxt.textContent = `--°C`;
    }
  }

  // Modes
  document.querySelectorAll('.mode-tab').forEach(b => b.classList.remove('active'));
  const mBtn = document.getElementById(`mode-${ac.mode}`);
  if (mBtn) mBtn.classList.add('active');

  // Fan
  const fVal = document.getElementById('dash-fan-val');
  if (fVal) {
    if (ac.fanSpeed === 'auto') fVal.textContent = 'Auto';
    else if (ac.fanSpeed === 'turbo') fVal.textContent = 'Turbo';
    else fVal.textContent = `Level ${ac.fanSpeed}`;
  }

  // Swing
  const sVal = document.getElementById('dash-swing-val');
  if (sVal) sVal.textContent = ac.swing ? 'ON' : 'OFF';
}

// ---------- Dashboard Interactions ----------
function toggleDashboardPower() {
  state.devices.ac.on = !state.devices.ac.on;
  vibrate(30); playClick();
  saveState();
  syncDashboard();
  
  // Fake IR blast for dashboard
  if (state.devices.ac.on) showToast("❄️ AC Turned ON");
  else showToast("AC Turned OFF");
}

function setDashMode(mode) {
  if (!state.devices.ac.on) {
    showToast("Turn AC ON first");
    return;
  }
  state.devices.ac.mode = mode;
  vibrate(20); playClick();
  saveState();
  syncDashboard();
}

const FAN_SPEEDS = ['auto', '1', '2', '3', 'turbo'];
function cycleDashFan() {
  if (!state.devices.ac.on) return;
  let idx = FAN_SPEEDS.indexOf(state.devices.ac.fanSpeed);
  idx = (idx + 1) % FAN_SPEEDS.length;
  state.devices.ac.fanSpeed = FAN_SPEEDS[idx];
  vibrate(15); playClick();
  saveState();
  syncDashboard();
}

function toggleDashSwing() {
  if (!state.devices.ac.on) return;
  state.devices.ac.swing = !state.devices.ac.swing;
  vibrate(15); playClick();
  saveState();
  syncDashboard();
}

// ---------- Voice ----------
function openVoiceModal() {
  // If voice modal exists, show it. Otherwise just Toast.
  const modal = document.getElementById('voice-modal');
  if (modal) modal.classList.remove('hidden');
  else showToast("Voice module activated");
}
function closeVoiceModal() {
  const modal = document.getElementById('voice-modal');
  if (modal) modal.classList.add('hidden');
}
function startVoice() {
  showToast("Listening...");
  setTimeout(() => closeVoiceModal(), 2000);
}
function voiceCommand(text) {
  showToast(`Command sent: ${text}`);
  closeVoiceModal();
}

// ---------- Feedback Helpers ----------
function showToast(msg) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = msg;
  toast.classList.remove('hidden');
  toast.style.display = 'block';
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => {
    toast.classList.add('hidden');
    toast.style.display = 'none';
  }, 2500);
}
function vibrate(pattern) {
  if (!state.settings.vibration) return;
  if ('vibrate' in navigator) navigator.vibrate(pattern);
}
function playClick() {
  if (!state.settings.sound) return;
  try {
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain); gain.connect(ctx.destination);
    osc.frequency.value = 880;
    gain.gain.setValueAtTime(0.1, ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.1);
    osc.start(); osc.stop(ctx.currentTime + 0.1);
  } catch(e) {}
}
