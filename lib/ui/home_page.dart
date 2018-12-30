import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:kalium_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:kalium_wallet_flutter/ui/settings/settings_sheet.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';

class KaliumHomePage extends StatefulWidget {
  KaliumHomePage({Key key, this.title}) : super(key: key);
  final String title;
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
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Drawer(
          child: SettingsSheet(),
        ),
      ),
      body: GestureDetector(
              child: Container(
          constraints: BoxConstraints.expand(),
          color: greyLight,
          child: Column(
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
                        color: white90,
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
                          buildReceivedCard('1520', 'ban_1rigge1...bbedwa', context),
                          buildReceivedCard('13020', 'ban_1yekta1...fuuyek', context),
                          buildSentCard('100', '@fudcake', context),
                          buildSentCard('1201', '@rene', context),
                          buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                          buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                          buildSentCard('1201', '@rene', context),
                          buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                          buildSentCard('1201', '@rene', context),
                          buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                          buildReceivedCard('10', 'ban_1stfup1...smugge', context),
                          buildReceivedCard('10', 'ban_1stfup1...smugge', context),
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
                            colors: [greyLight, greyLightZero],
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
                            colors: [greyLightZero, greyLight],
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
                color: greyLight,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(14.0, 0.0, 7.0, 24.0),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          color: yellow,
                          child: Text('Receive',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  color: greyLight)),
                          padding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 20),
                          onPressed: () => receive.mainBottomSheet(context),
                          highlightColor: greyLight40,
                          splashColor: greyLight40,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(7.0, 0.0, 14.0, 24.0),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          color: yellow,
                          child: Text('Send',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w700,
                                  color: greyLight)),
                          padding: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 20),
                          onPressed: () => send.mainBottomSheet(context),
                          highlightColor: greyLight40,
                          splashColor: greyLight40,
                        ),
                      ),
                    ),
                  ],
                ),
              ), //Buttons Area End
            ],
          ),
        ),
      ),
    );
  }
}

//Main Card
Widget buildMainCard(BuildContext context, _scaffoldKey) {
  return Container(
    decoration: BoxDecoration(
      color: greyDark,
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: EdgeInsets.only(top: 42.0, left: 14.0, right: 14.0),
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
                margin: EdgeInsets.only(top:5, left:5),
                height: 50,
                width: 50,
                child: FlatButton(
                  onPressed: (){
                    _scaffoldKey.currentState.openDrawer();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0)),
                  padding: EdgeInsets.all(0.0),
                  child: Icon(KaliumIcons.settings, color: white90, size: 24)),
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
                child: Text("€534",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: white60)),
              ),
              Row(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(right: 5.0),
                      child: Icon(KaliumIcons.bananocurrency,
                          color: yellow, size: 20)),
                  Container(
                    margin: EdgeInsets.only(right: 15.0),
                    child: Text("412,580",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                            color: yellow)),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                      child: Icon(KaliumIcons.btc, color: white60, size: 14)),
                  Text("0.1534",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: white60)),
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
        highlightColor: white15,
        splashColor: white15,
        color: greyDark,
        padding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)),
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
                        child: Icon(KaliumIcons.received,
                            color: yellow60, size: 20)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Received",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: white90,
                          ),
                        ),
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text: amount,
                                style: TextStyle(
                                  color: yellow60,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: " BAN",
                                style: TextStyle(
                                  color: yellow60,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w100,
                                ),
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
                  style: TextStyle(
                    fontSize: 11.0,
                    fontFamily: 'OverpassMono',
                    fontWeight: FontWeight.w100,
                    color: white60,
                  ),
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
      color: greyDark,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: FlatButton(
      highlightColor: white15,
      splashColor: white15,
      color: greyDark,
      padding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)),
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
                      child:
                          Icon(KaliumIcons.sent, color: white60, size: 20)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Sent",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: white90,
                        ),
                      ),
                      RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: '',
                          children: [
                            TextSpan(
                              text: amount,
                              style: TextStyle(
                                color: yellow60,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: " BAN",
                              style: TextStyle(
                                color: yellow60,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w100,
                              ),
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
                style: TextStyle(
                  fontSize: 11.0,
                  fontFamily: 'OverpassMono',
                  fontWeight: FontWeight.w100,
                  color: white60,
                ),
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
                            'Copy Address', Dimens.BUTTON_LEFT_DIMENS),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(KaliumButtonType.PRIMARY_OUTLINE,
                            'View Details', Dimens.BUTTON_RIGHT_DIMENS),
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