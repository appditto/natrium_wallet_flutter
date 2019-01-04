// app_state_container.dart
import 'package:kalium_wallet_flutter/model/wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalium_wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:kalium_wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
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

class StateContainerState extends State<StateContainer> {
  // Whichever properties you wanna pass around your app as state
  KaliumWallet wallet;

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
    }
  }

  // You can (and probably will) have methods on your StateContainer
  // These methods are then used through our your app to 
  // change state.
  // Using setState() here tells Flutter to repaint all the 
  // Widgets in the app that rely on the state you've changed.
  void updateWallet({address}) {
    if (wallet == null) {
      wallet = new KaliumWallet(address: address);
      setState(() {
        address = address;
      });
    } else {
      setState(() {
        wallet.address = address ?? wallet.address;
      });
    }
  }

  void handleSubscribeResponse(SubscribeResponse response) {
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
      wallet.accountBalance = BigInt.from(-1);
    } else {
      wallet.accountBalance = BigInt.tryParse(response.balance);
    }
    wallet.localCurrencyPrice = response.price;
    wallet.nanoPrice = response.nanoPrice;
    wallet.btcPrice = response.btcPrice;
  }

  void requestUpdate() {
    if (wallet != null && wallet.address != null) {
      SharedPrefsUtil.inst.getUuid().then((result) {
        new SubscribeRequest(account:wallet.address, currency:"USD", uuid:result);
        accountService.queueRequest(new SubscribeRequest());
        accountService.processQueue();
      });
      //TODO currency
    }
  }

  void logOut() {
    wallet = new KaliumWallet();
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