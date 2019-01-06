import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';


class KaliumSendSheet {
  FocusNode _sendAddressFocusNode;
  TextEditingController _sendAddressController;
  FocusNode _sendAmountFocusNode;
  TextEditingController _sendAmountController;

  // State initial constants
  static const String _amountHintText = "Enter Amount";
  static const String _addressHintText = "Enter Address";
  // States
  var _sendAddressStyle;
  var _amountHint = _amountHintText;
  var _addressHint = _addressHintText;

  KaliumSendSheet() {
    _sendAmountFocusNode = new FocusNode();
    _sendAddressFocusNode = new FocusNode();
    _sendAmountController = new TextEditingController();
    _sendAddressController = new TextEditingController();
    _sendAddressStyle = KaliumStyles.TextStyleAddressText60;
  }

  mainBottomSheet(BuildContext context) {
    showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setState)
          {
            // On amount focus change
            _sendAmountFocusNode.addListener(() {
              if (_sendAmountFocusNode.hasFocus) {
                setState(() {
                  _amountHint = "";
                });
              } else {
                setState(()  {
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
                setState(()  {
                  _addressHint = _addressHintText;
                });
              }
            });
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, left: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child:
                        Icon(KaliumIcons.close, size: 16,
                            color: KaliumColors.text),
                        padding: EdgeInsets.all(17.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),

                    //Container for the header and address text
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "SEND FROM",
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: threeLineAddressText(
                                StateContainer
                                    .of(context)
                                    .wallet
                                    .address),
                          ),
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
                                    text: StateContainer
                                        .of(context)
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
                                    text: " BAN",
                                    style: TextStyle(
                                      color: KaliumColors.primary60,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  TextSpan(
                                    text: ")",
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

                    //This container is a temporary solution for the alignment problem
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                    ),
                  ],
                ),

                //A main container that holds "Enter Amount" and "Enter Address" text fields
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 35),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 70, right: 70),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            focusNode: _sendAmountFocusNode,
                            controller: _sendAmountController,
                            cursorColor: KaliumColors.primary,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                            ],
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: _amountHint,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontWeight: FontWeight.w100),
                            ),
                            keyboardType: TextInputType.numberWithOptions(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16.0,
                              color: KaliumColors.primary,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          margin: EdgeInsets.only(left: 70, right: 70, top: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
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
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NunitoSans'),
                              suffixIcon: Container(
                                width: 20,
                                height: 20,
                                child: FlatButton(
                                  onPressed: () {
                                    Clipboard.getData("text/plain").then((ClipboardData data) {
                                      if (data == null || data.text == null) {
                                        return;
                                      }
                                      Address address = new Address(data.text);
                                      if (NanoAccounts.isValid(NanoAccountType.BANANO, address.address)) {
                                        setState(() {
                                          _sendAddressStyle = KaliumStyles.TextStyleAddressPrimary60;
                                        });
                                        _sendAddressController.text = address.address;
                                      }
                                    });
                                  },
                                  child: Icon(KaliumIcons.paste,
                                      size: 20, color: KaliumColors.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(100.0)),
                                  materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                                ),
                              ),
                            ),
                            textAlign: TextAlign.center,
                            style: _sendAddressStyle,
                            onChanged: (text) {
                              // Always reset the error message to be less annoying
                              /*
                              setState(() {
                                _errorTextColor = _initialErrorTextColor;
                              });
                              */
                              // If valid address, clear focus/close keyboard
                              if (NanoAccounts.isValid(NanoAccountType.BANANO, text)) {
                                _sendAddressFocusNode.unfocus();
                                setState(() {
                                  _sendAddressStyle = KaliumStyles.TextStyleAddressPrimary60;
                                });
                              } else {
                                setState(() {
                                  _sendAddressStyle = KaliumStyles.TextStyleAddressText60;
                                });
                              }
                            },
                          ),
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
                          buildKaliumButton(KaliumButtonType.PRIMARY, 'Send',
                              Dimens.BUTTON_TOP_DIMENS,
                              onPressed: () {
                                String destination = 'ban_1ka1ium4pfue3uxtntqsrib8mumxgazsjf58gidh1xeo5te3whsq8z476goo';
                                String amount = "1000";
                                KaliumSendConfirmSheet(amount, destination).mainBottomSheet(context);
                              }),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          buildKaliumButton(KaliumButtonType.PRIMARY_OUTLINE,
                              'Scan QR Code', Dimens.BUTTON_BOTTOM_DIMENS,
                              onPressed: () {
                                // TODO - Handle QR code pressed
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
}