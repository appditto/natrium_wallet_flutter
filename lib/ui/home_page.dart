import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:kalium_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:kalium_wallet_flutter/ui/settings/settings_sheet.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';

class KaliumHomePage extends StatefulWidget {
  @override
  _KaliumHomePageState createState() => _KaliumHomePageState();
}

class _KaliumHomePageState extends State<KaliumHomePage> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  KaliumReceiveSheet receive = new KaliumReceiveSheet();
  KaliumSendSheet send = new KaliumSendSheet();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: KaliumColors.background,
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Drawer(
          child: SettingsSheet(),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Main Card
          buildMainCard(context, _scaffoldKey),
          //Main Card End

          //Transactions Text
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 20.0, 26.0, 0.0),
            child: Row(
              children: <Widget>[
                Text(
                  "TRANSACTIONS",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w100,
                    color: KaliumColors.text,
                  ),
                ),
              ],
            ),
          ), //Transactions Text End

          //Transactions List
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  child: ListView(
                    padding: EdgeInsets.only(top: 5.0, bottom: 15.0),
                    children: <Widget>[
                      buildReceivedCard(
                          '1520', 'ban_1rigge1...bbedwa', context),
                      buildReceivedCard(
                          '13020', 'ban_1yekta1...fuuyek', context),
                      buildSentCard('100', '@fudcake', context),
                      buildSentCard('1201', '@rene', context),
                      buildReceivedCard(
                          '10', 'ban_1stfup1...smugge', context),
                      buildReceivedCard(
                          '10', 'ban_1stfup1...smugge', context),
                      buildSentCard('1201', '@rene', context),
                      buildReceivedCard(
                          '10', 'ban_1stfup1...smugge', context),
                      buildSentCard('1201', '@rene', context),
                      buildReceivedCard(
                          '10', 'ban_1stfup1...smugge', context),
                      buildReceivedCard(
                          '10', 'ban_1stfup1...smugge', context),
                      buildReceivedCard(
                          '10', 'ban_1stfup1...smugge', context),
                      buildSentCard('1201', '@rene', context),
                      buildSentCard('1201', '@rene', context),
                    ],
                  ),
                ),

                //List Top Gradient End
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 10.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [KaliumColors.background, KaliumColors.background00],
                        begin: Alignment(0.5, -1.0),
                        end: Alignment(0.5, 1.0),
                      ),
                    ),
                  ),
                ), // List Top Gradient End

                //List Bottom Gradient
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 30.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [KaliumColors.background00, KaliumColors.background],
                        begin: Alignment(0.5, -1),
                        end: Alignment(0.5, 0.5),
                      ),
                    ),
                  ),
                ), //List Bottom Gradient End
              ],
            ),
          ), //Transactions List End

          //Buttons Area
          Container(
            color: KaliumColors.background,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(14.0, 0.0, 7.0, MediaQuery.of(context).size.height*0.035),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      color: KaliumColors.primary,
                      child: Text('Receive',
                          textAlign: TextAlign.center,
                          style: KaliumStyles.TextStyleButtonPrimary),
                      padding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 20),
                      onPressed: () => receive.mainBottomSheet(context),
                      highlightColor: KaliumColors.background40,
                      splashColor: KaliumColors.background40,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(7.0, 0.0, 14.0, MediaQuery.of(context).size.height*0.035),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      color: KaliumColors.primary,
                      child: Text('Send',
                          textAlign: TextAlign.center,
                          style: KaliumStyles.TextStyleButtonPrimary),
                      padding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 20),
                      onPressed: () => send.mainBottomSheet(context),
                      highlightColor: KaliumColors.background40,
                      splashColor: KaliumColors.background40,
                    ),
                  ),
                ),
              ],
            ),
          ), //Buttons Area End
        ],
      ),
    );
  }
}

