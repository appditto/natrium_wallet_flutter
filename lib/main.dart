import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/ui/home_page.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_welcome.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_backup_seed.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_backup_confirm.dart';
import 'package:kalium_wallet_flutter/ui/intro/intro_import_seed.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/util/nanoutil.dart';
import 'colors.dart';

void main() async {
  // Setup logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  // Run app
  runApp(new StateContainer(child: new KaliumApp()));
}

class KaliumApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaliumF',
      theme: ThemeData(
        dialogBackgroundColor: KaliumColors.backgroundDark,
        primaryColor: KaliumColors.primary,
        accentColor: KaliumColors.primary15,
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
        '/intro_import': (context) => IntroImportSeedPage(),
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
    var pin = await Vault.inst.getPin();
    // If we have a seed set, but not a pin - or vice versa
    // Then delete the seed and pin from device and start over.
    // This would mean user did not complete the intro screen completely.
    if (seed != null && pin != null) {
      isLoggedIn = true;
    } else if (seed != null && pin == null) {
      await Vault.inst.deleteSeed();
    } else if (pin != null && seed ==null) {
      await Vault.inst.deletePin();
    }

    if (isLoggedIn) {
      var stateContainer = StateContainer.of(context);
      stateContainer.updateWallet(address: NanoUtil.seedToAddress(seed));
      stateContainer.requestUpdate();
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/intro_welcome');
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return new Scaffold(
      backgroundColor: KaliumColors.background,
    );
  }
}
