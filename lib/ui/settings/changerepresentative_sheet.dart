import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:event_taxi/event_taxi.dart';
import 'package:nanodart/nanodart.dart';

import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/ui/util/routes.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/util/ninja/ninja_node.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/state_block.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';

import 'changerepresentativemanualentry_sheet.dart';

class AppChangeRepresentativeSheet {
  // State variables
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  StreamSubscription<RepChangedEvent> _repChangeSub;

  Future<bool> _onWillPop() async {
    if (_repChangeSub != null) {
      _repChangeSub.cancel();
    }
    return true;
  }

  _getRepresentativeWidgets(BuildContext context, List<NinjaNode> list) {
    if (list == null) return [];
    List<Widget> ret = [];
    list.forEach((node) {
      if (node.alias != null && node.alias.trim().length > 0) {
        ret.add(_buildSingleRepresentative(
          node,
          context,
        ));
      }
    });
    return ret;
  }

  _buildRepresenativeDialog(BuildContext context) {
    return AppSimpleDialog(
        title: Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Text(
            AppLocalization.of(context).representatives,
            style: AppStyles.textStyleDialogHeader(context),
          ),
        ),
        children: _getRepresentativeWidgets(
            context, StateContainer.of(context).nanoNinjaNodes));
  }

  String _sanitizeAlias(String alias) {
    if (alias != null) {
      return alias.replaceAll(RegExp(r'[^a-zA-Z_.!?_;:-]'), '');
    }
    return '';
  }

  _buildSingleRepresentative(NinjaNode rep, BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Divider(
            height: 2,
            color: StateContainer.of(context).curTheme.text15,
          ),
          FlatButton(
            highlightColor: StateContainer.of(context).curTheme.text15,
            splashColor: StateContainer.of(context).curTheme.text15,
            onPressed: () {
              if (!NanoAccounts.isValid(NanoAccountType.NANO, rep.account)) {
                  return;
              }
                // Authenticate
                sl
                    .get<SharedPrefsUtil>()
                    .getAuthMethod()
                    .then((authMethod) {
                  sl
                      .get<BiometricUtil>()
                      .hasBiometrics()
                      .then((hasBiometrics) {
                    if (authMethod.method ==
                            AuthMethod.BIOMETRICS &&
                        hasBiometrics) {
                      sl
                          .get<BiometricUtil>()
                          .authenticateWithBiometrics(
                              context,
                              AppLocalization.of(context)
                                  .changeRepAuthenticate)
                          .then((authenticated) {
                        if (authenticated) {
                          sl
                              .get<HapticUtil>()
                              .fingerprintSucess();
                          Navigator.of(context).push(
                              AnimationLoadingOverlay(
                                  AnimationType.GENERIC,
                                  StateContainer.of(
                                          context)
                                      .curTheme
                                      .animationOverlayStrong,
                                  StateContainer.of(
                                          context)
                                      .curTheme
                                      .animationOverlayMedium));
                          // If account isnt open, just store the account in sharedprefs
                          if (StateContainer.of(context)
                                  .wallet
                                  .openBlock ==
                              null) {
                            sl
                                .get<SharedPrefsUtil>()
                                .setRepresentative(
                                    rep.account)
                                .then((result) {
                              EventTaxiImpl.singleton()
                                  .fire(RepChangedEvent(
                                      previous: StateBlock(
                                          representative:
                                              rep.account,
                                          previous: "",
                                          link: "",
                                          balance: "",
                                          account: "")));
                            });
                          } else {
                            StateContainer.of(context)
                                .requestChange(
                                    StateContainer.of(
                                            context)
                                        .wallet
                                        .frontier,
                                    StateContainer.of(
                                            context)
                                        .wallet
                                        .accountBalance
                                        .toString(),
                                    rep.account);
                          }
                        }
                      });
                    } else {
                      // PIN Authentication
                      sl
                          .get<Vault>()
                          .getPin()
                          .then((expectedPin) {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder:
                                (BuildContext context) {
                          return new PinScreen(
                            PinOverlayType.ENTER_PIN,
                            (pin) {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                  AnimationLoadingOverlay(
                                AnimationType.GENERIC,
                                StateContainer.of(context)
                                    .curTheme
                                    .animationOverlayStrong,
                                StateContainer.of(context)
                                    .curTheme
                                    .animationOverlayMedium,
                              ));
                              // If account isnt open, just store the account in sharedprefs
                              if (StateContainer.of(
                                          context)
                                      .wallet
                                      .openBlock ==
                                  null) {
                                sl
                                    .get<
                                        SharedPrefsUtil>()
                                    .setRepresentative(
                                        rep.account)
                                    .then((result) {
                                  EventTaxiImpl
                                          .singleton()
                                      .fire(RepChangedEvent(
                                          previous: StateBlock(
                                              representative:
                                                  rep.account,
                                              previous:
                                                  "",
                                              link: "",
                                              balance: "",
                                              account:
                                                  "")));
                                });
                              } else {
                                StateContainer.of(context)
                                    .requestChange(
                                        StateContainer.of(
                                                context)
                                            .wallet
                                            .frontier,
                                        StateContainer.of(
                                                context)
                                            .wallet
                                            .accountBalance
                                            .toString(),
                                          rep.account);
                              }
                            },
                            expectedPin: expectedPin,
                            description:
                                AppLocalization.of(
                                        context)
                                    .pinRepChange,
                          );
                        }));
                      });
                    }
                 });
                });
            },
            padding: EdgeInsets.all(0),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsetsDirectional.only(start: 24),
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _sanitizeAlias(rep.alias),
                          style: TextStyle(
                              color: StateContainer.of(context).curTheme.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.0,
                              fontFamily: 'Nunito Sans'),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 7),
                          child: RichText(
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: "${AppLocalization.of(context).votingWeight}: ",
                                  style: TextStyle(
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .text,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 14.0,
                                    fontFamily: 'Nunito Sans',
                                  ),
                                ),
                                TextSpan(
                                  text: NumberUtil.getPercentOfTotalSupply(
                                      rep.votingWeight),
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                                TextSpan(
                                  text: "%",
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          child: RichText(
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: "${AppLocalization.of(context).uptime}: ",
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text,
                                      fontWeight: FontWeight.w100,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                                TextSpan(
                                  text: (rep.uptime).toStringAsFixed(2),
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                                TextSpan(
                                  text: "%",
                                  style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.0,
                                      fontFamily: 'Nunito Sans'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsetsDirectional.only(end: 24, start:14),
                    child: Stack(
                      children: <Widget>[
                        Container(
                            child: Icon(
                              AppIcons.score,
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              size: 50,
                            )),
                        Container(
                          alignment: AlignmentDirectional(-0.03, 0.03),
                          width: 50,
                          height: 50,
                          child: Text(
                            (rep.score).toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: StateContainer.of(context)
                                  .curTheme
                                  .backgroundDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Nunito Sans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  mainBottomSheet(BuildContext context) {
    _repChangeSub =
        EventTaxiImpl.singleton().registerTo<RepChangedEvent>().listen((event) {
      if (event.previous != null) {
        StateContainer.of(context).wallet.representative =
            event.previous.representative;
        UIUtil.showSnackbar(
            AppLocalization.of(context).changeRepSucces, context);
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      }
    });

    AppSheets.showAppHeightEightSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
                onWillPop: _onWillPop,
                child: SafeArea(
                    minimum: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.035,
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          //A container for the header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 60, width: 60),
                              //Container for the header
                              Column(
                                children: <Widget>[
                                  // Sheet handle
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    height: 5,
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    decoration: BoxDecoration(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text10,
                                      borderRadius:
                                          BorderRadius.circular(100.0),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width -
                                                140),
                                    child: AutoSizeText(
                                      CaseChange.toUpperCase(
                                          AppLocalization.of(context)
                                              .changeRepAuthenticate,
                                          context),
                                      style: AppStyles.textStyleHeader(context),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      stepGranularity: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                              //A container for the info button
                              Container(
                                width: 50,
                                height: 50,
                                margin: EdgeInsetsDirectional.only(top: 10.0, end: 10.0),
                                child: FlatButton(
                                  highlightColor: StateContainer.of(context)
                                      .curTheme
                                      .text15,
                                  splashColor: StateContainer.of(context)
                                      .curTheme
                                      .text15,
                                  onPressed: () {
                                    AppDialogs.showInfoDialog(
                                        context,
                                        AppLocalization.of(context)
                                            .repInfoHeader,
                                        AppLocalization.of(context).repInfo);
                                  },
                                  child: Icon(AppIcons.info,
                                      size: 24,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text),
                                  padding: EdgeInsets.all(13.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(100.0)),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                ),
                              ),
                            ],
                          ),

                          //A expanded section for current representative and new representative fields
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: smallScreen(context) ? 20 : 35,
                                  bottom: smallScreen(context) ? 20 : 35),
                              child: Stack(children: <Widget>[
                                Container(
                                    color: Colors.transparent,
                                    child: SizedBox.expand(),
                                    constraints: BoxConstraints.expand(),
                                ),
                                Column(
                                  children: <Widget>[
                                    // Currently represented by text
                                    Container(
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.105,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.105),
                                        child: Text(
                                          AppLocalization.of(context)
                                              .currentlyRepresented,
                                          style: AppStyles.textStyleParagraph(
                                              context),
                                        )),
                                    // Current representative
                                    GestureDetector(
                                      onTap: () {
                                        Clipboard.setData(new ClipboardData(
                                            text: StateContainer.of(context)
                                                .wallet
                                                .representative));
                                        setState(() {
                                          _addressCopied = true;
                                        });
                                        if (_addressCopiedTimer != null) {
                                          _addressCopiedTimer.cancel();
                                        }
                                        _addressCopiedTimer = new Timer(
                                            const Duration(milliseconds: 800),
                                            () {
                                          setState(() {
                                            _addressCopied = false;
                                          });
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        margin: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.105,
                                            right: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.105,
                                            top: 10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 25.0, vertical: 15.0),
                                        decoration: BoxDecoration(
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .backgroundDarkest,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: UIUtil.threeLineAddressText(
                                            context,
                                            StateContainer.of(context)
                                                .wallet
                                                .representative,
                                            type: _addressCopied
                                                ? ThreeLineAddressTextType
                                                    .SUCCESS_FULL
                                                : ThreeLineAddressTextType
                                                    .PRIMARY),
                                      ),
                                    ),
                                    // Address Copied text container
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 5, bottom: 5),
                                      child: Text(
                                          _addressCopied
                                              ? AppLocalization.of(context)
                                                  .addressCopied
                                              : "",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: StateContainer.of(context)
                                                .curTheme
                                                .success,
                                            fontFamily: 'NunitoSans',
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          ),

                          //A row with change and close button
                          Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  AppButton.buildAppButton(
                                    context,
                                    AppButtonType.PRIMARY,
                                    AppLocalization.of(context).pickFromList,
                                    Dimens.BUTTON_TOP_DIMENS,
                                    disabled: StateContainer.of(context)
                                            .nanoNinjaNodes ==
                                        null,
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return _buildRepresenativeDialog(
                                                context);
                                          });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  AppButton.buildAppButton(
                                    context,
                                    AppButtonType.PRIMARY_OUTLINE,
                                    AppLocalization.of(context).manualEntry,
                                    Dimens.BUTTON_BOTTOM_DIMENS,
                                    onPressed: () {
                                      AppChangeRepresentativeManualEntrySheet()
                                          .mainBottomSheet(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    )));
          });
        });
  }
}
