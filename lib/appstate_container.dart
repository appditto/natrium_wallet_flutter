import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:kalium_wallet_flutter/model/wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:package_info/package_info.dart';
import 'package:uni_links/uni_links.dart';
import 'package:kalium_wallet_flutter/model/available_currency.dart';
import 'package:kalium_wallet_flutter/model/address.dart';
import 'package:kalium_wallet_flutter/model/state_block.dart';
import 'package:kalium_wallet_flutter/model/deep_link_action.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/network/model/block_types.dart';
import 'package:kalium_wallet_flutter/network/model/request_item.dart';
import 'package:kalium_wallet_flutter/network/model/request/account_history_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/blocks_info_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/pending_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/process_request.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/callback_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/blocks_info_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/price_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/process_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/pending_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/pending_response_item.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/nanoutil.dart';
import 'package:kalium_wallet_flutter/network/account_service.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';

class _InheritedStateContainer extends InheritedWidget {
   // Data is your entire state. In our case just 'User' 
  final StateContainerState data;
   
  // You must pass through a child and your state.
  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  // This is a built in method which you can use to check if
  // any state has changed. If not, no reason to rebuild all the widgets
  // that rely on your state.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}

class StateContainer extends StatefulWidget {
   // You must pass through a child. 
  final Widget child;
  final KaliumWallet wallet;
  final String currencyLocale;
  final Locale deviceLocale;
  final String appVersionString;
  final AvailableCurrency curCurrency;

  StateContainer({
    @required this.child,
    this.wallet,
    this.currencyLocale,
    this.deviceLocale,
    this.appVersionString,
    this.curCurrency
  });

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer).data;
  }
  
  @override
  StateContainerState createState() => new StateContainerState();
}

/// TODO
/// since we're doing the bulk of the heavy lifting here, we should probably document it better
/// and organize it a bit
class StateContainerState extends State<StateContainer> {
  final Logger log = Logger("StateContainerState");
  // Whichever properties you wanna pass around your app as state
  KaliumWallet wallet;
  String currencyLocale;
  Locale deviceLocale = Locale('en', 'US');
  String appVersionString;
  AvailableCurrency curCurrency = AvailableCurrency(AvailableCurrencyEnum.USD);
  // Subscribe to deep link changes
  StreamSubscription _deepLinkSub;
  String _initialDeepLink; // If app hasn't loaded yet, store initial DL here

  // This map stashes pending process requests, this is because we need to update these requests
  // after a blocks_info with the balance after send, and sign the block
  Map<String, StateBlock> previousPendingMap = new Map();

  // Maps previous block requested to next block
  Map<String, StateBlock> pendingResponseBlockMap = new Map();

  // Maps all pending receives to previous blocks
  Map<String, StateBlock> pendingBlockMap = new Map();

