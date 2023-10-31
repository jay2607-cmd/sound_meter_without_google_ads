import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_meter/provider/db_provider.dart';
import 'package:sound_meter/screens/home_screen.dart';
import 'package:store_checker/store_checker.dart';

import 'database/save_model.dart';

List<CameraDescription> cameras = <CameraDescription>[];

void logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

bool verifyInstallerId() {
  // A list with valid installers package name
  List<String> validInstallers = [
    "com.android.vending",
    "com.google.android.feedback"
  ];

  // The package name of the app that has installed your app
  final String installer = "com.ronrajtech.jg.sounddeciblemeter";

  // true if your app has been downloaded from Play Store
  return validInstallers.contains(installer);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.getBool("isPersonalised") == null) {
    preferences.setBool("isPersonalised", false);
  }

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }

  var directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  Hive.registerAdapter(SaveModelAdapter());

  await Hive.openBox<SaveModel>("savedB");

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  // true if it's downloaded from play store
  // bool showAds = verifyInstallerId();

  Source installationSource = await StoreChecker.getSource;

  String source = "";

  switch (installationSource) {
    case Source.IS_INSTALLED_FROM_PLAY_STORE:
      // Installed from Play Store
      source = "Play Store";
      Fluttertoast.showToast(
        msg: "is Ad from PlayStore: $source",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      break;

    case Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER:
      // Installed from Google Package installer
      source = "Google Package installer";
      DbProvider().saveShowAdsState(false);
      break;
    case Source.IS_INSTALLED_FROM_LOCAL_SOURCE:
      // Installed using adb commands or side loading or any cloud service
      source = "Local Source";
      DbProvider().saveShowAdsState(false);
      break;
    case Source.IS_INSTALLED_FROM_AMAZON_APP_STORE:
      // Installed from Amazon app store
      source = "Amazon Store";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY:
      // Installed from Huawei app store
      source = "Huawei App Gallery";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE:
      // Installed from Samsung app store
      source = "Samsung Galaxy Store";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE:
      // Installed from Samsung Smart Switch Mobile
      source = "Samsung Smart Switch Mobile";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS:
      // Installed from Xiaomi app store
      source = "Xiaomi Get Apps";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_OPPO_APP_MARKET:
      // Installed from Oppo app store
      source = "Oppo App Market";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_VIVO_APP_STORE:
      // Installed from Vivo app store
      source = "Vivo App Store";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_RU_STORE:
      // Installed apk from RuStore
      source = "RuStore";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_OTHER_SOURCE:
      // Installed from other market store
      source = "Other Source";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_APP_STORE:
      // Installed from app store
      source = "App Store";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.IS_INSTALLED_FROM_TEST_FLIGHT:
      // Installed from Test Flight
      source = "Test Flight";
      DbProvider().saveShowAdsState(false);

      break;
    case Source.UNKNOWN:
      // Installed from Unknown source
      source = "Unknown Source";
      DbProvider().saveShowAdsState(false);
      Fluttertoast.showToast(
        msg: "is Ad from PlayStore: $source",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      break;
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  bool isPaused = false;
  bool isShowAds = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appOpenAdManager.loadAd();
    WidgetsBinding.instance.addObserver(this);

    DbProvider().getShowAdsState().then((value) {
      setState(() {
        isShowAds = value;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      isPaused = true;
    }
    DbProvider().getShowAdsState().then((value) {
      setState(() {
        isShowAds = value;
      });
    });
    if (state == AppLifecycleState.resumed && isPaused && isShowAds == true) {
      print("Resumed==========================");
      appOpenAdManager.showAdIfAvailable();
      isPaused = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Audio Sound Decibel Meter",
        theme: ThemeData(
          fontFamily: "Montserrat",
        ),
        home: const SplashScreen());
  }
}

bool isShowOpenAds = true;

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  static bool isLoaded = false;

  var adOpenUnit =
      isShowOpenAds ? "ca-app-pub-6839127603684379/9859253770" : "";

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: adOpenUnit,
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print("Ad Loaded.................................");
          _appOpenAd = ad;
          isLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print(error);
        },
      ),
    );
  }

  // Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    print(
        "Called=====================================================================");
    if (_appOpenAd == null) {
      print('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
  }
}
