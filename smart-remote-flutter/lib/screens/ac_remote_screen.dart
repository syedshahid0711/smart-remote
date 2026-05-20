import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/device.dart';
import '../services/storage_service.dart';

class AcRemoteScreen extends StatefulWidget {
  const AcRemoteScreen({Key? key}) : super(key: key);

  @override
  State<AcRemoteScreen> createState() => _AcRemoteScreenState();
}

class _AcRemoteScreenState extends State<AcRemoteScreen> {
  late SmartDevice _device;
  bool _initialized = false;

  // AC State
  int _temp = 24;
  String _mode = 'cool'; // 'cool', 'dry', 'fan'
  String _fanSpeed = 'auto'; // 'auto', '1', '2', '3', 'turbo'
  bool _swing = false;
  bool _sleep = false;
  bool _displayOn = true;
  int _timerOff = 0;
  int _timerOn = 0;

  // Countdown timer details
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  String _timerType = ''; // 'OFF' or 'ON'

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _device = ModalRoute.of(context)!.settings.arguments as SmartDevice;
      _loadAcState();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAcState() async {
    final state = await StorageService.loadState();
    final acState = state['ac_${_device.id}'] ?? {};
    
    if (mounted) {
      setState(() {
        _temp = acState['temp'] ?? 24;
        _mode = acState['mode'] ?? 'cool';
        _fanSpeed = acState['fanSpeed'] ?? 'auto';
        _swing = acState['swing'] ?? false;
        _sleep = acState['sleep'] ?? false;
        _displayOn = acState['displayOn'] ?? true;
        _timerOff = acState['timerOff'] ?? 0;
        _timerOn = acState['timerOn'] ?? 0;
      });
      
      if (_timerOff > 0) {
        _startCountdown('OFF', _timerOff);
      } else if (_timerOn > 0) {
        _startCountdown('ON', _timerOn);
      }
    }
  }

