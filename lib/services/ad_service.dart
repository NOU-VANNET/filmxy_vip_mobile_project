import "package:google_mobile_ads/google_mobile_ads.dart";

bool _testMode = false;

class AdService {
  static Future<InitializationStatus> initialize({
    bool testMode = false,
  }) async {
    _testMode = testMode;
    return await MobileAds.instance.initialize();
  }

  static Future getInterstitialAd({
    required void Function(InterstitialAd ad) callback,
    void Function(LoadAdError err)? onError,
  }) {
    return InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => callback.call(ad),
        onAdFailedToLoad: (e) => onError?.call(e),
      ),
    );
  }

  static Future showAppOpenAd() async {
    return AppOpenAd.load(
      adUnitId: _appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show();
        },
        onAdFailedToLoad: (error) {
          throw Exception("Error while getting app open ad! ${error.message}");
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  static String get _appOpenUnitId =>
      _testMode ? "ca-app-pub-3940256099942544/3419835294" : "";
  static String get _interstitialUnitId =>
      _testMode ? "ca-app-pub-3940256099942544/1033173712" : "";
}
