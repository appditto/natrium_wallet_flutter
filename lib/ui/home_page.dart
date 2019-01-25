import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/localization.dart';
import 'package:kalium_wallet_flutter/model/list_model.dart';
import 'package:kalium_wallet_flutter/model/deep_link_action.dart';
import 'package:kalium_wallet_flutter/model/state_block.dart';
import 'package:kalium_wallet_flutter/model/db/contact.dart';
import 'package:kalium_wallet_flutter/model/db/kaliumdb.dart';
import 'package:kalium_wallet_flutter/network/model/block_types.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/error_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/contacts/add_contact.dart';
import 'package:kalium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:kalium_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:kalium_wallet_flutter/ui/send/send_complete_sheet.dart';
import 'package:kalium_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:kalium_wallet_flutter/ui/settings/settings_drawer.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/kalium_drawer.dart';
import 'package:kalium_wallet_flutter/ui/widgets/kalium_scaffold.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:kalium_wallet_flutter/ui/widgets/reactive_refresh.dart';
import 'package:kalium_wallet_flutter/ui/util/ui_util.dart';
import 'package:kalium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';
import 'package:kalium_wallet_flutter/util/fileutil.dart';
import 'package:kalium_wallet_flutter/util/hapticutil.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';

class KaliumHomePage extends StatefulWidget {
  @override
  _KaliumHomePageState createState() => _KaliumHomePageState();
}

