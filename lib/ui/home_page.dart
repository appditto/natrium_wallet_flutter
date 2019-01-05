import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalium_wallet_flutter/appstate_container.dart';
import 'package:kalium_wallet_flutter/colors.dart';
import 'package:kalium_wallet_flutter/dimens.dart';
import 'package:kalium_wallet_flutter/model/list_model.dart';
import 'package:kalium_wallet_flutter/network/model/block_types.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:kalium_wallet_flutter/styles.dart';
import 'package:kalium_wallet_flutter/kalium_icons.dart';
import 'package:kalium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:kalium_wallet_flutter/ui/receive/receive_sheet.dart';
import 'package:kalium_wallet_flutter/ui/settings/settings_sheet.dart';
import 'package:kalium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:kalium_wallet_flutter/ui/widgets/sheets.dart';

class KaliumHomePage extends StatefulWidget {
  @override
  _KaliumHomePageState createState() => _KaliumHomePageState();
}

class _KaliumHomePageState extends State<KaliumHomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  ListModel<AccountHistoryResponseItem> _historyList;
  List<AccountHistoryResponseItem> _testList = new List<AccountHistoryResponseItem>();

  KaliumReceiveSheet receive = new KaliumReceiveSheet();
  KaliumSendSheet send = new KaliumSendSheet();

  @override
  void initState() {
    super.initState();
    AccountHistoryResponseItem test = new AccountHistoryResponseItem(account: 'ban_1ka1ium4pfue3uxtntqsrib8mumxgazsjf58gidh1xeo5te3whsq8z476goo',
        amount:BigInt.from(10).pow(30).toString(), hash: 'abcdefg1234');
    test.type = BlockTypes.RECEIVE;
    AccountHistoryResponseItem test2 = new AccountHistoryResponseItem(account: 'ban_1ka1ium4pfue3uxtntqsrib8mumxgazsjf58gidh1xeo5te3whsq8z476goo',
        amount:BigInt.from(10).pow(31).toString(), hash: 'abcdefg1234');
    test2.type = BlockTypes.SEND;
    _testList.add(test);
    _testList.add(test2);
    _historyList = ListModel<AccountHistoryResponseItem>(
      listKey: _listKey,
      initialItems: _testList//StateContainer.of(context).wallet.history ?? new List<AccountHistoryResponseItem>(),
    );
  }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    return buildTransactionCard(_historyList[index], animation, context);
  }

  // Refresh list
  Future<void> _refresh() async {
    int randNum = new Random.secure().nextInt(10);
    AccountHistoryResponseItem test2 = new AccountHistoryResponseItem(account: 'ban_1ka1ium4pfue3uxtntqsrib8mumxgazsjf58gidh1xeo5te3whsq8z476goo',
        amount:BigInt.from(randNum).pow(30).toString(), hash: 'abcdefg1234');
    setState(() {
      _historyList.insertAtTop(test2);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarIconBrightness: Brightness.light));
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: KaliumColors.background,
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Drawer(
          child: SettingsSheet(),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //Main Card
          buildMainCard(context, _scaffoldKey),
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
                  RefreshIndicator(
                    child: AnimatedList(
                      key: _listKey,
                      initialItemCount: _historyList.length,
                      itemBuilder: _buildItem,
                    ),
                    onRefresh: _refresh,
                  ),
                  //List Top Gradient End
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 10.0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [KaliumColors.background00, KaliumColors.background],
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
                          colors: [KaliumColors.background00, KaliumColors.background],
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
                    margin: EdgeInsets.fromLTRB(14.0, 0.0, 7.0, MediaQuery.of(context).size.height*0.035),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      color: KaliumColors.primary,
                      child: Text('Receive',
                          textAlign: TextAlign.center,
                          style: KaliumStyles.TextStyleButtonPrimary),
                      padding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 20),
                      onPressed: () => receive.mainBottomSheet(context),
                      highlightColor: KaliumColors.background40,
                      splashColor: KaliumColors.background40,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(7.0, 0.0, 14.0, MediaQuery.of(context).size.height*0.035),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)),
                      color: KaliumColors.primary,
                      child: Text('Send',
                          textAlign: TextAlign.center,
                          style: KaliumStyles.TextStyleButtonPrimary),
                      padding: EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 20),
                      onPressed: () => send.mainBottomSheet(context),
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
}

//Main Card
Widget buildMainCard(BuildContext context, _scaffoldKey) {
  return Container(
    decoration: BoxDecoration(
      color:KaliumColors.backgroundDark,
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05, left: 14.0, right: 14.0),
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
                    child:
                        Icon(KaliumIcons.settings, color: KaliumColors.text, size: 24)),
              ),
            ],
          ),
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 5.0),
                child: Text(StateContainer.of(context).wallet.localCurrencyPrice,
                    textAlign: TextAlign.center,
                    style: KaliumStyles.TextStyleCurrencyAlt),
              ),
              Row(
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.only(right: 5.0),
                      child: Icon(KaliumIcons.bananocurrency,
                          color: KaliumColors.primary, size: 20)),
                  Container(
                    margin: EdgeInsets.only(right: 15.0),
                    child: Text(StateContainer.of(context).wallet.getAccountBalanceDisplay(),
                        textAlign: TextAlign.center,
                        style: KaliumStyles.TextStyleCurrency),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                      child: Icon(KaliumIcons.btc, color: KaliumColors.text60, size: 14)),
                  Text(StateContainer.of(context).wallet.btcPrice,
                      textAlign: TextAlign.center,
                      style: KaliumStyles.TextStyleCurrencyAlt),
                ],
              ),
            ],
          ),
        ),
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

// Transaction Card
Widget buildTransactionCard(AccountHistoryResponseItem item, Animation<double> animation, BuildContext context) {
  TransactionDetailsSheet transactionDetails = TransactionDetailsSheet();
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
      sizeFactor: animation,
      child: Container(
    margin: EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
    decoration: BoxDecoration(
      color:KaliumColors.backgroundDark,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: FlatButton(
      highlightColor: KaliumColors.text15,
      splashColor: KaliumColors.text15,
      color:KaliumColors.backgroundDark,
      padding: EdgeInsets.all(0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      onPressed: () => transactionDetails.mainBottomSheet(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
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
                item.getShortString(),
                textAlign: TextAlign.left,
                style: KaliumStyles.TextStyleTransactionAddress,
              ),
            ],
          ),
        ),
      ),
    ),
  ),
  );
} //Sent Card End

class TransactionDetailsSheet {
  mainBottomSheet(BuildContext context) {
    showKaliumHeightEightSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        buildKaliumButton(KaliumButtonType.PRIMARY,
                            'Copy Address', Dimens.BUTTON_TOP_EXCEPTION_DIMENS),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        buildKaliumButton(KaliumButtonType.PRIMARY_OUTLINE,
                            'View Details', Dimens.BUTTON_BOTTOM_DIMENS),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
