import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/styles.dart';

class AppTransferCompleteSheet {
  String transferAmount;

  AppTransferCompleteSheet(this.transferAmount);

  mainBottomSheet(BuildContext context) {
    AppSheets.showAppHeightNineSheet(
        context: context,
        closeOnTap: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Stack(
              children: <Widget>[
                // Container that holds everything
                Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      //A container for the paragraph and seed
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // Success tick (icon)
                            Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: Icon(AppIcons.success,
                                  size: 100, color: StateContainer.of(context).curTheme.success),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height *
                                          0.2,
                                  maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.6),
                              child: SvgPicture.asset('assets/transferfunds_illustration_end.svg'),
                            ),
                            Container(
                                alignment: Alignment(-1, 0),
                                margin: EdgeInsets.symmetric(horizontal: smallScreen(context)?35:60),
                                child: Text(
                                  AppLocalization.of(context)
                                      .transferComplete.replaceAll("%1", transferAmount),
                                  style:
                                      AppStyles.textStyleParagraphSuccess(context),
                                  textAlign: TextAlign.left,
                                )),
                            Container(
                                alignment: Alignment(-1, 0),
                                margin: EdgeInsets.symmetric(horizontal: smallScreen(context)?35:60),
                                child: Text(
                                  AppLocalization.of(context)
                                      .transferClose,
                                  style: AppStyles.textStyleParagraph(context),
                                  textAlign: TextAlign.left,
                                )),
                          ],
                        ),
                      ),

                      Row(
                        children: <Widget>[
                          AppButton.buildAppButton(context, 
                            AppButtonType.SUCCESS_OUTLINE,
                            AppLocalization.of(context)
                                .close
                                .toUpperCase(),
                            Dimens.BUTTON_BOTTOM_DIMENS,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          });
        });
  }
}