class _KaliumHomePageState extends State<KaliumHomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final GlobalKey<KaliumScaffoldState> _scaffoldKey = new GlobalKey<KaliumScaffoldState>();

  // Controller for placeholder card animations
  AnimationController _placeholderCardAnimationController;
  Animation<double> _opacityAnimation;
  bool _animationDisposed;

  // Receive card instance
  KaliumReceiveSheet receive;

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  ListModel<AccountHistoryResponseItem> _historyList;

  // monKey widget
  Widget _monKey;
  Widget _largeMonKey;
  bool _monkeyOverlayOpen = false;
  bool _monkeyDownloadTriggered = false;
  // List of contacts (Store it so we only have to query the DB once for transaction cards)
  List<Contact> _contacts = List();

  // Price conversion state (BTC, NANO, NONE)
  PriceConversion _priceConversion;
  TextStyle _convertedPriceStyle = KaliumStyles.TextStyleCurrencyAlt;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _registerBus();
    _monKey = SizedBox();
    WidgetsBinding.instance.addObserver(this);
    SharedPrefsUtil.inst.getPriceConversion().then((result) {
      _priceConversion = result;
    });
    _addSampleContact();
    _updateContacts();
    _monkeyDownloadTriggered = false;
    // Setup placeholder animation and start
    _animationDisposed = false;
    _placeholderCardAnimationController = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _placeholderCardAnimationController.addListener(_animationControllerListener);
    _opacityAnimation =
        new Tween(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    _opacityAnimation.addStatusListener(_animationStatusListener);
    _placeholderCardAnimationController.forward();
  }

  void _animationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        _placeholderCardAnimationController.forward();
        break;
      case AnimationStatus.completed:
        _placeholderCardAnimationController.reverse();
        break;
      default:
        return null;
    }    
  }

  void _animationControllerListener() {
    setState(() {});
  }

  void _disposeAnimation() {
    if (!_animationDisposed) {
      _animationDisposed = true;
      _opacityAnimation.removeStatusListener(_animationStatusListener);
      _placeholderCardAnimationController.removeListener(_animationControllerListener);
      _placeholderCardAnimationController.stop();
    }
  }

  /// Add donations contact if it hasnt already been added
  Future<void> _addSampleContact() async {
    bool contactAdded = await SharedPrefsUtil.inst.getFirstContactAdded();
    if (!contactAdded) {
      DBHelper db = DBHelper();
      bool addressExists = await db.contactExistsWithAddress(
          "ban_1ka1ium4pfue3uxtntqsrib8mumxgazsjf58gidh1xeo5te3whsq8z476goo");
      if (addressExists) {
        return;
      }
      bool nameExists = await db.contactExistsWithName("@KaliumDonations");
      if (nameExists) {
        return;
      }
      await SharedPrefsUtil.inst.setFirstContactAdded(true);
      Contact c = Contact(
          name: "@KaliumDonations",
          address:
              "ban_1ka1ium4pfue3uxtntqsrib8mumxgazsjf58gidh1xeo5te3whsq8z476goo");
      await db.saveContact(c);
    }
  }

  void _updateContacts() {
    DBHelper().getContacts().then((contacts) {
      setState(() {
        _contacts = contacts;
      });
    });
  }

  void _registerBus() {
    RxBus.register<AccountHistoryResponse>(tag: RX_HISTORY_HOME_TAG)
        .listen((historyResponse) {
      diffAndUpdateHistoryList(historyResponse.history);
      setState(() {
        _isRefreshing = false;
      });  
    });
    RxBus.register<StateBlock>(tag: RX_SEND_COMPLETE_TAG).listen((stateBlock) {
      // Route to send complete if received process response for send block
      if (stateBlock != null) {
        // Route to send complete
        String displayAmount =
            NumberUtil.getRawAsUsableString(stateBlock.sendAmount);
        DBHelper().getContactWithAddress(stateBlock.link).then((contact) {
          String contactName = contact == null ? null : contact.name;
          Navigator.of(context).popUntil(ModalRoute.withName('/home'));
          KaliumSendCompleteSheet(displayAmount, stateBlock.link, contactName)
              .mainBottomSheet(context);
        });
      }
    });
    RxBus.register<StateBlock>(tag: RX_REP_CHANGED_TAG).listen((stateBlock) {
      if (stateBlock != null) {
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
        StateContainer.of(context).wallet.representative =
            stateBlock.representative;
        UIUtil.showSnackbar(KaliumLocalization.of(context).changeRepSucces, context);
      }
    });
    RxBus.register<Contact>(tag: RX_CONTACT_MODIFIED_TAG).listen((contact) {
      _updateContacts();
    });
    RxBus.register<Contact>(tag: RX_CONTACT_ADDED_ALT_TAG).listen((contact) {
      UIUtil.showSnackbar(KaliumLocalization.of(context).contactAdded.replaceAll("%1", contact.name), context);
    });
    RxBus.register<bool>(tag: RX_MONKEY_OVERLAY_CLOSED_TAG).listen((result) {
      Future.delayed(Duration(milliseconds: 150), () {
        setState(() {
          _monkeyOverlayOpen = false;
        });
      });
    });
    RxBus.register<DeepLinkAction>(tag: RX_DEEP_LINK_TAG).listen((result) {
      print("RECEIVED deep linke action ${result.sendDestination}");
      String amount;
      String contactName;
      if (result.sendAmount != null) {
        // Require minimum 1 BANOSHI to send
        if (BigInt.parse(result.sendAmount) >= BigInt.from(10).pow(27)) {
          amount = result.sendAmount;
        }
      }
      // See if a contact
      DBHelper().getContactWithAddress(result.sendDestination).then((contact) {
        if (contact != null) {
          contactName = contact.name;
        }
        // Remove any other screens from stack
        Navigator.of(context).popUntil(ModalRoute.withName('/home'));
        if (amount != null) {
          // Go to send confirm with amount
          KaliumSendConfirmSheet(
                  NumberUtil.getRawAsUsableString(amount).replaceAll(",", ""),
                  result.sendDestination,
                  contactName: contactName)
              .mainBottomSheet(context);
        } else {
          // Go to send with address
          KaliumSendSheet(contact: contact, address: result.sendDestination)
              .mainBottomSheet(context);
        }
      });
    });
    RxBus.register<ErrorResponse>(tag: RX_SEND_FAILED_TAG).listen((result) {
      // Send failed, close send screens and display error
      Navigator.of(context).popUntil(ModalRoute.withName('/home'));
      UIUtil.showSnackbar(KaliumLocalization.of(context).sendError, context);
    });
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
    _placeholderCardAnimationController.dispose();
    super.dispose();
  }

  void _destroyBus() {
    RxBus.destroy(tag: RX_HISTORY_HOME_TAG);
    RxBus.destroy(tag: RX_PROCESS_TAG);
    RxBus.destroy(tag: RX_CONTACT_MODIFIED_TAG);
    RxBus.destroy(tag: RX_CONTACT_ADDED_ALT_TAG);
    RxBus.destroy(tag: RX_MONKEY_OVERLAY_CLOSED_TAG);
    RxBus.destroy(tag: RX_DEEP_LINK_TAG);
    RxBus.destroy(tag: RX_REP_CHANGED_TAG);
    RxBus.destroy(tag: RX_SEND_FAILED_TAG);
    RxBus.destroy(tag: RX_SEND_COMPLETE_TAG);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle websocket connection when app is in background
    // terminate it to be eco-friendly
    switch (state) {
      case AppLifecycleState.paused:
        _destroyBus();
        StateContainer.of(context).disconnect();
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        _registerBus();
        StateContainer.of(context).reconnect();
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
    String displayName = smallScreen(context)
        ? _historyList[index].getShorterString()
        : _historyList[index].getShortString();
    _contacts.forEach((contact) {
      if (contact.address == _historyList[index].account) {
        displayName = contact.name;
      }
    });
    return _buildTransactionCard(
        _historyList[index], animation, displayName, context);
  }

  // Return widget for list
  Widget _getListWidget(BuildContext context) {
    if (StateContainer.of(context).wallet.historyLoading) {
      // Loading Animation
      return ListView(
        padding: EdgeInsets.fromLTRB(0, 5.0, 0, 15.0),
        children: <Widget>[
          _buildLoadingTransactionCard(
              "Sent", "10244000", "123456789121234", context),
          _buildLoadingTransactionCard(
              "Received", "100,00000", "@bbedwards1234", context),
          _buildLoadingTransactionCard(
              "Sent", "14500000", "12345678912345671234", context),
          _buildLoadingTransactionCard(
              "Sent", "12,51200", "123456789121234", context),
          _buildLoadingTransactionCard(
              "Received", "1,45300", "123456789121234", context),
          _buildLoadingTransactionCard(
              "Sent", "100,00000", "12345678912345671234", context),
          _buildLoadingTransactionCard(
              "Received", "24,00000", "12345678912345671234", context),
          _buildLoadingTransactionCard(
              "Sent", "1,00000", "123456789121234", context),
        ],
      );
    } else if (StateContainer.of(context).wallet.history.length == 0) {
      _disposeAnimation();
      return ReactiveRefreshIndicator(
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
        isRefreshing: _isRefreshing,
      );
    } else {
      _disposeAnimation();
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
    return ReactiveRefreshIndicator(
      child: AnimatedList(
        key: _listKey,
        padding: EdgeInsets.fromLTRB(0, 5.0, 0, 15.0),
        initialItemCount: _historyList.length,
        itemBuilder: _buildItem,
      ),
      onRefresh: _refresh,
      isRefreshing: _isRefreshing,
    );
  }

  // Refresh list
  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });
    HapticUtil.success();
    StateContainer.of(context).requestUpdate();
    // Hide refresh indicator after 3 seconds if no server response
    Future.delayed(new Duration(seconds: 3), () {
      setState(() {
        _isRefreshing = false;
      });   
    });
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
    // Get items not in current list, and add them from top-down
    newList.reversed.where((item) => !_historyList.items.contains(item)).forEach((historyItem) {
      setState(() {
        _historyList.insertAtTop(historyItem);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (receive == null) {
      QrPainter painter = QrPainter(
        data: StateContainer.of(context).wallet.address,
        version: 6,
        errorCorrectionLevel: QrErrorCorrectLevel.Q,
      );
      painter.toImageData(MediaQuery.of(context).size.width).then((byteData) {
        setState(() {
          receive = KaliumReceiveSheet(Container(
              width: MediaQuery.of(context).size.width / 3.13,
              child: Image.memory(byteData.buffer.asUint8List())));
        });
      });
    }
    // Download/Retrieve smaller and large monKeys
    if (!_monkeyDownloadTriggered) {
      _monkeyDownloadTriggered = true;
      UIUtil.downloadOrRetrieveMonkey(context,
              StateContainer.of(context).wallet.address, MonkeySize.HOME_SMALL)
          .then((result) {
        if (result != null) {
          FileUtil.pngHasValidSignature(result).then((valid) {
            if (valid) {
              setState(() {
                _monKey = Image.file(result);
              });
            }
          });
        }
      });
      UIUtil.downloadOrRetrieveMonkey(context,
              StateContainer.of(context).wallet.address, MonkeySize.LARGE)
          .then((result) {
        if (result != null) {
          FileUtil.pngHasValidSignature(result).then((valid) {
            if (valid) {
              setState(() {
                _largeMonKey = Image.file(result);
              });
            }
          });
        }
      });
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent));
    return KaliumScaffold(
      key: _scaffoldKey,
      backgroundColor: KaliumColors.background,
      drawer: SizedBox(
        width: UIUtil.drawerWidth(context),
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
                  KaliumLocalization.of(context).transactions.toUpperCase(),
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
                      color: receive != null
                          ? KaliumColors.primary
                          : KaliumColors.primary60,
                      child: Text(KaliumLocalization.of(context).receive,
                          textAlign: TextAlign.center,
                          style: KaliumStyles.TextStyleButtonPrimary),
                      padding:
                          EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
                      onPressed: () {
                        if (receive == null) {
                          return;
                        }
                        receive.mainBottomSheet(context);
                      },
                      highlightColor: receive != null
                          ? KaliumColors.background40
                          : Colors.transparent,
                      splashColor: receive != null
                          ? KaliumColors.background40
                          : Colors.transparent,
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
                      color: StateContainer.of(context).wallet.accountBalance >
                              BigInt.zero
                          ? KaliumColors.primary
                          : KaliumColors.primary60,
                      child: Text(KaliumLocalization.of(context).send,
                          textAlign: TextAlign.center,
                          style: KaliumStyles.TextStyleButtonPrimary),
                      padding:
                          EdgeInsets.symmetric(vertical: 14.0, horizontal: 20),
                      onPressed: () {
                        if (StateContainer.of(context).wallet.accountBalance >
                            BigInt.zero) {
                          KaliumSendSheet().mainBottomSheet(context);
                        }
                      },
                      highlightColor:
                          StateContainer.of(context).wallet.accountBalance >
                                  BigInt.zero
                              ? KaliumColors.background40
                              : Colors.transparent,
                      splashColor:
                          StateContainer.of(context).wallet.accountBalance >
                                  BigInt.zero
                              ? KaliumColors.background40
                              : Colors.transparent,
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
      Animation<double> animation, String displayName, BuildContext context) {
    TransactionDetailsSheet transactionDetails =
        TransactionDetailsSheet(item.hash, item.account, displayName);
    String text;
    IconData icon;
    Color iconColor;
    if (item.type == BlockTypes.SEND) {
      text = KaliumLocalization.of(context).sent;
      icon = KaliumIcons.sent;
      iconColor = KaliumColors.text60;
    } else {
      text = KaliumLocalization.of(context).received;
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
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Column(
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
                                    style:
                                        KaliumStyles.TextStyleTransactionUnit,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2.4,
                    child: Text(
                      displayName,
                      textAlign: TextAlign.right,
                      style: KaliumStyles.TextStyleTransactionAddress,
                    ),
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
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
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
                    ),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Text(
                    address,
                    textAlign: TextAlign.right,
                    style: KaliumStyles.TextStyleTransactionAddress,
                  ),
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

  // Dummy Transaction Card
  Widget _buildLoadingTransactionCard(
      String type, String amount, String address, BuildContext context) {
    String text;
    IconData icon;
    Color iconColor;
    if (type == "Sent") {
      text = "Senttt";
      icon = KaliumIcons.dotfilled;
      iconColor = KaliumColors.text20;
    } else {
      text = "Receiveddd";
      icon = KaliumIcons.dotfilled;
      iconColor = KaliumColors.primary20;
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
                    // Transaction Icon
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                          margin: EdgeInsets.only(right: 16.0),
                          child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Transaction Type Text
                          Container(
                            child: Stack(
                              alignment: AlignmentDirectional(-1, 0),
                              children: <Widget>[
                                Text(
                                  text,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: "NunitoSans",
                                    fontSize: KaliumFontSizes.small,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.transparent,
                                  ),
                                ),
                                Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: KaliumColors.text45,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      text,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: "NunitoSans",
                                        fontSize: KaliumFontSizes.small - 4,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Amount Text
                          Container(
                            child: Stack(
                              alignment: AlignmentDirectional(-1, 0),
                              children: <Widget>[
                                Text(
                                  amount,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontFamily: "NunitoSans",
                                      color: Colors.transparent,
                                      fontSize: KaliumFontSizes.smallest,
                                      fontWeight: FontWeight.w600),
                                ),
                                Opacity(
                                  opacity: _opacityAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: KaliumColors.primary20,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      amount,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontFamily: "NunitoSans",
                                          color: Colors.transparent,
                                          fontSize:
                                              KaliumFontSizes.smallest - 3,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Address Text
                Container(
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        child: Stack(
                          alignment: AlignmentDirectional(1, 0),
                          children: <Widget>[
                            Text(
                              address,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: KaliumFontSizes.smallest,
                                fontFamily: 'OverpassMono',
                                fontWeight: FontWeight.w100,
                                color: Colors.transparent,
                              ),
                            ),
                            Opacity(
                              opacity: _opacityAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: KaliumColors.text20,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  address,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: KaliumFontSizes.smallest - 3,
                                    fontFamily: 'OverpassMono',
                                    fontWeight: FontWeight.w100,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //Dummy Transaction Card End

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
            width: 90.0,
            height: 90.0,
            child: FlatButton(
                child: _monkeyOverlayOpen
                    ? SizedBox()
                    : Stack(children: <Widget>[
                        Container(width: 80, height: 80, child: _largeMonKey),
                        Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            color: KaliumColors.backgroundDark,
                          ),
                        ),
                        _monKey
                      ]),
                padding: EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0)),
                onPressed: () {
                  if (_monkeyOverlayOpen || _largeMonKey == null) {
                    return;
                  }
                  setState(() {
                    _monkeyOverlayOpen = true;
                  });
                  Navigator.of(context).push(MonkeyOverlay(_largeMonKey));
                }),
          ),
        ],
      ),
    );
  } //Main Card

  // Get balance display
  Widget _getBalanceWidget(BuildContext context) {
    if (StateContainer.of(context).wallet.loading) {
      // Placeholder for balance text
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Stack(
              alignment: AlignmentDirectional(0, 0),
              children: <Widget>[
                Text(
                  "1234567",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "NunitoSans",
                      fontSize: KaliumFontSizes.small,
                      fontWeight: FontWeight.w600,
                      color: Colors.transparent),
                ),
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: KaliumColors.text20,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "1234567",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "NunitoSans",
                          fontSize: KaliumFontSizes.small - 3,
                          fontWeight: FontWeight.w600,
                          color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 225),
            child: Stack(
              alignment: AlignmentDirectional(0, 0),
              children: <Widget>[
                AutoSizeText(
                  "1234567",
                  style: TextStyle(
                      fontFamily: "NunitoSans",
                      fontSize: KaliumFontSizes.largestc,
                      fontWeight: FontWeight.w900,
                      color: Colors.transparent),
                  maxLines: 1,
                  stepGranularity: 0.1,
                  minFontSize: 1,
                ),
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: KaliumColors.primary60,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: AutoSizeText(
                      "1234567",
                      style: TextStyle(
                          fontFamily: "NunitoSans",
                          fontSize: KaliumFontSizes.largestc - 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.transparent),
                      maxLines: 1,
                      stepGranularity: 0.1,
                      minFontSize: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Stack(
              alignment: AlignmentDirectional(0, 0),
              children: <Widget>[
                Text(
                  "1234567",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "NunitoSans",
                      fontSize: KaliumFontSizes.small,
                      fontWeight: FontWeight.w600,
                      color: Colors.transparent),
                ),
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: KaliumColors.text20,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      "1234567",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "NunitoSans",
                          fontSize: KaliumFontSizes.small - 3,
                          fontWeight: FontWeight.w600,
                          color: Colors.transparent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return GestureDetector(
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
              StateContainer.of(context).wallet.getLocalCurrencyPrice(
                  locale: StateContainer.of(context).currencyLocale),
              textAlign: TextAlign.center,
              style: _convertedPriceStyle),
          Container(
            margin: EdgeInsets.only(right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 225),
                  child: AutoSizeText.rich(
                    TextSpan(
                      children: [
                        // Banano Icon
                        TextSpan(
                          text: "",
                          style: TextStyle(
                            fontFamily: 'KaliumIcons',
                            color: KaliumColors.primary,
                            fontSize: 23.0,
                          ),
                        ),
                        // Main balance text
                        TextSpan(
                          text: StateContainer.of(context)
                              .wallet
                              .getAccountBalanceDisplay(),
                          style: KaliumStyles.TextStyleCurrency,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    style: TextStyle(fontSize: 28.0),
                    stepGranularity: 0.1,
                    minFontSize: 1,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Icon(
                  _priceConversion == PriceConversion.BTC
                      ? KaliumIcons.btc
                      : KaliumIcons.nanocurrency,
                  color: _priceConversion == PriceConversion.NONE
                      ? Colors.transparent
                      : KaliumColors.text60,
                  size: 14),
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
    );
  }
}

class TransactionDetailsSheet {
  String _hash;
  String _address;
  String _displayName;
  TransactionDetailsSheet(String hash, String address, String displayName)
      : _hash = hash,
        _address = address,
        _displayName = displayName;
  // Current state references
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  mainBottomSheet(BuildContext context) {
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
                      // A stack for Copy Address and Add Contact buttons
                      Stack(
                        children: <Widget>[
                          // A row for Copy Address Button
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
                                  // Copy Address Button
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0)),
                                    color: _addressCopied
                                        ? KaliumColors.success
                                        : KaliumColors.primary,
                                    child: Text(
                                        _addressCopied
                                            ? KaliumLocalization.of(context)
                                                .addressCopied
                                            : KaliumLocalization.of(context)
                                                .copyAddress,
                                        textAlign: TextAlign.center,
                                        style: _addressCopied
                                            ? KaliumStyles
                                                .TextStyleButtonPrimaryGreen
                                            : KaliumStyles
                                                .TextStyleButtonPrimary),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14.0, horizontal: 20),
                                    onPressed: () {
                                      Clipboard.setData(
                                          new ClipboardData(text: _address));
                                      setState(() {
                                        // Set copied style
                                        _addressCopied = true;
                                      });
                                      if (_addressCopiedTimer != null) {
                                        _addressCopiedTimer.cancel();
                                      }
                                      _addressCopiedTimer = new Timer(
                                          const Duration(milliseconds: 800),
                                          () {
                                        setState(() {
                                          _addressCopied = false;
                                        });
                                      });
                                    },
                                    highlightColor: KaliumColors.success30,
                                    splashColor: KaliumColors.successDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // A row for Add Contact Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    top: Dimens.BUTTON_TOP_EXCEPTION_DIMENS[1],
                                    right:
                                        Dimens.BUTTON_TOP_EXCEPTION_DIMENS[2]),
                                child: Container(
                                  height: 55,
                                  width: 55,
                                  // Add Contact Button
                                  child: !_displayName.startsWith("@")
                                      ? FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            AddContactSheet(address: _address)
                                                .mainBottomSheet(context);
                                          },
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(100.0)),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10),
                                          child: Icon(KaliumIcons.addcontact,
                                              size: 35,
                                              color: _addressCopied
                                                  ? KaliumColors.successDark
                                                  : KaliumColors
                                                      .backgroundDark),
                                        )
                                      : SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // A row for View Details button
                      Row(
                        children: <Widget>[
                          KaliumButton.buildKaliumButton(
                              KaliumButtonType.PRIMARY_OUTLINE,
                              KaliumLocalization.of(context).viewDetails,
                              Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) {
                              return UIUtil.showBlockExplorerWebview(
                                  context, _hash);
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

// monKey Overlay
class MonkeyOverlay extends ModalRoute<void> {
  var monKey;
  MonkeyOverlay(this.monKey);

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => KaliumColors.overlay70;

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => false;

  Future<bool> _onClosed() async {
    RxBus.post(true, tag: RX_MONKEY_OVERLAY_CLOSED_TAG);
    return true;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Setup position transition
    return WillPopScope(
      onWillPop: _onClosed,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(child: _buildOverlayContent(context)),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _onClosed();
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
              child: SizedBox.expand(),
              constraints: BoxConstraints.expand(),
            ),
          ),
          Container(
            alignment: Alignment(0, -0.3),
            child: ClipOval(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: monKey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.42, -0.42),
        end: Offset.zero,
      ).animate(animation),
      child: ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}
