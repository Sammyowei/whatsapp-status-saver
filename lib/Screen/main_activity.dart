import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/Provider/ad_helper.dart';
import 'package:status_saver/Provider/bottom_nav_provider.dart';
import 'package:status_saver/Screen/BottomNavPages/Image/image.dart';
import 'package:status_saver/Screen/BottomNavPages/Video/video.dart';
import 'package:status_saver/Screen/settings/setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BannerAd _bottomBannerAd;

  bool isInlineBannerAdLoaded = false;
  bool _isBottomBannerAdLoaded = false;

  void _createBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: ((ad, error) {
          ad.dispose();
        }),
      ),
      request: const AdRequest(),
    );
    _bottomBannerAd.load();
  }

  List<Widget> pages = const [
    ImageHomePage(),
    VideoHomePage(),
  ];

  @override
  void initState() {
    super.initState();
    _createBottomBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
    _bottomBannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavProvider>(builder: (context, nav, child) {
      return Scaffold(
        persistentFooterButtons: _isBottomBannerAdLoaded
            ? [
                Center(
                  child: Container(
                    height: _bottomBannerAd.size.height.toDouble(),
                    width: _bottomBannerAd.size.width.toDouble(),
                    child: AdWidget(ad: _bottomBannerAd),
                  ),
                ),
              ]
            : null,
        appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MySettingPage()));
                  },
                  icon: const Icon(Icons.settings)),
              const SizedBox(
                width: 10.00,
              )
            ],
            elevation: 0,
            title: const Text(
              "WhatsApp Status Saver",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )),
        body: pages[nav.currentIndex],
        bottomNavigationBar: BottomNavigationBar(
            elevation: 0,
            onTap: (value) {
              nav.changeIndex(value);
            },
            currentIndex: nav.currentIndex,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.image,
                  ),
                  label: "Image"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.video_library_rounded), label: "Video"),
            ]),
      );
    });
  }
}
