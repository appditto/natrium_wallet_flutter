import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/db/account.dart';
import 'package:natrium_wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:natrium_wallet_flutter/ui/widgets/auto_resize_text.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';

class AppAccountsSheet {
  static const int MAX_ACCOUNTS = 20;
  List<Account> _accounts;
  bool _addingAccount;
  ScrollController _scrollController = new ScrollController();

  StreamSubscription<AccountsBalancesEvent> _balancesSub;
  StreamSubscription<AccountModifiedEvent> _accountModifiedSub;
  bool _accountIsChanging;

  DBHelper dbHelper;

  Future<bool> _onWillPop() async {
    if (_balancesSub != null) {
      _balancesSub.cancel();
    }
    if (_accountModifiedSub != null) {
      _accountModifiedSub.cancel();
    }
    return true;
  }

  AppAccountsSheet(List<Account> accounts, BigInt selectedBalance) {
    this._accounts = accounts;
    this._addingAccount = false;
    this._accountIsChanging = false;
    this._accounts.where((a) => a.selected).forEach((acct) {
      acct.balance = selectedBalance.toString();
    });
    this.dbHelper = DBHelper();
  }

  Future<void> _requestBalances(BuildContext context, List<Account> accounts) async {
    List<String> addresses = List();
    accounts.forEach((account) {
      if (account.address != null) {
        addresses.add(account.address);
      }
    });
    StateContainer.of(context).requestAccountsBalances(addresses);
  }

  Future<void> _handleAccountsBalancesResponse(AccountsBalancesEvent event, StateSetter setState) async {
    if (event.transfer) {
      return;
    }
    // Handle balances event
    _accounts.forEach((account) {
      event.response.balances.forEach((address, balance) {
        String combinedBalance = (BigInt.tryParse(balance.balance) + BigInt.tryParse(balance.pending)).toString();
        if (account.address == address && combinedBalance != account.balance) {
          setState(() {
            account.balance = combinedBalance;
          });
        }
      });
    });    
  }

  Future<void> _changeAccount(Account account, StateSetter setState) async {
    // Change account
    _accounts.forEach((a) {
      if (a.selected) {
        setState(() {
          a.selected = false;
        });
      } else if (account.index == a.index) {
        setState(() {
          a.selected = true;
        });
      }
    });
    await dbHelper.changeAccount(account);
    EventTaxiImpl.singleton().fire(AccountChangedEvent(account: account, delayPop: true));      
  }

  mainBottomSheet(BuildContext context) {
    _requestBalances(context, _accounts);
    AppSheets.showAppHeightNineSheet(
        context: context,
        onDisposed: _onWillPop,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            if (_balancesSub == null) {
              _balancesSub = EventTaxiImpl.singleton()
                  .registerTo<AccountsBalancesEvent>()
                  .listen((event) {
                _handleAccountsBalancesResponse(event, setState);
              });
            }
            if (_accountModifiedSub == null) {
              _accountModifiedSub =EventTaxiImpl.singleton()
                .registerTo<AccountModifiedEvent>()
                .listen((event) {
                  if (event.deleted) {
                    setState(() {
                      _accounts.removeWhere((a) => a.index == event.account.index);
                    });
                  } else {
                    // Name change
                    setState(() {
                      _accounts.removeWhere((a) => a.index == event.account.index);
                      _accounts.add(event.account);
                      _accounts.sort((a, b) => a.index.compareTo(b.index));
                    });
                  }
                });
            }
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
                        margin: EdgeInsets.only(top: 30.0, bottom: 15),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 140),
                        child: AutoSizeText(
                          CaseChange.toUpperCase(AppLocalization.of(context).accounts, context),
                          style: AppStyles.textStyleHeader(context),
                          maxLines: 1,
                          stepGranularity: 0.1,
                        ),
                      ),