  Future<void> _saveAcState() async {
    final state = await StorageService.loadState();
    state['ac_${_device.id}'] = {
      'temp': _temp,
      'mode': _mode,
      'fanSpeed': _fanSpeed,
      'swing': _swing,
      'sleep': _sleep,
      'displayOn': _displayOn,
      'timerOff': _timerOff,
      'timerOn': _timerOn,
    };
    await StorageService.saveState(state);

    // Sync device power state in Dashboard list
    final list = await StorageService.loadDevices();
    final idx = list.indexWhere((d) => d.id == _device.id);
    if (idx >= 0) {
      list[idx].isPoweredOn = _device.isPoweredOn;
      await StorageService.saveDevices(list);
    }
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  void _togglePower() {
    _triggerHaptic();
    _cancelTimer();
    setState(() {
      _device.isPoweredOn = !_device.isPoweredOn;
    });
    _saveAcState();

    _showToast('❄️ AC ${_device.isPoweredOn ? "ON" : "OFF"}');
  }

  void _changeTemp(int delta) {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _temp = (_temp + delta).clamp(16, 30);
    });
    _saveAcState();
    _showToast('Temperature set to $_temp°C');
  }

  void _setMode(String m) {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _mode = m;
    });
    _saveAcState();
    _showToast('Mode: ${m.toUpperCase()}');
  }

  void _setFanSpeed(String speed) {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _fanSpeed = speed;
    });
    _saveAcState();
    _showToast('Fan Speed: ${speed.toUpperCase()}');
  }

  void _toggleSwing() {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _swing = !_swing;
    });
    _saveAcState();
    _showToast('Swing ${_swing ? "ON" : "OFF"}');
  }

  void _toggleSleep() {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _sleep = !_sleep;
    });
    _saveAcState();
    _showToast('🌙 Sleep ${_sleep ? "ON" : "OFF"}');
  }

  void _toggleDisplay() {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _displayOn = !_displayOn;
    });
    _saveAcState();
    _showToast('💡 Display ${_displayOn ? "ON" : "OFF"}');
  }

  void _changeTimerOff(int delta) {
    if (!_device.isPoweredOn) {
      _showToast('Turn AC ON first');
      return;
    }
    _triggerHaptic();
    if (_timerType == 'ON') _cancelTimer();

    setState(() {
      _timerOff = (_timerOff + delta).clamp(0, 24);
    });
    _saveAcState();

    if (_timerOff > 0) {
      _startCountdown('OFF', _timerOff);
    } else {
      _cancelTimer();
    }
  }

  void _changeTimerOn(int delta) {
    if (_device.isPoweredOn) {
      _showToast('Turn AC OFF first');
      return;
    }
    _triggerHaptic();
    if (_timerType == 'OFF') _cancelTimer();

    setState(() {
      _timerOn = (_timerOn + delta).clamp(0, 24);
    });
    _saveAcState();

    if (_timerOn > 0) {
      _startCountdown('ON', _timerOn);
    } else {
      _cancelTimer();
    }
  }

  void _startCountdown(String type, int hours) {
    _countdownTimer?.cancel();
    setState(() {
      _timerType = type;
      _remainingTime = Duration(hours: hours);
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        _executeTimerAction();
        return;
      }
      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
      });
    });
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _countdownTimer = null;
      _timerType = '';
      _remainingTime = Duration.zero;
      _timerOff = 0;
      _timerOn = 0;
    });
    _saveAcState();
  }

  void _executeTimerAction() {
    final prevType = _timerType;
    _cancelTimer();
    setState(() {
      _device.isPoweredOn = (prevType == 'ON');
    });
    _saveAcState();
    _showToast('⏱️ AC turned ${_device.isPoweredOn ? "ON" : "OFF"} via Timer');
    HapticFeedback.vibrate();
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.purple,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDim),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _device.name,
              style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              '${_device.brandName} Air Conditioner',
              style: const TextStyle(color: AppColors.textDim, fontSize: 11),
            )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: GestureDetector(
                onTap: _togglePower,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _device.isPoweredOn ? AppColors.blue : AppColors.textDim,
                      width: 2,
                    ),
                    boxShadow: _device.isPoweredOn
                        ? AppColors.neonGlow(color: AppColors.blue, blurRadius: 12)
                        : null,
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    color: _device.isPoweredOn ? AppColors.blue : AppColors.textDim,
                    size: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Temperature Display dial card
            _buildTemperatureDialCard(),
            const SizedBox(height: 20),

            // Mode Selection
            Text(
              'MODE',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
            ),
            const SizedBox(height: 10),
            _buildModeGrid(),
            const SizedBox(height: 20),

            // Fan Speed Selection
            Text(
              'FAN SPEED',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
            ),
            const SizedBox(height: 10),
            _buildFanSpeedGrid(),
            const SizedBox(height: 20),

            // Swing Sleep Display toggle buttons
            _buildTogglesRow(),
            const SizedBox(height: 20),

            // Auto Timers
            Text(
              'AUTO TIMERS',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
            ),
            const SizedBox(height: 10),
            _buildTimerCard('⏱️ Turn OFF in', _timerOff, (v) => _changeTimerOff(v)),
            const SizedBox(height: 8),
            _buildTimerCard('⏱️ Turn ON in', _timerOn, (v) => _changeTimerOn(v)),

            if (_timerType.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildCountdownCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureDialCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: AcCircularDialPainter(
                      temp: _temp,
                      isPowered: _device.isPoweredOn,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_temp',
                        style: GoogleFonts.orbitron(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: _device.isPoweredOn ? AppColors.blue : AppColors.textDim,
                        ),
                      ),
                      Text(
                        '°C',
                        style: TextStyle(
                          fontSize: 16,
                          color: _device.isPoweredOn ? AppColors.blue : AppColors.textDim,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTempBtn('－', () => _changeTemp(-1)),
              const SizedBox(width: 24),
              Column(
                children: [
                  const Text('Temperature', style: TextStyle(color: AppColors.textDim, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${_mode[0].toUpperCase()}${_mode.substring(1)} Mode',
                    style: const TextStyle(color: AppColors.blue, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              _buildTempBtn('＋', () => _changeTemp(1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildModeGrid() {
    final modes = [
      {'id': 'cool', 'name': 'Cool', 'icon': '❄️'},
      {'id': 'dry', 'name': 'Dry', 'icon': '💧'},
      {'id': 'fan', 'name': 'Fan', 'icon': '🌀'},
    ];
    return Row(
      children: modes.map((m) {
        final active = _mode == m['id'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GestureDetector(
              onTap: () => _setMode(m['id']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  border: Border.all(
                    color: active ? AppColors.blue : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(m['icon']!, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(
                      m['name']!,
                      style: TextStyle(
                        color: active ? AppColors.blue : AppColors.textDim,
                        fontSize: 11,
                        fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFanSpeedGrid() {
    final speeds = [
      {'id': 'auto', 'name': 'Auto'},
      {'id': '1', 'name': 'Low'},
      {'id': '2', 'name': 'Med'},
      {'id': '3', 'name': 'High'},
      {'id': 'turbo', 'name': 'Turbo'},
    ];
    return Row(
      children: speeds.map((s) {
        final active = _fanSpeed == s['id'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: GestureDetector(
              onTap: () => _setFanSpeed(s['id']!),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  border: Border.all(
                    color: active ? AppColors.blue : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  s['name']!,
                  maxLines: 1,
                  style: TextStyle(
                    color: active ? AppColors.blue : AppColors.textDim,
                    fontSize: 10,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTogglesRow() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleBtn(
            '🔄 Swing ${_swing ? "ON" : "OFF"}',
            _swing,
            _toggleSwing,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToggleBtn(
            '🌙 Sleep ${_sleep ? "ON" : "OFF"}',
            _sleep,
            _toggleSleep,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToggleBtn(
            '💡 Display ${_displayOn ? "ON" : "OFF"}',
            _displayOn,
            _toggleDisplay,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bg3,
          border: Border.all(
            color: active ? AppColors.purple : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.purple : AppColors.textDim,
            fontSize: 10,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard(String label, int val, Function(int) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 13)),
          Row(
            children: [
              _buildSmallCircleBtn('－', () => onChange(-1)),
              const SizedBox(width: 12),
              Container(
                constraints: const BoxConstraints(minWidth: 60),
                alignment: Alignment.center,
                child: Text(
                  val > 0 ? '$val hr' : 'OFF',
                  style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              _buildSmallCircleBtn('＋', () => onChange(1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCountdownCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.orange.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _timerType == 'ON' ? '⏳ Turning ON in' : '⏳ Turning OFF in',
            style: const TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                _formatDuration(_remainingTime),
                style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _cancelTimer,
                child: Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.red),
                    color: AppColors.bg3,
                  ),
                  child: const Text('✕', style: TextStyle(color: AppColors.red, fontSize: 12)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTempBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bg3,
          border: Border.all(color: AppColors.cardBorder, width: 2),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 22)),
      ),
    );
  }

  Widget _buildSmallCircleBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bg3,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

// Circular indicator painter for AC remote
class AcCircularDialPainter extends CustomPainter {
  final int temp;
  final bool isPowered;

  AcCircularDialPainter({required this.temp, required this.isPowered});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width, size.height) / 2 - 8;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Paint basePaint = Paint()
      ..color = AppColors.bg3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawCircle(center, radius, basePaint);

    if (isPowered) {
      // Map temperature range (16 to 30)
      final double pct = ((temp - 16) / (30 - 16)).clamp(0.0, 1.0);
      final double sweepAngle = pct * 2 * pi * 0.77; // 280 degrees sweep

      final Paint arcPaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.blue, AppColors.purple],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;

      // Start from top rotated -90 degrees
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AcCircularDialPainter oldDelegate) {
    return oldDelegate.temp != temp || oldDelegate.isPowered != isPowered;
  }
}
