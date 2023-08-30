import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/network/account_service.dart';
import 'package:natrium_wallet_flutter/network/model/response/process_response.dart';

import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/flat_button.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';
import 'package:natrium_wallet_flutter/ui/util/routes.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/ninja/ninja_node.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';

import 'changerepresentativemanualentry_sheet.dart';

class AppChangeRepresentativeSheet {
  // State variables
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  StreamSubscription<AuthenticatedEvent> _authSub;

  void _registerBus(BuildContext context) {
    _authSub = EventTaxiImpl.singleton()
        .registerTo<AuthenticatedEvent>()
        .listen((event) {
      if (event.authType == AUTH_EVENT_TYPE.CHANGE) {
        doChange(context);
      }
    });
  }

  void _destroyBus() {
    if (_authSub != null) {
      _authSub.cancel();
    }
  }

  Future<bool> _onWillPop() async {
    _destroyBus();
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

  bool _animationOpen = false;
  NinjaNode _rep;

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
            onPressed: () async {
              if (!NanoAccounts.isValid(NanoAccountType.NANO, rep.account)) {
                return;
              }
              _rep = rep;
              // Authenticate
              AuthenticationMethod authMethod =
                  await sl.get<SharedPrefsUtil>().getAuthMethod();
              bool hasBiometrics =
                  await sl.get<BiometricUtil>().hasBiometrics();
              if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                try {
                  bool authenticated = await sl
                      .get<BiometricUtil>()
                      .authenticateWithBiometrics(context,
                          AppLocalization.of(context).changeRepAuthenticate);
                  if (authenticated) {
                    sl.get<HapticUtil>().fingerprintSucess();
                    EventTaxiImpl.singleton()
                        .fire(AuthenticatedEvent(AUTH_EVENT_TYPE.CHANGE));
                  }
                } catch (e) {
                  await authenticateWithPin(rep.account, context);
                }
              } else {
                // PIN Authentication
                await authenticateWithPin(rep.account, context);
              }
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
                                  text:
                                      "${AppLocalization.of(context).votingWeight}: ",
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
                                  text:
                                      "${AppLocalization.of(context).uptime}: ",
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
                    margin: EdgeInsetsDirectional.only(end: 24, start: 14),
                    child: Stack(
                      children: <Widget>[
                        Container(
                            child: Icon(
                          AppIcons.score,
                          color: StateContainer.of(context).curTheme.primary,
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

  Future<void> doChange(BuildContext context) async {
    _animationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.GENERIC,
        StateContainer.of(context).curTheme.animationOverlayStrong,
        StateContainer.of(context).curTheme.animationOverlayMedium,
        onPoppedCallback: () => _animationOpen = false));
    // If account isnt open, just store the account in sharedprefs
    if (StateContainer.of(context).wallet.openBlock == null) {
      await sl.get<SharedPrefsUtil>().setRepresentative(_rep.account);
      StateContainer.of(context).wallet.representative = _rep.account;
      UIUtil.showSnackbar(AppLocalization.of(context).changeRepSucces, context);
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
    } else {
      try {
        ProcessResponse resp = await sl.get<AccountService>().requestChange(
            StateContainer.of(context).wallet.address,
            _rep.account,
            StateContainer.of(context).wallet.frontier,
            StateContainer.of(context).wallet.accountBalance.toString(),
            NanoUtil.seedToPrivate(await StateContainer.of(context).getSeed(),
                StateContainer.of(context).selectedAccount.index));
        StateContainer.of(context).wallet.representative = _rep.account;
        StateContainer.of(context).wallet.frontier = resp.hash;
        UIUtil.showSnackbar(
            AppLocalization.of(context).changeRepSucces, context);
        Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      } catch (e) {
        sl.get<Logger>().e("Failed to change", error: e);
        if (_animationOpen) {
          Navigator.of(context).pop();
        }
        UIUtil.showSnackbar(AppLocalization.of(context).sendError, context);
      }
    }
  }

  mainBottomSheet(BuildContext context) {
    _registerBus(context);
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
                                margin: EdgeInsetsDirectional.only(
                                    top: 10.0, end: 10.0),
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
                                          barrierColor:
                                              StateContainer.of(context)
                                                  .curTheme
                                                  .barrier,
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
                                      Sheets.showAppHeightEightSheet(
                                          context: context,
                                          widget: ChangeRepManualSheet(
                                              TextEditingController()));
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

  Future<void> authenticateWithPin(String rep, BuildContext context) async {
    // PIN Authentication
    String expectedPin = await sl.get<Vault>().getPin();
    bool auth = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new PinScreen(
        PinOverlayType.ENTER_PIN,
        expectedPin: expectedPin,
        description: AppLocalization.of(context).pinRepChange,
      );
    }));
    if (auth != null && auth) {
      await Future.delayed(Duration(milliseconds: 200));
      EventTaxiImpl.singleton()
          .fire(AuthenticatedEvent(AUTH_EVENT_TYPE.CHANGE));
    }
  }
}
