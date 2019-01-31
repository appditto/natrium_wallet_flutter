import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/app_icons.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/model/setting_item.dart';

class KaliumSettings {
  //Settings item with a dropdown option
  static Widget buildSettingsListItemDoubleLine(
      BuildContext context,
      String heading,
      SettingSelectionItem defaultMethod,
      IconData icon,
      Function onPressed,
      {bool disabled = false}) {
    return IgnorePointer(
      ignoring: disabled,
      child: FlatButton(
        onPressed: () {
          onPressed();
        },
        padding: EdgeInsets.all(0.0),
        child: Container(
          height: 60.0,
          margin: EdgeInsets.only(left: 30.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 13.0),
                child: Container(
                  child: Icon(icon,
                      color: disabled
                          ? AppColors.primary45
                          : AppColors.primary,
                      size: 24),
                  margin: EdgeInsets.only(top: 3, left: 3, bottom: 3, right: 3),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    heading,
                    style: disabled
                        ? AppStyles.TextStyleSettingItemHeader45
                        : AppStyles.TextStyleSettingItemHeader,
                  ),
                  Text(
                    defaultMethod.getDisplayName(context),
                    style: disabled
                        ? AppStyles.TextStyleSettingItemSubheader30
                        : AppStyles.TextStyleSettingItemSubheader,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Settings item without any dropdown option but rather a direct functionality
  static Widget buildSettingsListItemSingleLine(
      String heading, IconData settingIcon,
      {Function onPressed}) {
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
              margin: new EdgeInsets.only(right: 13.0),
              child: Container(
                child: new Icon(
                  settingIcon,
                  color: AppColors.primary,
                  size: 24,
                ),
                margin: EdgeInsets.only(
                  top: 3,
                  left: settingIcon == AppIcons.logout ? 6 : 3,
                  bottom: 3,
                  right: settingIcon == AppIcons.logout ? 0 : 3,
                ),
              ),
            ),
            Text(
              heading,
              style: AppStyles.TextStyleSettingItemHeader,
            ),
          ],
        ),
      ),
    );
  }
}
