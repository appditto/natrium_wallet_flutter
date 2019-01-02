import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/styles.dart';

void doNothing() {
  return;
}

//Settings item with a dropdown option
Widget buildSettingsListItemDoubleLine(
    String heading, String option, IconData settingIcon) {
  return FlatButton(
    onPressed: () {
      return;
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
            child: new Icon(settingIcon, color: KaliumColors.primary, size: 24),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                heading,
                style: KaliumStyles.TextStyleSettingItemHeader,
              ),
              Text(
                option,
                style: KaliumStyles.TextStyleSettingItemSubheader,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

//Settings item without any dropdown option but rather a direct functionality
Widget buildSettingsListItemSingleLine(String heading, IconData settingIcon, { Function onPressed }) {
  return FlatButton(
    onPressed: () {
      if (onPressed != null) {
        onPressed();
      } else {
        return;
      }
    },
    padding: EdgeInsets.all(0.0),
    child: Container(
      height: 60.0,
      margin: new EdgeInsets.only(left: 30.0),
      child: Row(
        children: <Widget>[
          Container(
              margin: new EdgeInsets.only(right: 16.0),
              child: new Icon(settingIcon, color: KaliumColors.primary, size: 24)),
          Text(
            heading,
            style: KaliumStyles.TextStyleSettingItemHeader,
          ),
        ],
      ),
    ),
  );
}
