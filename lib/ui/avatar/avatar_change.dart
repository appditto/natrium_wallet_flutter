import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'dart:math' as math;

class AvatarChangePage extends StatefulWidget {
  final String seed;

  AvatarChangePage({this.seed});
  @override
  _AvatarChangePageState createState() => _AvatarChangePageState();
}

class _AvatarChangePageState extends State<AvatarChangePage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  int nonce;
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
                        "Change Natricon",
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
                        "You'll be asked to send 0.123~ Nano to the Natricon address to change your Natricon.",
                        style: AppStyles.textStyleParagraph(context),
                        maxLines: 3,
                        stepGranularity: 0.5,
                      ),
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(
                          start: smallScreen(context) ? 30 : 40,
                          end: smallScreen(context) ? 30 : 40,
                          top: 8),
                      child: AutoSizeText(
                        "This amount will be automatically refunded completely.",
                        style: AppStyles.textStyleParagraphPrimary(context),
                        maxLines: 2,
                        stepGranularity: 0.5,
                      ),
                    ),
                    Expanded(
                        child: Container(
                      alignment: Alignment.center,
                      child: Stack(alignment: Alignment.center, children: [
                        Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.5,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75),
                          child: SvgPicture.network(
                            'https://natricon.com/api/v1/nano?svc=natrium&outline=true&outlineColor=white&address=' +
                                StateContainer.of(context)
                                    .selectedAccount
                                    .address +
                                "&nonce=" +
                                nonce.toString(),
                            placeholderBuilder: (BuildContext context) =>
                                Container(
                              child: FlareActor(
                                "assets/ntr_placeholder_animation.flr",
                                animation: "main",
                                fit: BoxFit.contain,
                                color:
                                    StateContainer.of(context).curTheme.primary,
                              ),
                            ),
                            key: Key(
                                'https://natricon.com/api/v1/nano?svc=natrium&outline=true&outlineColor=white&address=' +
                                    StateContainer.of(context)
                                        .selectedAccount
                                        .address +
                                    "&nonce=" +
                                    nonce.toString()),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // Previous Natricon Button
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsetsDirectional.only(start: 28),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2,
                                    color: nonce != null
                                        ? StateContainer.of(context)
                                            .curTheme
                                            .primary
                                        : StateContainer.of(context)
                                            .curTheme
                                            .primary20),
                              ),
                              child: FlatButton(
                                highlightColor:
                                    StateContainer.of(context).curTheme.text15,
                                splashColor:
                                    StateContainer.of(context).curTheme.text15,
                                onPressed: nonce != null
                                    ? () {
                                        if (nonce == null) {
                                          return;
                                        } else if (nonce == 0) {
                                          setState(() {
                                            nonce = null;
                                            print(nonce);
                                          });
                                        } else {
                                          setState(() {
                                            nonce--;
                                            print(nonce);
                                          });
                                        }
                                      }
                                    : null,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                padding: EdgeInsetsDirectional.only(end: 4),
                                child: Icon(AppIcons.back,
                                    color: nonce != null
                                        ? StateContainer.of(context)
                                            .curTheme
                                            .primary
                                        : StateContainer.of(context)
                                            .curTheme
                                            .primary20,
                                    size: 24),
                              ),
                            ),
                            // Next Natricon Button
                            Container(
                              height: 50,
                              width: 50,
                              margin: EdgeInsetsDirectional.only(end: 28),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .primary),
                              ),
                              child: FlatButton(
                                highlightColor:
                                    StateContainer.of(context).curTheme.text15,
                                splashColor:
                                    StateContainer.of(context).curTheme.text15,
                                onPressed: () {
                                  if (nonce == null) {
                                    setState(() {
                                      nonce = 0;
                                      print(nonce);
                                    });
                                  } else {
                                    setState(() {
                                      nonce++;
                                      print(nonce);
                                    });
                                  }
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0)),
                                padding: EdgeInsetsDirectional.only(start: 4),
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: Icon(AppIcons.back,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      size: 24),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                    ))
                  ],
                ),
              ),

              //A column with 2 buttons
              Column(
                children: <Widget>[
                  Opacity(
                    opacity: nonce != null ? 1 : 0,
                    child: Row(
                      children: <Widget>[
                        // I want this Button
                        AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY,
                            "I Want This One",
                            Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                          return null;
                        }, disabled: nonce == null),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      // Go Back Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context).goBackButton,
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
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

  void _pinEnteredCallback(String pin) async {
    await sl.get<Vault>().writePin(pin);
    PriceConversion conversion =
        await sl.get<SharedPrefsUtil>().getPriceConversion();
    // Update wallet
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home', (Route<dynamic> route) => false,
        arguments: conversion);
  }
}
