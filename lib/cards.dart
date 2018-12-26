import 'package:flutter/material.dart';
import 'colors.dart';
import 'kalium_icons.dart';

//Main Card
Widget buildMainCard() {
  return new Container(
    decoration: new BoxDecoration(
      color: greyDark,
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: new EdgeInsets.only(top: 42.0, left: 14.0, right: 14.0),
    child: Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 80.0,
            height: 90.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Icon(KaliumIcons.settings, color: white90, size: 24),
              ],
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right:5.0),
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
                      child: Icon(KaliumIcons.bananocurrency, color: yellow, size: 20)),
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
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/monkey.png'),
              ),
            ),
            width: 80.0,
            height: 80.0,
          ),
        ],
      ),
    ),
  );
} //Main Card

//Received Card
Widget buildReceivedCard(String amount, String address) {
  return Container(
    margin: EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
    decoration: BoxDecoration(
      color: greyDark,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    margin: new EdgeInsets.only(right: 16.0),
                    child: new Icon(KaliumIcons.received,
                        color: yellow60, size: 20)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      "Received",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: white90,
                      ),
                    ),
                    new RichText(
                      textAlign: TextAlign.left,
                      text: new TextSpan(
                        text: '',
                        children: [
                          new TextSpan(
                            text: amount,
                            style: new TextStyle(
                              color: yellow60,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          new TextSpan(
                            text: " BAN",
                            style: new TextStyle(
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
            new Text(
              address,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12.0,
                fontFamily: 'OverpassMono',
                fontWeight: FontWeight.w100,
                color: white60,
              ),
            ),
          ],
        ),
      ),
    ),
  );
} //Received End

//Sent Card
Widget buildSentCard(String amount, String address) {
  return Container(
    margin: new EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
    decoration: new BoxDecoration(
      color: greyDark,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                    margin: new EdgeInsets.only(right: 16.0),
                    child:
                        new Icon(KaliumIcons.sent, color: white60, size: 20)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      "Sent",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: white90,
                      ),
                    ),
                    new RichText(
                      textAlign: TextAlign.left,
                      text: new TextSpan(
                        text: '',
                        children: [
                          new TextSpan(
                            text: amount,
                            style: new TextStyle(
                              color: yellow60,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          new TextSpan(
                            text: " BAN",
                            style: new TextStyle(
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
            new Text(
              address,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12.0,
                fontFamily: 'OverpassMono',
                fontWeight: FontWeight.w100,
                color: white60,
              ),
            ),
          ],
        ),
      ),
    ),
  );
} //Sent Card End
