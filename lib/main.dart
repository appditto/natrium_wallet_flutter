import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/ui/home_page.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_welcome.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'colors.dart';

void main() => runApp(new AppStateContainer(
                          child:new KaliumApp()
                      ));

class KaliumApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaliumF',
      theme: ThemeData(
        dialogBackgroundColor: KaliumColors.backgroundDark,
        primaryColor: KaliumColors.primary,
        accentColor: KaliumColors.primary,
        backgroundColor: KaliumColors.backgroundDark,
        fontFamily: 'NunitoSans',
        brightness: Brightness.dark,
      ),
      home: new Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  @override
  SplashState createState() => new SplashState();
}

class SplashState extends State<Splash> {
  Future checkLoggedIn() async {
    // See if logged in already
    bool isLoggedIn = false;
    Vault v = new Vault();
    var seed = await v.getSeed();
    if (seed != null) {
      isLoggedIn = true;
    }

    if (isLoggedIn) {
    Navigator.of(context).pushReplacement(
      new MaterialPageRoute(builder: (context) => new KaliumHomePage(title:"KaliumF")));
    } else {
      Navigator.of(context).pushReplacement(
        new MaterialPageRoute(builder: (context) => new IntroWelcomePage()));
    }
  }

  @override
  void initState() {
    super.initState();
    new Timer(new Duration(milliseconds: 200), () {
      checkLoggedIn();
    });
  }

  @override
  Widget build(BuildContext context) {
  return new Scaffold(
  body: new Center(
    child: new Text('Loading...'),
  ),
  );
  }
}