import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call/constants/const.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Spacer(
            flex: 2,
          ),
          Image.asset(
            'assets/Icon Frame.png',
            height: 200.0,
            width: 200.0,
          ),
          Spacer(
            flex: 2,
          ),
          Image.asset(
            'assets/Logo Alternate.png',
            height: 80.0,
          ),
          Spacer(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    ///Check for ONE TIME Intro screen
    Timer(Duration(milliseconds: 1500), () {
      checkFirstSeen();
    });
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = prefs.getString('name') != null;

    if (_seen) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/intro', (route) => false);
    }
  }
}
