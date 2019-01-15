import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:decimal/decimal.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';

import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/model/address.dart';
import 'package:kalium_wallet_flutter/model/db/contact.dart';
import 'package:kalium_wallet_flutter/model/db/kaliumdb.dart';
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
  List<Contact> _contacts;
  // Used to replace address textfield with colorized TextSpan
  bool _addressValidAndUnfocused = false;
  // Set to true when a contact is being entered
  bool _isContact = false;
  // Buttons States (Used because we hide the buttons under certain conditions)
  bool _pasteButtonVisible = true;
  bool _showContactButton = true;

  KaliumSendSheet({Contact contact}) {
    _sendAmountFocusNode = new FocusNode();
    _sendAddressFocusNode = new FocusNode();
    _sendAmountController = new TextEditingController();
    _sendAddressController = new TextEditingController();
    _sendAddressStyle = KaliumStyles.TextStyleAddressText60;
    _contacts = List();
    if (contact != null) {
      // Setup initial state for contact pre-filled
      _sendAddressController.text = contact.name;
      _isContact = true;
      _showContactButton = false;
      _pasteButtonVisible = false;
      _sendAddressStyle = KaliumStyles.TextStyleAddressPrimary;
    }
  }

  // A method for deciding if 1 or 3 line address text should be used
  _oneOrThreeLineAddressText(BuildContext context) {
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

  mainBottomSheet(BuildContext context) {
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
                  _addressValidAndUnfocused = false;
                });
                _sendAddressController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _sendAddressController.text.length));
                if (_sendAddressController.text.startsWith("@")) {
                  DBHelper()
                      .getContactsWithNameLike(_sendAddressController.text)
                      .then((contactList) {
                    setState(() {
                      _contacts = contactList;
                    });
                  });
                }
              } else {
                setState(() {
                  _addressHint = _addressHintText;
                  _contacts = [];
                  if (Address(_sendAddressController.text).isValid()) {
                    _addressValidAndUnfocused = true;
                  }
                });
                if (_sendAddressController.text.trim() == "@") {
                  _sendAddressController.text = "";
                  setState(() {
                    _showContactButton = true;
                  });
                }
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
                            style: KaliumStyles.textStyleHeader(context),
                          ),
                          // Address Text
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            child: _oneOrThreeLineAddressText(context),
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

                // A main container that holds everything
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 5, bottom: 5),
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
                        // A column for Enter Amount, Enter Address, Error containers and the pop up list
                        Column(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                // Column for Balance Text, Enter Amount container + Enter Amount Error container
                                Column(
                                  children: <Widget>[
                                    // Balance Text
                                    Container(
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
                                    // ******* Enter Amount Container ******* //
                                    getEnterAmountContainer(context, setState),
                                    // ******* Enter Amount Container End ******* //

                                    // ******* Enter Amount Error Container ******* //
                                    Container(
                                      alignment: Alignment(0, 0),
                                      margin: EdgeInsets.only(top: 3),
                                      child: Text(_amountValidationText,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: KaliumColors.primary,
                                            fontFamily: 'NunitoSans',
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                    // ******* Enter Amount Error Container End ******* //
                                  ],
                                ),

                                // Column for Enter Address container + Enter Address Error container
                                Column(
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.bottomCenter,
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: <Widget>[
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
                                            alignment: Alignment.bottomCenter,
                                            constraints: BoxConstraints(
                                                maxHeight: 174, minHeight: 0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                color: KaliumColors
                                                    .backgroundDarkest,
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                margin:
                                                    EdgeInsets.only(bottom: 50),
                                                // ********* The pop-up Contacts List ********* //
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  padding: EdgeInsets.only(
                                                      bottom: 0, top: 0),
                                                  itemCount: _contacts.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return _buildContactItem(
                                                        context,
                                                        setState,
                                                        _contacts[index]);
                                                  },
                                                ), // ********* The pop-up Contacts List End ********* //
                                              ),
                                            ),
                                          ),

                                          // ******* Enter Address Container ******* //
                                          getEnterAddressContainer(
                                              context, setState),
                                          // ******* Enter Address Container End ******* //
                                        ],
                                      ),
                                    ),

                                    // ******* Enter Address Error Container ******* //
                                    Container(
                                      alignment: Alignment(0, 0),
                                      margin: EdgeInsets.only(top: 3),
                                      child: Text(_addressValidationText,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: KaliumColors.primary,
                                            fontFamily: 'NunitoSans',
                                            fontWeight: FontWeight.w600,
                                          )),
                                    ),
                                    // ******* Enter Address Error Container End ******* //
                                  ],
                                ),
                              ],
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
                            bool validRequest =
                                _validateRequest(context, setState);
                            if (_sendAddressController.text.startsWith("@") &&
                                validRequest) {
                              // Need to make sure its a valid contact
                              DBHelper()
                                  .getContactWithName(
                                      _sendAddressController.text)
                                  .then((contact) {
                                if (contact == null) {
                                  setState(() {
                                    _addressValidationText = "Invalid Contact";
                                  });
                                } else {
                                  KaliumSendConfirmSheet(
                                          _sendAmountController.text,
                                          contact.address,
                                          contactName: contact.name,
                                          maxSend: _isMaxSend(context))
                                      .mainBottomSheet(context);
                                }
                              });
                            } else if (validRequest) {
                              KaliumSendConfirmSheet(_sendAmountController.text,
                                      _sendAddressController.text,
                                      maxSend: _isMaxSend(context))
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
                                Address address = Address(value);
                                if (!address.isValid()) {
                                  // Not a valid code
                                } else {
                                  setState(() {
                                    _sendAddressController.text =
                                        address.address;
                                    if (address.amount != null) {
                                      _sendAmountController.text =
                                          NumberUtil.getRawAsUsableString(
                                              address.amount);
                                    }
                                    _addressValidationText = "";
                                    _sendAddressStyle =
                                        KaliumStyles.TextStyleAddressText90;
                                    _pasteButtonVisible = false;
                                    _showContactButton = false;
                                    _addressValidAndUnfocused = true;
                                  });
                                  _sendAddressFocusNode.unfocus();
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

  // Determine if this is a max send or not by comparing balances
  bool _isMaxSend(BuildContext context) {
    // Sanitize commas
    if (_sendAmountController.text.isEmpty) { return false; }
    String textField = _sendAmountController.text.replaceAll(r',', "");
    String balance = StateContainer.of(context)
        .wallet
        .getAccountBalanceDisplay()
        .replaceAll(r",", "");
    // Convert to Integer representations
    int textFieldInt =
        (Decimal.parse(textField) * Decimal.fromInt(100)).toInt();
    int balanceInt = (Decimal.parse(balance) * Decimal.fromInt(100)).toInt();
    return textFieldInt == balanceInt;
  }

  // Build contact items for the list
  Widget _buildContactItem(
      BuildContext context, StateSetter setState, Contact contact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 42,
          margin: EdgeInsets.symmetric(horizontal: 25),
          width: double.infinity - 5,
          child: FlatButton(
            onPressed: () {
              _sendAddressController.text = contact.name;
              _sendAddressFocusNode.unfocus();
              setState(() {
                _isContact = true;
                _showContactButton = false;
                _pasteButtonVisible = false;
                _sendAddressStyle = KaliumStyles.TextStyleAddressPrimary;
              });
            },
            highlightColor: KaliumColors.text03,
            splashColor: KaliumColors.text03,
            child: Text(contact.name,
                textAlign: TextAlign.center,
                style: KaliumStyles.TextStyleAddressPrimary),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25),
          height: 1,
          color: KaliumColors.text03,
        ),
      ],
    );
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
    bool isContact = _sendAddressController.text.startsWith("@");
    if (_sendAddressController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = _addressRequiredText;
        _pasteButtonVisible = true;
      });
    } else if (!isContact && !Address(_sendAddressController.text).isValid()) {
      isValid = false;
      setState(() {
        _addressValidationText = _addressInvalidText;
        _pasteButtonVisible = true;
      });
    } else if (!isContact) {
      setState(() {
        _addressValidationText = "";
        _pasteButtonVisible = false;
      });
      _sendAddressFocusNode.unfocus();
    }
    return isValid;
  }

  //************ Enter Amount Container Method ************//
  //*******************************************************//
  getEnterAmountContainer(BuildContext context, StateSetter setState) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.105,
        right: MediaQuery.of(context).size.width * 0.105,
        top: 30,
      ),
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
          WhitelistingTextInputFormatter(RegExp("[0-9.,]")),
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
          // Currency Switch Button - TODO
          prefixIcon: false
              ? Container(
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
                        size: 20, color: KaliumColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(200.0)),
                  ),
                )
              : SizedBox(),
          // MAX Button
          suffixIcon: AnimatedCrossFade(
            duration: Duration(milliseconds: 100),
            firstChild: Container(
              width: 48,
              height: 48,
              child: FlatButton(
                highlightColor: KaliumColors.primary15,
                splashColor: KaliumColors.primary30,
                padding: EdgeInsets.all(12.0),
                onPressed: () {
                  if (_isMaxSend(context)) {
                    return;
                  }
                  setState(() {
                    _sendAmountController.text = StateContainer.of(context)
                        .wallet
                        .getAccountBalanceDisplay()
                        .replaceAll(r",", "");
                  });
                },
                child:
                    Icon(KaliumIcons.max, size: 24, color: KaliumColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200.0)),
              ),
            ),
            secondChild: SizedBox(),
            crossFadeState: _isMaxSend(context) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
          if (!Address(_sendAddressController.text).isValid()) {
            FocusScope.of(context).requestFocus(_sendAddressFocusNode);
          }
        },
      ),
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//

  //************ Enter Address Container Method ************//
  //*******************************************************//
  getEnterAddressContainer(BuildContext context, StateSetter setState) {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.105,
        right: MediaQuery.of(context).size.width * 0.105,
        top: 124,
      ),
      padding: _addressValidAndUnfocused
          ? EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0)
          : EdgeInsets.zero,
      width: double.infinity,
      decoration: BoxDecoration(
        color: KaliumColors.backgroundDarkest,
        borderRadius: BorderRadius.circular(25),
      ),
      // Enter Address Text field
      child: !_addressValidAndUnfocused
          ? TextField(
              textAlign:
                  _isContact && false ? TextAlign.left : TextAlign.center,
              focusNode: _sendAddressFocusNode,
              controller: _sendAddressController,
              cursorColor: KaliumColors.primary,
              keyboardAppearance: Brightness.dark,
              inputFormatters: [
                _isContact
                    ? LengthLimitingTextInputFormatter(20)
                    : LengthLimitingTextInputFormatter(64),
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
                prefixIcon: AnimatedCrossFade(
                  duration: Duration(milliseconds: 100),
                  firstChild: Container(
                    width: 48.0,
                    height: 48.0,
                    child: FlatButton(
                      highlightColor: KaliumColors.primary15,
                      splashColor: KaliumColors.primary30,
                      padding: EdgeInsets.all(14.0),
                      onPressed: () {
                        if (_showContactButton && _contacts.length == 0) {
                          // Show menu
                          FocusScope.of(context)
                              .requestFocus(_sendAddressFocusNode);
                          if (_sendAddressController.text.length == 0) {
                            _sendAddressController.text = "@";
                            _sendAddressController.selection = TextSelection.fromPosition(
                                      TextPosition(offset: _sendAddressController.text.length));
                          }
                          DBHelper().getContacts().then((contactList) {
                            setState(() {
                              _contacts = contactList;
                            });
                          });
                        }
                      },
                      child: Icon(KaliumIcons.at,
                          size: 20, color: KaliumColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200.0)),
                    ),
                  ),
                  secondChild: SizedBox(),
                  crossFadeState: _showContactButton && _contacts.length == 0
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
                // Paste Button
                suffixIcon: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 100),
                  firstChild: Container(
                    width: 48.0,
                    height: 48.0,
                    child: FlatButton(
                      highlightColor: KaliumColors.primary15,
                      splashColor: KaliumColors.primary30,
                      padding: EdgeInsets.all(14.0),
                      onPressed: () {
                        if (!_pasteButtonVisible) {
                          return;
                        }
                        Clipboard.getData("text/plain")
                            .then((ClipboardData data) {
                          if (data == null || data.text == null) {
                            return;
                          }
                          Address address = new Address(data.text);
                          if (address.isValid()) {
                            DBHelper()
                                .getContactWithAddress(address.address)
                                .then((contact) {
                              if (contact == null) {
                                setState(() {
                                  _isContact = false;
                                  _addressValidationText = "";
                                  _sendAddressStyle =
                                      KaliumStyles.TextStyleAddressText90;
                                  _pasteButtonVisible = false;
                                  _showContactButton = false;
                                });
                                _sendAddressController.text = address.address;
                                _sendAddressFocusNode.unfocus();
                                setState(() {
                                  _addressValidAndUnfocused = true;
                                });
                              } else {
                                // Is a contact
                                setState(() {
                                  _isContact = true;
                                  _addressValidationText = "";
                                  _sendAddressStyle =
                                      KaliumStyles.TextStyleAddressPrimary;
                                  _pasteButtonVisible = false;
                                  _showContactButton = false;
                                });
                                _sendAddressController.text = contact.name;
                              }
                            });
                          }
                        });
                      },
                      child: Icon(KaliumIcons.paste,
                          size: 20, color: KaliumColors.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(200.0)),
                    ),
                  ),
                  secondChild: SizedBox(),
                  crossFadeState: _pasteButtonVisible
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
              ),
              style: _sendAddressStyle,
              onChanged: (text) {
                if (text.length > 0) {
                  setState(() {
                    _showContactButton = false;
                  });
                } else {
                  setState(() {
                    _showContactButton = true;
                  });
                }
                bool isContact = text.startsWith("@");
                // Switch to contact mode if starts with @
                if (isContact) {
                  setState(() {
                    _isContact = true;
                  });
                  DBHelper().getContactsWithNameLike(text).then((matchedList) {
                    setState(() {
                      _contacts = matchedList;
                    });
                  });
                } else {
                  setState(() {
                    _isContact = false;
                    _contacts = [];
                  });
                }
                // Always reset the error message to be less annoying
                setState(() {
                  _addressValidationText = "";
                });
                if (!isContact && Address(text).isValid()) {
                  _sendAddressFocusNode.unfocus();
                  setState(() {
                    _sendAddressStyle = KaliumStyles.TextStyleAddressText90;
                    _addressValidationText = "";
                    _pasteButtonVisible = false;
                  });
                } else if (!isContact) {
                  setState(() {
                    _sendAddressStyle = KaliumStyles.TextStyleAddressText60;
                    _pasteButtonVisible = true;
                  });
                } else {
                  DBHelper().getContactWithName(text).then((contact) {
                    if (contact == null) {
                      setState(() {
                        _sendAddressStyle = KaliumStyles.TextStyleAddressText60;
                      });
                    } else {
                      setState(() {
                        _pasteButtonVisible = false;
                        _sendAddressStyle =
                            KaliumStyles.TextStyleAddressPrimary;
                      });
                    }
                  });
                }
              },
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  _addressValidAndUnfocused = false;
                });
                Future.delayed(Duration(milliseconds: 50), () {
                  FocusScope.of(context).requestFocus(_sendAddressFocusNode);
                });
              },
              child: UIUtil.threeLineAddressText(_sendAddressController.text),
            ),
    );
  } //************ Enter Address Container Method End ************//
  //*************************************************************//
}
