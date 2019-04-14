import 'dart:async';
import 'package:flutter/material.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_balance_item.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/pending_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/pending_response_item.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/styles.dart';

class AppTransferConfirmSheet {
  // accounts to private keys/account balances
  Map<String, AccountBalanceItem> privKeyBalanceMap;
  // accounts that have all been pocketed and ready to send
  Map<String, AccountBalanceItem> readyToSendMap = Map();
  // Total amount there is to transfer
  BigInt totalToTransfer = BigInt.zero;
  String totalAsReadableAmount = "";
  // Total amount transferred in raw
  BigInt totalTransferred = BigInt.zero;
  // Need to be received by current account
  PendingResponse accountPending;
  // Whether we finished transfer and are ready to start pocketing
  bool finished = false;
  // Whether animation overlay is open
  bool animationOpen = false;

  Function errorCallback;

  AppTransferConfirmSheet(this.privKeyBalanceMap, this.errorCallback);

  StreamSubscription<TransferAccountHistoryEvent> _historySub;
  StreamSubscription<TransferProcessEvent> _processSub;
  StreamSubscription<TransferPendingEvent> _pendingSub;
  StreamSubscription<TransferErrorEvent> _errorSub;

  Future<bool> _onWillPop() async {
    if (_historySub != null) {
      _historySub.cancel();
    }
    if (_processSub != null) {
      _processSub.cancel();
    }
    if (_pendingSub != null) {
      _pendingSub.cancel();
    }
    if (_errorSub != null) {
      _errorSub.cancel();
    }
    EventTaxiImpl.singleton().fire(UnlockCallbackEvent());
    return true;
  }

