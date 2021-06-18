import 'dart:core';

import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_payment_req.dart';

import '../service_locator.dart';

// Object to represent an account address or address URI, and provide useful utilities
class Address {
  String _address;
  String _amount;
  String _handoffData;

  Address(String value) {
    _parseAddressString(value);
  }

  String get address => _address;
  String get amount => _amount;

  String getShortString() {
    if (_address == null || _address.length < 64) return null;
    return _address.substring(0, 11) +
        "..." +
        _address.substring(_address.length - 6);
  }

  String getShorterString() {
    if (_address == null || _address.length < 64) return null;
    return _address.substring(0, 9) +
        "..." +
        _address.substring(_address.length - 4);
  }

  /// Returns the handoff payment spec encoded in the URI, or null if not
  /// provided or if the spec/data is invalid.
  HOPaymentRequest getHandoffPaymentSpec() {
    if (_handoffData == null) return null;
    try {
      return HOPaymentRequest.fromBase64(_handoffData,
          altAddr: address, altAmount: amount);
    } catch (e) {
      sl.get<Logger>().w("Invalid handoff spec in nano URI", e);
      return null;
    }
  }

  bool isValid() {
    return _address == null
        ? false
        : NanoAccounts.isValid(NanoAccountType.NANO, _address);
  }

  void _parseAddressString(String value) {
    if (value != null) {
      _address = NanoAccounts.findAccountInString(
          NanoAccountType.NANO, value.toLowerCase().replaceAll("\n", ""));
      var split = value.split(':');
      if (split.length > 1) {
        Uri uri = Uri.tryParse(value);
        if (uri != null) {
          if (uri.queryParameters['amount'] != null) {
            BigInt amount = BigInt.tryParse(uri.queryParameters['amount']);
            if (amount != null) {
              _amount = amount.toString();
            }
          }
          _handoffData = uri.queryParameters['handoff'];
        }
      }
    }
  }
}
