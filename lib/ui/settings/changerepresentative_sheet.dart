import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';

class KaliumChangeRepresentativeSheet {
  mainBottomSheet(BuildContext context) {
    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //A container for the header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    //This container is a temporary solution for the alignment problem
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                    ),

                    //Container for the header
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 30),
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
                    ),

                    //A container for the info button
                    Container(
                      width: 50,
                      height: 50,
                      margin: EdgeInsets.only(top: 10.0, right: 10.0),
                      child: FlatButton(
                        onPressed: () {
                          return;
                        },
                        child: Icon(KaliumIcons.info,
                            size: 24, color: KaliumColors.text),
                        padding: EdgeInsets.all(13.0),
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
                          margin: EdgeInsets.only(left: 50, right: 50, top: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: UIUtil.threeLineAddressText(
                              "ban_1yekta1u3ymis5tji4jxpr4iz8a9bp4bjoz5qdw3wstbub3wgxwi3nfuuyek"),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 50, right: 50, top: 20),
                          padding: EdgeInsets.only(left:20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: KaliumColors.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            textAlign: TextAlign.center,
                            cursorColor: KaliumColors.primary,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(64),
                            ],
                            textInputAction: TextInputAction.done,
                            maxLines: null,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Enter New Rep",
                              suffixIcon: Container(
                                width: 50.0,
                                child: FlatButton(
                                  padding: EdgeInsets.all(15.0),
                                  onPressed: () {
                                    return;
                                  },
                                  child: Icon(KaliumIcons.paste,
                                      size: 20.0, color: KaliumColors.primary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(200.0)),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                ),
                              ),
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  fontFamily: 'NunitoSans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w100),
                            ),
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize: 16.0,
                              color: KaliumColors.text,
                              fontFamily: 'OverpassMono',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //A row with change and close button
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        KaliumButton.buildKaliumButton(
                          KaliumButtonType.PRIMARY,
                          'CHANGE',
                          Dimens.BUTTON_TOP_DIMENS,
                          onPressed: () {
                            return;
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        KaliumButton.buildKaliumButton(
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
