import "package:get/get.dart";
import "package:google_mobile_ads/google_mobile_ads.dart";
import "package:vip/services/ad_service.dart";

class AdsController extends GetxController {
  InterstitialAd? ad;

  bool isCanShowAd = true;

  void initializeFirstAd() {
    AdService.showAppOpenAd();
    loadInterstitialAd();
  }

  Future loadInterstitialAd() async =>
      await AdService.getInterstitialAd(
        callback: (interstitialAd) {
          ad = interstitialAd;
          isCanShowAd = true;
          update();
        },
      );

  ///Set the cool down duration for the delay
  Future showInterstitialAd({
    Duration coolDown = const Duration(minutes: 3),
  }) async {
    if (ad != null && isCanShowAd) {
      ad?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (_) => _resetAd(coolDown),
        onAdDismissedFullScreenContent: (_) => _resetAd(coolDown),
      );
      ad?.show();
    }
  }

  Future _resetAd(Duration coolDown) async {
    if (!isCanShowAd) return;
    isCanShowAd = false;
    await ad?.dispose();
    ad = null;
    update();
    Future.delayed(coolDown, () => loadInterstitialAd());
  }

}
