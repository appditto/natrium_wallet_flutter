import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/clipboardutil.dart';

class IntroBackupSeedPage extends StatefulWidget {
  @override
  _IntroBackupSeedState createState() => _IntroBackupSeedState();
}

class _IntroBackupSeedState extends State<IntroBackupSeedPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _seed;
  TextStyle _seedTapStyle;
  var _seedCopiedColor = Colors.transparent;
  Timer _seedCopiedTimer;

  bool _seedCopied = false;

  @override
  void initState() {
    super.initState();
    _seed = NanoSeeds.generateSeed();
  }

  @override
  Widget build(BuildContext context) {
    // Back button pressed
    Future<bool> _onWillPop() async {
      // Delete seed
      await sl.get<Vault>().deleteAll();
      // Delete any shared prefs
      await sl.get<Vault>().deleteAll();
      return true;
    }

    return new WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          backgroundColor: StateContainer.of(context).curTheme.backgroundDark,
          body: LayoutBuilder(
            builder: (context, constraints) => SafeArea(
                  minimum: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.035,
                      top: MediaQuery.of(context).size.height * 0.075),
                  child: Column(
                    children: <Widget>[
                      //A widget that holds the header, the paragraph, the seed, "seed copied" text and the back button
                      Expanded(
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
                                      highlightColor: StateContainer.of(context)
                                          .curTheme
                                          .text15,
                                      splashColor: StateContainer.of(context)
                                          .curTheme
                                          .text15,
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50.0)),
                                      padding: EdgeInsets.all(0.0),
                                      child: Icon(AppIcons.back,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text,
                                          size: 24)),
                                ),
                              ],
                            ),
                            // The header
                            Container(
                              margin: EdgeInsets.only(
                                  top: 15.0, left: 50, right: 50),
                              alignment: Alignment(-1, 0),
                              child: Text(
                                AppLocalization.of(context).seed,
                                style:
                                    AppStyles.textStyleHeaderColored(context),
                              ),
                            ),
                            // The paragraph
                            Container(
                              margin: EdgeInsets.only(
                                  left: 50, right: 50, top: 15.0),
                              alignment: Alignment.centerLeft,
                              child: AutoSizeText(
                                AppLocalization.of(context).seedBackupInfo,
                                style: AppStyles.textStyleParagraph(context),
                                maxLines: 5,
                                stepGranularity: 0.5,
                              ),
                            ),
                            Container(
                              // A gesture detector to decide if the is tapped or not
                              child: new GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                        new ClipboardData(text: _seed));
                                    ClipboardUtil.setClipboardClearEvent();
                                    setState(() {
                                      _seedCopied = true;
                                      _seedCopiedColor =
                                          StateContainer.of(context)
                                              .curTheme
                                              .success;
                                    });
                                    if (_seedCopiedTimer != null) {
                                      _seedCopiedTimer.cancel();
                                    }
                                    _seedCopiedTimer = new Timer(
                                        const Duration(milliseconds: 1200), () {
                                      setState(() {
                                        _seedCopied = false;
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
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .backgroundDarkest,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: UIUtil.threeLineSeedText(
                                        context, _seed,
                                        textStyle: _seedCopied
                                            ? AppStyles.textStyleSeedGreen(
                                                context)
                                            : AppStyles.textStyleSeed(context)),
                                  )),
                            ),
                            // "Seed copied to Clipboard" text that appaears when seed is tapped
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child:
                                  Text(AppLocalization.of(context).seedCopied,
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

                      // Next Screen Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(right: 30),
                            height: 50,
                            width: 50,
                            child: FlatButton(
                                splashColor: StateContainer.of(context)
                                    .curTheme
                                    .primary30,
                                highlightColor: StateContainer.of(context)
                                    .curTheme
                                    .primary15,
                                onPressed: () {
                                  sl.get<Vault>().setSeed(_seed).then((result) {
                                    // Update wallet
                                    NanoUtil().loginAccount(context).then((_) {
                                      StateContainer.of(context).requestUpdate();
                                      Navigator.of(context)
                                          .pushNamed('/intro_backup_confirm');
                                    });
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                padding: EdgeInsets.all(0.0),
                                child: Icon(AppIcons.forward,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary,
                                    size: 50)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          ),
        ));
  }
}