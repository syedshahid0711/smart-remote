import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/device.dart';
import '../services/storage_service.dart';

class FanRemoteScreen extends StatefulWidget {
  const FanRemoteScreen({Key? key}) : super(key: key);

  @override
  State<FanRemoteScreen> createState() => _FanRemoteScreenState();
}

class _FanRemoteScreenState extends State<FanRemoteScreen> with SingleTickerProviderStateMixin {
  late SmartDevice _device;
  bool _initialized = false;

  // Fan state
  int _speed = 3; // 1 to 5
  bool _swing = false;
  bool _breezeMode = false;
  bool _nightMode = false;
  int _timerOff = 0;

  // Animation controller for fan rotation
  late AnimationController _rotationController;
  Timer? _timerCountdown;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _device = ModalRoute.of(context)!.settings.arguments as SmartDevice;
      _loadFanState();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _timerCountdown?.cancel();
    super.dispose();
  }

  Future<void> _loadFanState() async {
    final state = await StorageService.loadState();
    final fan = state['fan_${_device.id}'] ?? {};

    if (mounted) {
      setState(() {
        _speed = fan['speed'] ?? 3;
        _swing = fan['swing'] ?? false;
        _breezeMode = fan['breeze'] ?? false;
        _nightMode = fan['night'] ?? false;
        _timerOff = fan['timerOff'] ?? 0;
      });

      _updateAnimationSpeed();

      if (_timerOff > 0) {
        _startTimer(_timerOff);
      }
    }
  }

  Future<void> _saveFanState() async {
    final state = await StorageService.loadState();
    state['fan_${_device.id}'] = {
      'speed': _speed,
      'swing': _swing,
      'breeze': _breezeMode,
      'night': _nightMode,
      'timerOff': _timerOff,
    };
    await StorageService.saveState(state);

    // Sync dashboard list
    final list = await StorageService.loadDevices();
    final idx = list.indexWhere((d) => d.id == _device.id);
    if (idx >= 0) {
      list[idx].isPoweredOn = _device.isPoweredOn;
      await StorageService.saveDevices(list);
    }
  }

  void _updateAnimationSpeed() {
    if (!_device.isPoweredOn) {
      _rotationController.stop();
      return;
    }

    // Set duration based on speed setting (Speed 1 = 1.6s rotation, Speed 5 = 0.3s rotation)
    final double speedFactor = 1.8 - (_speed * 0.3);
    _rotationController.duration = Duration(milliseconds: (speedFactor * 1000).toInt());

    _rotationController.repeat();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  void _togglePower() {
    _triggerHaptic();
    setState(() {
      _device.isPoweredOn = !_device.isPoweredOn;
    });
    _updateAnimationSpeed();
    _saveFanState();
    _showToast('🌀 Fan ${_device.isPoweredOn ? "ON" : "OFF"}');
  }

  void _setSpeed(int speedVal) {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _speed = speedVal;
    });
    _updateAnimationSpeed();
    _saveFanState();
    _showToast('Speed Level: $speedVal');
  }

  void _toggleSwing() {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _swing = !_swing;
    });
    _saveFanState();
    _showToast('Swing ${_swing ? "ON" : "OFF"}');
  }

  void _toggleBreeze() {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _breezeMode = !_breezeMode;
      if (_breezeMode) _nightMode = false;
    });
    _saveFanState();
    _showToast('Breeze Mode ${_breezeMode ? "ON" : "OFF"}');
  }

  void _toggleNightMode() {
    if (!_device.isPoweredOn) return;
    _triggerHaptic();
    setState(() {
      _nightMode = !_nightMode;
      if (_nightMode) _breezeMode = false;
    });
    _saveFanState();
    _showToast('Night Mode ${_nightMode ? "ON" : "OFF"}');
  }

  void _changeTimer(int delta) {
    if (!_device.isPoweredOn) {
      _showToast('Turn Fan ON first');
      return;
    }
    _triggerHaptic();
    setState(() {
      _timerOff = (_timerOff + delta).clamp(0, 12);
    });
    _saveFanState();

    if (_timerOff > 0) {
      _startTimer(_timerOff);
    } else {
      _cancelTimer();
    }
  }

  void _startTimer(int hours) {
    _timerCountdown?.cancel();
    setState(() {
      _remainingTime = Duration(hours: hours);
    });

    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _timerCountdown?.cancel();
    setState(() {
      _timerCountdown = null;
      _remainingTime = Duration.zero;
      _timerOff = 0;
    });
    _saveFanState();
  }

  void _executeTimerAction() {
    _cancelTimer();
    setState(() {
      _device.isPoweredOn = false;
    });
    _updateAnimationSpeed();
    _saveFanState();
    _showToast('⏱️ Fan turned OFF via Timer');
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
              '${_device.brandName} Smart Fan',
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
            // Fan blades visualizer card
            _buildVisualizerCard(),
            const SizedBox(height: 20),

            // Speed select bar
            Text(
              'FAN SPEED',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
            ),
            const SizedBox(height: 10),
            _buildSpeedSelector(),
            const SizedBox(height: 20),

            // Toggles Row (Swing, Breeze, Night)
            _buildTogglesRow(),
            const SizedBox(height: 20),

            // Auto timer card
            Text(
              'AUTO TIMERS',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
            ),
            const SizedBox(height: 10),
            _buildTimerCard(),

            if (_timerCountdown != null) ...[
              const SizedBox(height: 8),
              _buildCountdownCard(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: RotationTransition(
          turns: _rotationController,
          child: SizedBox(
            width: 140,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Fan center hub
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.purple,
                    boxShadow: _device.isPoweredOn
                        ? AppColors.neonGlow(color: AppColors.purple, blurRadius: 10)
                        : null,
                  ),
                ),
                // Blade 1 (Up)
                Positioned(
                  top: 0,
                  child: Container(
                    width: 18,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(_device.isPoweredOn ? 0.95 : 0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(5)),
                    ),
                  ),
                ),
                // Blade 2 (Bottom Left)
                Positioned(
                  bottom: 8,
                  left: 10,
                  child: Transform.rotate(
                    angle: 2.1, // 120 degrees in rad
                    child: Container(
                      width: 18,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(_device.isPoweredOn ? 0.95 : 0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(5)),
                      ),
                    ),
                  ),
                ),
                // Blade 3 (Bottom Right)
                Positioned(
                  bottom: 8,
                  right: 10,
                  child: Transform.rotate(
                    angle: -2.1,
                    child: Container(
                      width: 18,
                      height: 58,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(_device.isPoweredOn ? 0.95 : 0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedSelector() {
    return Row(
      children: List.generate(5, (index) {
        final speedVal = index + 1;
        final active = _speed == speedVal;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: GestureDetector(
              onTap: () => _setSpeed(speedVal),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  border: Border.all(
                    color: active ? AppColors.blue : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$speedVal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: active ? AppColors.blue : AppColors.textDim,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTogglesRow() {
    return Row(
      children: [
        Expanded(
          child: _buildToggleBtn('🔄 Swing ${_swing ? "ON" : "OFF"}', _swing, _toggleSwing),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToggleBtn('🍃 Breeze ${_breezeMode ? "ON" : "OFF"}', _breezeMode, _toggleBreeze),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildToggleBtn('🌙 Night ${_nightMode ? "ON" : "OFF"}', _nightMode, _toggleNightMode),
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

  Widget _buildTimerCard() {
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
          const Text('⏱️ Turn OFF in', style: TextStyle(color: AppColors.textDim, fontSize: 13)),
          Row(
            children: [
              _buildSmallCircleBtn('－', () => _changeTimer(-1)),
              const SizedBox(width: 12),
              Container(
                constraints: const BoxConstraints(minWidth: 60),
                alignment: Alignment.center,
                child: Text(
                  _timerOff > 0 ? '$_timerOff hr' : 'OFF',
                  style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              _buildSmallCircleBtn('＋', () => _changeTimer(1)),
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
          const Text('⏳ Turning OFF in', style: TextStyle(color: AppColors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
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
