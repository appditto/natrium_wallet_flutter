import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/ui/home_page.dart';
import 'colors.dart';

Future<void> main() async {
  // TODO load seed, go to intro if applicable, etc.
  runApp(KaliumApp());
}
class KaliumApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KaliumF',
      theme: ThemeData(
        primaryColor: yellow,
        accentColor: yellow,
        fontFamily: 'NunitoSans',
        brightness: Brightness.dark,
      ),
      home: KaliumHomePage(title: 'KaliumF'),
    );
  }
}

