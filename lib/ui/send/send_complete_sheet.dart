import 'package:flutter/material.dart';

import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';

class AppSendCompleteSheet {
  String _amountRaw;
  String _amount;
  String _destination;
  String _contactName;
  String _localAmount;

  AppSendCompleteSheet(String amount, String destinaton, String contactName,
      {String localAmount}) {
    _amountRaw = amount;
    // Indicate that this is a special amount if some digits are not displayed
    if (NumberUtil.getRawAsUsableString(_amountRaw) == NumberUtil.getRawAsUsableDecimal(_amountRaw).toString()) {
      _amount = NumberUtil.getRawAsUsableString(_amountRaw);
    } else {
      _amount = NumberUtil.truncateDecimal(NumberUtil.getRawAsUsableDecimal(_amountRaw), digits: 6).toStringAsFixed(6) + "~";
    }
    _destination = destinaton.replaceAll("nano_", "xrb_");
    _contactName = contactName;
    _localAmount = localAmount;
  }

  mainBottomSheet(BuildContext context) {
    AppSheets.showAppHeightNineSheet(
        context: context,
        removeUntilHome: false,
        closeOnTap: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            // The main column that holds everything
            return SafeArea(
              minimum: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.035),
              child: Column(
              children: <Widget>[
                //A main container that holds the amount, address and "SENT TO" texts
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Success tick (icon)
                      Container(
                        alignment: Alignment(0, 0),
                        margin: EdgeInsets.only(bottom: 25),
                        child: Icon(AppIcons.success,
                            size: 100, color: StateContainer.of(context).curTheme.success),
                      ),
                      // Container for the Amount Text
                      Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.105,
                            right: MediaQuery.of(context).size.width * 0.105),
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: StateContainer.of(context).curTheme.backgroundDarkest,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        // Amount text
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text: "$_amount",
                                style: TextStyle(
                                  color: StateContainer.of(context).curTheme.success,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'NunitoSans',
                                ),
                              ),
                              TextSpan(
                                text: " NANO",
                                style: TextStyle(
                                  color: StateContainer.of(context).curTheme.success,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NunitoSans',
                                ),
                              ),
                              TextSpan(
                                text: _localAmount != null ? " ($_localAmount)" : "",
                                style: TextStyle(
                                  color: StateContainer.of(context).curTheme.success,
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
                              CaseChange.toUpperCase(AppLocalization.of(context)
                                  .sentTo, context),
                              style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.w700,
                                color: StateContainer.of(context).curTheme.success,
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
                              left: MediaQuery.of(context).size.width * 0.105,
                              right: MediaQuery.of(context).size.width * 0.105),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: StateContainer.of(context).curTheme.backgroundDarkest,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: UIUtil.threeLineAddressText(context, _destination,
                              type: ThreeLineAddressTextType.SUCCESS,
                              contactName: _contactName)),
                    ],
                  ),
                ),

                // CLOSE Button
                Container(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          AppButton.buildAppButton(context, 
                              AppButtonType.SUCCESS_OUTLINE,
                              CaseChange.toUpperCase(AppLocalization.of(context)
                                  .close, context),
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                            Navigator.of(context).pop();
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ));
          });
        });
  }
}
