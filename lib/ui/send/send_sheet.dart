import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/model/address.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/util/formatters.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';

// TODO - We want to implement a max send, this can't just be balance
// because there may be some off raw in the account. We want 0 as the balance_after_send

class KaliumSendSheet {
  FocusNode _sendAddressFocusNode;
  TextEditingController _sendAddressController;
  FocusNode _sendAmountFocusNode;
  TextEditingController _sendAmountController;

  // State initial constants
  static const String _amountHintText = "Enter Amount";
  static const String _addressHintText = "Enter Address";
  static const String _addressInvalidText = "Address entered was invalid";
  static const String _addressRequiredText = "Please Enter an Address";
  static const String _amountRequiredText = "Please Enter an Amount";
  static const String _amountInsufficientText = "Insufficient Balance";
  // States
  var _sendAddressStyle;
  var _amountHint = _amountHintText;
  var _addressHint = _addressHintText;
  var _amountValidationText = "";
  var _addressValidationText = "";
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;

  KaliumSendSheet() {
    _sendAmountFocusNode = new FocusNode();
    _sendAddressFocusNode = new FocusNode();
    _sendAmountController = new TextEditingController();
    _sendAddressController = new TextEditingController();
    _sendAddressStyle = KaliumStyles.TextStyleAddressText60;
  }