  @override
  void initState() {
    super.initState();
    _registerBus();
    // Set currency locale here for the UI to access
    SharedPrefsUtil.inst.getCurrency(deviceLocale).then((currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersionString = "${packageInfo.appName} v${packageInfo.version}";        
      });
    });
    // Deep link subscription
    _deepLinkSub = getLinksStream().listen((String link) {
      if (link != null) {
        log.fine("deep link $link");
        if (wallet.loading) {
          _initialDeepLink = link;
        } else {
          Address address = Address(link);
          if (!address.isValid()) { return; }
          Future.delayed(Duration(milliseconds: 100), () {
            RxBus.post(DeepLinkAction(sendDestination: address.address, sendAmount: address.amount), tag: RX_DEEP_LINK_TAG);
          });
        }
      }
    }, onError: (e) {
      log.severe(e.toString());
    });
  }

  // Register RX event listeners
  void _registerBus() {
    RxBus.register<SubscribeResponse>(tag: RX_SUBSCRIBE_TAG).listen(handleSubscribeResponse);
    RxBus.register<AccountHistoryResponse>(tag: RX_HISTORY_TAG).listen((historyResponse) {
      setState(() {
        wallet.historyLoading = false;
        wallet.history = historyResponse.history;
      });
      AccountService.pop();
      AccountService.processQueue();
      requestPending();
    });
    RxBus.register<PriceResponse>(tag: RX_PRICE_RESP_TAG).listen((priceResponse) {
      // PriceResponse's get pushed periodically, it wasn't a request we made so don't pop the queue
      setState(() {
        wallet.nanoPrice = priceResponse.nanoPrice.toString();
        wallet.btcPrice = priceResponse.btcPrice.toString();
        wallet.localCurrencyPrice = priceResponse.price.toString();
      });
    });
    RxBus.register<BlocksInfoResponse>(tag: RX_BLOCKS_INFO_RESP_TAG).listen(handleBlocksInfoResponse);
    RxBus.register<ConnectionChanged>(tag: RX_CONN_STATUS_TAG).listen((status) {
      if (status == ConnectionChanged.CONNECTED) {
        requestUpdate();
      }
    });
    RxBus.register<CallbackResponse>(tag: RX_CALLBACK_TAG).listen(handleCallbackResponse);
    RxBus.register<ProcessResponse>(tag: RX_PROCESS_TAG).listen(handleProcessResponse);
    RxBus.register<PendingResponse>(tag: RX_PENDING_RESP_TAG).listen(handlePendingResponse);
  }

  @override
  void dispose() {
    _destroyBus();
    _deepLinkSub.cancel();
    super.dispose();
  }

  void _destroyBus() {
    RxBus.destroy(tag: RX_SUBSCRIBE_TAG);
    RxBus.destroy(tag: RX_HISTORY_TAG);
    RxBus.destroy(tag: RX_PRICE_RESP_TAG);
    RxBus.destroy(tag: RX_BLOCKS_INFO_RESP_TAG);
    RxBus.destroy(tag: RX_CALLBACK_TAG);
    RxBus.destroy(tag: RX_CONN_STATUS_TAG);
    RxBus.destroy(tag: RX_PROCESS_TAG);
    RxBus.destroy(tag: RX_PENDING_RESP_TAG);
  }

  // You can (and probably will) have methods on your StateContainer
  // These methods are then used through our your app to 
  // change state.
  // Using setState() here tells Flutter to repaint all the 
  // Widgets in the app that rely on the state you've changed.
  void updateWallet({address}) {
    if (wallet == null) {
      setState(() {
        wallet = new KaliumWallet(address: address, loading: true);
      });
      requestUpdate(address: address);
    } else {
      setState(() {
        wallet.address = address;
      });
      requestUpdate(address: address);
    }
  }

  ///
  /// When a STATE block comes back successfully with a hash
  ///
  /// @param processResponse Process Response
  ///
  void handleProcessResponse(ProcessResponse processResponse) {
    // see what type of request sent this response
    bool doUpdate = true;
    StateBlock previous = pendingResponseBlockMap.remove(processResponse.hash);
    if (previous != null) {
      if (previous.subType == BlockTypes.OPEN) {
        setState(() {
          wallet.frontier = processResponse.hash;
          wallet.blockCount = 1;
        });
      } else {
        setState(() {
          wallet.frontier = processResponse.hash;
          wallet.blockCount = wallet.blockCount + 1;
        });
        if (previous.subType == BlockTypes.SEND) {
          RxBus.post(previous, tag:RX_SEND_COMPLETE_TAG);
        } else if (previous.subType == BlockTypes.RECEIVE) {
          // Handle next receive if there is one
          StateBlock frontier = pendingBlockMap.remove(processResponse.hash);
          if (frontier != null && pendingBlockMap.length > 0) {
            StateBlock nextBlock = pendingBlockMap.remove(pendingBlockMap.keys.first);
            nextBlock.previous = frontier.hash;
            nextBlock.representative = frontier.representative;
            nextBlock.setBalance(frontier.balance);
            doUpdate = false;
            _getPrivKey().then((result) {
              nextBlock.sign(result);
              pendingBlockMap.putIfAbsent(nextBlock.hash, () => nextBlock);
              pendingResponseBlockMap.putIfAbsent(nextBlock.hash, () => nextBlock);
              AccountService.queueRequest(new ProcessRequest(block: json.encode(nextBlock.toJson())));
              AccountService.processQueue();
            });
          }
        } else if (previous.subType == BlockTypes.CHANGE) {
          RxBus.post(previous, tag:RX_REP_CHANGED_TAG);
        }
      }
    }
    if (doUpdate) {
      requestUpdate();
    } else {
      AccountService.processQueue();
    }
  }

  // Handle pending response
  void handlePendingResponse(PendingResponse response) {
    AccountService.pop();
    response.blocks.forEach((hash, pendingResponseItem) {
      PendingResponseItem pendingResponseItemN = pendingResponseItem;
      pendingResponseItemN.hash = hash;
      handlePendingItem(pendingResponseItemN);
    });
    if (response.blocks.length == 0) {
      AccountService.processQueue();
    }
  }

  /// Handle account_subscribe response
  void handleSubscribeResponse(SubscribeResponse response) {
    // Set currency locale here for the UI to access
    SharedPrefsUtil.inst.getCurrency(deviceLocale).then((currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    setState(() {
      wallet.loading = false;
      wallet.frontier = response.frontier;
      wallet.representative = response.representative;
      wallet.representativeBlock = response.representativeBlock;
      wallet.openBlock = response.openBlock;
      wallet.blockCount = response.blockCount;
      if (response.uuid != null) {
        SharedPrefsUtil.inst.setUuid(response.uuid).then((result) {
          wallet.uuid = response.uuid;
        });
      }
      if (response.balance == null) {
        wallet.accountBalance = BigInt.from(0);
      } else {
        wallet.accountBalance = BigInt.tryParse(response.balance);
      }
      wallet.localCurrencyPrice = response.price.toString();
      wallet.nanoPrice = response.nanoPrice.toString();
      wallet.btcPrice = response.btcPrice.toString();
    });
    AccountService.pop();
    AccountService.processQueue();
    // If this is first load, handle any deep links that may have opened the app
    _checkDeepLink(response);
  }

  void _checkDeepLink(SubscribeResponse resp) {
    try {
      if (_initialDeepLink == null) { return; }
      Address address = Address(_initialDeepLink);
      if (!address.isValid()) { return; }
      RxBus.post(DeepLinkAction(sendDestination: address.address, sendAmount: address.amount), tag: RX_DEEP_LINK_TAG);
    } catch (e) {
      log.severe(e.toString());
    }
  }
  
  /// Handle blocks_info response
  /// Typically, this preceeds a process request. And we want to update
  /// that request with data from the previous block (which is what we got from this request)
  void handleBlocksInfoResponse(BlocksInfoResponse resp) {
    String hash = resp.blocks.keys.first;
    StateBlock previousBlock = StateBlock.fromJson(json.decode(resp.blocks[hash].contents));
    StateBlock nextBlock = previousPendingMap.remove(hash);
    if (nextBlock == null) {
      return;
    }

    // Update data on our next pending request
    nextBlock.representative = previousBlock.representative;
    nextBlock.setBalance(previousBlock.balance);
    if (nextBlock.subType == BlockTypes.SEND && nextBlock.balance == "0") {
      // In case of a max send, go back and update sendAmount with the balance
      nextBlock.sendAmount = wallet.accountBalance.toString();      
    }
    _getPrivKey().then((result) {
      nextBlock.sign(result);
      pendingResponseBlockMap.putIfAbsent(nextBlock.hash, () => nextBlock);
      // If this is of type RECEIVE, update its data in our pending map
      if (nextBlock.subType == BlockTypes.RECEIVE) {
        StateBlock prevReceive = pendingBlockMap.remove(nextBlock.link);
        if (prevReceive != null) {
          print("put ${nextBlock.hash}");
          pendingBlockMap.putIfAbsent(nextBlock.hash, () => nextBlock);
        }
      }
      AccountService.pop();
      AccountService.queueRequest(new ProcessRequest(block: json.encode(nextBlock.toJson())));
      AccountService.processQueue();
    });
  }

  /// Handle callback response
  /// Typically this means we need to pocket transactions
  void handleCallbackResponse(CallbackResponse resp) {
    log.fine("Received callback ${json.encode(resp.toJson())}");
    if (resp.isSend != "true") {
      log.fine("Is not send");
      AccountService.processQueue();
      return;
    }
    PendingResponseItem pendingItem = PendingResponseItem(hash: resp.hash, source: resp.account, amount: resp.amount);
    handlePendingItem(pendingItem);
  }

  void handlePendingItem(PendingResponseItem item) {
    if (!AccountService.queueContainsRequestWithHash(item.hash) && !pendingBlockMap.containsKey(item.hash)) {
      if (wallet.openBlock == null && !AccountService.queueContainsOpenBlock()) {
        requestOpen("0", item.hash, item.amount);
      } else if (pendingBlockMap.length == 0) {
          requestReceive(wallet.frontier, item.hash, item.amount);
      } else {
        pendingBlockMap.putIfAbsent(item.hash, () {
          return StateBlock(
            subtype:BlockTypes.RECEIVE,
            previous: wallet.frontier,
            representative: wallet.representative,
            balance:item.amount,
            link:item.hash,
            account:wallet.address
          );
        });
      }
    }
  }

  void requestUpdate({String address}) {
    if (wallet != null && wallet.address != null) {
        if (address != null) {
          wallet.address = address;
        }
        SharedPrefsUtil.inst.getUuid().then((result) {
        AccountService.clearQueue();
        pendingBlockMap.clear();
        pendingResponseBlockMap.clear();
        previousPendingMap.clear();
        AccountService.queueRequest(new SubscribeRequest(account:wallet.address, currency:curCurrency.getIso4217Code(), uuid:result));
        AccountService.queueRequest(new AccountHistoryRequest(account: wallet.address, count: 10));
        AccountService.processQueue();
      }); 
    }
  }

  void requestSubscribe() {
    if (wallet != null && wallet.address != null) {
      SharedPrefsUtil.inst.getUuid().then((result) {
        AccountService.removeSubscribeHistoryPendingFromQueue();
        AccountService.queueRequest(new SubscribeRequest(account:wallet.address, currency:curCurrency.getIso4217Code(), uuid:result));
        AccountService.processQueue();
      });
    }
  }

  ///
  /// Request pending blocks
  /// 
  void requestPending() {
    if (wallet.address != null) {
      AccountService.queueRequest(new PendingRequest(account: wallet.address, count: max(wallet.blockCount ?? 0, 10)));
      AccountService.processQueue();
    }
  }

  ///
  /// Create a state block send request
  /// 
  /// @param previous - Previous Hash
  /// @param destination - Destination address
  /// @param amount - Amount to send in RAW
  /// 
  void requestSend(String previous, String destination, String amount) {
    String representative = wallet.representative;

    StateBlock sendBlock = new StateBlock(
      subtype:BlockTypes.SEND,
      previous: previous,
      representative: representative,
      balance:amount,
      link:destination,
      account:wallet.address
    );
    previousPendingMap.putIfAbsent(previous, () => sendBlock);

    AccountService.queueRequest(new BlocksInfoRequest(hashes: [previous]));
    AccountService.processQueue();
  }

  ///
  /// Create a state block receive request
  /// 
  /// @param previous - Previous Hash
  /// @param source - source address
  /// @param balance - balance in RAW
  /// 
  void requestReceive(String previous, String source, String balance) {
    String representative = wallet.representative;

    StateBlock receiveBlock = new StateBlock(
      subtype:BlockTypes.RECEIVE,
      previous: previous,
      representative: representative,
      balance:balance,
      link:source,
      account:wallet.address
    );
    previousPendingMap.putIfAbsent(previous, () => receiveBlock);
    pendingBlockMap.putIfAbsent(source, () => receiveBlock);

    AccountService.queueRequest(new BlocksInfoRequest(hashes: [previous]));
    AccountService.processQueue();
  }

  ///
  /// Create a state block open request
  /// 
  /// @param previous - Previous Hash
  /// @param source - source address
  /// @param balance - balance in RAW
  /// 
  void requestOpen(String previous, String source, String balance) {
    String representative = wallet.representative;

    StateBlock openBlock = new StateBlock(
      subtype:BlockTypes.OPEN,
      previous: previous,
      representative: representative,
      balance:balance,
      link:source,
      account:wallet.address
    );
    _getPrivKey().then((result) {
      openBlock.sign(result);
      pendingResponseBlockMap.putIfAbsent(openBlock.hash, () => openBlock);

      AccountService.queueRequest(ProcessRequest(block: json.encode(openBlock.toJson())));
      AccountService.processQueue();
    });
  }

  ///
  /// Create a state block change request
  /// 
  /// @param previous - Previous Hash
  /// @param balance - Current balance
  /// @param representative - New representative
  /// 
  void requestChange(String previous, String balance, String representative) {
    StateBlock changeBlock = new StateBlock(
      subtype:BlockTypes.CHANGE,
      previous: previous,
      representative: representative,
      balance:balance,
      link:"0000000000000000000000000000000000000000000000000000000000000000",
      account:wallet.address
    );
    _getPrivKey().then((result) {
      changeBlock.sign(result);
      pendingResponseBlockMap.putIfAbsent(changeBlock.hash, () => changeBlock);

      AccountService.queueRequest(ProcessRequest(block: json.encode(changeBlock.toJson())));
      AccountService.processQueue();
    });
  }

  void logOut() {
    setState(() {
      wallet = new KaliumWallet();
    });
    AccountService.clearQueue();
  }

  Future<String> _getPrivKey() async {
   return NanoUtil.seedToPrivate(await Vault.inst.getSeed(), 0);
  }

  // Simple build method that just passes this state through
  // your InheritedWidget
  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}
