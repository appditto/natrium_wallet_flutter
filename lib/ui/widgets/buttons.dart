import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/main.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/util/exceptions.dart';
import 'package:natrium_wallet_flutter/ui/widgets/outline_button.dart';

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
      BuildContext context, AppButtonType type, String buttonText,
      {Function onPressed,
      bool disabled = false,
      List<double> dimens = const [0, 0, 0, 0],
      bool isExpanded = true}) {
    switch (type) {
      case AppButtonType.PRIMARY:
        return isExpanded
            ? Expanded(
                child: _buildPrimaryButton(
                    context, dimens, onPressed, disabled, buttonText))
            : _buildPrimaryButton(
                context, dimens, onPressed, disabled, buttonText);
      case AppButtonType.PRIMARY_OUTLINE:
        return Expanded(
          child: Container(
              height: 55,
              margin: EdgeInsetsDirectional.fromSTEB(
                  dimens[0], dimens[1], dimens[2], dimens[3]),
              child: OutlinedButton(
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        StateContainer.of(context).curTheme.primary30),
                    splashFactory: InkSplash.splashFactory,
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                    ),
                    side: MaterialStateProperty.all(
                      BorderSide(
                          color: disabled
                              ? StateContainer.of(context).curTheme.primary60
                              : StateContainer.of(context).curTheme.primary,
                          width: 2.0),
                    )),
                onPressed: () {
                  if (onPressed != null && !disabled) {
                    onPressed();
                  }
                  return;
                },
                child: AutoSizeText(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: disabled
                      ? AppStyles.textStyleButtonPrimaryOutlineDisabled(context)
                      : AppStyles.textStyleButtonPrimaryOutline(context),
                  maxLines: 1,
                  stepGranularity: 0.5,
                ),
              )),
        );

      case AppButtonType.SUCCESS:
        return Expanded(
          child: Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(100)),
              height: 55,
              margin: EdgeInsetsDirectional.fromSTEB(
                  dimens[0], dimens[1], dimens[2], dimens[3]),
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(
                      StateContainer.of(context).curTheme.successDark),
                  splashFactory: InkSplash.splashFactory,
                  backgroundColor: MaterialStateProperty.all(
                      StateContainer.of(context).curTheme.success),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0)),
                  ),
                ),
                onPressed: () {
                  if (onPressed != null && !disabled) {
                    onPressed();
                  }
                  return;
                },
                child: AutoSizeText(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: AppStyles.textStyleButtonPrimaryGreen(context),
                  maxLines: 1,
                  stepGranularity: 0.5,
                ),
              )),
        );
      case AppButtonType.SUCCESS_OUTLINE:
        return Expanded(
          child: Container(
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.backgroundDark,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  StateContainer.of(context).curTheme.boxShadowButton
                ],
              ),
              height: 55,
              margin: EdgeInsetsDirectional.fromSTEB(
                  dimens[0], dimens[1], dimens[2], dimens[3]),
              child: OutlinedButton(
                style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                        StateContainer.of(context).curTheme.success30),
                    splashFactory: InkSplash.splashFactory,
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                    ),
                    side: MaterialStateProperty.all(BorderSide(
                        color: StateContainer.of(context).curTheme.success,
                        width: 2.0)
                    )),
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  }
                  return;
                },
                child: AutoSizeText(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: AppStyles.textStyleButtonSuccessOutline(context),
                  maxLines: 1,
                  stepGranularity: 0.5,
                ),
              )
              /* OutlineButton(
              color: StateContainer.of(context).curTheme.backgroundDark,
              textColor: StateContainer.of(context).curTheme.success,
              borderSide: BorderSide(
                  color: StateContainer.of(context).curTheme.success,
                  width: 2.0),
              highlightedBorderColor:
                  StateContainer.of(context).curTheme.success,
              splashColor: StateContainer.of(context).curTheme.success30,
              highlightColor: StateContainer.of(context).curTheme.success15,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleButtonSuccessOutline(context),
                maxLines: 1,
                stepGranularity: 0.5,
              ),
              onPressed: () {
                if (onPressed != null) {
                  onPressed();
                }
                return;
              },
            ), */
              ),
        );
      case AppButtonType.TEXT_OUTLINE:
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: StateContainer.of(context).curTheme.backgroundDark,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton],
            ),
            height: 55,
            margin: EdgeInsetsDirectional.fromSTEB(
                dimens[0], dimens[1], dimens[2], dimens[3]),
            child: OutlinedButton(
              style: ButtonStyle(
                splashFactory: InkSplash.splashFactory,
                overlayColor: MaterialStateProperty.all(
                    StateContainer.of(context).curTheme.text30),
                side: MaterialStateProperty.all(BorderSide(
                    color: StateContainer.of(context).curTheme.text,
                    width: 2.0)),
              ),
              child: AutoSizeText(
                buttonText,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleButtonTextOutline(context),
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
  }

  static Container _buildPrimaryButton(
      BuildContext context,
      List<double> dimens,
      Function onPressed,
      bool disabled,
      String buttonText) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          boxShadow: [StateContainer.of(context).curTheme.boxShadowButton],
        ),
        height: 55,
        margin: EdgeInsetsDirectional.fromSTEB(
            dimens[0], dimens[1], dimens[2], dimens[3]),
        child: TextButton(
          onPressed: () {
            if (onPressed != null && !disabled) {
              onPressed();
            }
            return;
          },
          style: ButtonStyle(
            splashFactory: InkSplash.splashFactory,
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0))),
            backgroundColor: MaterialStateProperty.all(
              disabled
                  ? StateContainer.of(context).curTheme.primary60
                  : StateContainer.of(context).curTheme.primary,
            ),
            overlayColor: disabled
                ? MaterialStateProperty.all(Colors.transparent)
                : MaterialStateProperty.all(
                    StateContainer.of(context).curTheme.background40),
          ),
          child: AutoSizeText(buttonText,
              textAlign: TextAlign.center,
              style: AppStyles.textStyleButtonPrimary(context),
              maxLines: 1,
              stepGranularity: 0.5),
        ));
  } //
}
