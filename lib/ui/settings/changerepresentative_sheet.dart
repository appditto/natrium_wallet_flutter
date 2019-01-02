import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumChangeRepresentativeSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //A container for the header
                Container(
                  margin: EdgeInsets.only(top: 30.0, left: 60, right: 60),
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

                //A container for the paragraph and seed
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 35, bottom: 35),
                    child: Column(
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(left: 50, right: 50),
                            child: Text(
                              "Currently Representative By",
                              style: KaliumStyles.TextStyleParagraph,
                            )),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(left: 50, right:50, top:10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: threeLineAddressText(
                              "ban_1yekta1u3ymis5tji4jxpr4iz8a9bp4bjoz5qdw3wstbub3wgxwi3nfuuyek"),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 50, right: 50, top:20),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            cursorColor: KaliumColors.primary,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(64),
                            ],
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter New Representative",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w100),
                            ),
                            keyboardType: TextInputType.numberWithOptions(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 14.0,
                              color: KaliumColors.text,
                              fontFamily: 'OverpassMono',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //A row with close button
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumButton(
                          KaliumButtonType.PRIMARY,
                          'CHANGE',
                          Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () {
                            doNothing();
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(
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
  }
}
