import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/model/setting_item.dart';

enum LockTimeoutOption { ZERO, ONE, FIVE, FIFTEEN, THIRTY, SIXTY }

/// Represent auto-lock delay when requiring auth to open
class LockTimeoutSetting extends SettingSelectionItem {
  LockTimeoutOption setting;

  LockTimeoutSetting(this.setting);

  String getDisplayName(BuildContext context) {
    switch (setting) {
      case LockTimeoutOption.ZERO:
        return KaliumLocalization.of(context).instantly;
      case LockTimeoutOption.ONE:
        return KaliumLocalization.of(context).xMinute.replaceAll("%1", "1");
      case LockTimeoutOption.FIVE:
        return KaliumLocalization.of(context).xMinutes.replaceAll("%1", "5");
      case LockTimeoutOption.FIFTEEN:
        return KaliumLocalization.of(context).xMinutes.replaceAll("%1", "15");
      case LockTimeoutOption.THIRTY:
        return KaliumLocalization.of(context).xMinutes.replaceAll("%1", "30");
      case LockTimeoutOption.SIXTY:
        return KaliumLocalization.of(context).xMinutes.replaceAll("%1", "60");
      default:
        return KaliumLocalization.of(context).xMinute.replaceAll("%1", "1");
    }
  }

  int getMinuteValue() {
    switch (setting) {
      case LockTimeoutOption.ZERO:
        return 0;
      case LockTimeoutOption.ONE:
        return 1;
      case LockTimeoutOption.FIVE:
        return 5;
      case LockTimeoutOption.FIFTEEN:
        return 15;
      case LockTimeoutOption.THIRTY:
        return 30;
      case LockTimeoutOption.SIXTY:
        return 60;
      default:
        return 1;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}