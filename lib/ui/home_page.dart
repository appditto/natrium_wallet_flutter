import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/list_model.dart';
import 'package:kalium_wallet_flutter/model/state_block.dart';
import 'package:kalium_wallet_flutter/network/account_service.dart';
import 'package:kalium_wallet_flutter/network/model/block_types.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:kalium_wallet_flutter/ui/send/send_complete_sheet.dart';
import 'package:kalium_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:kalium_wallet_flutter/ui/settings/settings_sheet.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/kalium_drawer.dart';
import 'package:kalium_wallet_flutter/ui/widgets/kalium_scaffold.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';

class KaliumHomePage extends StatefulWidget {
  @override
  _KaliumHomePageState createState() => _KaliumHomePageState();
}

class _KaliumHomePageState extends State<KaliumHomePage>
    with WidgetsBindingObserver {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  var _scaffoldKey = new GlobalKey<KaliumScaffoldState>();

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  ListModel<AccountHistoryResponseItem> _historyList;

  KaliumReceiveSheet receive = new KaliumReceiveSheet();

  // Price conversion state (BTC, NANO, NONE)
  PriceConversion _priceConversion;
  TextStyle _convertedPriceStyle = KaliumStyles.TextStyleCurrencyAlt;

  // Timeeout for refresh
  StreamSubscription<dynamic> _refreshTimeout;

  @override
  void initState() {
    super.initState();
    _registerBus();
    WidgetsBinding.instance.addObserver(this);
    SharedPrefsUtil.inst.getPriceConversion().then((result) {
      _priceConversion = result;
    });
  }

  void _registerBus() {
    RxBus.register<AccountHistoryResponse>(tag: RX_HISTORY_HOME_TAG).listen((historyResponse) {
      diffAndUpdateHistoryList(historyResponse.history);
      if (_refreshTimeout != null) {
        _refreshTimeout.cancel();
      }
    });
    RxBus.register<StateBlock>(tag: RX_SEND_COMPLETE_TAG).listen((stateBlock) {
      // Route to send complete if received process response for send block
      if (stateBlock != null) {
        // Route to send complete
        String displayAmount = NumberUtil.getRawAsUsableString(stateBlock.sendAmount);
        KaliumSendCompleteSheet(displayAmount, stateBlock.link).mainBottomSheet(context);
        StateContainer.of(context).requestUpdate();
      }
    });
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _destroyBus() {
    RxBus.destroy(tag: RX_HISTORY_HOME_TAG);
    RxBus.destroy(tag: RX_PROCESS_TAG);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle websocket connection when app is in background
    // terminate it to be eco-friendly
    switch (state) {
      case AppLifecycleState.paused:
        accountService.reset();
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        accountService.initCommunication();
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return _buildTransactionCard(_historyList[index], animation, context);
  }

  // Return widget for list
  Widget _getListWidget(BuildContext context) {
    if (StateContainer.of(context).wallet.historyLoading) {
      // Loading Animation
      return Center(
        child: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1),
          //Widgth/Height ratio is needed because BoxFit is not working as expected
          width: double.infinity,
          height: MediaQuery.of(context).size.width,
          child: FlareActor("assets/loading_animation.flr",
              animation: "main", fit: BoxFit.contain),
        ),
      );
    } else if (StateContainer.of(context).wallet.history.length == 0) {
      return RefreshIndicator(
        child: ListView(
          padding: EdgeInsets.fromLTRB(0, 5.0, 0, 15.0),
          children: <Widget>[
            _buildWelcomeTransactionCard(),
            _buildDummyTransactionCard(
                "Sent", "A little", "to a random monkey", context),
            _buildDummyTransactionCard(
                "Received", "A lot of", "from a random monkey", context),
          ],
        ),
        onRefresh: _refresh,
      );
    }
    // Setup history list
    if (_historyList == null) {
      setState(() {
        _historyList = ListModel<AccountHistoryResponseItem>(
          listKey: _listKey,
          initialItems: StateContainer.of(context).wallet.history,
        );
      });
    }
    return RefreshIndicator(
      child: AnimatedList(
        key: _listKey,
        padding: EdgeInsets.fromLTRB(0, 5.0, 0, 15.0),
        initialItemCount: _historyList.length,
        itemBuilder: _buildItem,
      ),
      onRefresh: _refresh,
    );
  }

  // Refresh list
  Future<void> _refresh() async {
    StateContainer.of(context).requestUpdate();
    // TODO figure out how to cancel this future when the server responds with
    await Future.delayed(new Duration(seconds: 1), () { });
  }

  ///
  /// Because there's nothing convenient like DiffUtil, some manual logic
  /// to determine the differences between two lists and to add new items.
  ///
  /// Depends on == being overriden in the AccountHistoryResponseItem class
  ///
  /// Required to do it this way for the animation
  ///
  void diffAndUpdateHistoryList(List<AccountHistoryResponseItem> newList) {
    if (newList == null || newList.length == 0 || _historyList == null) return;
    var reversedNew = newList.reversed;
    var currentList = _historyList.items;

    reversedNew.forEach((item) {
      if (!currentList.contains(item)) {
        setState(() {
          _historyList.insertAtTop(item);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return KaliumScaffold(
      key: _scaffoldKey,
      backgroundColor: KaliumColors.background,
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: KaliumDrawer(
          child: SettingsSheet(),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Main Card
          _buildMainCard(context, _scaffoldKey),
          //Main Card End

          //Transactions Text
          Container(
            margin: EdgeInsets.fromLTRB(30.0, 20.0, 26.0, 0.0),
            child: Row(
              children: <Widget>[
                Text(
                  "TRANSACTIONS",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w100,
                    color: KaliumColors.text,
                  ),
                ),
              ],
            ),
          ), //Transactions Text End

          //Transactions List
          Expanded(
            child: Stack(
              children: <Widget>[
                _getListWidget(context),
                //List Top Gradient End
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 10.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          KaliumColors.background00,
                          KaliumColors.background
                        ],
                        begin: Alignment(0.5, 1.0),
                        end: Alignment(0.5, -1.0),
                      ),
                    ),
                  ),
                ), // List Top Gradient End

                //List Bottom Gradient
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 30.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          KaliumColors.background00,
                          KaliumColors.background
                        ],
                        begin: Alignment(0.5, -1),
                        end: Alignment(0.5, 0.5),
                      ),
                    ),
                  ),
                ), //List Bottom Gradient End
              ],
            ),
          ), //Transactions List End

          //Buttons Area
          Container(
            color: KaliumColors.background,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(14.0, 0.0, 7.0,
                        MediaQuery.of(context).size.height * 0.035),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      color: KaliumColors.primary,
                      child: Text('Receive',
                          textAlign: TextAlign.center,
                          style: KaliumStyles.TextStyleButtonPrimary),
                      padding:
                          EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
                      onPressed: () => receive.mainBottomSheet(context),
                      highlightColor: KaliumColors.background40,
                      splashColor: KaliumColors.background40,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(7.0, 0.0, 14.0,
                        MediaQuery.of(context).size.height * 0.035),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      color: KaliumColors.primary,
                      child: Text('Send',
                          textAlign: TextAlign.center,
                          style: KaliumStyles.TextStyleButtonPrimary),
                      padding:
                          EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
                      onPressed: () =>
                          KaliumSendSheet().mainBottomSheet(context),
                      highlightColor: KaliumColors.background40,
                      splashColor: KaliumColors.background40,
                    ),
                  ),
                ),
              ],
            ),
          ), //Buttons Area End
        ],
      ),
    );
  }

