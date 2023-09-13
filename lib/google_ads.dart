//
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
//
// late BannerAd bannerAd;
// bool isLoaded = false;
//
// // testing ad id

// class GoogleAds extends StatefulWidget {
//   const GoogleAds({super.key});
//
//   @override
//   State<GoogleAds> createState() => GoogleAdsState();
// }
//
// class GoogleAdsState extends State<GoogleAds> {
//
//   initBannerAd() {
//     bannerAd = BannerAd(
//       size: AdSize.banner,
//       adUnitId: adBannerUnit,
//       listener: BannerAdListener(onAdLoaded: (ad) {
//         setState(() {
//           isLoaded = true;
//         });
//       }, onAdFailedToLoad: (ad, error) {
//         ad.dispose();
//         print(error);
//       }),
//       request: AdRequest(),
//     );
//
//     bannerAd.load();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
// }
//
//

var adBannerUnit = "ca-app-pub-3940256099942544/6300978111";

var adIntUnit = "ca-app-pub-3940256099942544/1033173712";

var adNativeUnit = "ca-app-pub-3940256099942544/2247696110";

const kPrivacyPolicy =
    "http://ec2-18-116-59-188.us-east-2.compute.amazonaws.com/RonrajTech/RonrajTechPrivacyPolicy.html";

const kShareUrl =
    "https://play.google.com/store/apps/details?id=com.ronrajtech.jg.sounddeciblemeter";
