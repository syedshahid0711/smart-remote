import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/device.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<SmartDevice> _devices = [];
  ClimateData? _climate;
  bool _isLoadingWeather = true;
  String _weatherStatus = 'Loading...';
  Color _weatherStatusColor = AppColors.purple;
  Timer? _weatherTimer;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    // Refresh weather every 5 minutes
    _weatherTimer = Timer.periodic(const Duration(minutes: 5), (_) => _loadWeather());
  }

  @override
  void dispose() {
    _weatherTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    final devs = await StorageService.loadDevices();
    setState(() {
      _devices = devs;
    });
    await _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoadingWeather = true;
    });
    final climate = await WeatherService.fetchClimateData();
    
    String status = 'Optimal';
    Color sc = AppColors.green;
    if (climate.temperature > 35 || climate.humidity > 80) {
      status = 'Warning';
      sc = AppColors.orange;
    }
    if (climate.temperature > 40 || climate.humidity > 90) {
      status = 'Critical';
      sc = AppColors.red;
    }

    if (mounted) {
      setState(() {
        _climate = climate;
        _weatherStatus = status;
        _weatherStatusColor = sc;
        _isLoadingWeather = false;
      });
    }
  }

  void _showDeleteDialog(SmartDevice dev) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          '🗑️ Remove Device?',
          style: GoogleFonts.orbitron(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          '"${dev.name}" will be removed from your dashboard.',
          style: const TextStyle(color: AppColors.textDim, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textDim)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _devices.removeWhere((d) => d.id == dev.id);
              });
              await StorageService.saveDevices(_devices);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Device removed'),
                  backgroundColor: AppColors.purple,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _navigateToDevice(SmartDevice dev) {
    String route = '/tv';
    if (dev.type == 'ac') {
      route = '/ac';
    } else if (dev.type == 'lights') {
      route = '/lights';
    } else if (dev.type == 'fan') {
      route = '/fan';
    }
    Navigator.pushNamed(context, route, arguments: dev).then((_) => _loadAllData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 90.0, top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.bg3,
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Icon(Icons.grid_view_rounded, color: AppColors.textDim, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SmartNova',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Text(
                            'Climate Control',
                            style: TextStyle(color: AppColors.textDim, fontSize: 11),
                          )
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.textDim),
                    onPressed: _loadAllData,
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Spill status bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.purple,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.purple.withOpacity(0.8),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'IR Blaster Ready',
                          style: TextStyle(color: AppColors.textDim, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.black26,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: AppColors.purple,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '100%',
                          style: TextStyle(color: AppColors.textDim, fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Climate environment card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.bg2,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ROOM ENVIRONMENT',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: const Color(0xFFCDBEEF),
                          ),
                        ),
                        Text(
                          _weatherStatus,
                          style: TextStyle(
                            color: _weatherStatusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoadingWeather
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Column(
                                children: [
                                  CircularProgressIndicator(strokeWidth: 2, color: AppColors.blue),
                                  SizedBox(height: 12),
                                  Text(
                                    '📡 Fetching live data from your location...',
                                    style: TextStyle(color: AppColors.textDim, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              // Circular Ring
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: TemperatureArcPainter(
                                          temp: _climate?.temperature ?? 24.0,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text('🌡️', style: TextStyle(fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${_climate?.temperature.toStringAsFixed(1)}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const Text(
                                                '°C',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                          const Text(
                                            'Temperature',
                                            style: TextStyle(
                                              color: AppColors.textDim,
                                              fontSize: 9,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Side lists
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildEnvStackItem('💧', '${_climate?.humidity ?? 55}%', 'Humidity'),
                                    const SizedBox(height: 8),
                                    _buildEnvStackItem('🍃', '${_climate?.aqi.round() ?? 32} AQI', 'Air Quality'),
                                    const SizedBox(height: 8),
                                    _buildEnvStackItem('💨', _climate?.airQualityStatus ?? 'Excellent', 'Air Status'),
                                  ],
                                ),
                              )
                            ],
                          ),
                    if (!_isLoadingWeather && _climate != null) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          '📍 Live • ${_climate!.latitude.toStringAsFixed(2)}, ${_climate!.longitude.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.textDim, fontSize: 10),
                        ),
                      )
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // My Devices Label
              Text(
                'MY DEVICES',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: const Color(0xFFCDBEEF),
                ),
              ),
              const SizedBox(height: 12),

              // My Devices List
              _devices.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('📱', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text(
                            'No Devices Yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCDBEEF),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap "+ Add New Device" to add your TV, AC, Fan or other IR devices.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textDim, fontSize: 12),
                          )
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _devices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final dev = _devices[index];
                        return GestureDetector(
                          onTap: () => _navigateToDevice(dev),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.bg3,
                              border: Border.all(
                                color: dev.isPoweredOn
                                    ? AppColors.blue.withOpacity(0.5)
                                    : AppColors.cardBorder,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: dev.isPoweredOn
                                  ? AppColors.neonGlow(color: AppColors.blue, blurRadius: 10)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.bg2,
                                  ),
                                  child: Text(dev.typeIcon, style: const TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dev.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${dev.brandName} • ${dev.typeName}',
                                        style: const TextStyle(color: AppColors.textDim, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showDeleteDialog(dev),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColors.bg2,
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: const Text('✕', style: TextStyle(color: AppColors.red, fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textDim, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 16),

              // Add Device dashed button
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/add').then((_) => _loadAllData()),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    border: Border.all(
                      color: AppColors.cardBorder,
                      style: BorderStyle.solid, // dashed equivalent in Flutter via simple borders
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('＋', style: TextStyle(color: AppColors.textDim, fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Text(
                        'Add New Device',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildEnvStackItem(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                label,
                style: const TextStyle(color: AppColors.textDim, fontSize: 10),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppColors.bg2,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Dashboard', true, () {}),
          _buildNavItem(Icons.add_circle_outline_rounded, 'Add Device', false, () {
            Navigator.pushNamed(context, '/add').then((_) => _loadAllData());
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? AppColors.purple : AppColors.textDim,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.purple : AppColors.textDim,
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}

// Temperature painter logic mapping the premium circular gradient ring
class TemperatureArcPainter extends CustomPainter {
  final double temp;

  TemperatureArcPainter({required this.temp});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = min(size.width, size.height) / 2 - 8;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Paint basePaint = Paint()
      ..color = AppColors.bg3
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final Paint dashedPaint = Paint()
      ..color = AppColors.cardBorder.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw base ring
    canvas.drawCircle(center, radius, basePaint);
    canvas.drawCircle(center, radius - 10, dashedPaint);

    // Draw dynamic temperature arc (mapping 0°C to 50°C)
    final double pct = ((temp - 0) / 50).clamp(0.0, 1.0);
    final double sweepAngle = pct * 2 * pi * 0.75; // 270 degrees sweep

    final Paint arcPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.red, AppColors.purple, AppColors.blue],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // Center point of arc needs to align with rotate(135deg)
    final double startAngle = 3 * pi / 4; // 135 degrees in radians
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TemperatureArcPainter oldDelegate) {
    return oldDelegate.temp != temp;
  }
}
