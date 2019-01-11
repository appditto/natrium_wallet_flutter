import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/ui/util/exceptions.dart';

enum KaliumButtonType { PRIMARY, PRIMARY_OUTLINE, SUCCESS_OUTLINE }

class KaliumButton {
  // Primary button builder
  static Widget buildKaliumButton(
      KaliumButtonType type, String buttonText, List<double> dimens,
      {Function onPressed, bool disabled = false}) {
    switch (type) {
      case KaliumButtonType.PRIMARY:
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              color: disabled ? KaliumColors.primary60 : KaliumColors.primary,
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: KaliumStyles.TextStyleButtonPrimary),
              padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
              onPressed: () {
                if (onPressed != null && !disabled) {
                  onPressed();
                }
                return;
              },
              highlightColor: KaliumColors.background40,
              splashColor: KaliumColors.background40,
            ),
          ),
        );
      case KaliumButtonType.PRIMARY_OUTLINE:
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlineButton(
              textColor: disabled ? KaliumColors.primary60 : KaliumColors.primary,
              borderSide: BorderSide(color: disabled? KaliumColors.primary60 : KaliumColors.primary, width: 2.0),
              highlightedBorderColor: disabled ? KaliumColors.primary60 : KaliumColors.primary,
              splashColor: KaliumColors.primary30,
              highlightColor: KaliumColors.primary15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: disabled ? KaliumStyles.TextStyleButtonPrimaryOutlineDisabled : KaliumStyles.TextStyleButtonPrimaryOutline),
              padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
              onPressed: () {
                if (onPressed != null && !disabled) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      case KaliumButtonType.SUCCESS_OUTLINE:
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlineButton(
              textColor: KaliumColors.success,
              borderSide: BorderSide(color: KaliumColors.success, width: 2.0),
              highlightedBorderColor: KaliumColors.success,
              splashColor: KaliumColors.success30,
              highlightColor: KaliumColors.success15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: KaliumStyles.TextStyleButtonSuccessOutline),
              padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
              onPressed: () {
                if (onPressed != null) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      default:
        throw new UIException("Invalid Button Type $type");
    }
  } //
}
