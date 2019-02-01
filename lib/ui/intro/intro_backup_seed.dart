import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/colors.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/clipboardutil.dart';

class IntroBackupSeedPage extends StatefulWidget {
  @override
  _IntroBackupSeedState createState() => _IntroBackupSeedState();
}

class _IntroBackupSeedState extends State<IntroBackupSeedPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _seed;
  TextStyle _seedTapStyle = AppStyles.TextStyleSeed;
  var _seedCopiedColor = Colors.transparent;
  Timer _seedCopiedTimer;

  @override
  void initState() {
    super.initState();
    _seed = NanoSeeds.generateSeed();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent));

    // Back button pressed
    Future<bool> _onWillPop() async {
      // Delete seed
      await Vault.inst.deleteAll();
      // Delete any shared prefs
      await Vault.inst.deleteAll();
      return true;
    }

    return new WillPopScope(
      onWillPop:_onWillPop,
      child: new Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) => Column(
                children: <Widget>[
                  //A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.075),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              // Back Button
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
                                    child: Icon(AppIcons.back,
                                        color: AppColors.text, size: 24)),
                              ),
                            ],
                          ),
                          // The header
                          Container(
                            margin: EdgeInsets.only(top: 15.0, left: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  AppLocalization.of(context).seed,
                                  style: AppStyles.TextStyleHeaderColored,
                                ),
                              ],
                            ),
                          ),
                          // The paragraph
                          Container(
                            margin:
                                EdgeInsets.only(left: 50, right: 50, top: 15.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                                AppLocalization.of(context).seedBackupInfo,
                                style: AppStyles.TextStyleParagraph),
                          ),
                          Container(
                            // A gesture detector to decide if the is tapped or not
                            child: new GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      new ClipboardData(text: _seed));
                                  ClipboardUtil.setClipboardClearEvent();
                                  setState(() {
                                    _seedTapStyle = AppStyles.TextStyleSeedGreen;
                                    _seedCopiedColor = AppColors.success;
                                  });
                                  if (_seedCopiedTimer != null) {
                                    _seedCopiedTimer.cancel();
                                  }
                                  _seedCopiedTimer = new Timer(
                                      const Duration(milliseconds: 1200), () {
                                    setState(() {
                                      _seedTapStyle = AppStyles.TextStyleSeed;
                                      _seedCopiedColor = Colors.transparent;
                                    });
                                  });
                                },
                                // The seed
                                child: new Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 15),
                                  margin: EdgeInsets.only(top: 25),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundDark,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child:
                                    UIUtil.threeLineSeedText(_seed, textStyle: _seedTapStyle),    
                                )),
                          ),
                          // "Seed copied to Clipboard" text that appaears when seed is tapped
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            child: Text(AppLocalization.of(context).seedCopied,
                                textAlign: TextAlign.center,
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

                  // Next Screen Button 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 30, right: 30),
                        height: 50,
                        width: 50,
                        child: FlatButton(
                            splashColor: AppColors.primary30,
                            highlightColor: AppColors.primary15,
                            onPressed: () {
                              Vault.inst.setSeed(_seed).then((result) {
                                // Update wallet
                                StateContainer.of(context).updateWallet(address:NanoUtil.seedToAddress(result));
                                StateContainer.of(context).requestUpdate();
                                Navigator.of(context).pushNamed('/intro_backup_confirm');
                              });
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: EdgeInsets.all(0.0),
                            child: Icon(AppIcons.forward,
                                color: AppColors.primary, size: 50)),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      )
    );
  }
}
