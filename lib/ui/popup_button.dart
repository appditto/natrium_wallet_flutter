import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';

class AppPopupButton extends StatefulWidget {
  final onVerticalDragEndFunction;

  AppPopupButton({this.onVerticalDragEndFunction});
  @override
  _AppPopupButtonState createState() => _AppPopupButtonState();
}

class _AppPopupButtonState extends State<AppPopupButton> {
  double scanButtonSize = 0;
  bool isScrolledUpEnough = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 150),
          curve: Curves.easeOut,
          margin: EdgeInsetsDirectional.only(bottom: 12),
          height: scanButtonSize,
          width: scanButtonSize,
          decoration: BoxDecoration(
            color: StateContainer.of(context).curTheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        // Send Button
        GestureDetector(
          onVerticalDragEnd: (value) {
            setState(() {
              scanButtonSize = 0;
            });
            if (isScrolledUpEnough) {
              widget.onVerticalDragEndFunction();
            }
            isScrolledUpEnough = false;
          },
          onVerticalDragUpdate: (dragUpdateDetails) {
            if (dragUpdateDetails.localPosition.dy < -55) {
              isScrolledUpEnough = true;
              sl.get<HapticUtil>().success();
            }
            if (dragUpdateDetails.localPosition.dy < 0) {
              if (dragUpdateDetails.localPosition.dy >= -55) {
                setState(() {
                  scanButtonSize = dragUpdateDetails.localPosition.dy * -1;
                });
              } else if (dragUpdateDetails.localPosition.dy >= -65) {
                setState(() {
                  scanButtonSize = 55 +
                      (((dragUpdateDetails.localPosition.dy * -1) - 55) / 20);
                });
              } else if (dragUpdateDetails.localPosition.dy >= -75) {
                setState(() {
                  scanButtonSize = 65 +
                      (((dragUpdateDetails.localPosition.dy * -1) - 65) / 40);
                });
              } else {
                setState(() {
                  scanButtonSize = 75 +
                      (((dragUpdateDetails.localPosition.dy * -1) - 75) / 80);
                });
              }
            }
            print(dragUpdateDetails.localPosition.dy);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton],
            ),
            height: 55,
            width: (MediaQuery.of(context).size.width - 42) / 2,
            margin: EdgeInsetsDirectional.only(start: 7, top: 0.0, end: 14.0),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              color: StateContainer.of(context).wallet != null &&
                      StateContainer.of(context).wallet.accountBalance >
                          BigInt.zero
                  ? StateContainer.of(context).curTheme.primary
                  : StateContainer.of(context).curTheme.primary60,
              child: AutoSizeText(
                AppLocalization.of(context).send,
                textAlign: TextAlign.center,
                style: AppStyles.textStyleButtonPrimary(context),
                maxLines: 1,
                stepGranularity: 0.5,
              ),
              onPressed: () {
                if (StateContainer.of(context).wallet != null &&
                    StateContainer.of(context).wallet.accountBalance >
                        BigInt.zero) {
                  Sheets.showAppHeightEightSheet(
                      context: context,
                      widget: SendSheet(
                          localCurrency:
                              StateContainer.of(context).curCurrency));
                }
              },
              highlightColor: StateContainer.of(context).wallet != null &&
                      StateContainer.of(context).wallet.accountBalance >
                          BigInt.zero
                  ? StateContainer.of(context).curTheme.background40
                  : Colors.transparent,
              splashColor: StateContainer.of(context).wallet != null &&
                      StateContainer.of(context).wallet.accountBalance >
                          BigInt.zero
                  ? StateContainer.of(context).curTheme.background40
                  : Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
