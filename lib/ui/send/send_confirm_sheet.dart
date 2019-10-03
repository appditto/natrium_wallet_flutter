import 'dart:async';

import 'package:flutter/material.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:manta_dart/messages.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/biometrics.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/model/authentication_method.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/ui/widgets/security.dart';

class SendConfirmSheet extends StatefulWidget {
  final String amountRaw;
  final String destination;
  final String contactName;
  final String localCurrency;
  final bool maxSend;
  final MantaWallet manta;

  SendConfirmSheet(
      {this.amountRaw,
      this.destination,
      this.contactName,
      this.localCurrency,
      this.manta,
      this.maxSend = false})
      : super();

  _SendConfirmSheetState createState() => _SendConfirmSheetState();
}

class _SendConfirmSheetState extends State<SendConfirmSheet> {
  String amount;
  String destinationAltered;
  bool animationOpen;
  bool sent;
  bool isMantaTransaction;

  @override
  void initState() {
    super.initState();
    _registerBus();
    this.animationOpen = false;
    this.sent = false;
    this.isMantaTransaction = true;
    // Derive amount from raw amount
    if (NumberUtil.getRawAsUsableString(widget.amountRaw).replaceAll(",", "") ==
        NumberUtil.getRawAsUsableDecimal(widget.amountRaw).toString()) {
      amount = NumberUtil.getRawAsUsableString(widget.amountRaw);
    } else {
      amount = NumberUtil.truncateDecimal(
                  NumberUtil.getRawAsUsableDecimal(widget.amountRaw),
                  digits: 6)
              .toStringAsFixed(6) +
          "~";
    }
    // Ensure nano_ prefix on destination
    destinationAltered = widget.destination.replaceAll("xrb_", "nano_");
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  // Event bus
  StreamSubscription<SendFailedEvent> _sendEventFailedSub;
  StreamSubscription<ProcessEvent> _processEventSub;

  void _registerBus() {
    _sendEventFailedSub =
        EventTaxiImpl.singleton().registerTo<SendFailedEvent>().listen((event) {
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(AppLocalization.of(context).sendError, context);
      Navigator.of(context).pop();
    });
    _processEventSub =
        EventTaxiImpl.singleton().registerTo<ProcessEvent>().listen((event) {
      if (!sent && widget.manta != null) {
        widget.manta.sendPayment(
            transactionHash: event.response.hash, cryptoCurrency: "NANO");
      }
      sent = true;
    });
  }

  void _destroyBus() {
    if (_sendEventFailedSub != null) {
      _sendEventFailedSub.cancel();
    }
    if (_processEventSub != null) {
      _processEventSub.cancel();
    }
  }

  void _showSendingAnimation() {
    animationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.SEND,
        StateContainer.of(context).curTheme.animationOverlayStrong,
        StateContainer.of(context).curTheme.animationOverlayMedium,
        onPoppedCallback: () => animationOpen = false));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.035),
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
                              AppLocalization.of(context).sending, context),
                          style: AppStyles.textStyleHeader(context),
                        ),
                      ],
                    ),
                  ),
                  // Container for the amount text
                  Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.105,
                        right: MediaQuery.of(context).size.width * 0.105),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          StateContainer.of(context).curTheme.backgroundDarkest,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // Amount text
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: "$amount",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                          TextSpan(
                            text: " NANO",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context).curTheme.primary,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                          TextSpan(
                            text: widget.localCurrency != null
                                ? " ($widget.localCurrency)"
                                : "",
                            style: TextStyle(
                              color:
                                  StateContainer.of(context).curTheme.primary,
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
                              AppLocalization.of(context).to, context),
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
                          left: MediaQuery.of(context).size.width * 0.105,
                          right: MediaQuery.of(context).size.width * 0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)
                            .curTheme
                            .backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: isMantaTransaction
                          ? Column(
                              children: <Widget>[
                                AutoSizeText(
                                  "Appditto",
                                  minFontSize: 12,
                                  stepGranularity: 0.1,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.headerPrimary(context),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                AutoSizeText(
                                  "123 Sesame St, Ohio, United States 55555",
                                  minFontSize: 10,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  stepGranularity: 0.1,
                                  style: AppStyles.addressText(context),
                                ),
                                Container(
                                  margin: EdgeInsetsDirectional.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsetsDirectional.only(
                                            start: 10, end: 20),
                                        child: Icon(
                                          AppIcons.appia,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                smallScreen(context)
                                    ? UIUtil.oneLineAddressText(
                                        context, destinationAltered)
                                    : UIUtil.threeLineAddressText(
                                        context, destinationAltered)
                              ],
                            )
                          : UIUtil.threeLineAddressText(
                              context, destinationAltered,
                              contactName: widget.contactName)),
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
                              AppLocalization.of(context).confirm, context),
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                        // Authenticate
                        sl
                            .get<SharedPrefsUtil>()
                            .getAuthMethod()
                            .then((authMethod) {
                          sl
                              .get<BiometricUtil>()
                              .hasBiometrics()
                              .then((hasBiometrics) {
                            if (authMethod.method == AuthMethod.BIOMETRICS &&
                                hasBiometrics) {
                              sl
                                  .get<BiometricUtil>()
                                  .authenticateWithBiometrics(
                                      context,
                                      AppLocalization.of(context)
                                          .sendAmountConfirm
                                          .replaceAll("%1", amount))
                                  .then((authenticated) {
                                if (authenticated) {
                                  sl.get<HapticUtil>().fingerprintSucess();
                                  _showSendingAnimation();
                                  StateContainer.of(context).requestSend(
                                      StateContainer.of(context)
                                          .wallet
                                          .frontier,
                                      destinationAltered,
                                      widget.maxSend ? "0" : widget.amountRaw,
                                      localCurrencyAmount:
                                          widget.localCurrency);
                                }
                              });
                            } else {
                              // PIN Authentication
                              sl.get<Vault>().getPin().then((expectedPin) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return new PinScreen(
                                    PinOverlayType.ENTER_PIN,
                                    (pin) {
                                      Navigator.of(context).pop();
                                      _showSendingAnimation();
                                      StateContainer.of(context).requestSend(
                                          StateContainer.of(context)
                                              .wallet
                                              .frontier,
                                          destinationAltered,
                                          widget.maxSend
                                              ? "0"
                                              : widget.amountRaw);
                                    },
                                    expectedPin: expectedPin,
                                    description: AppLocalization.of(context)
                                        .sendAmountConfirmPin
                                        .replaceAll("%1", amount),
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
                              AppLocalization.of(context).cancel, context),
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
