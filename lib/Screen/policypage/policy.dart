import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        elevation: 0,
      ),
      body: const SafeArea(
        child: WebView(
            initialUrl: "https://bumble-studio-privacy-policy.netlify.app"),
      ),
    );
  }
}
