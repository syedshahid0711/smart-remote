import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/device.dart';
import '../services/storage_service.dart';

class LightsRemoteScreen extends StatefulWidget {
  const LightsRemoteScreen({Key? key}) : super(key: key);

  @override
  State<LightsRemoteScreen> createState() => _LightsRemoteScreenState();
}

class _LightsRemoteScreenState extends State<LightsRemoteScreen> {
  late SmartDevice _device;
  bool _initialized = false;

  // Lights state
  bool _on = true;
  int _brightness = 70;
  Color _color = Colors.white;
  String _sceneName = 'Warm White';
  double _hueValue = 0.0; // Slider value for custom hue selection (0 to 360)

  final List<Map<String, dynamic>> _quickColors = [
    {'name': 'White', 'color': Colors.white},
    {'name': 'Warm', 'color': const Color(0xFFFFCC44)},
    {'name': 'Red', 'color': const Color(0xFFFF4444)},
    {'name': 'Blue', 'color': const Color(0xFF44AAFF)},
    {'name': 'Green', 'color': const Color(0xFF44FF88)},
    {'name': 'Purple', 'color': const Color(0xFFAA44FF)},
    {'name': 'Orange', 'color': const Color(0xFFFF8844)},
  ];

  final List<Map<String, dynamic>> _scenes = [
    {'id': 'warm', 'name': 'Warm', 'emoji': '🌅', 'color': const Color(0xFFFFCC44), 'bright': 70, 'lbl': 'Warm White'},
    {'id': 'cool', 'name': 'Cool', 'emoji': '❄️', 'color': const Color(0xFF44AAFF), 'bright': 80, 'lbl': 'Cool White'},
    {'id': 'movie', 'name': 'Movie', 'emoji': '🎬', 'color': const Color(0xFF220044), 'bright': 15, 'lbl': 'Movie Mode'},
    {'id': 'sleep', 'name': 'Sleep', 'emoji': '🌙', 'color': const Color(0xFF442200), 'bright': 5, 'lbl': 'Sleep Mode'},
    {'id': 'party', 'name': 'Party', 'emoji': '🎉', 'color': const Color(0xFFFF44AA), 'bright': 100, 'lbl': 'Party Mode'},
    {'id': 'focus', 'name': 'Focus', 'emoji': '💻', 'color': Colors.white, 'bright': 100, 'lbl': 'Focus Mode'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _device = ModalRoute.of(context)!.settings.arguments as SmartDevice;
      _loadLightsState();
      _initialized = true;
    }
  }

  Future<void> _loadLightsState() async {
    final state = await StorageService.loadState();
    final lights = state['lights_${_device.id}'] ?? {};

    if (mounted) {
      setState(() {
        _on = lights['on'] ?? true;
        _brightness = lights['brightness'] ?? 70;
        final hexStr = lights['color'] ?? 'FFFFFFFF';
        _color = Color(int.parse(hexStr, radix: 16));
        _sceneName = lights['sceneName'] ?? 'Warm White';
        // Estimate custom hue
        final hsv = HSVColor.fromColor(_color);
        _hueValue = hsv.hue;
      });
    }
  }

