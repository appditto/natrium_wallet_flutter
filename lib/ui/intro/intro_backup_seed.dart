import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/ui/widgets/mnemonic_display.dart';

import '../../dimens.dart';

class IntroBackupSeedPage extends StatefulWidget {
  @override
  _IntroBackupSeedState createState() => _IntroBackupSeedState();
}

class _IntroBackupSeedState extends State<IntroBackupSeedPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _seed;
  List<String> _mnemonic;

  @override
  void initState() {
    super.initState();
    _seed = NanoSeeds.generateSeed();
    _mnemonic = NanoMnemomics.seedToMnemonic(_seed);
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // Back Button
                                Container(
                                  margin: EdgeInsetsDirectional.only(
                                      start: smallScreen(context) ? 15 : 20),
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
                                // 3 dots
                                Container(
                                  margin: EdgeInsetsDirectional.only(
                                      end: smallScreen(context) ? 15 : 20),
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
                                      child: Icon(Icons.swap_horiz,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text,
                                          size: 36)),
                                ),
                              ],
                            ),
                            // The header
                            Container(
                              margin: EdgeInsetsDirectional.only(
                                start: smallScreen(context) ? 30 : 40,
                                end: smallScreen(context) ? 30 : 40,
                                top: 10,
                              ),
                              alignment: AlignmentDirectional(-1, 0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width-(smallScreen(context)?120:140)),
                                    child: AutoSizeText(
                                      "Secret Phrase",
                                      style: AppStyles.textStyleHeaderColored(
                                          context),
                                      stepGranularity: 0.1,
                                      minFontSize: 12.0,
                                      maxLines: 1,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsetsDirectional.only(
                                        start: 10, end: 10),
                                    child: Icon(
                                      Icons.vpn_key,
                                      size: 36,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Mnemonic word list
                            MnemonicDisplay(_mnemonic),
                          ],
                        ),
                      ),
                      // Next Screen Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY,
                            "I've Backed It Up",
                            Dimens.BUTTON_BOTTOM_DIMENS,
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
