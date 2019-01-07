import 'dart:convert';

import 'package:kalium_wallet_flutter/model/wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/model/state_block.dart';
import 'package:kalium_wallet_flutter/model/vault.dart';
import 'package:kalium_wallet_flutter/network/model/block_types.dart';
import 'package:kalium_wallet_flutter/network/model/request/account_history_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/blocks_info_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/process_request.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/blocks_info_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/process_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/price_response.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/nanoutil.dart';
import 'package:kalium_wallet_flutter/network/account_service.dart';

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

  StateContainer({
    @required this.child,
    this.wallet
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
  // Whichever properties you wanna pass around your app as state
  KaliumWallet wallet;

  // This map stashes pending process requests, this is because we need to update these requests
  // after a blocks_info with the balance after send, and sign the block
  Map<String, StateBlock> previousPendingMap = new Map();

  // Map for routing, if process response comes back with a hash in this map then
  // We'll retrieve the block from it and route to send complete
  Map<String, StateBlock> sendRequestMap = new Map();

  @override
  void initState() {
    super.initState();
    accountService.addListener(_onServerMessageReceived);
  }

  @override
  void dispose() {
    accountService.removeListener(_onServerMessageReceived);
    super.dispose();
  }

  void _onServerMessageReceived(message) {
    if (message is String && message == 'connected') {
      requestUpdate();
    } else if (message is SubscribeResponse) {
      handleSubscribeResponse(message);
    } else if (message is AccountHistoryResponse) {
      setState(() {
        wallet.historyLoading = false;
        wallet.history = message.history;
      });
    } else if (message is PriceResponse) {
      setState(() {
        wallet.nanoPrice = message.nanoPrice.toString();
        wallet.btcPrice = message.btcPrice.toString();
        wallet.localCurrencyPrice = message.price.toString();
      });
    } else if (message is BlocksInfoResponse) {
      handleBlocksInfoResponse(message);
    } else if (message is ProcessResponse) {

    }
  }

  // You can (and probably will) have methods on your StateContainer
  // These methods are then used through our your app to 
  // change state.
  // Using setState() here tells Flutter to repaint all the 
  // Widgets in the app that rely on the state you've changed.
  void updateWallet({address}) {
    if (wallet == null) {
      wallet = new KaliumWallet(address: address, loading: true);
      setState(() {
        address = address;
      });
    } else {
      setState(() {
        wallet.address = address ?? wallet.address;
      });
    }
  }

  /// Handle account_subscribe response
  void handleSubscribeResponse(SubscribeResponse response) {
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
    _getPrivKey().then((result) {
      nextBlock.sign(result);
      if (nextBlock.subType == BlockTypes.SEND) {
        sendRequestMap.putIfAbsent(nextBlock.hash, () => nextBlock);
      }
      accountService.queueRequest(new ProcessRequest(block: json.encode(nextBlock.toJson())));
      accountService.processQueue();
    });
  }

  void requestUpdate() {
    if (wallet != null && wallet.address != null) {
      SharedPrefsUtil.inst.getUuid().then((result) {
        accountService.queueRequest(new SubscribeRequest(account:wallet.address, currency:"USD", uuid:result));
        accountService.queueRequest(new AccountHistoryRequest(account: wallet.address, count: 10));
        accountService.processQueue();
      });
      //TODO currency
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
    // TODO - Allow user to set representative
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

    accountService.queueRequest(new BlocksInfoRequest(hashes: [previous]));
    accountService.processQueue();
  }

  void logOut() {
    wallet = new KaliumWallet();
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