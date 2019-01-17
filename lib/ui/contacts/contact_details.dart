import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';

import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';
import 'package:kalium_wallet_flutter/model/db/contact.dart';
import 'package:kalium_wallet_flutter/model/db/kaliumdb.dart';
import 'package:kalium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';

// Contact Details Sheet
class ContactDetailsSheet {
  Contact contact;
  String documentsDirectory;

  ContactDetailsSheet(this.contact, this.documentsDirectory);

  // State variables
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  mainBottomSheet(BuildContext context) {
    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        animationDurationMs: 200,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Trashcan Button
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, left: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          KaliumDialogs.showConfirmDialog(context,
                                                          KaliumLocalization.of(context).removeContact,
                                                          KaliumLocalization.of(context).getRemoveContactConfirmation(contact.name),
                                                          KaliumLocalization.of(context).yes.toUpperCase(),
                          () {
                            DBHelper dbHelper = DBHelper();
                            dbHelper.deleteContact(contact).then((deleted) {
                              if (deleted) {
                                RxBus.post(contact, tag: RX_CONTACT_REMOVED_TAG);
                                RxBus.post(contact, tag: RX_CONTACT_MODIFIED_TAG);
                                Navigator.of(context).pop();
                              } else {
                                // TODO - error for failing to delete contact
                              }
                            });
                          },
                          cancelText: KaliumLocalization.of(context).no.toUpperCase());
                        },
                        child: Icon(KaliumIcons.trashcan,
                            size: 24, color: KaliumColors.text),
                        padding: EdgeInsets.all(13.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                    // The header of the sheet
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            KaliumLocalization.of(context).contactHeader.toUpperCase(),
                            style: KaliumStyles.textStyleHeader(context),
                          ),
                        ],
                      ),
                    ),
                    // Search Button
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) {
                            return UIUtil.showAccountWebview(context, contact.address);
                          }));
                        },
                        child: Icon(KaliumIcons.search,
                            size: 24, color: KaliumColors.text),
                        padding: EdgeInsets.all(13.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                  ],
                ),

                // The main container that holds monKey, Contact Name and Contact Address
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // monKey container
                      Container(
                        height: 200,
                        width: 200,
                        child: contact.monkeyPath != null ? Image.file(File("$documentsDirectory/${contact.monkeyPath}")): SizedBox(),
                      ),
                      // Contact Name container
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.105,
                          right: MediaQuery.of(context).size.width * 0.105,
                          top: 15,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          color: KaliumColors.backgroundDarkest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          contact.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                            color: KaliumColors.primary,
                            fontFamily: 'NunitoSans',
                          ),
                        ),
                      ),
                      // Contact Address
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              new ClipboardData(text: contact.address));
                          setState(() {
                            _addressCopied = true;
                          });
                          if (_addressCopiedTimer != null) {
                            _addressCopiedTimer.cancel();
                          }
                          _addressCopiedTimer = new Timer(
                              const Duration(milliseconds: 800), () {
                            setState(() {
                              _addressCopied = false;
                            });
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.105,
                              right: MediaQuery.of(context).size.width * 0.105,
                              top: 15),
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: UIUtil.threeLineAddressText(
                            contact.address,
                            type: _addressCopied ? ThreeLineAddressTextType.SUCCESS_FULL : ThreeLineAddressTextType.PRIMARY
                          ),
                        ),
                      ),
                      // Address Copied text container
                      Container(
                        margin: EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(_addressCopied ? KaliumLocalization.of(context).addressCopied : "",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: KaliumColors.success,
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),

                // A column with "Send" and "Close" buttons
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // Send Button
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY,
                              KaliumLocalization.of(context).send,
                              Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                            Navigator.of(context).pop();
                            KaliumSendSheet(contact: contact).mainBottomSheet(context);
                          }),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          // Close Button
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY_OUTLINE,
                              KaliumLocalization.of(context).close,
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
}
