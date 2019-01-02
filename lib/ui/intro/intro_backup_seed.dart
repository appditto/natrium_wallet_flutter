import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/ui/home_page.dart';
import 'package:kalium_wallet_flutter/util/nanoutil.dart';

class IntroBackupSeedPage extends StatefulWidget {
  @override
  _IntroBackupSeedState createState() => _IntroBackupSeedState();
}

class _IntroBackupSeedState extends State<IntroBackupSeedPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _seed;
  var _seedTapColor;
  var _seedCopiedColor;
  Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
        
    Vault.inst.writeSeed(NanoSeeds.generateSeed()).then((result) {
      // Update wallet
      StateContainer.of(context).updateWallet(address:NanoUtil.seedToAddress(result));
      // Update local state
      setState(() {
        _seed = result;
        _seedTapColor = KaliumColors.yellow;
        _seedCopiedColor = Colors.transparent;
      });
    });
  }

  @override
  void dispose() {

    Vault.inst.deleteSeed().then((result) {
      super.dispose();
      StateContainer.of(context).updateWallet(address:null);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: KaliumColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
              children: <Widget>[
                //A widget that holds welcome animation + text and expands to the rest of the available area
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.075),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              height: 50,
                              width: 50,
                              child: FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                  padding: EdgeInsets.all(0.0),
                                  child: Icon(KaliumIcons.back,
                                      color: KaliumColors.text, size: 24)),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.0, left: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Seed",
                                style: KaliumStyles.TextStyleHeaderColored,
                              ),
                            ],
                          ),
                        ),
                        //Container for the text
                        Container(
                          margin:
                              EdgeInsets.only(left: 50, right: 50, top: 15.0),
                          child: Text(
                              "Below is your wallet's seed. It is crucial that you backup your seed and never store it as plaintext or a screenshot.",
                              style: KaliumStyles.TextStyleParagraph),
                        ),
                        Container(
                          child: new GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                    new ClipboardData(text: _seed));
                                setState(() {
                                  _seedTapColor = KaliumColors.success;
                                  _seedCopiedColor = KaliumColors.success;
                                });
                                if (_seedCopiedTimer != null) {
                                  _seedCopiedTimer.cancel();
                                }
                                _seedCopiedTimer = new Timer(
                                    const Duration(milliseconds: 800), () {
                                  setState(() {
                                    _seedTapColor = KaliumColors.yellow;
                                    _seedCopiedColor = Colors.transparent;
                                  });
                                });
                              },
                              child: new Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 15),
                                margin: EdgeInsets.only(
                                    left: 50, right: 50, top: 25),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: KaliumColors.backgroundDark,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  _seed,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _seedTapColor,
                                    fontSize: 14.0,
                                    height: 1.2,
                                    fontFamily: 'OverpassMono',
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text('Seed Copied To Clipboard',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: _seedCopiedColor,
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with next screen button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 30, right: 30),
                      height: 50,
                      width: 50,
                      child: FlatButton(
                          splashColor: KaliumColors.primary30,
                          highlightColor: KaliumColors.primary15,
                          onPressed: () {
                            Navigator.of(context)
                              .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0)),
                          padding: EdgeInsets.all(0.0),
                          child: Icon(KaliumIcons.forward,
                              color: KaliumColors.primary, size: 50)),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }
}
