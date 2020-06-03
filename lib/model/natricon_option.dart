import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum NatriconOptions { ON, OFF }

/// Represent natricon on/off setting
class NatriconSetting extends SettingSelectionItem {
  NatriconOptions setting;

  NatriconSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case NatriconOptions.ON:
        return AppLocalization.of(context).onStr;
      case NatriconOptions.OFF:
      default:
        return AppLocalization.of(context).off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}