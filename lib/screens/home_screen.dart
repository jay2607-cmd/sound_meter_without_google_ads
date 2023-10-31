import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_meter/screens/info.dart';

import 'package:sound_meter/screens/recorder_homeview.dart';
import 'package:sound_meter/screens/save_main.dart';
import 'package:sound_meter/screens/views/reusable_grid_view.dart';
import 'package:sound_meter/ump_consent/initialize_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../google_ads.dart';
import '../main.dart';
import '../provider/db_provider.dart';
import 'camera_home.dart';
import 'noise_detector.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  late InterstitialAd interstitialAd;
  bool isInterstitaleLoaded = false;

  var privacyPolicy = Uri.parse(kPrivacyPolicy);

  var dataUsage = Uri.parse(kPrivacyPolicy);

  Future<void>? _launched;

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  // interstitle app id
  var adInterstitaleUnit = "";

  initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: adInterstitaleUnit,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
        interstitialAd = ad;
        isInterstitaleLoaded = true;
        setState(() {});
        interstitialAd.fullScreenContentCallback =
            FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
          ad.dispose();

          setState(() {
            isInterstitaleLoaded = false;
          });

          // do your task for close activity
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(cameras: cameras, logError: logError)));
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

  late SharedPreferences preferences;

  loadIsPersonalised() async {
    preferences = await SharedPreferences.getInstance();
  }

  bool isShowAds = true;

  @override
  void initState() {
    super.initState();

    // DbProvider().getShowAdsState().then((value) {
    //   isShowAds = value;
    //   print("isShowAds sfdfg $isShowAds");
    //
    //   if (isShowAds == true) {
    //     adInterstitaleUnit = adIntUnit;
    //     initInterstitialAd();
    //   } else {
    //     adInterstitaleUnit = "";
    //     initInterstitialAd();
    //   }
    // });

    // loadIsPersonalised();

    Timer(const Duration(milliseconds: 3000), () {
      // show pop up

      // if (isInterstitaleLoaded && isShowAds) {
      //   if (preferences.getBool("isPersonalised") == true) {
      //     interstitialAd.show();
      //   } else {
      //     showExitPopup();
      //   }
      // } else {
      //   if (preferences.getBool("isPersonalised") == true) {
      // Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             HomeScreen(cameras: cameras, logError: logError)));

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => InitializeScreen(
                    targetWidget:
                        HomeScreen(cameras: cameras, logError: logError),
                  )));
      // } else {
      //   // show pop
      //   showExitPopup();
      // }
      // }
    });
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            title: Row(
              children: [
                Image.asset(
                  "assets/images/appicon (1).png",
                  height: 40,
                  width: 40,
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  'Audio Sound Decibel Meter',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            content: Text(
              'We care about your privacy & data security. We keep this app free by showing ads.\n\nWith your permission at launch time we are showing tailor ads to you.\n\nIf you want to change setting of your consent, please click below \'Deactivate\' button.',
            ),
            actions: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (isInterstitaleLoaded) {
                        interstitialAd.show();
                      } else {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen(
                                    cameras: cameras, logError: logError)));
                      }
                      preferences.setBool("isPersonalised", true);
                      print("preferences.getBool('isPersonalised')");
                      print(preferences.getBool("isPersonalised"));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff724BE5), // Set background color
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Add border radius
                      ),
                    ),
                    child: Text('Yes, Continue'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff724BE5),
                      padding: EdgeInsets.symmetric(
                          vertical: 16), // Add vertical padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Add border radius
                      ),
                    ),
                    child: Text('Exit'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _launched = _launchInBrowser(privacyPolicy);
                        });
                      },
                      child: Text("Privacy & Policy")),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _launched = _launchInBrowser(dataUsage);
                        });
                      },
                      child: Text("How App & Our Partners uses your data!")),
                ],
              ),
            ],
          ),
        ) ??
        Future.value(false);
  }

