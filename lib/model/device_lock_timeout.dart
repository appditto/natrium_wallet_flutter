import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum LockTimeoutOption { ZERO, ONE, FIVE, FIFTEEN, THIRTY, SIXTY }

/// Represent auto-lock delay when requiring auth to open
class LockTimeoutSetting extends SettingSelectionItem {
  LockTimeoutOption setting;

  LockTimeoutSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case LockTimeoutOption.ZERO:
        return AppLocalization.of(context).instantly;
      case LockTimeoutOption.ONE:
        return AppLocalization.of(context).xMinute.replaceAll("%1", "1");
      case LockTimeoutOption.FIVE:
        return AppLocalization.of(context).xMinutes.replaceAll("%1", "5");
      case LockTimeoutOption.FIFTEEN:
        return AppLocalization.of(context).xMinutes.replaceAll("%1", "15");
      case LockTimeoutOption.THIRTY:
        return AppLocalization.of(context).xMinutes.replaceAll("%1", "30");
      case LockTimeoutOption.SIXTY:
        return AppLocalization.of(context).xMinutes.replaceAll("%1", "60");
      default:
        return AppLocalization.of(context).xMinute.replaceAll("%1", "1");
    }
  }

  Duration getDuration() {
    switch (setting) {
      case LockTimeoutOption.ZERO:
        return Duration(seconds:3);
      case LockTimeoutOption.ONE:
        return Duration(minutes:1);
      case LockTimeoutOption.FIVE:
        return Duration(minutes: 5);
      case LockTimeoutOption.FIFTEEN:
        return Duration(minutes: 15);
      case LockTimeoutOption.THIRTY:
        return Duration(minutes: 30);
      case LockTimeoutOption.SIXTY:
        return Duration(minutes:1);
      default:
        return Duration(minutes:1);
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}