import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/sheets.dart';
import 'colors.dart';
import 'kalium_icons.dart';

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
  KaliumSmallBottomSheet transactionDetails = KaliumSmallBottomSheet();
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
  KaliumSmallBottomSheet transactionDetails = KaliumSmallBottomSheet();
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
