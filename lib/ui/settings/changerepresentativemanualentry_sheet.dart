import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:event_taxi/event_taxi.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/app_simpledialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
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
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/state_block.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';

// TODO - add validations

class AppChangeRepresentativeManualEntrySheet {
  FocusNode _repFocusNode;
  TextEditingController _repController;

  String _changeRepHint = "";
  TextStyle _repAddressStyle;
  bool _showPasteButton = true;
  bool _addressValidAndUnfocused = false;
  bool _animationOpen = false;

  AppChangeRepresentativeManualEntrySheet() {
    _repFocusNode = new FocusNode();
    _repController = new TextEditingController();
  }

  StreamSubscription<RepChangedEvent> _repChangeSub;

  Future<bool> _onWillPop() async {
    if (_repChangeSub != null) {
      _repChangeSub.cancel();
    }
    return true;
  }

  mainBottomSheet(BuildContext context) {
    _changeRepHint = AppLocalization.of(context).changeRepHint;
    _repAddressStyle = AppStyles.textStyleAddressText60(context);
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
            // On address focus change
            _repFocusNode.addListener(() {
              if (_repFocusNode.hasFocus) {
                setState(() {
                  _changeRepHint = "";
                  _addressValidAndUnfocused = false;
                });
                _repController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _repController.text.length));
              } else {
                setState(() {
                  _changeRepHint = AppLocalization.of(context).changeRepHint;
                  if (Address(_repController.text).isValid()) {
                    _addressValidAndUnfocused = true;
                  }
                });
              }
            });
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
                              //A container for the info button
                              Container(
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.only(top: 10.0, left: 10.0),
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
                              // Scan QR Button
                              Container(
                                width: 50,
                                height: 50,
                                margin: EdgeInsets.only(top: 10.0, right: 10.0),
                                child: FlatButton(
                                  highlightColor: StateContainer.of(context)
                                      .curTheme
                                      .text15,
                                  splashColor: StateContainer.of(context)
                                      .curTheme
                                      .text15,
                                  onPressed: () {
                                    UIUtil.cancelLockEvent();
                                    BarcodeScanner.scan(
                                            StateContainer.of(context)
                                                .curTheme
                                                .qrScanTheme)
                                        .then((result) {
                                      if (result == null) {
                                        return;
                                      }
                                      Address address = new Address(result);
                                      if (address.isValid()) {
                                        setState(() {
                                          _addressValidAndUnfocused = true;
                                          _showPasteButton = false;
                                          _repAddressStyle =
                                              AppStyles.textStyleAddressText60(
                                                  context);
                                        });
                                        _repController.text = address.address;
                                        _repFocusNode.unfocus();
                                      } else {
                                        UIUtil.showSnackbar(
                                            AppLocalization.of(context)
                                                .qrInvalidAddress,
                                            context);
                                      }
                                    });
                                  },
                                  child: Icon(AppIcons.scan,
                                      size: 28,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text),
                                  padding: EdgeInsets.all(11.0),
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
                                  bottom: smallScreen(context) ? 20 : 55),
                              child: Stack(children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    // Clear focus of our fields when tapped in this empty space
                                    _repFocusNode.unfocus();
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: SizedBox.expand(),
                                    constraints: BoxConstraints.expand(),
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    // New representative
                                    Container(
                                      margin: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width *
                                                0.105,
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.105,
                                        top:
                                            MediaQuery.of(context).size.height *
                                                0.05,
                                      ),
                                      width: double.infinity,
                                      padding: _addressValidAndUnfocused
                                          ? EdgeInsets.symmetric(
                                              horizontal: 25.0, vertical: 15.0)
                                          : EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        color: StateContainer.of(context)
                                            .curTheme
                                            .backgroundDarkest,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: !_addressValidAndUnfocused
                                          ? TextField(
                                              focusNode: _repFocusNode,
                                              controller: _repController,
                                              textAlign: TextAlign.center,
                                              cursorColor:
                                                  StateContainer.of(context)
                                                      .curTheme
                                                      .primary,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                    65),
                                              ],
                                              textInputAction:
                                                  TextInputAction.done,
                                              maxLines: null,
                                              autocorrect: false,
                                              decoration: InputDecoration(
                                                hintText: _changeRepHint,
                                                // Empty Container
                                                prefixIcon: Container(
                                                  width: 48.0,
                                                  height: 48.0,
                                                ),
                                                // Paste Button
                                                suffixIcon: AnimatedCrossFade(
                                                  duration: Duration(
                                                      milliseconds: 100),
                                                  firstChild: Container(
                                                    width: 48.0,
                                                    height: 48.0,
                                                    child: FlatButton(
                                                      highlightColor:
                                                          StateContainer.of(
                                                                  context)
                                                              .curTheme
                                                              .primary15,
                                                      splashColor:
                                                          StateContainer.of(
                                                                  context)
                                                              .curTheme
                                                              .primary30,
                                                      padding:
                                                          EdgeInsets.all(15.0),
                                                      onPressed: () {
                                                        if (!_showPasteButton) {
                                                          return;
                                                        }
                                                        Clipboard.getData(
                                                                "text/plain")
                                                            .then((ClipboardData
                                                                data) {
                                                          if (data == null ||
                                                              data.text ==
                                                                  null) {
                                                            return;
                                                          }
                                                          Address address =
                                                              new Address(
                                                                  data.text);
                                                          if (address
                                                              .isValid()) {
                                                            setState(() {
                                                              _addressValidAndUnfocused =
                                                                  true;
                                                              _showPasteButton =
                                                                  false;
                                                              _repAddressStyle =
                                                                  AppStyles
                                                                      .textStyleAddressText90(
                                                                          context);
                                                            });
                                                            _repController
                                                                    .text =
                                                                address.address;
                                                            _repFocusNode
                                                                .unfocus();
                                                          }
                                                        });
                                                      },
                                                      child: Icon(
                                                          AppIcons.paste,
                                                          size: 20.0,
                                                          color:
                                                              StateContainer.of(
                                                                      context)
                                                                  .curTheme
                                                                  .primary),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          200.0)),
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .padded,
                                                    ),
                                                  ),
                                                  secondChild: SizedBox(),
                                                  crossFadeState:
                                                      _showPasteButton
                                                          ? CrossFadeState
                                                              .showFirst
                                                          : CrossFadeState
                                                              .showSecond,
                                                ),
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                  fontFamily: 'NunitoSans',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w100,
                                                  color:
                                                      StateContainer.of(context)
                                                          .curTheme
                                                          .text60,
                                                ),
                                              ),
                                              keyboardType: TextInputType.text,
                                              style: _repAddressStyle,
                                              onChanged: (text) {
                                                if (Address(text).isValid()) {
                                                  _repFocusNode.unfocus();
                                                  setState(() {
                                                    _showPasteButton = false;
                                                    _repAddressStyle = AppStyles
                                                        .textStyleAddressText90(
                                                            context);
                                                  });
                                                } else {
                                                  setState(() {
                                                    _showPasteButton = true;
                                                    _repAddressStyle = AppStyles
                                                        .textStyleAddressText60(
                                                            context);
                                                  });
                                                }
                                              },
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _addressValidAndUnfocused =
                                                      false;
                                                });
                                                Future.delayed(
                                                    Duration(milliseconds: 50),
                                                    () {
                                                  FocusScope.of(context)
                                                      .requestFocus(
                                                          _repFocusNode);
                                                });
                                              },
                                              child:
                                                  UIUtil.threeLineAddressText(
                                                      context,
                                                      _repController.text),
                                            ),
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
                                    AppLocalization.of(context)
                                        .changeRepButton
                                        .toUpperCase(),
                                    Dimens.BUTTON_TOP_DIMENS,
                                    onPressed: () {
                                      if (!NanoAccounts.isValid(
                                          NanoAccountType.NANO,
                                          _repController.text)) {
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
                                                _animationOpen = true;
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
                                                            .animationOverlayMedium,
                                                        onPoppedCallback: () =>
                                                            _animationOpen =
                                                                false));
                                                // If account isnt open, just store the account in sharedprefs
                                                if (StateContainer.of(context)
                                                        .wallet
                                                        .openBlock ==
                                                    null) {
                                                  sl
                                                      .get<SharedPrefsUtil>()
                                                      .setRepresentative(
                                                          _repController.text)
                                                      .then((result) {
                                                    EventTaxiImpl.singleton()
                                                        .fire(RepChangedEvent(
                                                            previous: StateBlock(
                                                                representative:
                                                                    _repController
                                                                        .text,
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
                                                          _repController.text);
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
                                                              _repController
                                                                  .text)
                                                          .then((result) {
                                                        EventTaxiImpl
                                                                .singleton()
                                                            .fire(RepChangedEvent(
                                                                previous: StateBlock(
                                                                    representative:
                                                                        _repController
                                                                            .text,
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
                                                              _repController
                                                                  .text);
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
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  AppButton.buildAppButton(
                                    context,
                                    AppButtonType.PRIMARY_OUTLINE,
                                    CaseChange.toUpperCase(
                                        AppLocalization.of(context).close,
                                        context),
                                    Dimens.BUTTON_BOTTOM_DIMENS,
                                    onPressed: () {
                                      Navigator.pop(context);
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
