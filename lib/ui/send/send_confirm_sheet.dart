import 'dart:async';

import 'package:flutter/material.dart';
import 'package:event_taxi/event_taxi.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';

class AppSendConfirmSheet {
  String _amount;
  String _amountRaw;
  String _destination;
  String _contactName;
  String _localCurrency;
  bool _maxSend;

  bool animationOpen = false;

  AppSendConfirmSheet(String amount, String destinaton,
      {bool maxSend = false, String contactName, String localCurrencyAmount}) {
    _amountRaw = amount;
    // Indicate that this is a special amount if some digits are not displayed
    if (NumberUtil.getRawAsUsableString(_amountRaw).replaceAll(",", "") ==
        NumberUtil.getRawAsUsableDecimal(_amountRaw).toString()) {
      _amount = NumberUtil.getRawAsUsableString(_amountRaw);
    } else {
      _amount = NumberUtil.truncateDecimal(
                  NumberUtil.getRawAsUsableDecimal(_amountRaw),
                  digits: 6)
              .toStringAsFixed(6) +
          "~";
    }
    _destination = destinaton.replaceAll("xrb_", "nano_");
    _contactName = contactName;
    _maxSend = maxSend;
    _localCurrency = localCurrencyAmount;
  }

  StreamSubscription<SendFailedEvent> _sendEventFailedSub;

  Future<bool> _onWillPop() async {
    if (_sendEventFailedSub != null) {
      _sendEventFailedSub.cancel();
    }
    return true;
  }

