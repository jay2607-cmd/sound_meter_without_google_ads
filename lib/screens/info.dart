import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sound_meter/screens/user_consent.dart';
import 'package:url_launcher/url_launcher.dart';

import '../google_ads.dart';
import '../webview.dart';
import 'license_credit.dart';

class Info extends StatefulWidget {
  const Info({super.key});

  @override
  State<Info> createState() => _InfoState();
}

class _InfoState extends State<Info> {
  var toLaunch;

  // _launchURLBrowser() async {
  //   const url = 'http://ec2-18-116-59-188.us-east-2.compute.amazonaws.com/RonrajTech/RonrajTechPrivacyPolicy.html';
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not launch $url';
  //   }
  // }

  _launchURLInApp(BuildContext context) {
    const url = kPrivacyPolicy;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    toLaunch = Uri.parse(
        kShareUrl);

    Future<void>? _launched;
    Future<void> _launchInBrowser(Uri url) async {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    }

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            ListTile(
              title: Text("Version Name"),
              subtitle: Text("1.0"),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UserConsent()));
              },
              child: ListTile(
                title: Text(
                  "User Consent",
                ),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserConsent()));
                  },
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Share.share(
                    kShareUrl);
              },
              child: ListTile(
                title: Text("Share App"),
                trailing: IconButton(
                  onPressed: () {
                    Share.share(
                        kShareUrl);
                  },
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _launched = _launchInBrowser(toLaunch);
                });
              },
              child: ListTile(
                title: Text("Rate Us"),
                trailing: IconButton(
                  onPressed: () => (setState(() {
                    _launched = _launchInBrowser(toLaunch);
                  })),
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _launchURLInApp(context);
              },
              child: ListTile(
                title: Text(
                  "Privacy & Policy",
                ),
                trailing: IconButton(

                  onPressed: () {
                    _launchURLInApp(context);
                  },
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LicenseAndCredit()));
              },
              child: ListTile(
                title: Text("License and Credit"),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LicenseAndCredit()));
                  },
                  icon: Icon(Icons.arrow_forward_ios_sharp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
