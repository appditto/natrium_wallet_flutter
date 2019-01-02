import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';

class IntroBackupConfirm extends StatefulWidget {
  @override
  _IntroBackupConfirmState createState() => _IntroBackupConfirmState();
}

class _IntroBackupConfirmState extends State<IntroBackupConfirm> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));

    return new Scaffold(
      key: _scaffoldKey,
      backgroundColor: KaliumColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) => Column(
              children: <Widget>[
                //A widget that holds welcome animation + text and expands to the rest of the available area
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.height * 0.075),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              height: 50,
                              width: 50,
                              child: FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(50.0)),
                                  padding: EdgeInsets.all(0.0),
                                  child: Icon(KaliumIcons.back,
                                      color: KaliumColors.text, size: 24)),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 15.0, left: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Backup your seed",
                                style: KaliumStyles.TextStyleHeaderColored,
                              ),
                            ],
                          ),
                        ),
                        //Container for the text
                        Container(
                          margin:
                              EdgeInsets.only(left: 50, right: 50, top: 15.0),
                          child: Text(
                              "Are you sure that you backed up your wallet seed?",
                              style: KaliumStyles.TextStyleParagraph),
                        ),
                      ],
                    ),
                  ),
                ),

               //A column with "New Wallet" and "Import Wallet" buttons
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumButton(
                            KaliumButtonType.PRIMARY_OUTLINE,
                            'YES',
                            Dimens.BUTTON_TOP_DIMENS, 
                          onPressed: () {
                            SharedPrefsUtil.inst.setSeedBackedUp(true).then((result) {
                              Navigator.of(context)
                                  .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                            });
                        }),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(
                            KaliumButtonType.PRIMARY,
                            'NO',
                            Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                              Navigator.of(context).pop();
                        }),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }
}