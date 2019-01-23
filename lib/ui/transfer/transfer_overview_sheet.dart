import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:kalium_wallet_flutter/ui/transfer/transfer_manual_entry_sheet.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumTransferOverviewSheet {
  Widget transferFundsStart =
      SvgPicture.asset('assets/transferfunds_illustration_start.svg');
  mainBottomSheet(BuildContext context) {
    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  // A container for the header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //Close Button
                      Container(
                        width: 50,
                        height: 50,
                        margin: EdgeInsets.only(top: 10.0, left: 10.0),
                        child: FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Icon(KaliumIcons.close,
                              size: 16, color: KaliumColors.text),
                          padding: EdgeInsets.all(17.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                        ),
                      ),
                      // The header
                      Container(
                        margin: EdgeInsets.only(top: 30.0),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width-140),
                        child: AutoSizeText(
                          KaliumLocalization.of(context)
                              .transferHeader
                              .toUpperCase(),
                          style: KaliumStyles.textStyleHeader(context),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          stepGranularity: 0.1,
                        ),
                      ),
                      // Emtpy SizedBox
                      SizedBox(
                        height: 60,
                        width: 60,
                      ),
                    ],
                  ),

                  // A container for the illustration and paragraphs
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.2,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.6),
                          child: transferFundsStart,
                        ),
                        Container(
                            alignment: Alignment(-1, 0),
                            margin: EdgeInsets.symmetric(
                                horizontal: smallScreen(context)?35:60, vertical: 20),
                            child: Text(
                              KaliumLocalization.of(context).transferIntro,
                              style: KaliumStyles.TextStyleParagraph,
                              textAlign: TextAlign.left,
                            )),
                      ],
                    ),
                  ),

                  Row(
                    children: <Widget>[
                      KaliumButton.buildKaliumButton(
                        KaliumButtonType.PRIMARY,
                        KaliumLocalization.of(context).scanQrCode,
                        Dimens.BUTTON_TOP_DIMENS,
                        onPressed: () {
                          KaliumTransferConfirmSheet()
                              .mainBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      KaliumButton.buildKaliumButton(
                        KaliumButtonType.PRIMARY_OUTLINE,
                        "Manual Entry",
                        Dimens.BUTTON_BOTTOM_DIMENS,
                        onPressed: () {
                          KaliumTransferManualEntrySheet()
                              .mainBottomSheet(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