  mainBottomSheet(BuildContext context) {
    _sendEventFailedSub =
        EventTaxiImpl.singleton().registerTo<SendFailedEvent>().listen((event) {
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(AppLocalization.of(context).sendError, context);
      Navigator.of(context).pop();
    });

    AppSheets.showAppHeightNineSheet(
        context: context,
        onDisposed: _onWillPop,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // The main column that holds everything
            return WillPopScope(
              onWillPop: _onWillPop,
              child: SafeArea(
                  minimum: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.035),
                  child: Column(
                    children: <Widget>[
                      // Sheet handle
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 5,
                        width: MediaQuery.of(context).size.width * 0.15,
                        decoration: BoxDecoration(
                          color: StateContainer.of(context).curTheme.text10,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                      ),
                      //The main widget that holds the text fields, "SENDING" and "TO" texts
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // "SENDING" TEXT
                            Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    CaseChange.toUpperCase(
                                        AppLocalization.of(context).sending,
                                        context),
                                    style: AppStyles.textStyleHeader(context),
                                  ),
                                ],
                              ),
                            ),
                            // Container for the amount text
                            Container(
                              margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.105,
                                  right: MediaQuery.of(context).size.width *
                                      0.105),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 15),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: StateContainer.of(context)
                                    .curTheme
                                    .backgroundDarkest,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              // Amount text
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: '',
                                  children: [
                                    TextSpan(
                                      text: "$_amount",
                                      style: TextStyle(
                                        color: StateContainer.of(context)
                                            .curTheme
                                            .primary,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'NunitoSans',
                                      ),
                                    ),
                                    TextSpan(
                                      text: " NANO",
                                      style: TextStyle(
                                        color: StateContainer.of(context)
                                            .curTheme
                                            .primary,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: 'NunitoSans',
                                      ),
                                    ),
                                    TextSpan(
                                      text: _localCurrency != null
                                          ? " ($_localCurrency)"
                                          : "",
                                      style: TextStyle(
                                        color: StateContainer.of(context)
                                            .curTheme
                                            .primary,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'NunitoSans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // "TO" text
                            Container(
                              margin: EdgeInsets.only(top: 30.0, bottom: 10),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    CaseChange.toUpperCase(
                                        AppLocalization.of(context).to,
                                        context),
                                    style: AppStyles.textStyleHeader(context),
                                  ),
                                ],
                              ),
                            ),
                            // Address text
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 15.0),
                                margin: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.105,
                                    right: MediaQuery.of(context).size.width *
                                        0.105),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: StateContainer.of(context)
                                      .curTheme
                                      .backgroundDarkest,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: UIUtil.threeLineAddressText(
                                    context, _destination,
                                    contactName: _contactName)),
                          ],
                        ),
                      ),

                      //A container for CONFIRM and CANCEL buttons
                      Container(
                        child: Column(
                          children: <Widget>[
                            // A row for CONFIRM Button
                            Row(
                              children: <Widget>[
                                // CONFIRM Button
                                AppButton.buildAppButton(
                                    context,
                                    AppButtonType.PRIMARY,
                                    CaseChange.toUpperCase(
                                        AppLocalization.of(context).confirm,
                                        context),
                                    Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                                  // Authenticate
                                  sl.get<SharedPrefsUtil>()
                                      .getAuthMethod()
                                      .then((authMethod) {
                                    sl.get<BiometricUtil>().hasBiometrics()
                                        .then((hasBiometrics) {
                                      if (authMethod.method ==
                                              AuthMethod.BIOMETRICS &&
                                          hasBiometrics) {
                                        sl.get<BiometricUtil>()
                                                .authenticateWithBiometrics(
                                                    context,
                                                    AppLocalization.of(context)
                                                        .sendAmountConfirm
                                                        .replaceAll(
                                                            "%1", _amount))
                                            .then((authenticated) {
                                          if (authenticated) {
                                            sl.get<HapticUtil>().fingerprintSucess();
                                            animationOpen = true;
                                            Navigator.of(context).push(
                                                AnimationLoadingOverlay(
                                                    AnimationType.SEND,
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .animationOverlayStrong,
                                                    StateContainer.of(context)
                                                        .curTheme
                                                        .animationOverlayMedium,
                                                    onPoppedCallback: () =>
                                                        animationOpen = false));
                                            StateContainer.of(context)
                                                .requestSend(
                                                    StateContainer.of(context)
                                                        .wallet
                                                        .frontier,
                                                    _destination,
                                                    _maxSend ? "0" : _amountRaw,
                                                    localCurrencyAmount:
                                                        _localCurrency);
                                          }
                                        });
                                      } else {
                                        // PIN Authentication
                                        sl.get<Vault>().getPin().then((expectedPin) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return new PinScreen(
                                              PinOverlayType.ENTER_PIN,
                                              (pin) {
                                                Navigator.of(context).pop();
                                                animationOpen = true;
                                                Navigator.of(context).push(
                                                    AnimationLoadingOverlay(
                                                        AnimationType.SEND,
                                                        StateContainer.of(
                                                                context)
                                                            .curTheme
                                                            .animationOverlayStrong,
                                                        StateContainer.of(
                                                                context)
                                                            .curTheme
                                                            .animationOverlayMedium,
                                                        onPoppedCallback: () =>
                                                            animationOpen =
                                                                false));
                                                StateContainer.of(context)
                                                    .requestSend(
                                                        StateContainer.of(
                                                                context)
                                                            .wallet
                                                            .frontier,
                                                        _destination,
                                                        _maxSend
                                                            ? "0"
                                                            : _amountRaw);
                                              },
                                              expectedPin: expectedPin,
                                              description:
                                                  AppLocalization.of(context)
                                                      .sendAmountConfirmPin
                                                      .replaceAll(
                                                          "%1", _amount),
                                            );
                                          }));
                                        });
                                      }
                                    });
                                  });
                                }),
                              ],
                            ),
                            // A row for CANCEL Button
                            Row(
                              children: <Widget>[
                                // CANCEL Button
                                AppButton.buildAppButton(
                                    context,
                                    AppButtonType.PRIMARY_OUTLINE,
                                    CaseChange.toUpperCase(
                                        AppLocalization.of(context).cancel,
                                        context),
                                    Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }
}
