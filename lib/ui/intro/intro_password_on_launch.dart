import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';

class IntroPasswordOnLaunch extends StatefulWidget {
  final bool comingFromImport;
  IntroPasswordOnLaunch({this.comingFromImport = false});
  @override
  _IntroPasswordOnLaunchState createState() => _IntroPasswordOnLaunchState();
}

class _IntroPasswordOnLaunchState extends State<IntroPasswordOnLaunch> {
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
              //A widget that holds the header, the paragraph and Back Button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                              highlightColor:
                                  StateContainer.of(context).curTheme.text15,
                              splashColor:
                                  StateContainer.of(context).curTheme.text15,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0)),
                              padding: EdgeInsets.all(0.0),
                              child: Icon(AppIcons.back,
                                  color:
                                      StateContainer.of(context).curTheme.text,
                                  size: 24)),
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
                      child: AutoSizeText(
                        AppLocalization.of(context).requireAPasswordToOpenHeader,
                        maxLines: 3,
                        stepGranularity: 0.5,
                        style: AppStyles.textStyleHeaderColored(context),
                      ),
                    ),
                    // The paragraph
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 16.0),
                      child: AutoSizeText(
                        AppLocalization.of(context).createPasswordFirstParagraph,
                        style: AppStyles.textStyleParagraph(context),
                        maxLines: 5,
                        stepGranularity: 0.5,
                      ),
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 8),
                      child: AutoSizeText(
                        AppLocalization.of(context).createPasswordSecondParagraph,
                        style: AppStyles.textStyleParagraphPrimary(context),
                        maxLines: 4,
                        stepGranularity: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              //A column with "Skip" and "Yes" buttons
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Skip Button
                      AppButton.buildAppButton(context, AppButtonType.PRIMARY,
                          AppLocalization.of(context).noSkipButton, Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        widget.comingFromImport
                            ? Navigator.of(context).pushNamed('/intro_import')
                            : Navigator.of(context)
                                .pushNamed('/intro_backup_safety');
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Yes BUTTON
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).yesButton,
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        widget.comingFromImport
                            ? Navigator.of(context)
                                .pushNamed('/intro_password_fromimport')
                            : Navigator.of(context)
                                .pushNamed('/intro_password');
                      }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
