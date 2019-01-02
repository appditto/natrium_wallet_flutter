import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/ui/home_page.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_welcome.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_backup_seed.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_backup_confirm.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/util/nanoutil.dart';
import 'colors.dart';

void main() => runApp(new StateContainer(
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
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/intro_welcome': (context) => IntroWelcomePage(),
        '/intro_backup': (context) => IntroBackupSeedPage(),
        '/intro_backup_confirm': (context) => IntroBackupConfirm(),
        '/home': (context) => KaliumHomePage()
      },
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
    var seed = await Vault.inst.getSeed();
    if (seed != null) {
      isLoggedIn = true;
    }

    if (isLoggedIn) {
      var stateContainer = StateContainer.of(context);
      stateContainer.updateWallet(address:NanoUtil.seedToAddress(seed));
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/intro_welcome');
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