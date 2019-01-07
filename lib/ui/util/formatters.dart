import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';

/// Input formatter that ensures we only have a certain amount of digits after the decimal
class CurrencyInputFormatter extends TextInputFormatter {

  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    bool returnOriginal = true;
    if(newValue.selection.baseOffset == 0 || !newValue.text.contains(".")){
      return newValue;
    }

    List<String> splitStr = newValue.text.split('.');
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
      if (returnOriginal) {
        return newValue;
      } else {
        String newText = splitStr[0] + "." + splitStr[1];
        return newValue.copyWith(
          text: newText,
          selection: new TextSelection.collapsed(offset: newText.length));
      }
    }
    String newText = splitStr[0] + "." + splitStr[1].substring(0, NumberUtil.maxDecimalDigits);
    return newValue.copyWith(
      text: newText,
      selection: new TextSelection.collapsed(offset: newText.length));
  }
}