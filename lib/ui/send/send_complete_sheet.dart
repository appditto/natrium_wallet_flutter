import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:manta_dart/messages.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';

class SendCompleteSheet extends StatefulWidget {
  final String amountRaw;
  final String destination;
  final String contactName;
  final String localAmount;
  final PaymentRequestMessage paymentRequest;
  final int natriconNonce;

  SendCompleteSheet({this.amountRaw, this.destination, this.contactName, this.localAmount, this.paymentRequest, this.natriconNonce}) : super();  

  _SendCompleteSheetState createState() => _SendCompleteSheetState();
}

class _SendCompleteSheetState extends State<SendCompleteSheet> {
  String amount;
  String destinationAltered;
  bool isMantaTransaction;

  @override
  void initState() {
    super.initState();
    // Indicate that this is a special amount if some digits are not displayed
    if (NumberUtil.getRawAsUsableString(widget.amountRaw).replaceAll(",", "") ==
        NumberUtil.getRawAsUsableDecimal(widget.amountRaw).toString()) {
      amount = NumberUtil.getRawAsUsableString(widget.amountRaw);
    } else {
      amount = NumberUtil.truncateDecimal(
                  NumberUtil.getRawAsUsableDecimal(widget.amountRaw),
                  digits: 6)
              .toStringAsFixed(6) +
          "~";
    }
    destinationAltered = widget.destination.replaceAll("xrb_", "nano_");
    isMantaTransaction = widget.paymentRequest != null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // Sheet handle
            Container(
              margin: EdgeInsets.only(top: 10),
              height: 5,
              width: MediaQuery.of(context).size.width * 0.15,
              decoration: BoxDecoration(
                color: StateContainer.of(context).curTheme.text10,
                borderRadius: BorderRadius.circular(100.0),
              ),
            ),
            //A main container that holds the amount, address and "SENT TO" texts
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Success tick (icon)
                  Container(
                    alignment: AlignmentDirectional(0, 0),
                    margin: EdgeInsets.only(bottom: 25),
                    child: Icon(AppIcons.success,
                        size: 100,
                        color: StateContainer.of(context)
                            .curTheme
                            .success),
                  ),
                  // Container for the Amount Text
                  Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.105,
                        right:
                            MediaQuery.of(context).size.width * 0.105),
                    padding: EdgeInsets.symmetric(
                        horizontal: 25, vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: StateContainer.of(context)
                          .curTheme
                          .backgroundDarkest,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // Amount text
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: "Ӿ$amount",
                            style: TextStyle(
                              color: StateContainer.of(context)
                                  .curTheme
                                  .success,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                          TextSpan(
                            text: widget.localAmount != null
                                ? " (${widget.localAmount})"
                                : "",
                            style: TextStyle(
                              color: StateContainer.of(context)
                                  .curTheme
                                  .success.withOpacity(0.75),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'NunitoSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Container for the "SENT TO" text
                  Container(
                    margin: EdgeInsets.only(top: 30.0, bottom: 10),
                    child: Column(
                      children: <Widget>[
                        // "SENT TO" text
                        Text(
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).sentTo,
                              context),
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.w700,
                            color: StateContainer.of(context)
                                .curTheme
                                .success,
                            fontFamily: 'NunitoSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // The container for the address
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15.0),
                      margin: EdgeInsets.only(
                          left:
                              MediaQuery.of(context).size.width * 0.105,
                          right: MediaQuery.of(context).size.width *
                              0.105),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)
                            .curTheme
                            .backgroundDarkest,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child:  isMantaTransaction
                          ? Column(
                              children: <Widget>[
                                AutoSizeText(
                                  widget.paymentRequest.merchant.name,
                                  minFontSize: 12,
                                  stepGranularity: 0.1,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.headerSuccess(context),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                AutoSizeText(
                                  widget.paymentRequest.merchant.address,
                                  minFontSize: 10,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  stepGranularity: 0.1,
                                  style: AppStyles.addressText(context),
                                ),
                                Container(
                                  margin: EdgeInsetsDirectional.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsetsDirectional.only(
                                            start: 10, end: 20),
                                        child: Icon(
                                          AppIcons.appia,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                UIUtil.smallScreen(context)
                                    ? UIUtil.oneLineAddressText(
                                        context, destinationAltered, type: OneLineAddressTextType.SUCCESS)
                                    : UIUtil.threeLineAddressText(
                                        context, destinationAltered, type: ThreeLineAddressTextType.SUCCESS)
                              ],
                            )
                          : UIUtil.threeLineAddressText(
                              context, destinationAltered,
                              type: ThreeLineAddressTextType.SUCCESS,
                              contactName: widget.contactName)),
                ],
              ),
            ),

            // CLOSE Button
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.SUCCESS_OUTLINE,
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).close,
                              context),
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        )
      );    
  }
}

