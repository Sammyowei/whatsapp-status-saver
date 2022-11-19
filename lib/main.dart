import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/Provider/bottom_nav_provider.dart';
import 'package:status_saver/Provider/getStatusProvider.dart';
import 'package:status_saver/Screen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent));
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => GetStatusProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.dark,
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Colors.green,
            ),
            appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white)),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
