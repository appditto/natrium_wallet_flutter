import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';

doNothing() {
  return;
}

//Standard Yellow Kalium Button
Widget buildKaliumButton(String buttonText, double marginLeft, double marginTop,
    double marginRight, double marginButtom) {
  return Expanded(
    child: Container(
      margin:
          EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginButtom),
      child: FlatButton(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        color: yellow,
        child: Text(buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20.0, fontWeight: FontWeight.w700, color: greyLight)),
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
        onPressed: () {
          doNothing();
        },
        highlightColor: greyLight40,
        splashColor: greyLight40,
      ),
    ),
  );
} //

//Outlined Yellow Kalium Button
Widget buildKaliumOutlineButton(String buttonText, double marginLeft,
    double marginTop, double marginRight, double marginButtom) {
  return Expanded(
    child: Container(
      margin:
          EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginButtom),
      child: OutlineButton(
        textColor: yellow,
        borderSide: BorderSide(color: yellow, width: 2.0),
        highlightedBorderColor: yellow,
        splashColor: yellow30,
        highlightColor: yellow15,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.0)),
        child: Text(buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20.0, fontWeight: FontWeight.w700, color: yellow)),
        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
        onPressed: () {
          doNothing();
        },
      ),
    ),
  );
}
//
