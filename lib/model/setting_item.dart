import 'package:flutter/material.dart';

/// Models that are used in settings dialogs/dropdowns
abstract class SettingSelectionItem {
  String getDisplayName(BuildContext context);
}