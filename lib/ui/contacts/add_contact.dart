import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:barcode_scan/barcode_scan.dart';

import 'package:natrium_wallet_flutter/colors.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/bus/rxbus.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/model/db/contact.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/util/formatters.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';

// Add Contacts Sheet
class AddContactSheet {
  String address;

  AddContactSheet({this.address});

  // Form info
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _addressFocusNode = FocusNode();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  // State variables
  bool _addressValid = false;
  bool _showPasteButton = true;
  bool _showNameHint = true;
  bool _showAddressHint = true;
  bool _addressValidAndUnfocused = false;
  String _nameValidationText = "";
  String _addressValidationText = "";

  /// Return true if textfield should be shown, false if colorized should be shown
  bool _shouldShowTextField() {
    if (address != null) {
      return false;
    } else if (_addressValidAndUnfocused) {
      return false;
    }
    return true;
  }

  mainBottomSheet(BuildContext context) {
    AppSheets.showAppHeightNineSheet(
        context: context,
        animationDurationMs: 200,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // On name focus change
            _nameFocusNode.addListener(() {
              if (_nameFocusNode.hasFocus) {
                setState(() {
                  _showNameHint = false;
                });
              } else {
                setState(() {
                  _showNameHint = true;
                });
              }
            });
            // On address focus change
            _addressFocusNode.addListener(() {
              if (_addressFocusNode.hasFocus) {
                setState(() {
                  _showAddressHint = false;
                  _addressValidAndUnfocused = false;
                });
                _addressController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _addressController.text.length));
              } else {
                setState(() {
                  _showAddressHint = true;
                  if (Address(_addressController.text).isValid()) {
                    _addressValidAndUnfocused = true;
                  }
                });
              }
            });
            return Column(
              children: <Widget>[
                // Top row of the sheet which contains the header and the scan qr button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Empty SizedBox
                    SizedBox(
                      width: 60,
                      height: 60,
                    ),
                    // The header of the sheet
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 140),
                      child: Column(
                        children: <Widget>[
                          AutoSizeText(
                            AppLocalization.of(context).addContact.toUpperCase(),
                            style: AppStyles.textStyleHeader(context),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            stepGranularity: 0.1,
                          ),
                        ],
                      ),
                    ),

