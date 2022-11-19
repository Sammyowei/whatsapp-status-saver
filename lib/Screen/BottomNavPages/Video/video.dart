import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:status_saver/Provider/ad_helper.dart';
import 'package:status_saver/Provider/getStatusProvider.dart';
import 'package:status_saver/Screen/BottomNavPages/Video/video_view.dart';
import 'package:status_saver/Utils/getThumbnails.dart';

const int maxFailedLoadAtempts = 3;
int _maxLoadAttempt = 2;
const _totalLoadAttempt = 1;

class VideoHomePage extends StatefulWidget {
  const VideoHomePage({Key? key}) : super(key: key);

  @override
  State<VideoHomePage> createState() => _VideoHomePageState();
}

class _VideoHomePageState extends State<VideoHomePage> {
  int _interstitialLoadAttempts = 0;

  late BannerAd _inlineBannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInlineBannerAdLoaded = false;
  bool _isFetched = false;

  void _createInlineBannerAd() {
    _inlineBannerAd = BannerAd(
      size: AdSize.fullBanner,
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
            file.getStatus(".mp4");
            Future.delayed(const Duration(microseconds: 1), () {
              _isFetched = true;
            });
          }
          return file.isWhatsappAvailable == false
              ? Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text('WhatsApp is not Available'),
                  ))
              : file.getVideos.isEmpty
                  ? Container(
                      color: Colors.black,
                      child: const Center(
                        child: Text("No Video available"),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        right: 5,
                        left: 5,
                      ),
                      child: GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 3,
                          mainAxisSpacing: 3,
                        ),
                        children: List.generate(file.getVideos.length, (index) {
                          // if (_isInlineBannerAdLoaded && index % 4 == 0) {
                          //   return Container(
                          //     padding: const EdgeInsets.only(
                          //       bottom: 10,
                          //       top: 10,
                          //     ),
                          //     width: _inlineBannerAd.size.width.toDouble(),
                          //     height: _inlineBannerAd.size.height.toDouble(),
                          //     child: AdWidget(ad: _inlineBannerAd),
                          //   );
                          // }
                          final data = file.getVideos[index];
                          return FutureBuilder<String>(
                              future: getThumbnail(data.path),
                              builder: (context, snapshot) {
                                return snapshot.hasData
                                    ? GestureDetector(
                                        onTap: () async {
                                          _maxLoadAttempt = 0;
                                          _maxLoadAttempt += 1;
                                          if (_maxLoadAttempt ==
                                              _totalLoadAttempt) {
                                            await _showInterstitialAd();
                                          }
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (_) => VideoView(
                                                      videoPath: data.path,
                                                    )),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              image: DecorationImage(
                                                  image: FileImage(
                                                      File(snapshot.data!))),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(
                                            color:
                                                Colors.black.withOpacity(0.7)),
                                      );
                              });
                        }),
                      ),
                    );
        }));
  }
}
