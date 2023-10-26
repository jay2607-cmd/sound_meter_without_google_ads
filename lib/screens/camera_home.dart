import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sound_meter/screens/pickFile.dart';
import 'package:sound_meter/screens/views/reusable_grid_view.dart';

import '../google_ads.dart';
import '../provider/db_provider.dart';
import '../utils/constants.dart';
import 'capture_video_and_measure_noise.dart';

class CameraHome extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function logError;

  CameraHome({super.key, required this.cameras, required this.logError});

  @override
  State<CameraHome> createState() => _CameraHomeState();
}

class _CameraHomeState extends State<CameraHome> {
  NativeAd? nativeAd;
  bool isNativeAdLoaded = false;

  bool isShowAds = true;
String adUnit = "";

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    DbProvider().getShowAdsState().then((value) {
      isShowAds = value;
      print("isShowAds sfdfg $isShowAds");

      if (isShowAds == true) {
        adUnit = adNativeUnit;
        loadNativeAd();
      } else {
        adUnit = "";
        loadNativeAd();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Fluttertoast.showToast(
      msg: "is Ad from PlayStore In Activity Check : $isShowAds",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
    );
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                Navigator.pop(context);
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      primary: false,
                      padding: const EdgeInsets.all(20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      children: <Widget>[
                        ReusableGridView(
                          className: CameraApp(
                              cameras: widget.cameras,
                              logError: widget.logError),
                          label1: "",
                          label2: "Camera",
                          imgPath: "assets/images/camera.png",
                        ),
                        ReusableGridView(
                          className: PickFile(),
                          label1: "",
                          label2: "Gallery",
                          imgPath: "assets/images/folder.png",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
}