//Main Card
Widget buildMainCard(BuildContext context, _scaffoldKey) {
  return Container(
    decoration: BoxDecoration(
      color:KaliumColors.backgroundDark,
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05, left: 14.0, right: 14.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: 90.0,
          height: 120.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 5, left: 5),
                height: 50,
                width: 50,
                child: FlatButton(
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0)),
                    padding: EdgeInsets.all(0.0),
                    child:
                        Icon(KaliumIcons.settings, color: KaliumColors.text, size: 24)),
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 5.0),
                child: Text(StateContainer.of(context).wallet.localCurrencyPrice,
                    textAlign: TextAlign.center,
                    style: KaliumStyles.TextStyleCurrencyAlt),
              ),
              Row(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(right: 5.0),
                      child: Icon(KaliumIcons.bananocurrency,
                          color: KaliumColors.primary, size: 20)),
                  Container(
                    margin: EdgeInsets.only(right: 15.0),
                    child: Text(StateContainer.of(context).wallet.getAccountBalanceDisplay(),
                        textAlign: TextAlign.center,
                        style: KaliumStyles.TextStyleCurrency),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                      child: Icon(KaliumIcons.btc, color: KaliumColors.text60, size: 14)),
                  Text(StateContainer.of(context).wallet.btcPrice,
                      textAlign: TextAlign.center,
                      style: KaliumStyles.TextStyleCurrencyAlt),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/monkey.png'),
            ),
          ),
          width: 90.0,
          height: 90.0,
        ),
      ],
    ),
  );
} //Main Card

//Received Card
Widget buildReceivedCard(String amount, String address, BuildContext context) {
  TransactionDetailsSheet transactionDetails = TransactionDetailsSheet();
  return Container(
    margin: EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
    child: Container(
      child: FlatButton(
        highlightColor: KaliumColors.text15,
        splashColor: KaliumColors.text15,
        color:KaliumColors.backgroundDark,
        padding: EdgeInsets.all(0.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        onPressed: () => transactionDetails.mainBottomSheet(context),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(right: 16.0),
                        child: Icon(KaliumIcons.received,
                            color: KaliumColors.primary60, size: 20)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Received",
                          textAlign: TextAlign.left,
                          style: KaliumStyles.TextStyleTransactionType,
                        ),
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text: amount,
                                style: KaliumStyles.TextStyleTransactionAmount,
                              ),
                              TextSpan(
                                text: " BAN",
                                style: KaliumStyles.TextStyleTransactionUnit,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  address,
                  textAlign: TextAlign.left,
                  style: KaliumStyles.TextStyleTransactionAddress,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
} //Received End

//Sent Card
Widget buildSentCard(String amount, String address, BuildContext context) {
  TransactionDetailsSheet transactionDetails = TransactionDetailsSheet();
  return Container(
    margin: EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
    decoration: BoxDecoration(
      color:KaliumColors.backgroundDark,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: FlatButton(
      highlightColor: KaliumColors.text15,
      splashColor: KaliumColors.text15,
      color:KaliumColors.backgroundDark,
      padding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      onPressed: () => transactionDetails.mainBottomSheet(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(right: 16.0),
                      child: Icon(KaliumIcons.sent, color: KaliumColors.text60, size: 20)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Sent",
                        textAlign: TextAlign.left,
                        style: KaliumStyles.TextStyleTransactionType,
                      ),
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: amount,
                              style: KaliumStyles.TextStyleTransactionAmount,
                            ),
                            TextSpan(
                              text: " BAN",
                              style: KaliumStyles.TextStyleTransactionUnit,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                address,
                textAlign: TextAlign.left,
                style: KaliumStyles.TextStyleTransactionAddress,
              ),
            ],
          ),
        ),
      ),
    ),
  );
} //Sent Card End

class TransactionDetailsSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightEightSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumButton(KaliumButtonType.PRIMARY,
                            'Copy Address', Dimens.BUTTON_TOP_EXCEPTION_DIMENS),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(KaliumButtonType.PRIMARY_OUTLINE,
                            'View Details', Dimens.BUTTON_BOTTOM_DIMENS),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
