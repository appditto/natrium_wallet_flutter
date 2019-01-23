import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:kalium_wallet_flutter/ui/transfer/transfer_confirm_sheet.dart';
import 'package:kalium_wallet_flutter/ui/transfer/transfer_manual_entry_sheet.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/styles.dart';

class KaliumTransferOverviewSheet {
  static const int NUM_SWEEP = 15; // Number of accounts to sweep from a seed
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  // Map private keys to account_balance response
  Map<String, AccountBalanceItem> privKeyBalanceMap = Map();

  mainBottomSheet(BuildContext context) {
    KaliumSheets.showKaliumHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              key: _scaffoldKey,
              body: Container(
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
                            child: SvgPicture.asset('assets/transferfunds_illustration_start.svg'),
                          ),
                          Container(
                              alignment: Alignment(-1, 0),
                              margin: EdgeInsets.symmetric(
                                  horizontal: smallScreen(context)?35:60, vertical: 20),
                              child: Text(
                                KaliumLocalization.of(context).transferIntro.replaceAll("%1", KaliumLocalization.of(context).scanQrCode),
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
                            BarcodeScanner.scan().then((value) {
                              if (!NanoSeeds.isValidSeed(value)) {
                                UIUtil.showSnackbar(_scaffoldKey, KaliumLocalization.of(context).seedInvalid);
                                return;
                              }
                              // Show loading overlay
                              Navigator.of(context)
                                            .push(AnimationLoadingOverlay(AnimationType.TRANSFER_SEARCHING));
                              // Get accounts from seed
                              List<String> accountsToRequest = getAccountsFromSeed(context, value);
                              // Make balances request
                              StateContainer.of(context).requestAccountsBalances(accountsToRequest);
                            });
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
              ),
            );
          });
        });
  }

  /// Get NUM_SWEEP accounts from seed to request balances for
  List<String> getAccountsFromSeed(BuildContext context, String seed) {
    List<String> accountsToRequest = List();
    String privKey;
    String address;
    // Get NUM_SWEEP private keys + accounts from seed
    for (int i=0; i < NUM_SWEEP; i++) {
      privKey = NanoKeys.seedToPrivate(seed, i);
      address = NanoAccounts.createAccount(NanoAccountType.BANANO, NanoKeys.createPublicKey(privKey));
      // Don't add this if it is the currently logged in account
      if (address != StateContainer.of(context).wallet.address) {
        privKeyBalanceMap.putIfAbsent(privKey, () => AccountBalanceItem(privKey: privKey));
        accountsToRequest.add(address);
      }
    }
    // Also treat this seed as a private key
    address = NanoAccounts.createAccount(NanoAccountType.BANANO, NanoKeys.createPublicKey(seed));
    if (address != StateContainer.of(context).wallet.address) {
      privKeyBalanceMap.putIfAbsent(seed, () => AccountBalanceItem(privKey: privKey));
      accountsToRequest.add(address);
    }
    return accountsToRequest;
  }
}
