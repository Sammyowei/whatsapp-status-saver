import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:status_saver/Provider/getStatusProvider.dart';
import 'package:status_saver/Screen/BottomNavPages/Image/image_view.dart';

import '../../../Provider/ad_helper.dart';

const int maxFailedLoadAtempts = 3;

class ImageHomePage extends StatefulWidget {
  const ImageHomePage({Key? key}) : super(key: key);

  @override
  State<ImageHomePage> createState() => _ImageHomePageState();
}

class _ImageHomePageState extends State<ImageHomePage> {
  int _interstitialLoadAttempts = 0;

  late BannerAd _inlineBannerAd;
  InterstitialAd? _interstitialAd;

  bool _isInlineBannerAdLoaded = false;
  bool _isFetched = false;

  void _createInlineBannerAd() {
    _inlineBannerAd = BannerAd(
      size: AdSize.largeBanner,
      adUnitId: AdHelper.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isInlineBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: ((ad, error) {
          ad.dispose();
        }),
      ),
      request: const AdRequest(),
    );
    _inlineBannerAd.load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_interstitialLoadAttempts >= maxFailedLoadAtempts) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      }, onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      });
      _interstitialAd!.show();
    }
  }

  @override
  void initState() {
    super.initState();
    _createInlineBannerAd();
    _createInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();
    _inlineBannerAd.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white70,
        body: Consumer<GetStatusProvider>(builder: (context, file, child) {
          if (_isFetched == false) {
            file.getStatus(".jpg");
            Future.delayed(const Duration(microseconds: 1), () {
              _isFetched = true;
            });
          }
          return file.isWhatsappAvailable == false
              ? Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(child: Text('Whatsapp is not available')),
                )
              : file.getImages.isEmpty
                  ? Container(
                      color: Colors.black.withOpacity(0.7),
                      child: const Center(
                        child: Text(
                          "No image available",
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.black.withOpacity(0.7),
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 5,
                        right: 5,
                      ),
                      child: GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 3,
                                mainAxisSpacing: 3),
                        children: List.generate(file.getImages.length, (index) {
                          final data = file.getImages[index];
                          return GestureDetector(
                            onTap: () async {
                              await _showInterstitialAd();
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (_) => ImageView(
                                          imagePath: data.path,
                                        )),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.3),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: FileImage(File(data.path))),
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }),
                      ),
                    );
        }));
  }
}
