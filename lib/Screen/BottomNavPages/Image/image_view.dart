import 'dart:developer';
import 'dart:io';
import 'package:status_saver/Provider/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_api/flutter_native_api.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

const int maxFailedLoadAtempts = 3;

class ImageView extends StatefulWidget {
  final String? imagePath;
  const ImageView({Key? key, this.imagePath}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  int _interstitialLoadAttempts = 0;

  InterstitialAd? _interstitialAd;

  ///list of buttons
  List<Widget> buttonsList = const [
    Icon(
      Icons.download,
      color: Colors.white,
    ),
    Icon(
      Icons.print,
      color: Colors.white,
    ),
    Icon(
      Icons.share,
      color: Colors.white,
    ),
  ];

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

    _createInterstitialAd();
  }

  @override
  void dispose() {
    super.dispose();

    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            image: DecorationImage(
              fit: BoxFit.contain,
              image: FileImage(
                File(widget.imagePath!),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(buttonsList.length, (index) {
              return FloatingActionButton(
                backgroundColor: Colors.green,
                heroTag: "$index",
                onPressed: () async {
                  await _showInterstitialAd();

                  Future.delayed(
                    const Duration(seconds: 6),
                  );
                  switch (index) {
                    case 0:
                      log("download image");
                      ImageGallerySaver.saveFile(widget.imagePath!)
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Image Saved")));
                      });
                      break;
                    case 1:
                      log("Print");
                      FlutterNativeApi.printImage(
                          widget.imagePath!, widget.imagePath!.split("/").last);
                      break;
                    case 2:
                      log("Share");
                      FlutterNativeApi.shareImage(widget.imagePath!);
                      break;
                  }
                },
                child: buttonsList[index],
              );
            })),
      ),
    );
  }
}
