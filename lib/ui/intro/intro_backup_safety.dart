import 'dart:async';
import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';

class IntroBackupSafetyPage extends StatefulWidget {
  @override
  _IntroBackupSafetyState createState() => _IntroBackupSafetyState();
}

class _IntroBackupSafetyState extends State<IntroBackupSafetyPage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
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
                          ],
                        ),
                        // Safety icon
                        Container(
                          margin: EdgeInsetsDirectional.only(
                            start: smallScreen(context) ? 30 : 40,
                            top: 15,
                          ),
                          child: Icon(
                            AppIcons.security,
                            size: 60,
                            color:
                                StateContainer.of(context).curTheme.primary,
                          ),
                        ),
                        // The header
                        Container(
                          margin: EdgeInsetsDirectional.only(
                            start: smallScreen(context) ? 30 : 40,
                            end: smallScreen(context) ? 30 : 40,
                            top: 10,
                          ),
                          alignment: AlignmentDirectional(-1, 0),
                          child: AutoSizeText(
                            "Safety First!",
                            style:
                                AppStyles.textStyleHeaderColored(context),
                            stepGranularity: 0.1,
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                        ),
                        // The paragraph
                        Container(
                          margin: EdgeInsetsDirectional.only(
                              start: smallScreen(context) ? 30 : 40,
                              end: smallScreen(context) ? 30 : 40,
                              top: 15.0),
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: <Widget>[
                              AutoSizeText(
                                "In the next screen, you will see your secret phrase. It is a password to access your funds. It is crucial that you back it up and never share it with anyone.",
                                style:
                                    AppStyles.textStyleParagraph(context),
                                maxLines: 5,
                                stepGranularity: 0.5,
                              ),
                              Container(
                                margin: EdgeInsetsDirectional.only(top: 15),
                                child: AutoSizeText(
                                  "If you lose your device or uninstall the application, you'll need your secret phrase or seed to recover your funds!",
                                  style:
                                      AppStyles.textStyleParagraphPrimary(
                                          context),
                                  maxLines: 4,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY,
                          "Got It!",
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pushNamed('/intro_backup');
                      }),
                    ],
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
