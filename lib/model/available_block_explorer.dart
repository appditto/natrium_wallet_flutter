import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:natrium_wallet_flutter/model/setting_item.dart';

enum AvailableBlockExplorerEnum {
  SPYNANO,
  NANOEXPLORER,
  BLOCKLATTICE,
  NANOCOMMUNITYY,
  NANOBROWSE
}

/// Represent the available authentication methods our app supports
class AvailableBlockExplorer extends SettingSelectionItem {
  AvailableBlockExplorerEnum explorer;

  AvailableBlockExplorer(this.explorer);

  String getDisplayName(BuildContext context) {
    switch (explorer) {
      case AvailableBlockExplorerEnum.SPYNANO:
        return "spynano.org";
      case AvailableBlockExplorerEnum.NANOEXPLORER:
        return "nanexplorer.com";
      case AvailableBlockExplorerEnum.BLOCKLATTICE:
        return "blocklattice.io";
      case AvailableBlockExplorerEnum.NANOCOMMUNITYY:
        return "nano.community";
      case AvailableBlockExplorerEnum.NANOBROWSE:
        return "nanobrowse.com";
      default:
        return "spynano.org";
    }
  }

  String getBlockUrl(String hash) {
    switch (explorer) {
      case AvailableBlockExplorerEnum.SPYNANO:
        return "https://spynano.org/hash/$hash";
      case AvailableBlockExplorerEnum.NANOEXPLORER:
        return "https://nanexplorer.com/nano/block/$hash";
      case AvailableBlockExplorerEnum.BLOCKLATTICE:
        return "https://blocklattice.io/block/$hash";
      case AvailableBlockExplorerEnum.NANOCOMMUNITYY:
        return "https://nano.community/$hash";
      case AvailableBlockExplorerEnum.NANOBROWSE:
        return "https://nanobrowse.com/block/$hash";
      default:
        return "https://spynano.org/hash/$hash";
    }
  }

  String getAccountUrl(String account) {
    switch (explorer) {
      case AvailableBlockExplorerEnum.SPYNANO:
        return "https://spynano.org/account/$account";
      case AvailableBlockExplorerEnum.NANOEXPLORER:
        return "https://nanexplorer.com/nano/account/$account";
      case AvailableBlockExplorerEnum.BLOCKLATTICE:
        return "https://blocklattice.io/account/$account";
      case AvailableBlockExplorerEnum.NANOCOMMUNITYY:
        return "https://nano.community/$account";
      case AvailableBlockExplorerEnum.NANOBROWSE:
        return "https://nanobrowse.com/account/$account";
      default:
        return "https://spynano.org/account/$account";
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return explorer.index;
  }
}
