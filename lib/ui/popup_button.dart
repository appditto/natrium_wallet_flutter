import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:manta_dart/messages.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/db/contact.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:natrium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/ui/widgets/flat_button.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:natrium_wallet_flutter/util/hapticutil.dart';
import 'package:natrium_wallet_flutter/util/manta.dart';
import 'package:natrium_wallet_flutter/util/user_data_util.dart';

class AppPopupButton extends StatefulWidget {
  @override
  _AppPopupButtonState createState() => _AppPopupButtonState();
}

class _AppPopupButtonState extends State<AppPopupButton> {
  double scanButtonSize = 0;
  double popupMarginBottom = 0;
  bool isScrolledUpEnough = false;
  bool firstTime = true;
  bool isSendButtonColorPrimary = true;
  Color popupColor = Colors.transparent;

  bool animationOpen;

  void _showMantaAnimation() {
    animationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.MANTA,
        StateContainer.of(context).curTheme.animationOverlayStrong,
        StateContainer.of(context).curTheme.animationOverlayMedium,
        onPoppedCallback: () => animationOpen = false));
  }

  @override
  void initState() {
    super.initState();
    animationOpen = false;
  }

  Future<void> scanAndHandlResult() async {
    dynamic scanResult =
        await Navigator.pushNamed(context, '/before_scan_screen');
    // Parse scan data and route appropriately
    if (scanResult == null) {
      UIUtil.showSnackbar(
          AppLocalization.of(context).qrInvalidAddress, context);
    } else if (!QRScanErrs.ERROR_LIST.contains(scanResult) &&
        MantaWallet.parseUrl(scanResult) != null) {
      try {
        _showMantaAnimation();
        // Get manta payment request
        MantaWallet manta = MantaWallet(scanResult);
        PaymentRequestMessage paymentRequest =
            await MantaUtil.getPaymentDetails(manta);
        if (animationOpen) {
          Navigator.of(context).pop();
        }
        MantaUtil.processPaymentRequest(context, manta, paymentRequest);
      } catch (e) {
        if (animationOpen) {
          Navigator.of(context).pop();
        }
        UIUtil.showSnackbar(AppLocalization.of(context).mantaError, context);
      }
    } else if (!QRScanErrs.ERROR_LIST.contains(scanResult)) {
      // Is a URI
      Address address = Address(scanResult);
      if (address.address == null) {
        UIUtil.showSnackbar(
            AppLocalization.of(context).qrInvalidAddress, context);
      } else {
        // See if this address belongs to a contact
        Contact contact =
            await sl.get<DBHelper>().getContactWithAddress(address.address);
        // If amount is present, fill it and go to SendConfirm
        BigInt amountBigInt =
            address.amount != null ? BigInt.tryParse(address.amount) : null;
        bool sufficientBalance = false;
        if (amountBigInt != null && amountBigInt < BigInt.from(10).pow(24)) {
          UIUtil.showSnackbar(
              AppLocalization.of(context)
                  .minimumSend
                  .replaceAll("%1", "0.000001"),
              context);
        } else if (amountBigInt != null &&
            StateContainer.of(context).wallet.accountBalance > amountBigInt) {
          sufficientBalance = true;
        }
        if (amountBigInt != null && sufficientBalance) {
          // Go to confirm sheet
          Sheets.showAppHeightNineSheet(
              context: context,
              widget: SendConfirmSheet(
                  amountRaw: address.amount,
                  destination:
                      contact != null ? contact.address : address.address,
                  contactName: contact != null ? contact.name : null));
        } else {
          // Go to send sheet
          Sheets.showAppHeightNineSheet(
              context: context,
              widget: SendSheet(
                  localCurrency: StateContainer.of(context).curCurrency,
                  contact: contact,
                  address: contact != null ? contact.address : address.address,
                  quickSendAmount:
                      amountBigInt != null ? address.amount : null));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Hero(
          tag: 'scanButton',
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
            curve: Curves.easeOut,
            height: scanButtonSize,
            width: scanButtonSize,
            decoration: BoxDecoration(
              color: popupColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              AppIcons.scan,
              size: scanButtonSize < 60 ? scanButtonSize / 1.8 : 33,
              color: StateContainer.of(context).curTheme.background,
            ),
          ),
        ),
        // Send Button
        GestureDetector(
          onVerticalDragStart: (StateContainer.of(context).wallet != null &&
                  StateContainer.of(context).wallet.accountBalance >
                      BigInt.zero)
              ? (value) {
                  setState(() {
                    popupColor = StateContainer.of(context).curTheme.primary;
                  });
                }
              : (value) {},
          onVerticalDragEnd: (StateContainer.of(context).wallet != null &&
                  StateContainer.of(context).wallet.accountBalance >
                      BigInt.zero)
              ? (value) {
                  isSendButtonColorPrimary = true;
                  firstTime = true;
                  if (isScrolledUpEnough) {
                    setState(() {
                      popupColor = Colors.white;
                    });
                    scanAndHandlResult();
                  }
                  isScrolledUpEnough = false;
                  setState(() {
                    scanButtonSize = 0;
                  });
                }
              : (value) {},
          onVerticalDragUpdate: (StateContainer.of(context).wallet != null &&
                  StateContainer.of(context).wallet.accountBalance >
                      BigInt.zero)
              ? (dragUpdateDetails) {
                  if (dragUpdateDetails.localPosition.dy < -60) {
                    isScrolledUpEnough = true;
                    if (firstTime) {
                      sl.get<HapticUtil>().success();
                    }
                    firstTime = false;
                    setState(() {
                      popupColor = StateContainer.of(context).curTheme.success;
                      isSendButtonColorPrimary = true;
                    });
                  } else {
                    isScrolledUpEnough = false;
                    popupColor = StateContainer.of(context).curTheme.primary;
                    isSendButtonColorPrimary = false;
                  }
                  // Swiping below the starting limit
                  if (dragUpdateDetails.localPosition.dy >= 0) {
                    setState(() {
                      scanButtonSize = 0;
                      popupMarginBottom = 0;
                    });
                  } else if (dragUpdateDetails.localPosition.dy > -60) {
                    setState(() {
                      scanButtonSize = dragUpdateDetails.localPosition.dy * -1;
                      popupMarginBottom = 5 + scanButtonSize / 3;
                    });
                  } else {
                    setState(() {
                      scanButtonSize = 60 +
                          ((dragUpdateDetails.localPosition.dy * -1) - 60) / 30;
                      popupMarginBottom = 5 + scanButtonSize / 3;
                    });
                  }
                }
              : (dragUpdateDetails) {},
          child: AnimatedContainer(
            duration: Duration(milliseconds: 100),
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
                  ? isSendButtonColorPrimary
                      ? StateContainer.of(context).curTheme.primary
                      : StateContainer.of(context).curTheme.success
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
