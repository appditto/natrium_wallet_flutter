import 'dart:math';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

class NumberUtil {
  static final BigInt rawPerBan = BigInt.from(pow(10, 29));
  static final int maxDecimalDigits = 2; // Max digits after decimal

  /**
   * Convert raw to ban and return as BigDecimal
   * 
   * @param raw 100000000000000000000000000000
   * @return Decimal value 1.000000000000000000000000000000
   */
  static Decimal getRawAsUsableDecimal(String raw) {
    Decimal amount = Decimal.parse(raw.toString());
    return amount / Decimal.parse(rawPerBan.toString());
  }

  /**
   * Truncate a Decimal to a specific amount of digits
   * 
   * @param input 1.059
   * @return double value 1.05
   */
  static double truncateDecimal(Decimal input) {
    return (input * Decimal.fromInt(pow(10, maxDecimalDigits))).truncateToDouble() / 100;
  }

  /**
   * Return raw as a normal amount.
   * 
   * @param raw 100000000000000000000000000000
   * @returns 1
   */
  static String getRawAsUsableString(String raw) {
    NumberFormat nf = new NumberFormat.currency(locale:'en_US', decimalDigits: maxDecimalDigits, symbol:'');
    return nf.format(truncateDecimal(getRawAsUsableDecimal(raw)));
  }
}