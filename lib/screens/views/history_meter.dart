import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../logic/dB_meter.dart';
import '../../utils/constants.dart';

class HistoryMeter extends StatefulWidget {
  const HistoryMeter(
      {super.key,
      required this.maxDB,
      required this.date,
      required this.time,
      required this.area});

  final double maxDB;
  final String date, time, area;

  @override
  State<HistoryMeter> createState() => _HistoryMeterState();
}

class _HistoryMeterState extends State<HistoryMeter>
    with WidgetsBindingObserver {
  late InterstitialAd interstitialAd;
  bool isInterstitaleLoaded = false;

  // interstitle app id
  var adInterstitaleUnit = "ca-app-pub-3940256099942544/1033173712";

  NativeAd? nativeAd;
  bool isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    initInterstitialAd();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   if (isInterstitaleLoaded) {
  //     interstitialAd.show();
  //   }
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //
  //   if(state == AppLifecycleState.paused) {
  //     if (isInterstitaleLoaded) {
  //       interstitialAd.show();
  //     }
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadNativeAd();
  }

  void loadNativeAd() {
    nativeAd = NativeAd(
      adUnitId: "ca-app-pub-3940256099942544/2247696110",
      factoryId: "listTileMedium",
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          isNativeAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        nativeAd!.dispose();
      }),
      request: const AdRequest(),
    );
    nativeAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isInterstitaleLoaded) {
          interstitialAd.show();
          return false; // Prevent the default back navigation
        } else {
          return true; // Allow the default back navigation
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              icon: Image.asset(
                'assets/images/back.png',
                height: 28,
                width: 28,
              ),
              onPressed: () {
                if (isInterstitaleLoaded) {
                  interstitialAd.show();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "History Meter ",
              style: kAppbarStyle,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(height: 330, child: dBMeter(widget.maxDB)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Noise Detected :",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        " ${widget.maxDB.toStringAsFixed(2)} dB",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1C95FF)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text("Area : ${widget.area}",
                      style: const TextStyle(fontSize: 13)),
                  SizedBox(
                    height: 4,
                  ),
                  Text("Date : ${widget.date}",
                      style: const TextStyle(fontSize: 13)),
                  SizedBox(
                    height: 4,
                  ),
                  Text("Time : ${widget.time}",
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            )
          ],
        ),
        bottomNavigationBar: isNativeAdLoaded
            ? Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                height: 265,
                child: AdWidget(
                  ad: nativeAd!,
                ),
              )
            : SizedBox(),
      ),
    );
  }

  initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adInterstitaleUnit,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
        interstitialAd = ad;
        setState(() {
          isInterstitaleLoaded = true;
        });
        interstitialAd.fullScreenContentCallback =
            FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
          ad.dispose();

          setState(() {
            isInterstitaleLoaded = false;
          });

          // do your task for close activity
          Navigator.pop(context);
        }, onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();

          setState(() {
            isInterstitaleLoaded = false;
          });
        });
      }, onAdFailedToLoad: (error) {
        interstitialAd.dispose();
      }),
    );
  }
}
