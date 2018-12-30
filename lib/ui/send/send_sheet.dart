import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';

class KaliumSendSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
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
                          Icon(KaliumIcons.close, size: 16, color: white90),
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
                          child: threeLineAddressBuilder(
                              'ban_1yekta1xn94qdnbmmj1tqg76zk3apcfd31pjmuy6d879e3mr469a4o4sdhd4'),
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
                                    color: yellow60,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: 'NunitoSans',
                                  ),
                                ),
                                TextSpan(
                                  text: "412,580",
                                  style: TextStyle(
                                    color: yellow60,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'NunitoSans',
                                  ),
                                ),
                                TextSpan(
                                  text: " BAN",
                                  style: TextStyle(
                                    color: yellow60,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: 'NunitoSans',
                                  ),
                                ),
                                TextSpan(
                                  text: ")",
                                  style: TextStyle(
                                    color: yellow60,
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
                          color: greyDarkest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          cursorColor: yellow,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(13),
                          ],
                          textInputAction: TextInputAction.done,
                          maxLines: null,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: "Enter Amount",
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
                            color: yellow,
                            fontFamily: 'NunitoSans',
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        margin: EdgeInsets.only(left: 70, right: 70, top: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: greyDarkest,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TextField(
                          cursorColor: yellow,
                          keyboardAppearance: Brightness.dark,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(64),
                          ],
                          textInputAction: TextInputAction.done,
                          maxLines: null,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: "Enter Address",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontFamily: 'NunitoSans'),
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            fontSize: 16.0,
                            color: white90,
                            fontFamily: 'OverpassMono',
                          ),
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
                        buildKaliumButton(KaliumButtonType.PRIMARY,
                            'Send', Dimens.BUTTON_TOP_DIMENS),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(KaliumButtonType.PRIMARY_OUTLINE, 'Scan QR Code', Dimens.BUTTON_BOTTOM_DIMENS),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}