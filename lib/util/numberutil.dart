import 'dart:math';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

class NumberUtil {
  static final BigInt rawPerBan = BigInt.from(10).pow(29);
  static const int maxDecimalDigits = 2; // Max digits after decimal

  /// Convert raw to ban and return as BigDecimal
  ///
  /// @param raw 100000000000000000000000000000
  /// @return Decimal value 1.000000000000000000000000000000
  ///
  static Decimal getRawAsUsableDecimal(String raw) {
    Decimal amount = Decimal.parse(raw.toString());
    Decimal result = amount / Decimal.parse(rawPerBan.toString());
    return result;
  }

  /// Truncate a Decimal to a specific amount of digits
  ///
  /// @param input 1.059
  /// @return double value 1.05
  ///
  static double truncateDecimal(Decimal input) {
    return (input * Decimal.fromInt(pow(10, maxDecimalDigits))).truncateToDouble() / pow(10, maxDecimalDigits);
  }

  /// Return raw as a normal amount.
  ///
  /// @param raw 100000000000000000000000000000
  /// @returns 1
  ///
  static String getRawAsUsableString(String raw) {
    NumberFormat nf = new NumberFormat.currency(locale:'en_US', decimalDigits: maxDecimalDigits, symbol:'');
    String asString = nf.format(truncateDecimal(getRawAsUsableDecimal(raw)));
    var split = asString.split(".");
    if (split.length > 1) {
      if (int.parse(split[1]) == 0) {
        asString = split[0];
      }
    }
    return asString;
  }

  /// Return readable string amount as raw string
  /// @param amount 1.01
  /// @returns  101000000000000000000000000000
  ///
  static String getAmountAsRaw(String amount) {
    Decimal asDecimal = Decimal.parse(amount);
    Decimal rawDecimal = Decimal.parse(rawPerBan.toString());
    return (asDecimal * rawDecimal).toString();
  }
}