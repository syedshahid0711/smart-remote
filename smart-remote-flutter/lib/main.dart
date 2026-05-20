import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/colors.dart';
import 'screens/dashboard.dart';
import 'screens/add_device.dart';
import 'screens/tv_remote_screen.dart';
import 'screens/ac_remote_screen.dart';
import 'screens/lights_remote_screen.dart';
import 'screens/fan_remote_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartNovaApp());
}

class SmartNovaApp extends StatelessWidget {
  const SmartNovaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartNova Remote',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.bg,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg2,
          elevation: 0,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.apply(
                bodyColor: AppColors.text,
                displayColor: AppColors.text,
              ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.blue,
          secondary: AppColors.purple,
          background: AppColors.bg,
          surface: AppColors.bg2,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/add': (context) => const AddDeviceScreen(),
        '/tv': (context) => const TvRemoteScreen(),
        '/ac': (context) => const AcRemoteScreen(),
        '/lights': (context) => const LightsRemoteScreen(),
        '/fan': (context) => const FanRemoteScreen(),
      },
    );
  }
}
