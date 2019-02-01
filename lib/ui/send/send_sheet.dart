import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:decimal/decimal.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:intl/intl.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/colors.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/model/db/contact.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/util/formatters.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';

class AppSendSheet {
  FocusNode _sendAddressFocusNode;
  TextEditingController _sendAddressController;
  FocusNode _sendAmountFocusNode;
  TextEditingController _sendAmountController;

  // States
  var _sendAddressStyle;
  var _amountHint;
  var _addressHint;
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
  // Local currency mode/fiat conversion
  bool _localCurrencyMode = false;
  String _lastLocalCurrencyAmount = "";
  String _lastCryptoAmount = "";
  NumberFormat _localCurrencyFormat;

  AppSendSheet({Contact contact, String address}) {
    _sendAmountFocusNode = new FocusNode();
    _sendAddressFocusNode = new FocusNode();
    _sendAmountController = new TextEditingController();
    _sendAddressController = new TextEditingController();
    _sendAddressStyle = AppStyles.TextStyleAddressText60;
    _contacts = List();
    if (contact != null) {
      // Setup initial state for contact pre-filled
      _sendAddressController.text = contact.name;
      _isContact = true;
      _showContactButton = false;
      _pasteButtonVisible = false;
      _sendAddressStyle = AppStyles.TextStyleAddressPrimary;
    } else if (address != null) {
      // Setup initial state with prefilled address
      _sendAddressController.text = address;
      _showContactButton = false;
      _pasteButtonVisible = false;
      _sendAddressStyle = AppStyles.TextStyleAddressText90;
      _addressValidAndUnfocused = true;
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
    _amountHint = AppLocalization.of(context).enterAmount;
    _addressHint = AppLocalization.of(context).enterAddress;
    String locale = StateContainer.of(context).currencyLocale;
    switch (locale) {
      case "es_VE":
        _localCurrencyFormat = NumberFormat.currency(locale:locale, symbol: "Bs.S");
        break;
      case "tr_TR":
        _localCurrencyFormat = NumberFormat.currency(locale:locale, symbol: "₺");
        break;
      default:
        _localCurrencyFormat = NumberFormat.simpleCurrency(locale:locale);
        break;
    }
    AppSheets.showAppHeightNineSheet(
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
                  _amountHint = AppLocalization.of(context).enterAmount;
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
                  _addressHint = AppLocalization.of(context).enterAddress;
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
                        child: Icon(AppIcons.close,
                            size: 16, color: AppColors.text),
                        padding: EdgeInsets.all(17.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),

                    // Container for the header, address and balance text
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          // Header
                          AutoSizeText(
                            AppLocalization.of(context)
                                .sendFrom
                                .toUpperCase(),
                            style: AppStyles.textStyleHeader(context),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            stepGranularity: 0.1,
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
                                                color: AppColors.primary60,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w100,
                                                fontFamily: 'NunitoSans',
                                              ),
                                            ),
                                            TextSpan(
                                              text: _localCurrencyMode ?
                                                StateContainer.of(context)
                                                    .wallet
                                                    .getLocalCurrencyPrice(
                                                              locale: StateContainer.of(context).currencyLocale)
                                                : StateContainer.of(context)
                                                    .wallet
                                                    .getAccountBalanceDisplay(),
                                              style: TextStyle(
                                                color: AppColors.primary60,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'NunitoSans',
                                              ),
                                            ),
                                            TextSpan(
                                              text: _localCurrencyMode ? ")" : " BAN)",
                                              style: TextStyle(
                                                color: AppColors.primary60,
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
                                            color: AppColors.primary,
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
                                            // ********************************************* //
                                            // ********* The pop-up Contacts List ********* //
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                  color: AppColors
                                                      .backgroundDarkest,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25),
                                                  ),
                                                  margin: EdgeInsets.only(
                                                      bottom: 50),
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
                                                  // ************************************************** //
                                                ),
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
                                            color: AppColors.primary,
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
                          AppButton.buildAppButton(
                              AppButtonType.PRIMARY,
                              AppLocalization.of(context).send,
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
                                    _addressValidationText =
                                        AppLocalization.of(context)
                                            .contactInvalid;
                                  });
                                } else {
                                  AppSendConfirmSheet(
                                          _sendAmountController.text,
                                          contact.address,
                                          contactName: contact.name,
                                          maxSend: _isMaxSend(context))
                                      .mainBottomSheet(context);
                                }
                              });
                            } else if (validRequest) {
                              AppSendConfirmSheet(_sendAmountController.text,
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
                          AppButton.buildAppButton(
                              AppButtonType.PRIMARY_OUTLINE,
                              AppLocalization.of(context).scanQrCode,
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                            try {
                              UIUtil.cancelLockEvent();
                              BarcodeScanner.scan(OverlayTheme.KALIUM).then((value) {
                                Address address = Address(value);
                                if (!address.isValid()) {
                                  UIUtil.showSnackbar(
                                      AppLocalization.of(context)
                                          .qrInvalidAddress,
                                      context);
                                } else {
                                  DBHelper()
                                      .getContactWithAddress(address.address)
                                      .then((contact) {
                                    if (contact == null) {
                                      setState(() {
                                        _isContact = false;
                                        _addressValidationText = "";
                                        _sendAddressStyle =
                                            AppStyles.TextStyleAddressText90;
                                        _pasteButtonVisible = false;
                                        _showContactButton = false;
                                      });
                                      _sendAddressController.text =
                                          address.address;
                                      _sendAddressFocusNode.unfocus();
                                      setState(() {
                                        _addressValidAndUnfocused = true;
                                      });
                                    } else {
                                      // Is a contact
                                      setState(() {
                                        _isContact = true;
                                        _addressValidationText = "";
                                        _sendAddressStyle = AppStyles
                                            .TextStyleAddressPrimary;
                                        _pasteButtonVisible = false;
                                        _showContactButton = false;
                                      });
                                      _sendAddressController.text =
                                          contact.name;
                                    }
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

  String _convertLocalCurrencyToCrypto(BuildContext context) {
    String convertedAmt = NumberUtil.sanitizeNumber(_sendAmountController.text);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueLocal = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(StateContainer.of(context).wallet.localCurrencyConversion);
    return NumberUtil.truncateDecimal(valueLocal / conversion).toString();
  }

  String _convertCryptoToLocalCurrency(BuildContext context) {
    String convertedAmt = NumberUtil.sanitizeNumber(_sendAmountController.text);
    if (convertedAmt.isEmpty) {
      return "";
    }
    Decimal valueCrypto = Decimal.parse(convertedAmt);
    Decimal conversion = Decimal.parse(StateContainer.of(context).wallet.localCurrencyConversion);
    convertedAmt = NumberUtil.truncateDecimal(valueCrypto * conversion).toString();    
    convertedAmt = convertedAmt.replaceAll(".", _localCurrencyFormat.symbols.DECIMAL_SEP);
    convertedAmt = _localCurrencyFormat.currencySymbol + convertedAmt;
    return convertedAmt;
  }

  // Determine if this is a max send or not by comparing balances
  bool _isMaxSend(BuildContext context) {
    // Sanitize commas
    if (_sendAmountController.text.isEmpty) {
      return false;
    }
    try {
      String textField = _sendAmountController.text.replaceAll(r',', "");
      String balance;
      if (_localCurrencyMode) {
        balance = StateContainer.of(context)
          .wallet
          .getLocalCurrencyPrice(locale: StateContainer.of(context).currencyLocale);
      } else {
        balance = StateContainer.of(context)
          .wallet
          .getAccountBalanceDisplay()
          .replaceAll(r",", "");
      }
      // Convert to Integer representations
      int textFieldInt;
      int balanceInt;
      if (_localCurrencyMode) {
        // Sanitize currency values into plain integer representations
        textField = textField.replaceAll(",", ".");
        String sanitizedTextField = NumberUtil.sanitizeNumber(textField);
        String sanitizedBalance = NumberUtil.sanitizeNumber(balance);
        textFieldInt =
            (Decimal.parse(sanitizedTextField) * Decimal.fromInt(100)).toInt();
        balanceInt = (Decimal.parse(sanitizedBalance) * Decimal.fromInt(100)).toInt();
      } else {
        textFieldInt =
            (Decimal.parse(textField) * Decimal.fromInt(100)).toInt();
        balanceInt = (Decimal.parse(balance) * Decimal.fromInt(100)).toInt();
      }
      return textFieldInt == balanceInt;
    } catch (e) {
      return false;
    }
  }

  void toggleLocalCurrency(BuildContext context, StateSetter setState) {
    // Keep a cache of previous amounts because, it's kinda nice to see approx what nano is worth
    // this way you can tap button and tap back and not end up with X.9993451 NANO
    if (_localCurrencyMode) {
      // Switching to crypto-mode
      if (NumberUtil.sanitizeNumber(_sendAmountController.text) == _lastLocalCurrencyAmount) {
        _sendAmountController.text = _lastCryptoAmount;
      } else {
        _lastLocalCurrencyAmount = NumberUtil.sanitizeNumber(_sendAmountController.text);
        _sendAmountController.text = _convertLocalCurrencyToCrypto(context);
      }
      _sendAmountController.selection =
          TextSelection.fromPosition(TextPosition(
              offset:
                  _sendAmountController.text.length));
      setState(() {
        _localCurrencyMode = false;
      });
    } else {
      // Switching to local-currency mode
      _lastCryptoAmount = _sendAmountController.text;
      _lastLocalCurrencyAmount = NumberUtil.sanitizeNumber(_convertCryptoToLocalCurrency(context));
      setState(() {
        _localCurrencyMode = true;
      });
      _sendAmountController.text = _convertCryptoToLocalCurrency(context);
      _sendAmountController.selection =
          TextSelection.fromPosition(TextPosition(
              offset:
                  _sendAmountController.text.length));
    }
  }

  // Build contact items for the list
  Widget _buildContactItem(
      BuildContext context, StateSetter setState, Contact contact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 42,
          width: double.infinity - 5,
          child: FlatButton(
            onPressed: () {
              _sendAddressController.text = contact.name;
              _sendAddressFocusNode.unfocus();
              setState(() {
                _isContact = true;
                _showContactButton = false;
                _pasteButtonVisible = false;
                _sendAddressStyle = AppStyles.TextStyleAddressPrimary;
              });
            },
            child: Text(contact.name,
                textAlign: TextAlign.center,
                style: AppStyles.TextStyleAddressPrimary),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25),
          height: 1,
          color: AppColors.text03,
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
        _amountValidationText = AppLocalization.of(context).amountMissing;
      });
    } else {
      BigInt balanceRaw = StateContainer.of(context).wallet.accountBalance;
      BigInt sendAmount = BigInt.tryParse(
          NumberUtil.getAmountAsRaw(_sendAmountController.text));
      if (sendAmount == null || sendAmount == BigInt.zero) {
        isValid = false;
        setState(() {
          _amountValidationText = AppLocalization.of(context).amountMissing;
        });
      } else if (sendAmount > balanceRaw) {
        isValid = false;
        setState(() {
          _amountValidationText =
              AppLocalization.of(context).insufficientBalance;
        });
      }
    }
    // Validate address
    bool isContact = _sendAddressController.text.startsWith("@");
    if (_sendAddressController.text.trim().isEmpty) {
      isValid = false;
      setState(() {
        _addressValidationText = AppLocalization.of(context).addressMising;
        _pasteButtonVisible = true;
      });
    } else if (!isContact && !Address(_sendAddressController.text).isValid()) {
      isValid = false;
      setState(() {
        _addressValidationText = AppLocalization.of(context).invalidAddress;
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
        color: AppColors.backgroundDarkest,
        borderRadius: BorderRadius.circular(25),
      ),
      // Amount Text Field
      child: TextField(
        focusNode: _sendAmountFocusNode,
        controller: _sendAmountController,
        cursorColor: AppColors.primary,
        inputFormatters: [
          LengthLimitingTextInputFormatter(13),
          _localCurrencyMode ?
            CurrencyFormatter(decimalSeparator: _localCurrencyFormat.symbols.DECIMAL_SEP, commaSeparator: _localCurrencyFormat.symbols.GROUP_SEP)
          : CurrencyFormatter(),
          LocalCurrencyFormatter(active: _localCurrencyMode, currencyFormat: _localCurrencyFormat)
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
          prefixIcon: Container(
              width: 48,
              height: 48,
              child: FlatButton(
                padding: EdgeInsets.all(14.0),
                highlightColor: AppColors.primary15,
                splashColor: AppColors.primary30,
                onPressed: () {
                  toggleLocalCurrency(context, setState);
                },
                child: Icon(AppIcons.swapcurrency,
                    size: 20, color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200.0)),
              ),
            ),          // MAX Button
          suffixIcon: AnimatedCrossFade(
            duration: Duration(milliseconds: 100),
            firstChild: Container(
              width: 48,
              height: 48,
              child: FlatButton(
                highlightColor: AppColors.primary15, 
                splashColor: AppColors.primary30,
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
                child: Icon(AppIcons.max,
                    size: 24, color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(200.0)),
              ),
            ),
            secondChild: SizedBox(),
            crossFadeState: _isMaxSend(context)
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ),
        keyboardType: TextInputType.numberWithOptions(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16.0,
          color: AppColors.primary,
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
        color: AppColors.backgroundDarkest,
        borderRadius: BorderRadius.circular(25),
      ),
      // Enter Address Text field
      child: !_addressValidAndUnfocused
          ? TextField(
              textAlign:
                  _isContact && false ? TextAlign.left : TextAlign.center,
              focusNode: _sendAddressFocusNode,
              controller: _sendAddressController,
              cursorColor: AppColors.primary,
              keyboardAppearance: Brightness.dark,
              inputFormatters: [
                _isContact
                    ? LengthLimitingTextInputFormatter(20)
                    : LengthLimitingTextInputFormatter(65),
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
                      highlightColor: AppColors.primary15,
                      splashColor: AppColors.primary30,
                      padding: EdgeInsets.all(14.0),
                      onPressed: () {
                        if (_showContactButton && _contacts.length == 0) {
                          // Show menu
                          FocusScope.of(context)
                              .requestFocus(_sendAddressFocusNode);
                          if (_sendAddressController.text.length == 0) {
                            _sendAddressController.text = "@";
                            _sendAddressController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset:
                                        _sendAddressController.text.length));
                          }
                          DBHelper().getContacts().then((contactList) {
                            setState(() {
                              _contacts = contactList;
                            });
                          });
                        }
                      },
                      child: Icon(AppIcons.at,
                          size: 20, color: AppColors.primary),
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
                      highlightColor: AppColors.primary15,
                      splashColor: AppColors.primary30,
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
                                      AppStyles.TextStyleAddressText90;
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
                                      AppStyles.TextStyleAddressPrimary;
                                  _pasteButtonVisible = false;
                                  _showContactButton = false;
                                });
                                _sendAddressController.text = contact.name;
                              }
                            });
                          }
                        });
                      },
                      child: Icon(AppIcons.paste,
                          size: 20, color: AppColors.primary),
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
                    _sendAddressStyle = AppStyles.TextStyleAddressText90;
                    _addressValidationText = "";
                    _pasteButtonVisible = false;
                  });
                } else if (!isContact) {
                  setState(() {
                    _sendAddressStyle = AppStyles.TextStyleAddressText60;
                    _pasteButtonVisible = true;
                  });
                } else {
                  DBHelper().getContactWithName(text).then((contact) {
                    if (contact == null) {
                      setState(() {
                        _sendAddressStyle = AppStyles.TextStyleAddressText60;
                      });
                    } else {
                      setState(() {
                        _pasteButtonVisible = false;
                        _sendAddressStyle =
                            AppStyles.TextStyleAddressPrimary;
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