  mainBottomSheet(BuildContext context) {
    // Block callback responses
    StateContainer.of(context).lockCallback();
    // See how much we have to transfer and separate accounts with pendings
    List<String> accountsToRemove = List();
    privKeyBalanceMap
        .forEach((String account, AccountBalanceItem accountBalanceItem) {
      totalToTransfer += BigInt.parse(accountBalanceItem.balance) +
          BigInt.parse(accountBalanceItem.pending);
      if (BigInt.parse(accountBalanceItem.pending) == BigInt.zero &&
          BigInt.parse(accountBalanceItem.balance) > BigInt.zero) {
        readyToSendMap.putIfAbsent(account, () => accountBalanceItem);
        accountsToRemove.add(account);
      } else if (BigInt.parse(accountBalanceItem.pending) == BigInt.zero &&
          BigInt.parse(accountBalanceItem.balance) == BigInt.zero) {
        accountsToRemove.add(account);
      }
    });
    accountsToRemove.forEach((account) {
      privKeyBalanceMap.remove(account);
    });
    totalAsReadableAmount =
        NumberUtil.getRawAsUsableString(totalToTransfer.toString());

    // Register event buses (this will probably get a little messy)
    // Receiving account history
    _historySub = EventTaxiImpl.singleton()
        .registerTo<TransferAccountHistoryEvent>()
        .listen((event) {
      AccountHistoryResponse historyResponse = event.response;
      bool readyToSend = false;
      String account = historyResponse.account;
      AccountBalanceItem accountBalanceItem;
      if (!privKeyBalanceMap.containsKey(account)) {
        accountBalanceItem = readyToSendMap[account];
        readyToSend = true;
      } else {
        accountBalanceItem = privKeyBalanceMap[account];
      }
      if (historyResponse.history.length > 0) {
        accountBalanceItem.frontier = historyResponse.history.first.hash;
        if (readyToSend) {
          readyToSendMap[account] = accountBalanceItem;
        } else {
          privKeyBalanceMap[account] = accountBalanceItem;
        }
      }
      if (readyToSend) {
        startProcessing(context);
      } else {
        StateContainer.of(context).requestPending(account: account);
      }
    });
    // Pending response
    _pendingSub = EventTaxiImpl.singleton()
        .registerTo<TransferPendingEvent>()
        .listen((event) {
      // See if this is our account or a paper wallet account
      if (event.response.account != StateContainer.of(context).wallet.address) {
        if (!privKeyBalanceMap.containsKey(event.response.account)) {
          errorCallback();
        }
        privKeyBalanceMap[event.response.account].pendingResponse =
            event.response;
        // Begin open/receive with pendings
        processNextPending(context, event.response.account);
      } else {
        // Store result and start pocketing these
        accountPending = event.response;
        processAppPending(context);
      }
    });
    // Process response
    _processSub = EventTaxiImpl.singleton()
        .registerTo<TransferProcessEvent>()
        .listen((processResponse) {
      // If this is our own account
      if (processResponse.account ==
          StateContainer.of(context).wallet.address) {
        StateContainer.of(context).wallet.frontier = processResponse.hash;
        processAppPending(context);
        return;
      }
      // A paper wallet account
      AccountBalanceItem balItem =
          privKeyBalanceMap.remove(processResponse.account);
      if (balItem != null) {
        balItem.frontier = processResponse.hash;
        balItem.balance = processResponse.balance;
        privKeyBalanceMap[processResponse.account] = balItem;
        // Process next item
        processNextPending(context, processResponse.account);
      } else {
        balItem = readyToSendMap.remove(processResponse.account);
        if (balItem == null) {
          errorCallback();
        }
        totalTransferred += BigInt.parse(balItem.balance);
        startProcessing(context);
      }
    });
    // Error response
    _errorSub = EventTaxiImpl.singleton()
        .registerTo<TransferErrorEvent>()
        .listen((event) {
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      errorCallback();
    });
    AppSheets.showAppHeightNineSheet(
        context: context,
        onDisposed: _onWillPop,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
              onWillPop: _onWillPop,
              child: SafeArea(
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
                                    textAlign: TextAlign.left,
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
                                    textAlign: TextAlign.left,
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
                                    textAlign: TextAlign.left,
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
                                    Dimens.BUTTON_TOP_DIMENS, onPressed: () {
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
                                  startProcessing(context);
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
              ),
            );
          });
        });
  }

  Future<String> _getPrivKey(int index) async {
    return NanoUtil.seedToPrivate(await sl.get<Vault>().getSeed(), index);
  }

  ///
  /// processNextPending()
  ///
  /// Take the next pending block for this account and make a process request for an open/receive
  /// If there are no more pendings, move the account to "readyToSend" and begin processing next
  /// account.
  ///
  /// @param account
  ///
  void processNextPending(BuildContext context, String account) {
    AccountBalanceItem accountBalanceItem = privKeyBalanceMap[account];
    PendingResponse pendingResponse = accountBalanceItem.pendingResponse;
    Map<String, PendingResponseItem> pendingBlocks = pendingResponse.blocks;
    if (pendingBlocks.length > 0) {
      String hash = pendingBlocks.keys.first;
      PendingResponseItem pendingItem = pendingBlocks.remove(hash);
      if (accountBalanceItem.frontier != null) {
        // Receive block
        StateContainer.of(context).requestReceive(
            accountBalanceItem.frontier, hash, pendingItem.amount,
            privKey: accountBalanceItem.privKey, account: account);
      } else {
        // Open account
        StateContainer.of(context).requestOpen("0", hash, pendingItem.amount,
            privKey: accountBalanceItem.privKey, account: account);
      }
    } else {
      readyToSendMap.putIfAbsent(account, () => accountBalanceItem);
      privKeyBalanceMap.remove(account);
      startProcessing(context); // next account
    }
  }

  ///
  /// processAppPending()
  ///
  /// Start pocketing the transactions our logged in account received from this transfer
  ///
  /// @param context
  ///
  void processAppPending(BuildContext context) {
    if (accountPending == null) {
      errorCallback();
    }
    Map<String, PendingResponseItem> pendingBlocks = accountPending.blocks;
    if (pendingBlocks.length > 0) {
      String hash = pendingBlocks.keys.first;
      PendingResponseItem pendingItem = pendingBlocks.remove(hash);
      if (StateContainer.of(context).wallet.openBlock != null) {
        // Receive block
        _getPrivKey(StateContainer.of(context).selectedAccount.index).then((result) {
          StateContainer.of(context).requestReceive(
              StateContainer.of(context).wallet.frontier,
              hash,
              pendingItem.amount,
              privKey: result,
              account: StateContainer.of(context).wallet.address);
        });
      } else {
        // Open account
        _getPrivKey(StateContainer.of(context).selectedAccount.index).then((result) {
          StateContainer.of(context).requestOpen("0", hash, pendingItem.amount,
              privKey: result,
              account: StateContainer.of(context).wallet.address);
        });
      }
    } else {
      startProcessing(context); // Finish the process
    }
  }

  void startProcessing(BuildContext context) {
    if (privKeyBalanceMap.length > 0) {
      String account = privKeyBalanceMap.keys.first;
      StateContainer.of(context).requestAccountHistory(account);
    } else if (readyToSendMap.length > 0) {
      // Start requesting sends
      String account = readyToSendMap.keys.first;
      AccountBalanceItem balItem = readyToSendMap[account];
      if (balItem.frontier == null) {
        StateContainer.of(context).requestAccountHistory(account);
      } else {
        StateContainer.of(context).requestSend(
            balItem.frontier, StateContainer.of(context).wallet.address, "0",
            privKey: balItem.privKey, account: account);
      }
    } else if (!finished) {
      finished = true;
      StateContainer.of(context)
          .requestPending(account: StateContainer.of(context).wallet.address);
    } else {
      EventTaxiImpl.singleton()
          .fire(TransferCompleteEvent(amount: totalToTransfer));
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      Navigator.of(context).pop();
    }
  }
}
