import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';

/// Input formatter for BANANO/Fiat amounts
class CurrencyFormatter extends TextInputFormatter {

  String commaSeparator;
  String decimalSeparator;
  String symbol;

  CurrencyFormatter({this.commaSeparator = ",", this.decimalSeparator = ".", this.symbol = ""});

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    bool returnOriginal = true;
    if (newValue.text.contains(decimalSeparator) || newValue.text.contains(commaSeparator)) {
      returnOriginal = false;
    } else if (!newValue.text.startsWith(symbol)) {
      return newValue.copyWith(
        text: symbol + newValue.text,
        selection: new TextSelection.collapsed(offset: (symbol + newValue.text).length));
    } else if (symbol.isEmpty && newValue.text.trim() == symbol) {
      return newValue.copyWith(
        text: "",
        selection: new TextSelection.collapsed(offset: 0)
      );
    }

    // If no text, or text doesnt contain a period of comma, no work to do here
    if(newValue.selection.baseOffset == 0 || returnOriginal) {
      return newValue;
    }

    String workingText = newValue.text.replaceAll(commaSeparator, decimalSeparator);
    // if contains more than 2 decimals in newValue, return oldValue
    if (decimalSeparator.allMatches(workingText).length > 1) {
      return newValue.copyWith(
        text: oldValue.text,
        selection: new TextSelection.collapsed(offset: oldValue.text.length));
    } else if (workingText.startsWith(decimalSeparator)) {
      workingText = "0" + workingText;
    }

    if (!workingText.startsWith(symbol)) {
      workingText = symbol + workingText;
    }

    List<String> splitStr = workingText.split(decimalSeparator);
    // If this string contains more than 1 decimal, move all characters to after the first decimal
    if (splitStr.length > 2) {
      returnOriginal = false;
      splitStr.forEach((val) {
        if (splitStr.indexOf(val) > 1) {
          splitStr[1] += val;
        }
      });
    }
    if (splitStr[1].length <= NumberUtil.maxDecimalDigits) {
      if (workingText == newValue.text) {
        return newValue;
      } else {
        return newValue.copyWith(
          text: workingText,
          selection: new TextSelection.collapsed(offset: workingText.length));
       }
    }
    String newText = splitStr[0] + decimalSeparator + splitStr[1].substring(0, NumberUtil.maxDecimalDigits);
    return newValue.copyWith(
      text: newText,
      selection: new TextSelection.collapsed(offset: newText.length));
  }
}

/// Input formatter that ensures text starts with @
class ContactInputFormatter extends TextInputFormatter {

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if(newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String workingText = newValue.text;
    if (!workingText.startsWith("@")) {
      workingText = "@" + workingText;
    }

    List<String> splitStr = workingText.split('@');
    // If this string contains more than 1 @, remove all but the first one
    if (splitStr.length > 2) {
      workingText = "@" + workingText.replaceAll(r"@", "");
    }

    // If nothing changed, return original
    if (workingText == newValue.text) {
      return newValue;
    }

    return newValue.copyWith(
      text: workingText,
      selection: new TextSelection.collapsed(offset: workingText.length));
  }
}