import 'package:flutter/material.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/biometrics.dart';
import 'package:kalium_wallet_flutter/util/hapticutil.dart';
import 'package:kalium_wallet_flutter/model/authentication_method.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/network/model/response/error_response.dart';
import 'package:kalium_wallet_flutter/ui/widgets/security.dart';

class KaliumSendConfirmSheet {
  String _amount;
  String _amountRaw;
  String _destination;
  String _contactName;
  bool _maxSend;

  bool animationOpen = false;

  KaliumSendConfirmSheet(String amount, String destinaton, {bool maxSend = false, String contactName}) {
    _amount = amount;
    _amountRaw = NumberUtil.getAmountAsRaw(amount);
    _destination = destinaton;
    _contactName = contactName;
    _maxSend = maxSend;
  }

  Future<bool> _onWillPop() async {
    RxBus.destroy(tag: RX_SEND_FAILED_TAG);
    return true;
  }

  mainBottomSheet(BuildContext context) {
    RxBus.register<ErrorResponse>(tag: RX_SEND_FAILED_TAG).listen((result) {
      // Send failed
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      UIUtil.showSnackbar(KaliumLocalization.of(context).sendError, context);
      Navigator.of(context).pop();
    });

    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        animationDurationMs: 100,
        onDisposed: _onWillPop,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // The main column that holds everything
            return WillPopScope(
              onWillPop: _onWillPop,
              child: Column(
                children: <Widget>[
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
                                KaliumLocalization.of(context).sending.toUpperCase(),
                                style: KaliumStyles.textStyleHeader(context),
                              ),
                            ],
                          ),
                        ),
                        // Container for the amount text
                        Container(
                          margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.105, right: MediaQuery.of(context).size.width*0.105),
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
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
                                    color: KaliumColors.primary,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'NunitoSans',
                                  ),
                                ),
                                TextSpan(
                                  text: " BAN",
                                  style: TextStyle(
                                    color: KaliumColors.primary,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w100,
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
                                KaliumLocalization.of(context).to.toUpperCase(),
                                style: KaliumStyles.textStyleHeader(context),
                              ),
                            ],
                          ),
                        ),
                        // Address text
                        Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 15.0),
                            margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.105, right: MediaQuery.of(context).size.width*0.105),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: KaliumColors.backgroundDarkest,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: UIUtil.threeLineAddressText(_destination, contactName: _contactName)),
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
                            KaliumButton.buildKaliumButton(
                                KaliumButtonType.PRIMARY,
                                KaliumLocalization.of(context).confirm.toUpperCase(),
                                Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                                // Authenticate
                                SharedPrefsUtil.inst.getAuthMethod().then((authMethod) {
                                  BiometricUtil.hasBiometrics().then((hasBiometrics) {
                                    if (authMethod.method == AuthMethod.BIOMETRICS && hasBiometrics) {
                                      BiometricUtil.authenticateWithBiometrics(
                                        KaliumLocalization.of(context).sendAmountConfirm.replaceAll("%1", _amount)).then((authenticated) {
                                        if (authenticated) {
                                          HapticUtil.fingerprintSucess();
                                          animationOpen = true;
                                          Navigator.of(context).push(AnimationLoadingOverlay(AnimationType.SEND, onPoppedCallback: () => animationOpen = false));
                                          StateContainer.of(context).requestSend(
                                              StateContainer.of(context).wallet.frontier,
                                              _destination,
                                              _maxSend ? "0" : _amountRaw);
                                        }
                                      });
                                    } else {
                                      // PIN Authentication
                                      Vault.inst.getPin().then((expectedPin) {
                                        Navigator.of(context).push(MaterialPageRoute(
                                            builder: (BuildContext context) {
                                          return new PinScreen(PinOverlayType.ENTER_PIN, 
                                                              (pin) {
                                                                Navigator.of(context).pop();
                                                                animationOpen = true;
                                                                Navigator.of(context).push(AnimationLoadingOverlay(AnimationType.SEND, onPoppedCallback: () => animationOpen = false));
                                                                StateContainer.of(context).requestSend(
                                                                    StateContainer.of(context).wallet.frontier,
                                                                    _destination,
                                                                    _maxSend ? "0" : _amountRaw);
                                                              },
                                                              expectedPin:expectedPin,
                                                              description: KaliumLocalization.of(context).sendAmountConfirmPin.replaceAll("%1", _amount),);
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
                            KaliumButton.buildKaliumButton(
                                KaliumButtonType.PRIMARY_OUTLINE,
                                KaliumLocalization.of(context).cancel.toUpperCase(),
                                Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                              Navigator.of(context).pop();
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}
