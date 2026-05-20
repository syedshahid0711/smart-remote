import 'dart:convert';

class SmartDevice {
  final String id;
  final String type; // 'ac', 'tv', 'fan', 'stb', 'projector', 'speaker', 'lights'
  final String typeIcon;
  final String typeName;
  final String brand;
  final String brandName;
  String name;
  bool isPoweredOn;
  final String addedAt;

  SmartDevice({
    required this.id,
    required this.type,
    required this.typeIcon,
    required this.typeName,
    required this.brand,
    required this.brandName,
    required this.name,
    this.isPoweredOn = false,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'typeIcon': typeIcon,
      'typeName': typeName,
      'brand': brand,
      'brandName': brandName,
      'name': name,
      'on': isPoweredOn,
      'addedAt': addedAt,
    };
  }

  factory SmartDevice.fromMap(Map<String, dynamic> map) {
    return SmartDevice(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      typeIcon: map['typeIcon'] ?? '📱',
      typeName: map['typeName'] ?? '',
      brand: map['brand'] ?? '',
      brandName: map['brandName'] ?? '',
      name: map['name'] ?? '',
      isPoweredOn: map['on'] ?? false,
      addedAt: map['addedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SmartDevice.fromJson(String source) => SmartDevice.fromMap(json.decode(source));
}
