import 'dart:developer';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_api/flutter_native_api.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:status_saver/Provider/ad_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const int maxFailedLoadAtempts = 3;

class VideoView extends StatefulWidget {
  final String? videoPath;
  const VideoView({Key? key, this.videoPath}) : super(key: key);

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  int _interstitialLoadAttempts = 0;
  InterstitialAd? _interstitialAd;
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

    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.file(
        File(widget.videoPath!),
      ),
      autoInitialize: true,
      autoPlay: true,
      looping: true,
      aspectRatio: 1 / 1,
      allowFullScreen: true,
      errorBuilder: ((context, errorMessage) {
        return Center(
          child: Text(errorMessage),
        );
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _interstitialAd?.dispose();
    _chewieController!.pause();
    _chewieController!.dispose();
  }

  ///list of buttons
  List<Widget> buttonsList = const [
    Icon(
      Icons.download,
      color: Colors.white,
    ),
    Icon(
      Icons.share,
      color: Colors.white,
    ),
  ];

  ChewieController? _chewieController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Chewie(controller: _chewieController!),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(buttonsList.length, (index) {
              return FloatingActionButton(
                backgroundColor: Colors.green,
                heroTag: "$index",
                onPressed: () async {
                  switch (index) {
                    case 0:
                      log("download video");
                      ImageGallerySaver.saveFile(widget.videoPath!).then(
                        (value) async {
                          await _showInterstitialAd().whenComplete(
                            () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Video Saved"),
                              ),
                            ),
                          );
                        },
                      );
                      break;

                    case 1:
                      log("Share");
                      FlutterNativeApi.shareImage(widget.videoPath!);

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
