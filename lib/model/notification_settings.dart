import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum NotificationOptions { ON, OFF }

/// Represent notification on/off setting
class NotificationSetting extends SettingSelectionItem {
  NotificationOptions setting;

  NotificationSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case NotificationOptions.ON:
        return AppLocalization.of(context).onStr;
      case NotificationOptions.OFF:
      default:
        return AppLocalization.of(context).off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}