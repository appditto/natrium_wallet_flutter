import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/colors.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/util/exceptions.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';

enum AppButtonType {
  PRIMARY,
  PRIMARY_OUTLINE,
  SUCCESS,
  SUCCESS_OUTLINE,
  TEXT_OUTLINE
}

class AppButton {
  // Primary button builder
  static Widget buildAppButton(
      AppButtonType type, String buttonText, List<double> dimens,
      {Function onPressed, bool disabled = false}) {
    switch (type) {
      case AppButtonType.PRIMARY:
        return Expanded(
          child: Container(
            height: 55,
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              color: disabled ? AppColors.primary60 : AppColors.primary,
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.TextStyleButtonPrimary,
                maxLines: 1,
                stepGranularity: 0.5,
              ),
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
      case AppButtonType.PRIMARY_OUTLINE:
        return Expanded(
          child: Container(
            height: 55,
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlineButton(
              textColor: disabled ? AppColors.primary60 : AppColors.primary,
              borderSide: BorderSide(
                  color: disabled ? AppColors.primary60 : AppColors.primary,
                  width: 2.0),
              highlightedBorderColor:
                  disabled ? AppColors.primary60 : AppColors.primary,
              splashColor: AppColors.primary30,
              highlightColor: AppColors.primary15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: disabled
                    ? AppStyles.TextStyleButtonPrimaryOutlineDisabled
                    : AppStyles.TextStyleButtonPrimaryOutline,
                maxLines: 1,
                stepGranularity: 0.5,
              ),
              onPressed: () {
                if (onPressed != null && !disabled) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      case AppButtonType.SUCCESS:
        return Expanded(
          child: Container(
            height: 55,
            margin:
                EdgeInsets.fromLTRB(dimens[0], dimens[1], dimens[2], dimens[3]),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              color: AppColors.success,
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.TextStyleButtonPrimaryGreen,
                maxLines: 1,
                stepGranularity: 0.5,
              ),
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
      case AppButtonType.SUCCESS_OUTLINE:
        return Expanded(
          child: Container(
            height: 55,
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
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.TextStyleButtonSuccessOutline,
                maxLines: 1,
                stepGranularity: 0.5,
              ),
              onPressed: () {
                if (onPressed != null) {
                  onPressed();
                }
                return;
              },
            ),
          ),
        );
      case AppButtonType.TEXT_OUTLINE:
        return Expanded(
          child: Container(
            height: 55,
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
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.TextStyleButtonTextOutline,
                maxLines: 1,
                stepGranularity: 0.5,
              ),
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
