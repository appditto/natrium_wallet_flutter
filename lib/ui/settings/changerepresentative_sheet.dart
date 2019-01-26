import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:kalium_wallet_flutter/ui/widgets/security.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/biometrics.dart';
import 'package:kalium_wallet_flutter/util/hapticutil.dart';
import 'package:kalium_wallet_flutter/model/address.dart';
import 'package:kalium_wallet_flutter/model/authentication_method.dart';
import 'package:kalium_wallet_flutter/model/state_block.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';

// TODO - add validations

class KaliumChangeRepresentativeSheet {
  FocusNode _repFocusNode;
  TextEditingController _repController;

  String _changeRepHint = "";
  TextStyle _repAddressStyle;
  bool _showPasteButton = true;
  bool _addressValidAndUnfocused = false;

  bool _animationOpen = false;

  KaliumChangeRepresentativeSheet() {
    _repFocusNode = new FocusNode();
    _repController = new TextEditingController();
    _repAddressStyle = KaliumStyles.TextStyleAddressText60;
  }

  Future<bool> _onWillPop() async {
    RxBus.destroy(tag: RX_REP_CHANGED_TAG);
    return true;
  }

  mainBottomSheet(BuildContext context) {
    _changeRepHint = KaliumLocalization.of(context).changeRepHint;

    RxBus.register<StateBlock>(tag: RX_REP_CHANGED_TAG).listen((stateBlock) {
      if (stateBlock != null) {
        StateContainer.of(context).wallet.representative =
            stateBlock.representative;
        UIUtil.showSnackbar(KaliumLocalization.of(context).changeRepSucces, context);
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
      }
    });

    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        onDisposed: _onWillPop,
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
                  _changeRepHint = KaliumLocalization.of(context).changeRepHint;
                  if (Address(_repController.text).isValid()) {
                    _addressValidAndUnfocused = true;
                  }
                });
              }
            });
            return WillPopScope(
              onWillPop: _onWillPop,
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
                          onPressed: () {
                            KaliumDialogs.showInfoDialog(
                                context,
                                KaliumLocalization.of(context).repInfoHeader,
                                KaliumLocalization.of(context).repInfo);
                          },
                          child: Icon(KaliumIcons.info,
                              size: 24, color: KaliumColors.text),
                          padding: EdgeInsets.all(13.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                      ),

                      //Container for the header
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 30),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width - 140),
                          child: AutoSizeText(
                            KaliumLocalization.of(context)
                                .changeRepAuthenticate
                                .toUpperCase(),
                            style: KaliumStyles.textStyleHeader(context),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            stepGranularity: 0.1,
                          ),
                        ),
                      ),

                      // Scan QR Button
                      Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(top: 10.0, right: 10.0),
                        child: FlatButton(
                          onPressed: () {
                            BarcodeScanner.scan().then((result) {
                              if (result == null) { return; }
                              Address address =
                                  new Address(result);
                              if (address.isValid()) {
                                setState(() {
                                  _addressValidAndUnfocused =
                                      true;
                                  _showPasteButton = false;
                                  _repAddressStyle =
                                      KaliumStyles
                                          .TextStyleAddressText90;
                                });
                                _repController.text =
                                    address.address;
                                _repFocusNode.unfocus();
                              } else {
                                UIUtil.showSnackbar(KaliumLocalization.of(context).qrInvalidAddress, context);
                              }
                            });
                          },
                          child: Icon(KaliumIcons.scan,
                              size: 28, color: KaliumColors.text),
                          padding: EdgeInsets.all(11.0),
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
                      margin: EdgeInsets.only(
                          top: smallScreen(context) ? 20 : 35,
                          bottom: smallScreen(context) ? 20 : 35),
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
                                  KaliumLocalization.of(context)
                                      .currentlyRepresented,
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
                              padding: _addressValidAndUnfocused
                                  ? EdgeInsets.symmetric(
                                      horizontal: 25.0, vertical: 15.0)
                                  : EdgeInsets.zero,
                              decoration: BoxDecoration(
                                color: KaliumColors.backgroundDarkest,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: !_addressValidAndUnfocused
                                  ? TextField(
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
                                        hintText: _changeRepHint,
                                        // Empty Container
                                        prefixIcon: Container(
                                          width: 48.0,
                                          height: 48.0,
                                        ),
                                        // Paste Button
                                        suffixIcon: AnimatedCrossFade(
                                          duration: Duration(milliseconds: 100),
                                          firstChild: Container(
                                            width: 48.0,
                                            height: 48.0,
                                            child: FlatButton(
                                              padding: EdgeInsets.all(15.0),
                                              onPressed: () {
                                                if (!_showPasteButton) {
                                                  return;
                                                }
                                                Clipboard.getData("text/plain")
                                                    .then((ClipboardData data) {
                                                  if (data == null ||
                                                      data.text == null) {
                                                    return;
                                                  }
                                                  Address address =
                                                      new Address(data.text);
                                                  if (address.isValid()) {
                                                    setState(() {
                                                      _addressValidAndUnfocused =
                                                          true;
                                                      _showPasteButton = false;
                                                      _repAddressStyle =
                                                          KaliumStyles
                                                              .TextStyleAddressText90;
                                                    });
                                                    _repController.text =
                                                        address.address;
                                                    _repFocusNode.unfocus();
                                                  }
                                                });
                                              },
                                              child: Icon(KaliumIcons.paste,
                                                  size: 20.0,
                                                  color: KaliumColors.primary),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          200.0)),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize.padded,
                                            ),
                                          ),
                                          secondChild: SizedBox(),
                                          crossFadeState: _showPasteButton
                                              ? CrossFadeState.showFirst
                                              : CrossFadeState.showSecond,
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
                                        if (Address(text).isValid()) {
                                          _repFocusNode.unfocus();
                                          setState(() {
                                            _showPasteButton = false;
                                            _repAddressStyle = KaliumStyles
                                                .TextStyleAddressText90;
                                          });
                                        } else {
                                          setState(() {
                                            _showPasteButton = true;
                                            _repAddressStyle = KaliumStyles
                                                .TextStyleAddressText60;
                                          });
                                        }
                                      },
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _addressValidAndUnfocused = false;
                                        });
                                        Future.delayed(
                                            Duration(milliseconds: 50), () {
                                          FocusScope.of(context)
                                              .requestFocus(_repFocusNode);
                                        });
                                      },
                                      child: UIUtil.threeLineAddressText(
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
                          KaliumButton.buildKaliumButton(
                            KaliumButtonType.PRIMARY,
                            KaliumLocalization.of(context)
                                .changeRepButton
                                .toUpperCase(),
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
                                            KaliumLocalization.of(context)
                                                .changeRepAuthenticate)
                                        .then((authenticated) {
                                      if (authenticated) {
                                        HapticUtil.fingerprintSucess();
                                        _animationOpen = true;
                                        Navigator.of(context).push(
                                            AnimationLoadingOverlay(
                                                AnimationType.GENERIC,
                                                onPoppedCallback: () => _animationOpen = false));
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
                                            Navigator.of(context).pop();
                                            Navigator.of(context).push(
                                                AnimationLoadingOverlay(
                                                    AnimationType.GENERIC));
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
                                              KaliumLocalization.of(context)
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
                          KaliumButton.buildKaliumButton(
                            KaliumButtonType.PRIMARY_OUTLINE,
                            KaliumLocalization.of(context).close.toUpperCase(),
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
            ));
          });
        });
  }
}