  Future<void> _saveLightsState() async {
    final state = await StorageService.loadState();
    state['lights_${_device.id}'] = {
      'on': _on,
      'brightness': _brightness,
      'color': _color.value.toRadixString(16).toUpperCase(),
      'sceneName': _sceneName,
    };
    await StorageService.saveState(state);

    // Sync dashboard power state
    final list = await StorageService.loadDevices();
    final idx = list.indexWhere((d) => d.id == _device.id);
    if (idx >= 0) {
      list[idx].isPoweredOn = _on;
      await StorageService.saveDevices(list);
    }
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  void _togglePower() {
    _triggerHaptic();
    setState(() {
      _on = !_on;
    });
    _saveLightsState();
    _showToast('💡 Lights ${_on ? "ON" : "OFF"}');
  }

  void _setLightState(bool stateVal) {
    _triggerHaptic();
    setState(() {
      _on = stateVal;
    });
    _saveLightsState();
    _showToast('💡 Lights ${_on ? "ON" : "OFF"}');
  }

  void _setBrightness(int v) {
    setState(() {
      _brightness = v;
    });
    _saveLightsState();
  }

  void _setColor(Color c, String label) {
    _triggerHaptic();
    setState(() {
      _color = c;
      _sceneName = label;
      final hsv = HSVColor.fromColor(c);
      _hueValue = hsv.hue;
      _on = true;
    });
    _saveLightsState();
  }

  void _setHue(double h) {
    setState(() {
      _hueValue = h;
      _color = HSVColor.fromAHSV(1.0, h, 1.0, 1.0).toColor();
      _sceneName = 'Custom';
      _on = true;
    });
    _saveLightsState();
  }

  void _setScene(Map<String, dynamic> scene) {
    _triggerHaptic();
    setState(() {
      _color = scene['color'] as Color;
      _brightness = scene['bright'] as int;
      _sceneName = scene['lbl'] as String;
      _on = true;
      final hsv = HSVColor.fromColor(_color);
      _hueValue = hsv.hue;
    });
    _saveLightsState();
    _showToast('Scene: ${scene['name']}');
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
            const Text(
              'Smart Wi-Fi Lights',
              style: TextStyle(color: AppColors.textDim, fontSize: 11),
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
                      color: _on ? AppColors.blue : AppColors.textDim,
                      width: 2,
                    ),
                    boxShadow: _on
                        ? AppColors.neonGlow(color: AppColors.blue, blurRadius: 12)
                        : null,
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    color: _on ? AppColors.blue : AppColors.textDim,
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
            // Preview bulb container
            _buildLightPreviewCard(),
            const SizedBox(height: 16),

            // ON / OFF Row
            _buildOnOffRow(),
            const SizedBox(height: 16),

            // Brightness Slider
            _buildBrightnessSliderSection(),
            const SizedBox(height: 16),

            // Custom Color Picker & Quick list
            _buildColorSection(),
            const SizedBox(height: 20),

            // Scene Presets
            Text(
              'SCENE PRESETS',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
            ),
            const SizedBox(height: 10),
            _buildSceneGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildLightPreviewCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: _on ? _color.withOpacity(0.08) : AppColors.bg2,
        border: Border.all(
          color: _on ? _color.withOpacity(0.4) : AppColors.cardBorder,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Animated light bulb icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _on ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, val, child) {
              return Opacity(
                opacity: 0.3 + (0.7 * val),
                child: Transform.scale(
                  scale: 0.9 + (0.15 * val),
                  child: Text(
                    '💡',
                    style: TextStyle(
                      fontSize: 64,
                      shadows: _on
                          ? [
                              Shadow(
                                color: _color,
                                blurRadius: 20,
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            _sceneName,
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _on ? _color : AppColors.textDim,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Brightness: $_brightness%',
            style: const TextStyle(color: AppColors.textDim, fontSize: 13),
          )
        ],
      ),
    );
  }

  Widget _buildOnOffRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _setLightState(true),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFFFFCC00),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('💡 Turn ON', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _setLightState(false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.cardBorder),
              backgroundColor: AppColors.bg2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('⭕ Turn OFF', style: TextStyle(color: AppColors.textDim, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        )
      ],
    );
  }

  Widget _buildBrightnessSliderSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🔆 Brightness', style: TextStyle(color: AppColors.textDim, fontSize: 13)),
              Text('$_brightness%', style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            min: 1,
            max: 100,
            value: _brightness.toDouble(),
            onChanged: _on ? (val) => _setBrightness(val.toInt()) : null,
            activeColor: AppColors.blue,
            inactiveColor: AppColors.bg3,
          )
        ],
      ),
    );
  }

  Widget _buildColorSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎨 Custom Hue Spectrum', style: TextStyle(color: AppColors.textDim, fontSize: 13)),
          const SizedBox(height: 12),
          // Custom Spectrum Hue bar using a Container gradient background
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: const LinearGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.indigo,
                  Colors.purple,
                  Colors.red,
                ],
              ),
            ),
          ),
          Slider(
            min: 0,
            max: 360,
            value: _hueValue,
            onChanged: _on ? _setHue : null,
            activeColor: Colors.white70,
            inactiveColor: Colors.transparent,
          ),
          const SizedBox(height: 10),
          const Text('Quick Colors', style: TextStyle(color: AppColors.textDim, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _quickColors.map((qc) {
              final active = _color.value == (qc['color'] as Color).value;
              return GestureDetector(
                onTap: () => _setColor(qc['color'] as Color, qc['name'] as String),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: qc['color'] as Color,
                    border: Border.all(
                      color: active ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: (qc['color'] as Color).withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildSceneGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: _scenes.length,
      itemBuilder: (context, index) {
        final sc = _scenes[index];
        final active = _sceneName == sc['lbl'];
        return GestureDetector(
          onTap: () => _setScene(sc),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bg2,
              border: Border.all(
                color: active ? AppColors.blue : AppColors.cardBorder,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(sc['emoji']!, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  sc['name']!,
                  style: TextStyle(
                    color: active ? AppColors.blue : AppColors.text,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
