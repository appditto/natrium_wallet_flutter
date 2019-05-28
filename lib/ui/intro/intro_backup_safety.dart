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
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/ui/widgets/mnemonic_display.dart';

class IntroBackupSafetyPage extends StatefulWidget {
  @override
  _IntroBackupSafetyState createState() => _IntroBackupSafetyState();
}

class _IntroBackupSafetyState extends State<IntroBackupSafetyPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

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
                                  margin: EdgeInsetsDirectional.only(start: smallScreen(context)?15:20),
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
                              margin: EdgeInsetsDirectional.only(
                                start: smallScreen(context) ? 30 : 50,
                                end: smallScreen(context) ? 30 : 50,
                              ),
                              alignment: AlignmentDirectional(-1, 0),
                              child: Text(
                                "Safety First!",
                                style:
                                    AppStyles.textStyleHeaderColored(context),
                              ),
                            ),
                            // The paragraph
                            Container(
                              margin: EdgeInsetsDirectional.only(
                                  start: smallScreen(context) ? 30 : 50,
                                  end: smallScreen(context) ? 30 : 50,
                                  top: 15.0),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: <Widget>[
                                  AutoSizeText(
                                    "In the next screen, you will see your secret phrase. It is like a complex master password to access your funds. It is crucial that you back it up and never share it with anyone.",
                                    style:
                                        AppStyles.textStyleParagraph(context),
                                    maxLines: 7,
                                    stepGranularity: 0.5,
                                  ),
                                  Container(
                                    margin: EdgeInsetsDirectional.only(top: 10),
                                    child: AutoSizeText(
                                      "Without your secret phrase, you won't be able to access your funds!",
                                      style:
                                          AppStyles.textStyleParagraphPrimary(context),
                                      maxLines: 7,
                                      stepGranularity: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Next Screen Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsetsDirectional.only(end: 30),
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
                                  Navigator.of(context)
                                      .pushNamed('/intro_backup');
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
