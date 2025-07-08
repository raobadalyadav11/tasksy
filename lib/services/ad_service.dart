import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static BannerAd? _bannerAd;
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  // Test Ad Unit IDs
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  static void initialize() {
    MobileAds.instance.initialize();
  }

  // Banner Ad
  static BannerAd createBannerAd({required Function(Ad) onAdLoaded}) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
  }

  // Interstitial Ad
  static void loadInterstitialAd({required Function(InterstitialAd) onAdLoaded}) {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitialAd(onAdLoaded: (ad) => _interstitialAd = ad);
    }
  }

  // Rewarded Ad
  static void loadRewardedAd({required Function(RewardedAd) onAdLoaded}) {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  static void showRewardedAd({required Function(AdWithoutView, RewardItem) onUserEarnedReward}) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
      _rewardedAd = null;
      loadRewardedAd(onAdLoaded: (ad) => _rewardedAd = ad);
    }
  }

  static void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}