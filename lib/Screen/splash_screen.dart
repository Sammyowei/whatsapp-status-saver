import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:status_saver/Screen/main_activity.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  void navigate() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (_) => const HomePage()),
          (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: const [
          Image(
            image: AssetImage('assets/whatsapp.png'),
          ),
        ],
      ),
    ));
  }
}