                      //A list containing accounts
                      Expanded(
                          child: Stack(
                        children: <Widget>[
                          _accounts == null ?
                            Center(
                              child: Text("Loading"),
                            )
                          :
                          ListView.builder(
                            itemCount: _accounts.length,
                            controller: _scrollController,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildAccountListItem(context, _accounts[index], setState);
                            },
                          ),
                          //List Top Gradient
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 20.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    StateContainer.of(context)
                                        .curTheme
                                        .backgroundDark00,
                                    StateContainer.of(context)
                                        .curTheme
                                        .backgroundDark,
                                  ],
                                  begin: Alignment(0.5, 1.0),
                                  end: Alignment(0.5, -1.0),
                                ),
                              ),
                            ),
                          ),
                          // List Bottom Gradient
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 20.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    StateContainer.of(context)
                                        .curTheme
                                        .backgroundDark,
                                    StateContainer.of(context)
                                        .curTheme
                                        .backgroundDark00
                                  ],
                                  begin: Alignment(0.5, 1.0),
                                  end: Alignment(0.5, -1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                      SizedBox(
                        height: 15,
                      ),
                      //A row with Add Account button
                      Row(
                        children: <Widget>[
                          _accounts == null || _accounts.length >= MAX_ACCOUNTS
                          ? SizedBox()
                          : AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY,
                            AppLocalization.of(context).addAccount,
                            Dimens.BUTTON_TOP_DIMENS,
                            disabled: _addingAccount,
                            onPressed: () {
                              if (!_addingAccount) {
                                setState(() {
                                  _addingAccount = true;
                                });
                                dbHelper.addAccount(nameBuilder: AppLocalization.of(context).defaultNewAccountName).then((newAccount) {
                                  _requestBalances(context, [newAccount]);
                                  StateContainer.of(context).updateRecentlyUsedAccounts();
                                  _accounts.add(newAccount);
                                  setState(() {
                                    _addingAccount = false;
                                    _accounts.sort((a, b) => a.index.compareTo(b.index));
                                    _scrollController.animateTo(
                                      newAccount.index * 70.0,
                                      curve: Curves.easeOut,
                                      duration: const Duration(milliseconds: 100),
                                    );    
                                  });
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      //A row with Close button
                      Row(
                        children: <Widget>[
                          AppButton.buildAppButton(
                            context,
                            AppButtonType.PRIMARY_OUTLINE,
                            AppLocalization.of(context).close,
                            Dimens.BUTTON_BOTTOM_DIMENS,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ));
          });
        });
  }

  Widget _buildAccountListItem(BuildContext context, Account account, StateSetter setState) {
    return FlatButton(
      highlightColor: StateContainer.of(context).curTheme.text15,
      splashColor: StateContainer.of(context).curTheme.text15,
      onPressed: () {
        if (!_accountIsChanging) {
          // Change account
          if (!account.selected) {
            setState(() {
              _accountIsChanging = true;
            });
            _changeAccount(account, setState);
          }          
        }
      },
      padding: EdgeInsets.all(0.0),
      child: Column(
        children: <Widget> [
          Divider(
            height: 2,
            color:
                StateContainer.of(context).curTheme.text15,
          ),
          Slidable(
            delegate:SlidableScrollDelegate(),
            actionExtentRatio: 0.2,
            child: Container(
              height: 70.0,
              margin: new EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Account Icon
                      Container(
                        child: Stack(
                          children: <Widget>[
                            Center(
                              child: Icon(
                                AppIcons.accountwallet,
                                color: account.selected
                                ? StateContainer.of(context).curTheme.success
                                : StateContainer.of(context).curTheme.primary,
                                size: 30,
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 40,
                                height: 30,
                                alignment: Alignment(0, 0.3),
                                child: Text(account.getShortName(),
                                    style: TextStyle(
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .backgroundDark,
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w800,
                                    )),                     
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Account name and address
                      Container(
                        margin: EdgeInsets.only(left: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                account.name,
                                style: TextStyle(
                                  fontFamily: "NunitoSans",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: StateContainer.of(context).curTheme.text,
                                ),
                              ),
                            ),
                            // Main account address
                            Container(
                              child: Text(
                                account.address.substring(0, 11) + "...",
                                style: TextStyle(
                                  fontFamily: "OverpassMono",
                                  fontWeight: FontWeight.w100,
                                  fontSize: 14.0,
                                  color: StateContainer.of(context).curTheme.text60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        account.balance != null ? NumberUtil.getRawAsUsableString(account.balance) : "",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "NunitoSans",
                            fontWeight: FontWeight.w900,
                            color: StateContainer.of(context).curTheme.text),
                      ),
                      Text(
                        account.balance != null ? " NANO" : "",
                        style: TextStyle(
                            fontSize: 14.0,
                            fontFamily: "NunitoSans",
                            fontWeight: FontWeight.w100,
                            color: StateContainer.of(context).curTheme.text),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            secondaryActions: _getSlideActionsForAccount(context, account, setState)
          ),
        ],
      )
    );
  }

  List<Widget> _getSlideActionsForAccount(BuildContext context, Account account, StateSetter setState) {
    List<Widget> _actions = List();
    _actions.add(SlideAction(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: Icon(
          Icons.edit,
          color: StateContainer.of(context).curTheme.primary,
        ),
      ),
      onTap: () {
        AccountDetailsSheet(account).mainBottomSheet(context);
      }
    ));
    if (!account.selected && account.index > 0) {
      _actions.add(SlideAction(
        child: Container(
          constraints: BoxConstraints.expand(),
          child: Icon(
            Icons.delete,
            color: StateContainer.of(context).curTheme.primary,
          ),
        ),
        onTap: () {
          AppDialogs.showConfirmDialog(context,
            AppLocalization.of(context).hideAccountHeader,
            AppLocalization.of(context).removeAccountText.replaceAll("%1", AppLocalization.of(context).addAccount),
              CaseChange.toUpperCase(AppLocalization.of(context).yes, context),
            () {
              // Remove account
              dbHelper.deleteAccount(account).then((id) {
                StateContainer.of(context).updateRecentlyUsedAccounts();
                setState(() {
                  _accounts.removeWhere((a) => a.index == account.index);
                });
              });
            },
            cancelText: CaseChange.toUpperCase(AppLocalization.of(context).no, context)
          );             
        }
      ));
    }
    return _actions;
  }
}
