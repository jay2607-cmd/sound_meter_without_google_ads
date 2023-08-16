import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import '../utils/constants.dart';

class LicenseAndCredit extends StatefulWidget {
  const LicenseAndCredit({super.key});

  @override
  State<LicenseAndCredit> createState() => _LicenseAndCreditState();
}

class _LicenseAndCreditState extends State<LicenseAndCredit> {
  final String xmlCode = '''Copyright 2002-2012 The Apache Software Foundation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License''';

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
              "License and Credit",
              style: kAppbarStyle,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: HighlightView(
              xmlCode,
              language: 'xml',
              // theme: atomOneDarkTheme,
              padding: EdgeInsets.all(12),
            ),
          ),
        ),
      ),
    );
  }
}
