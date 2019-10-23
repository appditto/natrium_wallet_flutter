import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:logger/logger.dart';

class BiometricUtil {
  ///
  /// hasBiometrics()
  /// 
  /// @returns [true] if device has fingerprint/faceID available and registered, [false] otherwise
  Future<bool> hasBiometrics() async {
    LocalAuthentication localAuth = new LocalAuthentication();
    bool canCheck = await localAuth.canCheckBiometrics;
    if (canCheck) {
      List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();
      availableBiometrics.forEach((type) {
        sl.get<Logger>().i(type.toString());
        sl.get<Logger>().i("${type == BiometricType.face ? 'face' : type == BiometricType.iris ? 'iris' : type == BiometricType.fingerprint ? 'fingerprint' : 'unknown'}");
      });
      if (availableBiometrics.contains(BiometricType.face)) {
        return true;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return true;
      }
    }
    return false;
  }

  ///
  /// authenticateWithBiometrics()
  /// 
  /// @param [message] Message shown to user in FaceID/TouchID popup
  /// @returns [true] if successfully authenticated, [false] otherwise
  Future<bool> authenticateWithBiometrics(BuildContext context, String message) async {
    bool hasBiometricsEnrolled = await hasBiometrics();
    if (hasBiometricsEnrolled) {
      LocalAuthentication localAuth = new LocalAuthentication();
      return await localAuth.authenticateWithBiometrics(
        localizedReason: message,
        useErrorDialogs: false
      );
    }
    return false;
  }
}