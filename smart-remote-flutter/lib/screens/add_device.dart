import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../data/ir_database.dart';
import '../models/device.dart';
import '../services/storage_service.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({Key? key}) : super(key: key);

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  int _currentStep = 1;
  DeviceType? _selectedType;
  Brand? _selectedBrand;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<Brand> _filteredBrands = [];

  void _selectType(DeviceType type) {
    setState(() {
      _selectedType = type;
      _filteredBrands = IrDatabase.brands[type.id] ?? [];
      _searchController.clear();
    });
    _goToStep(2);
  }

  void _selectBrand(Brand brand) {
    setState(() {
      _selectedBrand = brand;
      _nameController.text = '${brand.name} ${_selectedType!.name}';
    });
    _goToStep(3);
  }

  void _filterBrands(String query) {
    final list = IrDatabase.brands[_selectedType!.id] ?? [];
    setState(() {
      _filteredBrands = list
          .where((b) => b.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _transmitTestSignal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📡 Transmitting test IR signal (NEC)...'),
        backgroundColor: AppColors.purple,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _saveDevice() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name'), backgroundColor: AppColors.red),
      );
      return;
    }

    final devices = await StorageService.loadDevices();
    final newDev = SmartDevice(
      id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
      type: _selectedType!.id,
      typeIcon: _selectedType!.icon,
      typeName: _selectedType!.name,
      brand: _selectedBrand!.id,
      brandName: _selectedBrand!.name,
      name: name,
      isPoweredOn: false,
      addedAt: DateTime.now().toIso8601String(),
    );

    devices.add(newDev);
    await StorageService.saveDevices(devices);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $name added successfully!'),
        backgroundColor: AppColors.green,
      ),
    );

    Navigator.pop(context);
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _goBack() {
    if (_currentStep > 1) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String stepLabel = 'Select device type';
    if (_currentStep == 2) stepLabel = 'Select brand';
    if (_currentStep == 3) stepLabel = 'Test device';
    if (_currentStep == 4) stepLabel = 'Name your device';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDim),
          onPressed: _goBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Device',
              style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              stepLabel,
              style: const TextStyle(color: AppColors.textDim, fontSize: 11),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Wizard step progress bars
          _buildProgressIndicator(),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildStepContent(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(7, (index) {
          if (index % 2 == 0) {
            // Circle Dot
            final stepNum = (index ~/ 2) + 1;
            final isDone = stepNum < _currentStep;
            final isActive = stepNum == _currentStep;
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.purple
                    : isActive
                        ? AppColors.blue
                        : AppColors.bg3,
                border: Border.all(
                  color: isDone
                      ? AppColors.purple
                      : isActive
                          ? AppColors.blue
                          : AppColors.cardBorder,
                  width: 2,
                ),
                boxShadow: isActive
                    ? AppColors.neonGlow(color: AppColors.blue, blurRadius: 8)
                    : null,
              ),
            );
          } else {
            // Line
            final lineNum = index ~/ 2;
            final isDone = lineNum < _currentStep - 1;
            return Expanded(
              child: Container(
                height: 2,
                color: isDone ? AppColors.purple : AppColors.cardBorder,
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1SelectType();
      case 2:
        return _buildStep2SelectBrand();
      case 3:
        return _buildStep3TestSignal();
      case 4:
        return _buildStep4NameAndSave();
      default:
        return Container();
    }
  }

  Widget _buildStep1SelectType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What device do you want to add?',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFCDBEEF)),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: IrDatabase.types.length,
          itemBuilder: (context, index) {
            final t = IrDatabase.types[index];
            return GestureDetector(
              onTap: () => _selectType(t),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                      t.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFCDBEEF), fontSize: 11),
                    )
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildStep2SelectBrand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select ${_selectedType?.name} Brand',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFCDBEEF)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: _filterBrands,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '🔍 Search brand...',
            hintStyle: const TextStyle(color: AppColors.textDim),
            filled: true,
            fillColor: AppColors.bg3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.blue),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _filteredBrands.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final b = _filteredBrands[index];
              return InkWell(
                onTap: () => _selectBrand(b),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bg3,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        b.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textDim, size: 16)
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildStep3TestSignal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_selectedType?.icon ?? '📺', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Test Your Device',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Point your phone at the device and tap the button below. The app will send a Power signal.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDim, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _transmitTestSignal,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('📡 Send Test Signal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _goToStep(4),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('✅ It Worked!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trying alternate timing sets...')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('❌ Try Different Code', style: TextStyle(color: AppColors.textDim)),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4NameAndSave() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✨', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Name Your Device',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Give a custom name for your device (e.g., "Bedroom TV", "Living Room AC")',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textDim, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'My Device',
              hintStyle: const TextStyle(color: AppColors.textDim),
              filled: true,
              fillColor: AppColors.bg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.blue),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveDevice,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('💾 Save Device', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
