import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum AvailableBlockExplorerEnum { NANOCRAWLER, NANOLOOKER, NANOCAFE }

/// Represent the available authentication methods our app supports
class AvailableBlockExplorer extends SettingSelectionItem {
  AvailableBlockExplorerEnum explorer;

  AvailableBlockExplorer(this.explorer);

  String getDisplayName(BuildContext context) {
    switch (explorer) {
      case AvailableBlockExplorerEnum.NANOCRAWLER:
        return "nanocrawler.cc";
      case AvailableBlockExplorerEnum.NANOLOOKER:
        return "nanolooker.com";
      case AvailableBlockExplorerEnum.NANOCAFE:
        return "nanocafe.cc";
      default:
        return "nanocrawler.cc";
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return explorer.index;
  }
}
