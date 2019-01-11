import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';

import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/address.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';

class AddContactSheet {
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
                    //Empty container
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                    ),

                    //The header of the sheet
                    Container(
                      margin: EdgeInsets.only(top: 30.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "ADD CONTACT",
                            style: KaliumStyles.TextStyleHeader,
                          ),
                        ],
                      ),
                    ),

                    //Scan QR Button
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          return null;
                        },
                        child: Icon(KaliumIcons.scan,
                            size: 24, color: KaliumColors.text),
                        padding: EdgeInsets.all(13.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0)),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                  ],
                ),

                //A main container that holds "Enter Amount" and "Enter Address" text fields
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 35),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Enter Name Container
                        Container(
                          margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.105,
                              right: MediaQuery.of(context).size.width * 0.105),
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            cursorColor: KaliumColors.primary,
                            textInputAction: TextInputAction.next,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter a Name @",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NunitoSans'),
                            ),
                            keyboardType: TextInputType.numberWithOptions(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                              color: KaliumColors.text,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ),
                        // Enter Name Error Container
                        Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5),
                          child: Text("Error Text",
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
                              left: MediaQuery.of(context).size.width * 0.105,
                              right: MediaQuery.of(context).size.width * 0.105),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            style: KaliumStyles.TextStyleAddressText90,
                            textAlign: TextAlign.center,
                            cursorColor: KaliumColors.primary,
                            keyboardAppearance: Brightness.dark,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(64),
                            ],
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter an Address",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NunitoSans'),
                              // Empty Container
                              prefixIcon: Container(
                                width: 50,
                                height: 50,
                              ),
                              // PASTE BUTTTON
                              suffixIcon: Container(
                                width: 50,
                                child: FlatButton(
                                  highlightColor: KaliumColors.primary15,
                                  splashColor: KaliumColors.primary30,
                                  padding: EdgeInsets.all(15.0),
                                  onPressed: () {
                                    return null;
                                  },
                                  child: Icon(KaliumIcons.paste,
                                      size: 20, color: KaliumColors.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(200.0)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Enter Address Error Container
                        Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5),
                          child: Text("Error Text",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: KaliumColors.primary,
                                fontFamily: 'NunitoSans',
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),

                //A column with "Add Contact" and "Close" buttons
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY,
                              'Add Contact',
                              Dimens.BUTTON_TOP_DIMENS, onPressed: () {
                            return null;
                          }),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY_OUTLINE,
                              'Close',
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
