import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum AvailableBlockExplorerEnum { TRACKER } // PAWCRAWLER, TRACKER, NANOCAFE

/// Represent the available authentication methods our app supports
class AvailableBlockExplorer extends SettingSelectionItem {
  AvailableBlockExplorerEnum explorer;

  AvailableBlockExplorer(this.explorer);

  String getDisplayName(BuildContext context) {
    switch (explorer) {
      //case AvailableBlockExplorerEnum.PAWCRAWLER:
      //  return "nanocrawler.cc";
      case AvailableBlockExplorerEnum.TRACKER:
        return "tracker.paw.digital";
      //case AvailableBlockExplorerEnum.NANOCAFE:
      //  return "nanocafe.cc";
      default:
        return "tracker.paw.digital";
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return explorer.index;
  }
}