  mainBottomSheet(BuildContext context) {
    // A method for deciding if 1 or 3 line address text should be used
    oneOrThreeLineAddressText() {
      if (MediaQuery.of(context).size.height < 667)
        return UIUtil.oneLineAddressText(
          StateContainer.of(context).wallet.address,
          type: OneLineAddressTextType.PRIMARY60,
        );
      else
        return UIUtil.threeLineAddressText(
          StateContainer.of(context).wallet.address,
          type: ThreeLineAddressTextType.PRIMARY60,
        );
    }

    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // On amount focus change
            _sendAmountFocusNode.addListener(() {
              if (_sendAmountFocusNode.hasFocus) {
                setState(() {
                  _amountHint = "";
                });
              } else {
                setState(() {
                  _amountHint = _amountHintText;
                });
              }
            });
            // On address focus change
            _sendAddressFocusNode.addListener(() {
              if (_sendAddressFocusNode.hasFocus) {
                setState(() {
                  _addressHint = "";
                });
              } else {
                setState(() {
                  _addressHint = _addressHintText;
                });
              }
            });
            // The main column that holds everything
            return Column(
              children: <Widget>[
                // A row for the header of the sheet, balance text and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Close Button
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, left: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(KaliumIcons.close,
                            size: 16, color: KaliumColors.text),
                        padding: EdgeInsets.all(17.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),

                    // Container for the header, address and balance text
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: <Widget>[
                          // Header
                          Text(
                            "SEND FROM",
                            style: KaliumStyles.TextStyleHeader,
                          ),
                          // Address Text
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: oneOrThreeLineAddressText(),
                          ),
                          // Balance Text
                          Container(
                            margin: EdgeInsets.only(top: 6.0),
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: '',
                                children: [
                                  TextSpan(
                                    text: "(",
                                    style: TextStyle(
                                      color: KaliumColors.primary60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: StateContainer.of(context)
                                        .wallet
                                        .getAccountBalanceDisplay(),
                                    style: TextStyle(
                                      color: KaliumColors.primary60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: " BAN)",
                                    style: TextStyle(
                                      color: KaliumColors.primary60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //Empty SizedBox
                    SizedBox(
                      width: 60,
                      height: 60,
                    ),
                  ],
                ),

                // A main container that holds "Enter Amount" and "Enter Address" text fields
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 35),
                    child: Stack(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            // Clear focus of our fields when tapped in this empty space
                            _sendAddressFocusNode.unfocus();
                            _sendAmountFocusNode.unfocus();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: SizedBox.expand(),
                            constraints: BoxConstraints.expand(),
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            // Enter Amount Container
                            Container(
                              margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.105,
                                  right: MediaQuery.of(context).size.width *
                                      0.105),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: KaliumColors.backgroundDarkest,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              // Amount Text Field
                              child: TextField(
                                focusNode: _sendAmountFocusNode,
                                controller: _sendAmountController,
                                cursorColor: KaliumColors.primary,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(13),
                                  WhitelistingTextInputFormatter(
                                      RegExp("[0-9.,]")),
                                  CurrencyInputFormatter()
                                ],
                                onChanged: (text) {
                                  // Always reset the error message to be less annoying
                                  setState(() {
                                    _amountValidationText = "";
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                maxLines: null,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: _amountHint,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans'),
                                  // Currency Switch Button
                                  prefixIcon: Container(
                                    width: 48,
                                    height: 48,
                                    child: FlatButton(
                                      padding: EdgeInsets.all(14.0),
                                      highlightColor: KaliumColors.primary15,
                                      splashColor: KaliumColors.primary30,
                                      onPressed: () {
                                        return null;
                                      },
                                      child: Icon(KaliumIcons.swapcurrency,
                                          size: 20,
                                          color: KaliumColors.primary),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(200.0)),
                                    ),
                                  ),
                                  // MAX Button
                                  suffixIcon: Container(
                                    width: 48,
                                    height: 48,
                                    child: FlatButton(
                                      highlightColor: KaliumColors.primary15,
                                      splashColor: KaliumColors.primary30,
                                      padding: EdgeInsets.all(12.0),
                                      onPressed: () {
                                        return null;
                                      },
                                      child: Icon(KaliumIcons.max,
                                          size: 24,
                                          color: KaliumColors.primary),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(200.0)),
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.numberWithOptions(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.0,
                                  color: KaliumColors.primary,
                                  fontFamily: 'NunitoSans',
                                ),
                                onSubmitted: (text) {
                                  FocusScope.of(context)
                                      .requestFocus(_sendAddressFocusNode);
                                },
                              ),
                            ),
                            // Enter Amount Error Container
                            Container(
                              margin: EdgeInsets.only(top: 5, bottom: 5),
                              child: Text(_amountValidationText,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: KaliumColors.primary,
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                            // Enter Address Container
                            Container(
                              margin: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.105,
                                  right: MediaQuery.of(context).size.width *
                                      0.105),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: KaliumColors.backgroundDarkest,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              // Enter Address Text field
                              child: TextField(
                                textAlign: TextAlign.center,
                                focusNode: _sendAddressFocusNode,
                                controller: _sendAddressController,
                                cursorColor: KaliumColors.primary,
                                keyboardAppearance: Brightness.dark,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(64),
                                ],
                                textInputAction: TextInputAction.done,
                                maxLines: null,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: _addressHint,
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans'),
                                  // @ Button
                                  prefixIcon: Container(
                                    width: 48.0,
                                    height: 48.0,
                                    child: FlatButton(
                                      highlightColor: KaliumColors.primary15,
                                      splashColor: KaliumColors.primary30,
                                      padding: EdgeInsets.all(14.0),
                                      onPressed: () {
                                        return null;
                                      },
                                      child: Icon(KaliumIcons.at,
                                          size: 20,
                                          color: KaliumColors.primary),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(200.0)),
                                    ),
                                  ),
                                  // Paste Button
                                  suffixIcon: _pasteButtonVisible
                                      ? Container(
                                          width: 48.0,
                                          height: 48.0,
                                          child: FlatButton(
                                            highlightColor:
                                                KaliumColors.primary15,
                                            splashColor: KaliumColors.primary30,
                                            padding: EdgeInsets.all(14.0),
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
                                                    _addressValidationText = "";
                                                    _sendAddressStyle = KaliumStyles
                                                        .TextStyleAddressText90;
                                                    _pasteButtonVisible = false;
                                                  });
                                                  _sendAddressController.text =
                                                      address.address;
                                                }
                                              });
                                            },
                                            child: Icon(KaliumIcons.paste,
                                                size: 20,
                                                color: KaliumColors.primary),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        200.0)),
                                          ),
                                        )
                                      : SizedBox(),
                                ),
                                style: _sendAddressStyle,
                                onChanged: (text) {
                                  // Always reset the error message to be less annoying
                                  setState(() {
                                    _addressValidationText = "";
                                  });
                                  if (NanoAccounts.isValid(
                                      NanoAccountType.BANANO, text)) {
                                    _sendAddressFocusNode.unfocus();
                                    setState(() {
                                      _sendAddressStyle =
                                          KaliumStyles.TextStyleAddressText90;
                                      _addressValidationText = "";
                                      _pasteButtonVisible = false;
                                    });
                                  } else {
                                    setState(() {
                                      _sendAddressStyle =
                                          KaliumStyles.TextStyleAddressText60;
                                      _pasteButtonVisible = true;
                                    });
                                  }
                                },
                              ),
                            ),
                            // Enter Address Error Container
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Text(_addressValidationText,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: KaliumColors.primary,
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with "Scan QR Code" and "Send" buttons
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // Send Button
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY,
                              'Send',
                              Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                            if (_validateRequest(context, setState)) {
                              KaliumSendConfirmSheet(_sendAmountController.text,
                                      _sendAddressController.text)
                                  .mainBottomSheet(context);
                            }
                          }),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          // Scan QR Code Button
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY_OUTLINE,
                              'Scan QR Code',
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                            try {
                              BarcodeScanner.scan().then((value) {
                                String account =
                                    NanoAccounts.findAccountInString(
                                        NanoAccountType.BANANO, value);
                                if (account == null || account.isEmpty) {
                                  // Not a valid code
                                } else {
                                  setState(() {
                                    _sendAddressController.text = account;
                                    _addressValidationText = "";
                                    _sendAddressStyle =
                                        KaliumStyles.TextStyleAddressText90;
                                    _pasteButtonVisible = false;
                                  });
                                }
                              });
                            } catch (e) {
                              if (e.code == BarcodeScanner.CameraAccessDenied) {
                                // TODO - Permission Denied to use camera
                              } else {
                                // UNKNOWN ERROR
                              }
                            }
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }

  /// Validate form data to see if valid
  /// @returns true if valid, false otherwise
  bool _validateRequest(BuildContext context, StateSetter setState) {
    bool isValid = true;
    _sendAmountFocusNode.unfocus();
    _sendAddressFocusNode.unfocus();
    // Validate amount
    if (_sendAmountController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _amountValidationText = _amountRequiredText;
      });
    } else {
      BigInt balanceRaw = StateContainer.of(context).wallet.accountBalance;
      BigInt sendAmount = BigInt.tryParse(
          NumberUtil.getAmountAsRaw(_sendAmountController.text));
      if (sendAmount == null || sendAmount == BigInt.zero) {
        isValid = false;
        setState(() {
          _amountValidationText = _amountRequiredText;
        });
      } else if (sendAmount > balanceRaw) {
        isValid = false;
        setState(() {
          _amountValidationText = _amountInsufficientText;
        });
      }
    }
    // Validate address
    if (_sendAddressController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = _addressRequiredText;
        _pasteButtonVisible = true;
      });
    } else if (!NanoAccounts.isValid(
        NanoAccountType.BANANO, _sendAddressController.text)) {
      isValid = false;
      setState(() {
        _addressValidationText = _addressInvalidText;
        _pasteButtonVisible = true;
      });
    } else {
      setState(() {
        _addressValidationText = "";
        _pasteButtonVisible = false;
      });
    }
    return isValid;
  }
}
