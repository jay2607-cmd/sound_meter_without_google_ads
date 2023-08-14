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
