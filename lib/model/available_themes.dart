import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/themes.dart';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum ThemeOptions { HELIUM, INFINITUM, NIHONIUM, CHROMIUM, ADAMANTIUM }

/// Represent notification on/off setting
class ThemeSetting extends SettingSelectionItem {
  ThemeOptions theme;

  ThemeSetting(this.theme);

  String getDisplayName(BuildContext context) {
    switch (theme) {
      case ThemeOptions.ADAMANTIUM:
        return "Adamantium";
      case ThemeOptions.CHROMIUM:
        return "Chromium";
      case ThemeOptions.NIHONIUM:
        return "Nihonium";
      case ThemeOptions.INFINITUM:
        return "Infinitum";
      case ThemeOptions.HELIUM:
        return "Helium";
      default:
        return "Infinitum";
    }
  }

  BaseTheme getTheme() {
    switch (theme) {
      case ThemeOptions.ADAMANTIUM:
        return AdamantiumTheme();
      case ThemeOptions.CHROMIUM:
        return ChromiumTheme();
      case ThemeOptions.NIHONIUM:
        return NihoniumTheme();
      case ThemeOptions.INFINITUM:
        return InfinitumTheme();
      case ThemeOptions.HELIUM:
      default:
        return HeliumTheme();
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return theme.index;
  }
}