/*  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          color: Colors.white,
          child: Scaffold(
            body: Column(
              children: [
                AssetImage(""),
                SizedBox(height: 30,),
                Text("Noise Detector"),
              ],
            ),
          ),
        ),
      ),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(
                  "assets/images/splash_icon.png",
                ),
                height: 155,
                width: 155,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Audio Sound",
                style: TextStyle(fontSize: 23.5),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                "Decibel Meter",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function logError;

  HomeScreen({super.key, required this.cameras, required this.logError});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  NativeAd? nativeAd;
  bool isNativeAdLoaded = false;

  NativeAd? nativePopUpAd;
  bool isNativePopUpAdLoaded = false;

  bool isShowAds = true;
  String adUnit = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    DbProvider().getShowAdsState().then((value) {
      isShowAds = value;
      print("isShowAds sfdfg $isShowAds");

      if (isShowAds == true) {
        adUnit = adNativeUnit;
        loadNativeAd();
        loadNativePopUpAd();
      } else {
        adUnit = "";
        loadNativeAd();
        loadNativePopUpAd();
      }
    });
  }

  void loadNativeAd() {
    nativeAd = NativeAd(
      adUnitId: adUnit,
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

  void loadNativePopUpAd() {
    nativePopUpAd = NativeAd(
      adUnitId: adUnit,
      factoryId: "listTileMedium",
      listener: NativeAdListener(onAdLoaded: (ad) {
        setState(() {
          isNativePopUpAdLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        nativePopUpAd!.dispose();
      }),
      request: const AdRequest(),
    );
    nativePopUpAd!.load();
  }

  var toLaunch;

  @override
  Widget build(BuildContext context) {
    toLaunch = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.expressway.noisedetector.sm&pli=1');

    return WillPopScope(
      onWillPop: () {
        return showExitPopup();
      },
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.02,
                vertical: MediaQuery.of(context).size.height * 0.02),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xffF0F1F2),
                      image: DecorationImage(
                          image: AssetImage("assets/images/bg.png"),
                          fit: BoxFit.cover)),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 18, right: 18, top: 16, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/firstpage_icon.png",
                              height: 75,
                              width: 75,
                              fit: BoxFit.contain,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/appname.png",
                                  height: 80,
                                  width: 160,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 13, bottom: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Info()));
                                      },
                                      child: Image.asset(
                                          "assets/images/info.png",
                                          height: 35,
                                          width: 30,
                                          fit: BoxFit.contain),
                                    ),
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     showDialog(
                                    //         context: context,
                                    //         builder: (BuildContext context) {
                                    //           return AlertDialog(
                                    //             title: const Text('Alert!',
                                    //                 style: TextStyle(
                                    //                     color: Colors.red)),
                                    //             content: const Text(
                                    //                 'Are you sure, you want to buy in_app_purchase'),
                                    //             actions: [
                                    //               TextButton(
                                    //                 child: const Text('Cancel'),
                                    //                 onPressed: () {
                                    //                   Navigator.pop(context);
                                    //                 },
                                    //               ),
                                    //               TextButton(
                                    //                 child: Text('Buy'),
                                    //                 onPressed: () {
                                    //                   setState(() {});
                                    //
                                    //                   Navigator.pop(context);
                                    //                 },
                                    //               ),
                                    //             ],
                                    //           );
                                    //         });
                                    //   },
                                    //   child: Image.asset(
                                    //       "assets/images/ads.png",
                                    //       height: 35,
                                    //       width: 30,
                                    //       fit: BoxFit.contain),
                                    // ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        color: Color(0xFFDCDFE3),
                        thickness: 2,
                        indent: Checkbox.width,
                        endIndent: Checkbox.width,
                      ),
                      GridView.count(
                        childAspectRatio: 4 / 3,
                        shrinkWrap: true,
                        primary: false,
                        padding: const EdgeInsets.only(
                            left: 18, top: 7.5, bottom: 15, right: 18),
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 16,
                        crossAxisCount: 2,
                        children: <Widget>[
                          ReusableGridView(
                            className: NoiseDetector(),
                            label1: "Noise",
                            label2: "Detector",
                            imgPath: "assets/images/b1.png",
                          ),
                          ReusableGridView(
                            className: SaveMain.history(),
                            label1: "Noise",
                            label2: "History",
                            imgPath: "assets/images/b2.png",
                          ),
                          ReusableGridView(
                            className: RecorderHomeView(
                              title: 'Recorder',
                            ),
                            label1: "Voice",
                            label2: "Recorder",
                            imgPath: "assets/images/b3.png",
                          ),
                          ReusableGridView(
                            className: CameraHome(
                                cameras: widget.cameras,
                                logError: widget.logError),
                            label1: "Noise",
                            label2: "From My Files",
                            imgPath: "assets/images/b4.png",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Visibility(
            visible: isShowAds,
            child: isNativeAdLoaded
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
        ),
      ),
    );
  }

  Future<void>? _launched;

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit an App?'),
            actions: [
              Column(
                children: [
                  isNativePopUpAdLoaded
                      ? Visibility(
                          visible: isShowAds,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            height: 265,
                            width: 300,
                            child: AdWidget(
                              ad: nativePopUpAd!,
                            ),
                          ),
                        )
                      : SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _launched = _launchInBrowser(toLaunch);
                        }),

                        //return false when click on "NO"
                        child: Text('Rate US'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        //return false when click on "NO"
                        child: Text('No'),
                      ),
                      ElevatedButton(
                        onPressed: () => SystemNavigator.pop(),
                        //return true when click on "Yes"
                        child: Text('Yes'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ) ??
        Future.value(
            false); //if showDialouge had returned null, then return false
  }
}
