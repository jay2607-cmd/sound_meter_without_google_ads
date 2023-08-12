import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/constants.dart';
import 'live_screenshot.dart';

class ScreenshotPreview extends StatefulWidget {
  final List<File> imageFiles;
  final int index;
  final String filePath;
  final File file;

  const ScreenshotPreview(
      {super.key,
      required this.filePath,
      required this.file,
      required this.imageFiles,
      required this.index});

  @override
  State<ScreenshotPreview> createState() => _ScreenshotPreviewState();
}

class _ScreenshotPreviewState extends State<ScreenshotPreview> {

  late InterstitialAd interstitialAd;
  bool isInterstitaleLoaded = false;

  // interstitle app id
  var adInterstitaleUnit = "ca-app-pub-3940256099942544/1033173712";

  late BannerAd bannerAd;
  bool isLoaded = false;

  // testing ad id
  var adUnit = "ca-app-pub-3940256099942544/6300978111";

  initBannerAd() {
    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnit,
      listener: BannerAdListener(onAdLoaded: (ad) {
        setState(() {
          isLoaded = true;
        });
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
        print(error);
      }),
      request: AdRequest(),
    );

    bannerAd.load();
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

  @override
  void initState() {
    super.initState();
    initBannerAd();
    initInterstitialAd();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (isInterstitaleLoaded) {
      interstitialAd.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.filePath);
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: SafeArea(
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
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "Preview",
                style: kAppbarStyle,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: PhotoView(
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.white),
                  imageProvider: FileImage(File(widget.filePath)),
                ),
              ),
              Text(widget.filePath.substring(67, 86)),
              // Text(filePath.substring(77, 86 )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            Share.shareFiles([widget.filePath],
                                text: widget.filePath.substring(67, 86));
                          },
                          child: Center(
                            child: Text(
                              "SHARE",
                              style: kButtonTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xffFF5959)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Warning!',
                                      style: TextStyle(color: Colors.red)),
                                  content: const Text(
                                      'Are you really want to delete this file!'),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        setState(() {
                                          deleteFile(widget.filePath, widget.index);
                                          Navigator.pop(context);
                                          setState(() {});
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Center(
                              child: Text(
                            "DELETE",
                            style: kButtonTextStyle,
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.all(5),
            child: isLoaded
                ? SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
              child: AdWidget(ad: bannerAd),
            )
                : SizedBox(
              height: bannerAd.size.height.toDouble(),
              width: bannerAd.size.width.toDouble(),
            ),
          ),
        ),
      ),
    );
  }



  Future<void> deleteFile(String filePath, int index) async {
    try {
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        setState(() {
          widget.imageFiles.remove(file);
          widget.imageFiles
              .removeAt(index); // Remove the deleted file from the list
        });
        // widget.imageFiles.removeAt(index);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ImageListScreen()));
        print('$filePath deleted successfully');
      }
    } catch (e) {
      print('Error while deleting file: $e');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ImageListScreen()));
    }
  }

  Future<bool> _willPopCallback() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ImageListScreen()));
    return Future.value(true);
  }
}
