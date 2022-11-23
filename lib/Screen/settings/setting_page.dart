import 'package:flutter/material.dart';
import 'package:status_saver/Screen/cookiesPage/cookies.dart';
import 'package:status_saver/Screen/policypage/policy.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../Provider/ad_helper.dart';

class MySettingPage extends StatefulWidget {
  const MySettingPage({super.key});

  @override
  State<MySettingPage> createState() => _MySettingPageState();
}

class _MySettingPageState extends State<MySettingPage> {
  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  void _createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.mediumRectangle,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: ((ad, error) {
          ad.dispose();
        }),
      ),
      request: const AdRequest(),
    );
    _bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    _createBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting"),
        elevation: 0,
      ),
      body: SafeArea(
          child: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PolicyPage(),
                  ),
                );
              },
              child: const Text(
                "Privacy Policy                                                                                                         ",
                style: TextStyle(color: Colors.black, fontSize: 20),
              )),
          const SizedBox(
            height: 10,
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CookiePolicyPage(),
                  ),
                );
              },
              child: const Text(
                'Cookie Policy                                                       ',
                style: TextStyle(fontSize: 20, color: Colors.black),
              )),
          const SizedBox(
            height: 100,
          ),
          Center(
            child: Card(
              color: Colors.white,
              elevation: 20,
              child: Container(
                height: _bannerAd.size.height.toDouble(),
                width: _bannerAd.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
          ),
          const SizedBox(
            height: 250,
          ),
          const Text(
            "Version: 1.0.0",
            style: TextStyle(fontSize: 16),
          )
        ],
      )),
    );
  }
}
