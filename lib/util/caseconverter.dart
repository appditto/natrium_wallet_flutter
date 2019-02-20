import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';

/// Custom locale-specific uppercase/lowercase methods
class CaseChange {
  static String toUpperCase(String input, BuildContext context) {
    Locale locale = Locale(StateContainer.of(context).curLanguage.getLocaleString());
    if (locale != null && locale.languageCode == 'tr') {
      input = input.replaceAll("i", "İ");
    } else if (locale != null && locale.languageCode == 'de') {
      input = input.replaceAll("ß", "SS");
    }
    return input.toUpperCase();
  }
}