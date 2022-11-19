import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CookiePolicyPage extends StatefulWidget {
  const CookiePolicyPage({super.key});

  @override
  State<CookiePolicyPage> createState() => _CookiePolicyPageState();
}

class _CookiePolicyPageState extends State<CookiePolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cookie Policy"),
        elevation: 0,
      ),
      body: const SafeArea(
          child: WebView(
        initialUrl: "https://bumble-studio-cookie-policy.netlify.app",
      )),
    );
  }
}