                    // Scan QR Button
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                      child:  address == null ? FlatButton(
                        onPressed: () {
                            try {
                              UIUtil.cancelLockEvent();
                              BarcodeScanner.scan(OverlayTheme.KALIUM).then((value) {
                                Address address = Address(value);
                                if (!address.isValid()) {
                                  UIUtil.showSnackbar(AppLocalization.of(context).qrInvalidAddress, context);
                                } else {
                                  setState(() {
                                    _addressController.text = address.address;
                                    _addressValidationText = "";
                                    _addressValid = true;
                                    _addressValidAndUnfocused = true;
                                  });
                                  _addressFocusNode.unfocus();
                                }
                              });
                            } catch (e) {
                              if (e.code == BarcodeScanner.CameraAccessDenied) {
                                // TODO - Permission Denied to use camera
                              } else {
                                // UNKNOWN ERROR
                              }
                            }
                        },
                        child: Icon(AppIcons.scan,
                            size: 28, color: AppColors.text),
                        padding: EdgeInsets.all(11.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ) : SizedBox(),
                    ),
                  ],
                ),

                // The main container that holds "Enter Name" and "Enter Address" text fields
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // Clear focus of our fields when tapped in this empty space
                          _nameFocusNode.unfocus();
                          _addressFocusNode.unfocus();
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: SizedBox.expand(),
                          constraints: BoxConstraints.expand(),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.14),
                        child: Column(
                          children: <Widget>[
                            // Enter Name Container
                            Container(
                              margin: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.105,
                                  right: MediaQuery.of(context).size.width * 0.105),
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDarkest,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              // Enter Name text field
                              child: TextField(
                                focusNode: _nameFocusNode,
                                controller: _nameController,
                                cursorColor: AppColors.primary,
                                textInputAction: address != null ? TextInputAction.done : TextInputAction.next,
                                maxLines: null,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: _showNameHint ? AppLocalization.of(context).contactNameHint : "",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans'),
                                ),
                                keyboardType: TextInputType.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: AppColors.text,
                                  fontFamily: 'NunitoSans',
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(20),
                                  ContactInputFormatter()
                                ],
                                onSubmitted: (text) {
                                  if (address == null) {
                                    if (!Address(_addressController.text).isValid()) {
                                      FocusScope.of(context)
                                         .requestFocus(_addressFocusNode);
                                    } else {
                                      _nameFocusNode.unfocus();
                                      _addressFocusNode.unfocus();
                                    }
                                  }
                                },
                              ),
                            ),
                            // Enter Name Error Container
                            Container(
                              margin: EdgeInsets.only(top: 5, bottom: 5),
                              child: Text(_nameValidationText,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: AppColors.primary,
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                            // Enter Address container
                            Container(
                              margin: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.105,
                                  right: MediaQuery.of(context).size.width * 0.105),
                              padding: !_shouldShowTextField() ? EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 15.0) : EdgeInsets.zero,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDarkest,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              // Enter Address text field
                              child: _shouldShowTextField() ? TextField(
                                focusNode: _addressFocusNode,
                                controller: _addressController,
                                style: _addressValid ? AppStyles.TextStyleAddressText90 : AppStyles.TextStyleAddressText60,
                                textAlign: TextAlign.center,
                                cursorColor: AppColors.primary,
                                keyboardAppearance: Brightness.dark,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(65),
                                ],
                                textInputAction: TextInputAction.done,
                                maxLines: null,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: _showAddressHint ? AppLocalization.of(context).addressHint : "",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w100,
                                      fontFamily: 'NunitoSans'),
                                  // Empty SizedBox
                                  prefixIcon: SizedBox(
                                    width: 48,
                                    height: 48,
                                  ),
                                  // Paste Button
                                  suffixIcon: AnimatedCrossFade(
                                    duration: const Duration(milliseconds: 100),
                                    firstChild: Container(
                                        width: 48,
                                        child: FlatButton(
                                          highlightColor: AppColors.primary15,
                                          splashColor: AppColors.primary30,
                                          padding: EdgeInsets.all(14.0),
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
                                              Address address = Address(data.text);
                                              if (address.isValid()) {
                                                setState(() {
                                                  _addressValid = true;
                                                  _showPasteButton = false;
                                                  _addressController.text = address.address;
                                                  _addressValidAndUnfocused = true;
                                                });
                                                _addressFocusNode.unfocus();
                                              } else {
                                                setState(() {
                                                  _showPasteButton = true;
                                                  _addressValid = false;
                                                });
                                              }
                                            });
                                          },
                                          child: Icon(AppIcons.paste,
                                              size: 20, color: AppColors.primary),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(200.0)),
                                        ),
                                      ),
                                    secondChild: SizedBox(),
                                    crossFadeState: _showPasteButton
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                  ),
                                ),
                                onChanged: (text) {
                                  Address address = Address(text);
                                  if (address.isValid()) {
                                    setState(() {
                                      _addressValid = true;
                                      _showPasteButton = false;
                                      _addressController.text = address.address;
                                    });
                                    _addressFocusNode.unfocus();
                                  } else {
                                    setState(() {
                                      _showPasteButton = true;
                                      _addressValid = false;
                                    });
                                  }
                                },
                              ) : GestureDetector(
                                onTap: () {
                                  if (address != null) {
                                    return;
                                  }
                                  setState(() {
                                    _addressValidAndUnfocused = false;
                                  });
                                  Future.delayed(Duration(milliseconds: 50), () {
                                    FocusScope.of(context).requestFocus(_addressFocusNode);
                                  });
                                },
                                child: UIUtil.threeLineAddressText(address != null ? address : _addressController.text)
                              ),
                            ),
                            // Enter Address Error Container
                            Container(
                              margin: EdgeInsets.only(top: 5, bottom: 5),
                              child: Text(_addressValidationText,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: AppColors.primary,
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),                  
                ),

                //A column with "Add Contact" and "Close" buttons
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // Add Contact Button
                          AppButton.buildAppButton(
                              AppButtonType.PRIMARY,
                              AppLocalization.of(context).addContact,
                              Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                            validateForm(context, setState).then((isValid) {
                              if (!isValid) {
                                return;
                              }
                              DBHelper dbHelper = DBHelper();
                              Contact newContact = Contact(name: _nameController.text, address: address == null ? _addressController.text : address);
                              dbHelper.saveContact(newContact).then((id) {
                                if (address == null) {
                                  RxBus.post(newContact, tag: RX_CONTACT_ADDED_TAG);
                                }
                                UIUtil.showSnackbar(AppLocalization.of(context).contactAdded.replaceAll("%1", newContact.name), context);
                                RxBus.post(newContact, tag: RX_CONTACT_MODIFIED_TAG);
                                Navigator.of(context).pop();
                              });
                            });
                          }),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          // Close Button
                          AppButton.buildAppButton(
                              AppButtonType.PRIMARY_OUTLINE,
                              AppLocalization.of(context).close,
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                            Navigator.pop(context);
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

  Future<bool> validateForm(BuildContext context, StateSetter setState) async {
    bool isValid = true;
    // Address Validations
    // Don't validate address if it came pre-filled in
    if (address == null) {
      if (_addressController.text.isEmpty) {
        isValid = false;
        setState(() {
          _addressValidationText = AppLocalization.of(context).addressMising;
        });
      } else if (!Address(_addressController.text).isValid()) {
        isValid = false;
        setState(() {
          _addressValidationText = AppLocalization.of(context).invalidAddress;
        });
      } else {
        _addressFocusNode.unfocus();
        DBHelper dbHelper = DBHelper();
        bool addressExists = await dbHelper.contactExistsWithAddress(_addressController.text);
        if (addressExists) {
          setState(() {
            isValid = false;
            _addressValidationText = AppLocalization.of(context).contactExists;
          });
        }
      }
    }
    // Name Validations
    if (_nameController.text.isEmpty) {
      isValid = false;
      setState(() {
        _nameValidationText = AppLocalization.of(context).contactNameMissing;
      });
    } else {
      DBHelper dbHelper = DBHelper();
      bool nameExists = await dbHelper.contactExistsWithName(_nameController.text);
      if (nameExists) {
        setState(() {
          isValid = false;
          _nameValidationText = AppLocalization.of(context).contactExists;
        });
      }
    }
    return isValid;
  }
}
