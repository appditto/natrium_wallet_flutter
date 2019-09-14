import 'dart:async';

import 'package:flutter/material.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';

class AppPopupButton extends StatefulWidget {
  final Color buttonColor;
  AppPopupButton({this.buttonColor});
  @override
  _AppPopupButtonState createState() => _AppPopupButtonState();
}

class _AppPopupButtonState extends State<AppPopupButton> {
  double scanButtonSize = 0;
  double popupMarginBottom = 0;
  bool isScrolledUpEnough = false;
  bool firstTime = true;
  Color popupColor = Colors.transparent;
  Color sendButtonColor;
  @override
  void initState() {
    super.initState();
    sendButtonColor = widget.buttonColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Hero(
          tag: 'scanButton',
          child: AnimatedContainer(
            duration: Duration(milliseconds: 150),
            curve: Curves.easeOut,
            height: scanButtonSize,
            width: scanButtonSize,
            decoration: BoxDecoration(
              color: popupColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              AppIcons.scan,
              size: scanButtonSize < 60 ? scanButtonSize / 1.8 : 30,
              color: StateContainer.of(context).curTheme.background,
            ),
          ),
        ),
        // Send Button
        GestureDetector(
          onVerticalDragStart: (value) {
            setState(() {
              popupColor = StateContainer.of(context).curTheme.primary;
            });
          },
          onVerticalDragEnd: (value) {
            sendButtonColor = StateContainer.of(context).curTheme.primary;
            firstTime = true;
            if (isScrolledUpEnough) {
              setState(() {
                popupColor = Colors.white;
              });
              Navigator.pushNamed(context, '/before_scan_screen');
            }
            isScrolledUpEnough = false;
            setState(() {
              scanButtonSize = 0;
            });
          },
          onVerticalDragUpdate: (dragUpdateDetails) {
            if (dragUpdateDetails.localPosition.dy < -60) {
              isScrolledUpEnough = true;
              if (firstTime) {
                sl.get<HapticUtil>().success();
                print("REACHED");
              }
              firstTime = false;
              setState(() {
                popupColor = StateContainer.of(context).curTheme.success;
                sendButtonColor = StateContainer.of(context).curTheme.primary;
              });
            }
            // Swiping below the starting limit
            if (dragUpdateDetails.localPosition.dy >= 0) {
              setState(() {
                scanButtonSize = 0;
                popupMarginBottom = 0;
                sendButtonColor = StateContainer.of(context).curTheme.primary;
              });
            }
            // Swiping above the starting limit betwee 0 and 50
            else if (dragUpdateDetails.localPosition.dy < 0 &&
                dragUpdateDetails.localPosition.dy >= -50) {
              setState(() {
                scanButtonSize = dragUpdateDetails.localPosition.dy * -1;
                popupMarginBottom = 5 + scanButtonSize / 3;
                popupColor = StateContainer.of(context).curTheme.primary;
                sendButtonColor = StateContainer.of(context).curTheme.success;
              });
            }
            // Swiping between 50 and 60
            else if (dragUpdateDetails.localPosition.dy < -50 &&
                dragUpdateDetails.localPosition.dy >= -60) {
              setState(() {
                scanButtonSize = 50 +
                    (((dragUpdateDetails.localPosition.dy * -1) - 50) / 20);
                popupMarginBottom = 5 + scanButtonSize / 3;
                popupColor = StateContainer.of(context).curTheme.primary;
                sendButtonColor = StateContainer.of(context).curTheme.success;
              });
            }
            // Swiping between 60 and 70
            else if (dragUpdateDetails.localPosition.dy < -60 &&
                dragUpdateDetails.localPosition.dy >= -70) {
              isScrolledUpEnough = true;
              setState(() {
                scanButtonSize = 60 +
                    (((dragUpdateDetails.localPosition.dy * -1) - 60) / 40);
                popupMarginBottom = 5 + scanButtonSize / 3;
                popupColor = StateContainer.of(context).curTheme.success;
                sendButtonColor = StateContainer.of(context).curTheme.primary;
              });
            }
            // Swiping between 70 and 80
            else if (dragUpdateDetails.localPosition.dy < -70) {
              isScrolledUpEnough = true;
              setState(() {
                scanButtonSize = 70 +
                    (((dragUpdateDetails.localPosition.dy * -1) - 70) / 80);
                popupMarginBottom = 5 + scanButtonSize / 3;
                popupColor = StateContainer.of(context).curTheme.success;
                sendButtonColor = StateContainer.of(context).curTheme.primary;
              });
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 75),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [StateContainer.of(context).curTheme.boxShadowButton],
            ),
            height: 55,
            width: (MediaQuery.of(context).size.width - 42) / 2,
            margin: EdgeInsetsDirectional.only(
                start: 7, top: popupMarginBottom, end: 14.0),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              color: StateContainer.of(context).wallet != null &&
                      StateContainer.of(context).wallet.accountBalance >
                          BigInt.zero
                  ? sendButtonColor
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
                  Sheets.showAppHeightNineSheet(
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
