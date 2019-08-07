import 'dart:io';
import 'package:flutter/services.dart';

import 'package:vibrate/vibrate.dart';

import 'package:natrium_wallet_flutter/util/deviceutil.dart';

/// Utilities for haptic feedback
class HapticUtil {
  /// Feedback for error
  Future<void> error() async {
    if (Platform.isIOS) {
      // If this is simulator or this device doesn't have tapic (iPhone 7+) then we can't use this
      if (await DeviceUtil.isIPhone7OrGreater() && await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.error);
      } else {
        HapticFeedback.vibrate();
      }
    } else {
      HapticFeedback.vibrate();
    }
  }

  /// Feedback for success
  Future<void> success() async {
    if (Platform.isIOS) {
      // If this is simulator or this device doesn't have tapic (iPhone 7+) then we can't use this
      if (await DeviceUtil.isIPhone7OrGreater() && await Vibrate.canVibrate) {
        Vibrate.feedback(FeedbackType.medium);
      } else {
        HapticFeedback.mediumImpact();
      }
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  /// Feedback for fingerprint success
  /// iOS-only, since Android already gives us feedback on success
  Future<void> fingerprintSucess() async {
    if (Platform.isIOS) {
      Future.delayed(Duration(milliseconds: 50), () => success());
    }
  }
}