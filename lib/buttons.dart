import 'package:flutter/material.dart';
import 'colors.dart';

doNothing() {
  return;
}

Widget buildKaliumButton(String buttonText, double marginLeft, double marginTop,
    double marginRight, double marginButtom) {
  return Expanded(
    child: Container(
      margin: new EdgeInsets.fromLTRB(
          marginLeft, marginTop, marginRight, marginButtom),
      child: new FlatButton(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(100.0)),
        color: yellow,
        child: new Text(buttonText,
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
}