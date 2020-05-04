import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:logger/logger.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/model/wallet.dart';
import 'package:natrium_wallet_flutter/network/account_service.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_info_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/process_response.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:natrium_wallet_flutter/network/model/response/pending_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/pending_response_item.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/styles.dart';

class AppTransferConfirmSheet extends StatefulWidget {
  final Map<String, AccountBalanceItem> privKeyBalanceMap;
  final Function errorCallback;

  AppTransferConfirmSheet({this.privKeyBalanceMap, this.errorCallback}) : super();

  _AppTransferConfirmSheetState createState() => _AppTransferConfirmSheetState();
}

class _AppTransferConfirmSheetState extends State<AppTransferConfirmSheet> {
  // Total amount there is to transfer
  BigInt totalToTransfer;
  String totalAsReadableAmount;
  // Need to be received by current account
  PendingResponse accountPending;
  // Whether animation overlay is open
  bool animationOpen;

  // StateContainer instead
  StateContainerState state;

  @override
  void initState() {
    super.initState();
    this.totalToTransfer = BigInt.zero;
    this.totalAsReadableAmount = "";
    this.animationOpen = false;
    widget.privKeyBalanceMap
        .forEach((String account, AccountBalanceItem accountBalanceItem) {
      totalToTransfer += BigInt.parse(accountBalanceItem.balance) +
          BigInt.parse(accountBalanceItem.pending);
    });
    this.totalAsReadableAmount = NumberUtil.getRawAsUsableString(totalToTransfer.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this.state = StateContainer.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            //A container for the header
            Container(
              margin: EdgeInsets.only(top: 30.0, left: 70, right: 70),
              child: AutoSizeText(
                CaseChange.toUpperCase(
                    AppLocalization.of(context).transferHeader,
                    context),
                style: AppStyles.textStyleHeader(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                stepGranularity: 0.1,
              ),
            ),

            // A container for the paragraphs
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                smallScreen(context) ? 35 : 60),
                        child: Text(
                          AppLocalization.of(context)
                              .transferConfirmInfo
                              .replaceAll(
                                  "%1", totalAsReadableAmount),
                          style: AppStyles.textStyleParagraphPrimary(
                              context),
                          textAlign: TextAlign.start,
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                smallScreen(context) ? 35 : 60),
                        child: Text(
                          AppLocalization.of(context)
                              .transferConfirmInfoSecond,
                          style:
                              AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.start,
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal:
                                smallScreen(context) ? 35 : 60),
                        child: Text(
                          AppLocalization.of(context)
                              .transferConfirmInfoThird,
                          style:
                              AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.start,
                        )),
                  ],
                ),
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // Send Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY,
                          CaseChange.toUpperCase(
                              AppLocalization.of(context).confirm,
                              context),
                          Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                        animationOpen = true;
                        Navigator.of(context).push(
                            AnimationLoadingOverlay(
                                AnimationType.TRANSFER_TRANSFERRING,
                                StateContainer.of(context)
                                    .curTheme
                                    .animationOverlayStrong,
                                StateContainer.of(context)
                                    .curTheme
                                    .animationOverlayMedium, onPoppedCallback: () {
                          animationOpen = false;
                        }));
                        await processWallets();
                      }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      // Scan QR Code Button
                      AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY_OUTLINE,
                          AppLocalization.of(context)
                              .cancel
                              .toUpperCase(),
                          Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                        Navigator.of(context).pop();
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getPrivKey(int index) async {
    String seed;
    if (StateContainer.of(context).encryptedSecret != null)  {
      seed = NanoHelpers.byteToHex(NanoCrypt.decrypt(StateContainer.of(context).encryptedSecret, await sl.get<Vault>().getSessionKey()));
    } else {
      seed = await sl.get<Vault>().getSeed();
    }
    return NanoUtil.seedToPrivate(seed, index);
  }

  Future<void> processWallets() async {
    BigInt totalTransferred = BigInt.zero;
    try {
      state.lockCallback();
      for (String account in widget.privKeyBalanceMap.keys) {
        AccountBalanceItem  balanceItem = widget.privKeyBalanceMap[account];
        // Get frontiers first
        AccountInfoResponse resp = await sl.get<AccountService>().getAccountInfo(account);
        if (!resp.unopened) {
          balanceItem.frontier = resp.frontier;
        }
        // Receive pending blocks
        PendingResponse pr = await sl.get<AccountService>().getPending(account, 20);
        Map<String, PendingResponseItem> pendingBlocks = pr.blocks;
        for (String hash in pendingBlocks.keys) {
          PendingResponseItem item = pendingBlocks[hash];
          if (balanceItem.frontier != null) {
            ProcessResponse resp = await sl.get<AccountService>().requestReceive(
              AppWallet.defaultRepresentative,
              balanceItem.frontier,
              item.amount,
              hash,
              account,
              balanceItem.privKey
            );
            if (resp.hash != null)  {
              balanceItem.frontier = resp.hash;
              totalTransferred += BigInt.parse(item.amount);
            }
          } else {
            ProcessResponse resp = await sl.get<AccountService>().requestOpen(
              item.amount,
              hash,
              account,
              balanceItem.privKey
            );
            if (resp.hash != null) {
              balanceItem.frontier = resp.hash;            
              totalTransferred += BigInt.parse(item.amount);
            }
          }
          // Hack that waits for blocks to be confirmed
          await Future.delayed(const Duration(milliseconds: 300));
        }
        // Process send from this account
        resp = await sl.get<AccountService>().getAccountInfo(account);
        ProcessResponse sendResp = await sl.get<AccountService>().requestSend(
          AppWallet.defaultRepresentative,
          resp.frontier,
          resp.balance,
          state.wallet.address,
          account,
          balanceItem.privKey,
          max: true
        );
        if (sendResp.hash != null) {
          totalTransferred += BigInt.parse(balanceItem.balance);
        }
      }
    } catch (e) {
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      widget.errorCallback();
      sl.get<Logger>().e("Error processing wallet", e);
      return;
    } finally {
      state.unlockCallback();
    }
    try {
      state.lockCallback();
      // Receive all new blocks to our own account
      PendingResponse pr = await sl.get<AccountService>().getPending(state.wallet.address, 20, includeActive: true);
      Map<String, PendingResponseItem> pendingBlocks = pr.blocks;
      for (String hash in pendingBlocks.keys) {
        PendingResponseItem item = pendingBlocks[hash];
        if (state.wallet.openBlock != null) {
          ProcessResponse resp = await sl.get<AccountService>().requestReceive(
            state.wallet.representative,
            state.wallet.frontier,
            item.amount,
            hash,
            state.wallet.address,
            await _getPrivKey(state.selectedAccount.index)
          );
          if (resp.hash != null) {
            state.wallet.frontier = resp.hash;
          }
        } else {
          ProcessResponse resp = await sl.get<AccountService>().requestOpen(
            item.amount,
            hash,
            state.wallet.address,
            await _getPrivKey(state.selectedAccount.index),
            representative: state.wallet.representative
          );
          if (resp.hash != null) {
            state.wallet.frontier = resp.hash;
            state.wallet.openBlock = resp.hash;            
          }
        }
      }
      state.requestUpdate();
    } catch (e) {
      // Less-important error
      sl.get<Logger>().e("Error processing wallet", e);
    } finally {
      state.unlockCallback();
    }
    EventTaxiImpl.singleton()
        .fire(TransferCompleteEvent(amount: totalTransferred));
    if (animationOpen) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop();
  }
}
