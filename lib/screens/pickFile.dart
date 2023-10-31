
import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:video_player/video_player.dart';

import '../google_ads.dart';
import '../logic/dB_meter.dart';
import '../provider/db_provider.dart';
import '../utils/constants.dart';

class PickFile extends StatefulWidget {
  const PickFile({super.key});

  @override
  State<PickFile> createState() => _PickFileState();
}

class _PickFileState extends State<PickFile> {
  late BannerAd bannerAd;
  bool isLoaded = false;

  // testing ad id
  var adUnit = adBannerUnit;

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

  bool isRecording = false;
  bool _isPlaying = false;
  StreamSubscription<NoiseReading>? noiseSubscription;
  late NoiseMeter noiseMeter;
  double maxDB = 0;
  double? meanDB;

  late VideoPlayerController controller;

  File? _image;
  final picker = ImagePicker();

  late Future<void> video;

  void onData(NoiseReading noiseReading) {
    setState(() {
      if (controller.value.isPlaying) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
        stop();
      }
      // print("dataa: {$_isPlaying}");
    });
    setState(() {
      if (!isRecording) isRecording = true;
    });

    maxDB = noiseReading.maxDecibel;
    meanDB = noiseReading.meanDecibel;
  }

  // error handle
  void onError(Object e) {
    isRecording = false;
  }

  void start() async {
    try {
      noiseSubscription = noiseMeter.noiseStream.listen(onData);
    } catch (e) {
      print(e);
    }
  }

  void stop() async {
    try {
      noiseSubscription!.cancel();
      noiseSubscription = null;

      // setState(() => {},);
    } catch (e) {
      print('stopRecorder error: $e');
    }
  }

  late InterstitialAd interstitialAd;
  bool isInterstitaleLoaded = false;

  // interstitle app id
  var adInterstitaleUnit = "";

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
  bool isShowAds = true;

  @override
  void initState() {
    super.initState();
    noiseMeter = NoiseMeter(onError);
    DbProvider().getShowAdsState().then((value) {
      isShowAds = value;
      print("isShowAds sfdfg $isShowAds");

      if (isShowAds == true) {
        adUnit = adNativeUnit;
        adInterstitaleUnit = adIntUnit;
        initInterstitialAd();
        initBannerAd();
      } else {
        adUnit = "";
        adInterstitaleUnit = "";
        initInterstitialAd();
        initBannerAd();
      }
    });
  }

  @override
  void dispose() {
    stop();

    super.dispose();
  }

  // This funcion will helps you to pick and Image from Gallery
  _pickImageFromGallery() async {
    PickedFile? pickedFile = await picker.getVideo(
      source: ImageSource.gallery,
    );

    File image = File(pickedFile!.path);

    setState(() {
      _image = image;
      controller = VideoPlayerController.file(File(_image!.path));
      video = controller.initialize();
      controller.setLooping(false);
      controller.setVolume(1.0);
    });
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
                  if (isInterstitaleLoaded) {
                    interstitialAd.show();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "My Files",
                style: kAppbarStyle,
              ),
            ),
          ),
          floatingActionButton: _image != null
              ? FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      // if (_isPlaying) {
                      //   _onPause();
                      //   stop();
                      // } else {
                      //   _onPlay();
                      //   start();
                      // }
                      if (controller.value.isPlaying) {
                        controller.pause();
                        stop();
                      } else {
                        controller.play();
                        start();
                      }
                    });
                  },
                  child: Icon(controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow))
              : SizedBox.shrink(),
          body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // ElevatedButton(
                  //   onPressed: () {
                  //     _pickImageFromGallery();
                  //     // or
                  //     // _pickImageFromCamera();
                  //     // use the variables accordingly
                  //   },
                  //   child: Text("Pick Image From Gallery"),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: GestureDetector(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: DottedBorder(
                        borderType: BorderType.RRect,
                        color: Color(0xffCED3D9),
                        strokeWidth: 3.25,
                        radius: const Radius.circular(10),
                        strokeCap: StrokeCap.butt,
                        dashPattern: const [12, 15],
                        child: Column(
                          children: [
                            Container(
                              // height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(),
                              child: Column(
                                children: [
                                  IconButton(
                                    iconSize: 60,
                                    onPressed: () {
                                      _pickImageFromGallery();
                                    },
                                    icon:
                                        Image.asset("assets/images/addvideo.png"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      "Select Video",
                                      style: TextStyle(color: Color(0xff87898A)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_image != null)
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6.0, horizontal: 16),
                            child: Container(
                              // height: 450,
                              child: FutureBuilder(
                                future: video,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    return AspectRatio(
                                      aspectRatio: 4 / 5,
                                      child: VideoPlayer(controller),
                                    );
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          _image != null
                              ? Container(height: 350, child: dBMeter(maxDB))
                              : SizedBox.shrink()
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(
                          "Click on Select Video to select a Video",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ]),
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.all(5),
            child: isLoaded
                ? SizedBox(
                    height:50,
                    //width: bannerAd.size.width.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  )
                : SizedBox(
                    height:50,
                    //width: bannerAd.size.width.toDouble(),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPause() async {
    controller.pause();
    setState(() {
      _isPlaying = false;
      stop();
    });
  }

  Future<void> _onPlay() async {
    if (!_isPlaying) {
      controller.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }
}
