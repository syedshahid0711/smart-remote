import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ClimateData {
  final double temperature;
  final int humidity;
  final double aqi;
  final String airQualityStatus;
  final double latitude;
  final double longitude;

  ClimateData({
    required this.temperature,
    required this.humidity,
    required this.aqi,
    required this.airQualityStatus,
    required this.latitude,
    required this.longitude,
  });

  factory ClimateData.mock() {
    return ClimateData(
      temperature: 24.5,
      humidity: 55,
      aqi: 32.0,
      airQualityStatus: 'Good',
      latitude: 19.07,
      longitude: 72.87,
    );
  }
}

class WeatherService {
  static Future<ClimateData> fetchClimateData() async {
    double lat = 19.0760; // Mumbai fallback
    double lon = 72.8777;

    try {
      // 1. Check & Request Location Permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 5),
          );
          lat = position.latitude;
          lon = position.longitude;
        }
      }
    } catch (e) {
      // Log or ignore geolocator error, fallback to default coordinates
    }

    try {
      // 2. Fetch temperature and humidity
      final weatherUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${lat.toStringAsFixed(2)}&longitude=${lon.toStringAsFixed(2)}&current=temperature_2m,relative_humidity_2m,weather_code&timezone=auto'
      );
      final weatherRes = await http.get(weatherUrl).timeout(const Duration(seconds: 4));
      
      double temp = 26.0;
      int hum = 60;
      if (weatherRes.statusCode == 200) {
        final data = json.decode(weatherRes.body);
        temp = (data['current']['temperature_2m'] as num).toDouble();
        hum = (data['current']['relative_humidity_2m'] as num).toInt();
      }

      // 3. Fetch air quality European AQI
      final aqiUrl = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=${lat.toStringAsFixed(2)}&longitude=${lon.toStringAsFixed(2)}&current=european_aqi,pm2_5'
      );
      final aqiRes = await http.get(aqiUrl).timeout(const Duration(seconds: 4));
      
      double aqi = 15.0;
      String airStatus = 'Excellent';
      if (aqiRes.statusCode == 200) {
        final data = json.decode(aqiRes.body);
        aqi = (data['current']['european_aqi'] as num?)?.toDouble() ?? 15.0;
        
        if (aqi > 100) {
          airStatus = 'Hazardous';
        } else if (aqi > 80) {
          airStatus = 'Very Poor';
        } else if (aqi > 60) {
          airStatus = 'Poor';
        } else if (aqi > 40) {
          airStatus = 'Moderate';
        } else if (aqi > 20) {
          airStatus = 'Good';
        } else {
          airStatus = 'Excellent';
        }
      }

      return ClimateData(
        temperature: temp,
        humidity: hum,
        aqi: aqi,
        airQualityStatus: airStatus,
        latitude: lat,
        longitude: lon,
      );
    } catch (e) {
      // Return mock values if API calls failed (offline/throttled)
      return ClimateData.mock();
    }
  }
}
