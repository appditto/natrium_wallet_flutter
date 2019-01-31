import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/ui/util/exceptions.dart';

enum KaliumButtonType { PRIMARY, PRIMARY_OUTLINE, SUCCESS, SUCCESS_OUTLINE, TEXT_OUTLINE }

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
              color: disabled ? AppColors.primary60 : AppColors.primary,
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: AppStyles.TextStyleButtonPrimary),
              padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
              onPressed: () {
                if (onPressed != null && !disabled) {
                  onPressed();
                }
                return;
              },
              highlightColor: AppColors.background40,
              splashColor: AppColors.background40,
            ),
          ),
        );
      case KaliumButtonType.PRIMARY_OUTLINE:
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlineButton(
              textColor: disabled ? AppColors.primary60 : AppColors.primary,
              borderSide: BorderSide(color: disabled? AppColors.primary60 : AppColors.primary, width: 2.0),
              highlightedBorderColor: disabled ? AppColors.primary60 : AppColors.primary,
              splashColor: AppColors.primary30,
              highlightColor: AppColors.primary15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: disabled ? AppStyles.TextStyleButtonPrimaryOutlineDisabled : AppStyles.TextStyleButtonPrimaryOutline),
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
      case KaliumButtonType.SUCCESS:
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              color: AppColors.success,
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: AppStyles.TextStyleButtonPrimaryGreen),
              padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
              onPressed: () {
                if (onPressed != null && !disabled) {
                  onPressed();
                }
                return;
              },
              highlightColor: AppColors.success30,
              splashColor: AppColors.successDark,
            ),
          ),
        );
      case KaliumButtonType.SUCCESS_OUTLINE:
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlineButton(
              textColor: AppColors.success,
              borderSide: BorderSide(color: AppColors.success, width: 2.0),
              highlightedBorderColor: AppColors.success,
              splashColor: AppColors.success30,
              highlightColor: AppColors.success15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: AppStyles.TextStyleButtonSuccessOutline),
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
        case KaliumButtonType.TEXT_OUTLINE:
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlineButton(
              textColor: AppColors.text,
              borderSide: BorderSide(color: AppColors.text, width: 2.0),
              highlightedBorderColor: AppColors.text,
              splashColor: AppColors.text30,
              highlightColor: AppColors.text15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: AppStyles.TextStyleButtonTextOutline),
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
