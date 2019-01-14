import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_nano_core/flutter_nano_core.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:kalium_wallet_flutter/ui/widgets/security.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/biometrics.dart';
import 'package:kalium_wallet_flutter/model/address.dart';
import 'package:kalium_wallet_flutter/model/authentication_method.dart';
import 'package:kalium_wallet_flutter/model/state_block.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';

// TODO - add validations

class KaliumChangeRepresentativeSheet {
  FocusNode _repFocusNode;
  TextEditingController _repController;

  static const String _changeRepHintText = "Enter Representative";
  String _changeRepHint;
  TextStyle _repAddressStyle;

  KaliumChangeRepresentativeSheet() {
    _repFocusNode = new FocusNode();
    _repController = new TextEditingController();
    _repAddressStyle = KaliumStyles.TextStyleAddressText60;
  }

  mainBottomSheet(BuildContext context) {
    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // On address focus change
            _repFocusNode.addListener(() {
              if (_repFocusNode.hasFocus) {
                setState(() {
                  _changeRepHint = "";
                });
              } else {
                setState(() {
                  _changeRepHint = _changeRepHintText;
                });
              }
            });
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  //A container for the header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //This container is a temporary solution for the alignment problem
                      SizedBox(
                        width: 60,
                        height: 60,
                      ),

                      //Container for the header
                      Expanded(
                        child: Container(
                          alignment: Alignment(0, 0),
                          margin: EdgeInsets.only(top: 30),
                          child: Wrap(
                            direction: Axis.horizontal,
                            children: <Widget>[
                              Text(
                                "CHANGE REPRESENTATIVE",
                                style: KaliumStyles.TextStyleHeader,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      //A container for the info button
                      Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(top: 10.0, right: 10.0),
                        child: FlatButton(
                          onPressed: () {
                            KaliumDialogs.showInfoDialog(
                                context,
                                "What is a representative?",
                                "A representative is an account that votes for network consensus. Voting power is weighted by balance, you may delegate your balance to increase the voting weight of a representative you trust. Your representative does not have spending power over your funds. You should choose a representative that has little downtime and is trustworthy.");
                          },
                          child: Icon(KaliumIcons.info,
                              size: 24, color: KaliumColors.text),
                          padding: EdgeInsets.all(13.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                      ),
                    ],
                  ),

                  //A expanded section for current representative and new representative fields
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 35, bottom: 35),
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
                            Container(
                                margin: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.105,
                                    right: MediaQuery.of(context).size.width *
                                        0.105),
                                child: Text(
                                  "Currently Representative By",
                                  style: KaliumStyles.TextStyleParagraph,
                                )),
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.105,
                                  right:
                                      MediaQuery.of(context).size.width * 0.105,
                                  top: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 25.0, vertical: 15.0),
                              decoration: BoxDecoration(
                                color: KaliumColors.backgroundDarkest,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: UIUtil.threeLineAddressText(
                                  StateContainer.of(context)
                                      .wallet
                                      .representative),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.105,
                                  right:
                                      MediaQuery.of(context).size.width * 0.105,
                                  top: 20),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: KaliumColors.backgroundDarkest,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: TextField(
                                focusNode: _repFocusNode,
                                controller: _repController,
                                textAlign: TextAlign.center,
                                cursorColor: KaliumColors.primary,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(64),
                                ],
                                textInputAction: TextInputAction.done,
                                maxLines: null,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: "Enter New Rep",
                                  // Empty Container
                                  prefixIcon: Container(
                                    width: 48.0,
                                    height: 48.0,
                                  ),
                                  // Paste Button
                                  suffixIcon: Container(
                                    width: 48.0,
                                    height: 48.0,
                                    child: FlatButton(
                                      padding: EdgeInsets.all(15.0),
                                      onPressed: () {
                                        Clipboard.getData("text/plain")
                                            .then((ClipboardData data) {
                                          if (data == null ||
                                              data.text == null) {
                                            return;
                                          }
                                          Address address =
                                              new Address(data.text);
                                          if (NanoAccounts.isValid(
                                              NanoAccountType.BANANO,
                                              address.address)) {
                                            setState(() {
                                              _repAddressStyle = KaliumStyles
                                                  .TextStyleAddressText90;
                                            });
                                            _repController.text =
                                                address.address;
                                          }
                                        });
                                      },
                                      child: Icon(KaliumIcons.paste,
                                          size: 20.0,
                                          color: KaliumColors.primary),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(200.0)),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.padded,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontFamily: 'NunitoSans',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w100),
                                ),
                                keyboardType: TextInputType.text,
                                style: _repAddressStyle,
                                onChanged: (text) {
                                  if (NanoAccounts.isValid(
                                      NanoAccountType.BANANO, text)) {
                                    _repFocusNode.unfocus();
                                    setState(() {
                                      _repAddressStyle =
                                          KaliumStyles.TextStyleAddressText90;
                                    });
                                  } else {
                                    setState(() {
                                      _repAddressStyle =
                                          KaliumStyles.TextStyleAddressText60;
                                    });
                                  }
                                },
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
                          KaliumButton.buildKaliumButton(
                            KaliumButtonType.PRIMARY,
                            'CHANGE',
                            Dimens.BUTTON_TOP_DIMENS,
                            onPressed: () {
                              if (!NanoAccounts.isValid(NanoAccountType.BANANO,
                                  _repController.text)) {
                                return;
                              }
                              // Authenticate
                              SharedPrefsUtil.inst
                                  .getAuthMethod()
                                  .then((authMethod) {
                                BiometricUtil.hasBiometrics()
                                    .then((hasBiometrics) {
                                  if (authMethod.method ==
                                          AuthMethod.BIOMETRICS &&
                                      hasBiometrics) {
                                    BiometricUtil.authenticateWithBiometrics(
                                            "Change Representative")
                                        .then((authenticated) {
                                      if (authenticated) {
                                        Navigator.of(context)
                                            .push(SendAnimationOverlay());
                                        // If account isnt open, just store the account in sharedprefs
                                        if (StateContainer.of(context)
                                                .wallet
                                                .openBlock ==
                                            null) {
                                          SharedPrefsUtil.inst
                                              .setRepresentative(
                                                  _repController.text)
                                              .then((result) {
                                            RxBus.post(
                                                new StateBlock(
                                                    representative:
                                                        _repController.text,
                                                    previous: "",
                                                    link: "",
                                                    balance: "",
                                                    account: ""),
                                                tag: RX_REP_CHANGED_TAG);
                                          });
                                        } else {
                                          StateContainer.of(context)
                                              .requestChange(
                                                  StateContainer.of(context)
                                                      .wallet
                                                      .frontier,
                                                  StateContainer.of(context)
                                                      .wallet
                                                      .accountBalance
                                                      .toString(),
                                                  _repController.text);
                                        }
                                      }
                                    });
                                  } else {
                                    // PIN Authentication
                                    Vault.inst.getPin().then((expectedPin) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return new PinScreen(
                                          PinOverlayType.ENTER_PIN,
                                          (pin) {
                                            Navigator.of(context)
                                                .push(SendAnimationOverlay());
                                            // If account isnt open, just store the account in sharedprefs
                                            if (StateContainer.of(context)
                                                    .wallet
                                                    .openBlock ==
                                                null) {
                                              SharedPrefsUtil.inst
                                                  .setRepresentative(
                                                      _repController.text)
                                                  .then((result) {
                                                RxBus.post(
                                                    new StateBlock(
                                                        representative:
                                                            _repController.text,
                                                        previous: "",
                                                        link: "",
                                                        balance: "",
                                                        account: ""),
                                                    tag: RX_REP_CHANGED_TAG);
                                              });
                                            } else {
                                              StateContainer.of(context)
                                                  .requestChange(
                                                      StateContainer.of(context)
                                                          .wallet
                                                          .frontier,
                                                      StateContainer.of(context)
                                                          .wallet
                                                          .accountBalance
                                                          .toString(),
                                                      _repController.text);
                                            }
                                          },
                                          expectedPin: expectedPin,
                                          description:
                                              "Enter PIN to change representative.",
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
                          KaliumButton.buildKaliumButton(
                            KaliumButtonType.PRIMARY_OUTLINE,
                            'CLOSE',
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
            );
          });
        });
  }
}
