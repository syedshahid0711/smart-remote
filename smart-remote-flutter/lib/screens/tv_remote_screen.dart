import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../models/device.dart';
import '../services/storage_service.dart';
import '../data/ir_database.dart';

class TvRemoteScreen extends StatefulWidget {
  const TvRemoteScreen({Key? key}) : super(key: key);

  @override
  State<TvRemoteScreen> createState() => _TvRemoteScreenState();
}

class _TvRemoteScreenState extends State<TvRemoteScreen> {
  late SmartDevice _device;
  bool _initialized = false;
  Map<String, int> _codes = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _device = ModalRoute.of(context)!.settings.arguments as SmartDevice;
      final db = _device.type == 'stb' ? IrDatabase.stbCodes : IrDatabase.tvCodes;
      _codes = db[_device.brand] ?? db['lg'] ?? {};
      _initialized = true;
    }
  }

  void _sendCmd(String cmd) async {
    HapticFeedback.lightImpact();
    
    // Toggle power state locally
    if (cmd == 'power') {
      setState(() {
        _device.isPoweredOn = !_device.isPoweredOn;
      });
      // Save state to Storage
      final list = await StorageService.loadDevices();
      final idx = list.indexWhere((d) => d.id == _device.id);
      if (idx >= 0) {
        list[idx].isPoweredOn = _device.isPoweredOn;
        await StorageService.saveDevices(list);
      }
    }

    final code = _codes[cmd];
    final String msg = code != null
        ? '📡 Transmitting: 0x${code.toRadixString(16).toUpperCase()}'
        : 'Command $cmd not coded';

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
            Text(
              '${_device.brandName} ${_device.typeName}',
              style: const TextStyle(color: AppColors.textDim, fontSize: 11),
            )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: GestureDetector(
                onTap: () => _sendCmd('power'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _device.isPoweredOn ? AppColors.red : AppColors.textDim,
                      width: 2,
                    ),
                    boxShadow: _device.isPoweredOn
                        ? AppColors.neonGlow(color: AppColors.red, blurRadius: 12)
                        : null,
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    color: _device.isPoweredOn ? AppColors.red : AppColors.textDim,
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
          children: [
            // Volume & Channel Card
            _buildVolumeChannelCard(),
            const SizedBox(height: 16),

            // Navigation / D-Pad Card
            _buildNavigationCard(),
            const SizedBox(height: 16),

            // Input / Source Button
            ElevatedButton(
              onPressed: () => _sendCmd('input'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bg3,
                foregroundColor: const Color(0xFFCDBEEF),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: const Text('📡 Input / Source', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            // Number Pad Card
            _buildNumberPadCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChannelCard() {
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
          Text(
            'VOLUME & CHANNEL',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // VOL Col
              Column(
                children: [
                  _buildRemoteBtn('＋', () => _sendCmd('volUp')),
                  const SizedBox(height: 6),
                  const Text('VOL', style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _buildRemoteBtn('－', () => _sendCmd('volDn')),
                ],
              ),
              // Mute Button
              GestureDetector(
                onTap: () => _sendCmd('mute'),
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bg3,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Text('🔇', style: TextStyle(fontSize: 18)),
                ),
              ),
              // CH Col
              Column(
                children: [
                  _buildRemoteBtn('▲', () => _sendCmd('chUp')),
                  const SizedBox(height: 6),
                  const Text('CH', style: TextStyle(color: AppColors.textDim, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  _buildRemoteBtn('▼', () => _sendCmd('chDn')),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNavigationCard() {
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
          Text(
            'NAVIGATION',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
          ),
          const SizedBox(height: 16),
          // D-Pad Grid
          Center(
            child: Column(
              children: [
                // Up row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 56),
                    _buildDpadBtn('▲', () => _sendCmd('up')),
                    const SizedBox(width: 56),
                  ],
                ),
                const SizedBox(height: 6),
                // Left - OK - Right row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDpadBtn('◀', () => _sendCmd('left')),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _sendCmd('ok'),
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.blue, AppColors.purple],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: AppColors.neonGlow(color: AppColors.blue, blurRadius: 10),
                        ),
                        child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildDpadBtn('▶', () => _sendCmd('right')),
                  ],
                ),
                const SizedBox(height: 6),
                // Down row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 56),
                    _buildDpadBtn('▼', () => _sendCmd('down')),
                    const SizedBox(width: 56),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Nav buttons
          Row(
            children: [
              Expanded(child: _buildNavActionBtn('↩️', 'Back', () => _sendCmd('back'))),
              const SizedBox(width: 8),
              Expanded(child: _buildNavActionBtn('🏠', 'Home', () => _sendCmd('home'))),
              const SizedBox(width: 8),
              Expanded(child: _buildNavActionBtn('☰', 'Menu', () => _sendCmd('menu'))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildNumberPadCard() {
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
          Text(
            'NUMBER PAD',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: const Color(0xFFCDBEEF)),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              if (index == 9 || index == 11) return Container();
              final numVal = index == 10 ? 0 : index + 1;
              return InkWell(
                onTap: () => _sendCmd('n$numVal'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.bg3,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$numVal',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildRemoteBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bg3,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Widget _buildDpadBtn(String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.bg3,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(icon, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }

  Widget _buildNavActionBtn(String icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bg3,
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
