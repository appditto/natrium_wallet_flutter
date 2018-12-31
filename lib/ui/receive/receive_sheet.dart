import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';

class KaliumReceiveSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightEightSheet(
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
                          Icon(KaliumIcons.close, size: 16, color: KaliumColors.text),
                      padding: EdgeInsets.all(17.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    ),
                  ),

                  //Container for the address text
                  Container(
                    margin: EdgeInsets.only(top: 30.0),
                    child: threeLineAddressBuilder(
                        'ban_1yekta1xn94qdnbmmj1tqg76zk3apcfd31pjmuy6d879e3mr469a4o4sdhd4'),
                  ),

                  //This container is a temporary solution for the alignment problem
                  Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(top: 10.0, right: 10.0),
                  ),
                ],
              ),

              //MonkeyQR which takes all the available space left from the buttons & address text
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 35, bottom: 35),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/monkeyQR.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),

              //A column with "Scan QR Code" and "Send" buttons
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      buildKaliumButton(KaliumButtonType.PRIMARY_OUTLINE,
                          'Share Address', Dimens.BUTTON_TOP_DIMENS),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      buildKaliumButton(KaliumButtonType.PRIMARY,
                          'Copy Address', Dimens.BUTTON_BOTTOM_DIMENS),
                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }
}