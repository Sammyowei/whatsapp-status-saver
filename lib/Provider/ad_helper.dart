import 'dart:io';

import 'package:status_saver/Constants/admob_constants.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AdmobAdsUnit.bannerAdId;
    } else if (Platform.isIOS) {
      return AdmobAdsUnit.bannerAdId;
    } else {
      return throw UnsupportedError('Unsupported Platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AdmobAdsUnit.interstitialAdId;
    } else if (Platform.isIOS) {
      return AdmobAdsUnit.interstitialAdId;
    } else {
      return throw UnsupportedError('Unsupported Platform');
    }
  }
}
