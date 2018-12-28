import 'package:flutter/material.dart';
import 'buttons.dart';
import 'colors.dart';
import 'kalium_icons.dart';

//Settings item with a dropdown option
Widget buildSettingsListItemDoubleLine(
    String heading, String option, IconData settingIcon) {
  return FlatButton(
    onPressed: () {
      doNothing();
    },
    padding: EdgeInsets.all(0.0),
    child: Container(
      height: 60.0,
      margin: new EdgeInsets.only(left: 30.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: new EdgeInsets.only(right: 16.0),
            child: new Icon(settingIcon, color: yellow, size: 24),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                heading,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    color: white90),
              ),
              Text(
                option,
                style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w100,
                    color: white60),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

//Settings item without any dropdown option but rather a direct functionality
Widget buildSettingsListItemSingleLine(String heading, IconData settingIcon) {
  return FlatButton(
    onPressed: () {
      doNothing();
    },
    padding: EdgeInsets.all(0.0),
    child: Container(
      height: 60.0,
      margin: new EdgeInsets.only(left: 30.0),
      child: Row(
        children: <Widget>[
          Container(
              margin: new EdgeInsets.only(right: 16.0),
              child: new Icon(settingIcon, color: yellow, size: 24)),
          Text(
            heading,
            style: TextStyle(
                fontSize: 16.0, fontWeight: FontWeight.w600, color: white90),
          ),
        ],
      ),
    ),
  );
}
