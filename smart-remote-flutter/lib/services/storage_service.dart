import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device.dart';

class StorageService {
  static const String _keyDevices = 'smartnova_devices';
  static const String _keyState = 'smartnova_state';

  static Future<List<SmartDevice>> loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyDevices);
    if (jsonStr == null) return [];

    try {
      final List<dynamic> list = json.decode(jsonStr);
      return list.map((item) => SmartDevice.fromMap(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveDevices(List<SmartDevice> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final list = devices.map((d) => d.toMap()).toList();
    await prefs.setString(_keyDevices, json.encode(list));
  }

  static Future<Map<String, dynamic>> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyState);
    if (jsonStr == null) return {};

    try {
      return json.decode(jsonStr) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  static Future<void> saveState(Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyState, json.encode(state));
  }
}