// Transaction Card/List Item
  Widget _buildTransactionCard(AccountHistoryResponseItem item,
      Animation<double> animation, BuildContext context) {
    TransactionDetailsSheet transactionDetails =
        TransactionDetailsSheet(item.hash, item.account);
    String text;
    IconData icon;
    Color iconColor;
    if (item.type == BlockTypes.SEND) {
      text = "Sent";
      icon = KaliumIcons.sent;
      iconColor = KaliumColors.text60;
    } else {
      text = "Received";
      icon = KaliumIcons.received;
      iconColor = KaliumColors.primary60;
    }
    return SizeTransition(
      axis: Axis.vertical,
      axisAlignment: -1.0,
      sizeFactor: animation,
      child: Container(
        margin: EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
        decoration: BoxDecoration(
          color: KaliumColors.backgroundDark,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: FlatButton(
          highlightColor: KaliumColors.text15,
          splashColor: KaliumColors.text15,
          color: KaliumColors.backgroundDark,
          padding: EdgeInsets.all(0.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          onPressed: () => transactionDetails.mainBottomSheet(context),
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(right: 16.0),
                          child: Icon(icon, color: iconColor, size: 20)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            text,
                            textAlign: TextAlign.left,
                            style: KaliumStyles.TextStyleTransactionType,
                          ),
                          RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: item.getFormattedAmount(),
                                  style:
                                      KaliumStyles.TextStyleTransactionAmount,
                                ),
                                TextSpan(
                                  text: " BAN",
                                  style: KaliumStyles.TextStyleTransactionUnit,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    item.getShortString(),
                    textAlign: TextAlign.right,
                    style: KaliumStyles.TextStyleTransactionAddress,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  } //Transaction Card End

  // Dummy Transaction Card
  Widget _buildDummyTransactionCard(
      String type, String amount, String address, BuildContext context) {
    String text;
    IconData icon;
    Color iconColor;
    if (type == "Sent") {
      text = "Sent";
      icon = KaliumIcons.sent;
      iconColor = KaliumColors.text60;
    } else {
      text = "Received";
      icon = KaliumIcons.received;
      iconColor = KaliumColors.primary60;
    }
    return Container(
      margin: EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: KaliumColors.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: FlatButton(
        onPressed: () {
          return null;
        },
        highlightColor: KaliumColors.text15,
        splashColor: KaliumColors.text15,
        color: KaliumColors.backgroundDark,
        padding: EdgeInsets.all(0.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(right: 16.0),
                        child: Icon(icon, color: iconColor, size: 20)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          text,
                          textAlign: TextAlign.left,
                          style: KaliumStyles.TextStyleTransactionType,
                        ),
                        RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            text: '',
                            children: [
                              TextSpan(
                                text: amount,
                                style: KaliumStyles.TextStyleTransactionAmount,
                              ),
                              TextSpan(
                                text: " BAN",
                                style: KaliumStyles.TextStyleTransactionUnit,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  address,
                  textAlign: TextAlign.right,
                  style: KaliumStyles.TextStyleTransactionAddress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //Dummy Transaction Card End

  // Welcome Card
  Widget _buildWelcomeTransactionCard() {
    return Container(
      margin: EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: KaliumColors.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0)),
                color: KaliumColors.primary,
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                        text: "Welcome to Kalium. Once you receive ",
                        style: KaliumStyles.TextStyleTransactionWelcome,
                      ),
                      TextSpan(
                        text: "BANANO",
                        style: KaliumStyles.TextStyleTransactionWelcomePrimary,
                      ),
                      TextSpan(
                        text: ", transactions will show up like below.",
                        style: KaliumStyles.TextStyleTransactionWelcome,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
                color: KaliumColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

//Main Card
  Widget _buildMainCard(BuildContext context, _scaffoldKey) {
    return Container(
      decoration: BoxDecoration(
        color: KaliumColors.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.05,
          left: 14.0,
          right: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 90.0,
            height: 120.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 5, left: 5),
                  height: 50,
                  width: 50,
                  child: FlatButton(
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      padding: EdgeInsets.all(0.0),
                      child: Icon(KaliumIcons.settings,
                          color: KaliumColors.text, size: 24)),
                ),
              ],
            ),
          ),
          _getBalanceWidget(context),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/monkey.png'),
              ),
            ),
            width: 90.0,
            height: 90.0,
          ),
        ],
      ),
    );
  } //Main Card

  // Get balance display
  Widget _getBalanceWidget(BuildContext context) {
    if (StateContainer.of(context).wallet.loading) {
      return Container(
          child: Icon(KaliumIcons.bananologo,
              color: KaliumColors.primary, size: 40));
    }
    return Container(
      child: GestureDetector(
        onTap: () {
          if (_priceConversion == PriceConversion.BTC) {
            // Cycle to NANO price
            setState(() {
              _convertedPriceStyle = KaliumStyles.TextStyleCurrencyAlt;
              _priceConversion = PriceConversion.NANO;
            });
            SharedPrefsUtil.inst.setPriceConversion(PriceConversion.NANO);
          } else if (_priceConversion == PriceConversion.NANO) {
            // Hide prices
            setState(() {
              _convertedPriceStyle = KaliumStyles.TextStyleCurrencyAltHidden;
              _priceConversion = PriceConversion.NONE;
            });
            SharedPrefsUtil.inst.setPriceConversion(PriceConversion.NONE);
          } else {
            // Cycle to BTC price
            setState(() {
              _convertedPriceStyle = KaliumStyles.TextStyleCurrencyAlt;
              _priceConversion = PriceConversion.BTC;
            });
            SharedPrefsUtil.inst.setPriceConversion(PriceConversion.BTC);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 5.0),
              child: Text(StateContainer.of(context).wallet.localCurrencyPrice,
                  textAlign: TextAlign.center, style: _convertedPriceStyle),
            ),
            Row(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(right: 5.0),
                    child: Icon(KaliumIcons.bananocurrency,
                        color: KaliumColors.primary, size: 20)),
                Container(
                  margin: EdgeInsets.only(right: 15.0),
                  child: Text(
                      StateContainer.of(context)
                          .wallet
                          .getAccountBalanceDisplay(),
                      textAlign: TextAlign.center,
                      style: KaliumStyles.TextStyleCurrency),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                    child: Icon(_priceConversion == PriceConversion.BTC
                            ? KaliumIcons.btc
                            : KaliumIcons.nanocurrency,
                        color: _priceConversion == PriceConversion.NONE
                            ? Colors.transparent
                            : KaliumColors.text60,
                        size: 14)),
                Text(
                    _priceConversion == PriceConversion.BTC
                        ? StateContainer.of(context).wallet.btcPrice
                        : StateContainer.of(context).wallet.nanoPrice,
                    textAlign: TextAlign.center,
                    style: _convertedPriceStyle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionDetailsSheet {
  String _hash;
  String _address;
  TransactionDetailsSheet(String hash, String address)
      : _hash = hash,
        _address = address;
  // Address copied items
  // Initial constants
  static const String _copyAddress = 'Copy Address';
  static const String _addressCopied = 'Address Copied';
  static const TextStyle _copyButtonStyleInitial =
      KaliumStyles.TextStyleButtonPrimary;
  static const Color _copyButtonColorInitial = KaliumColors.primary;
  // Current state references
  String _copyButtonText;
  TextStyle _copyButtonStyle;
  Color _copyButtonBackground;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  mainBottomSheet(BuildContext context) {
    // Set initial state of copy button
    _copyButtonText = _copyAddress;
    _copyButtonStyle = _copyButtonStyleInitial;
    _copyButtonBackground = _copyButtonColorInitial;

    KaliumSheets.showKaliumHeightEightSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          // TODO move copy address stuff to a re-usable builder function
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(
                                  Dimens.BUTTON_TOP_EXCEPTION_DIMENS[0],
                                  Dimens.BUTTON_TOP_EXCEPTION_DIMENS[1],
                                  Dimens.BUTTON_TOP_EXCEPTION_DIMENS[2],
                                  Dimens.BUTTON_TOP_EXCEPTION_DIMENS[3]),
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100.0)),
                                color: _copyButtonBackground,
                                child: Text(_copyButtonText,
                                    textAlign: TextAlign.center,
                                    style: _copyButtonStyle),
                                padding: EdgeInsets.symmetric(
                                    vertical: 14.0, horizontal: 20),
                                onPressed: () {
                                  Clipboard.setData(
                                      new ClipboardData(text: _address));
                                  setState(() {
                                    // Set copied style
                                    _copyButtonText = _addressCopied;
                                    _copyButtonStyle = KaliumStyles
                                        .TextStyleButtonPrimaryGreen;
                                    _copyButtonBackground = KaliumColors.green;
                                    if (_addressCopiedTimer != null) {
                                      _addressCopiedTimer.cancel();
                                    }
                                    _addressCopiedTimer = new Timer(
                                        const Duration(milliseconds: 800), () {
                                      setState(() {
                                        _copyButtonText = _copyAddress;
                                        _copyButtonStyle =
                                            _copyButtonStyleInitial;
                                        _copyButtonBackground =
                                            _copyButtonColorInitial;
                                      });
                                    });
                                  });
                                },
                                highlightColor: KaliumColors.success30,
                                splashColor: KaliumColors.successDark,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY_OUTLINE,
                              'View Details',
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return UIUtil.showBlockExplorerWebview(_hash);
                            }));
                          }),
                        ],
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
