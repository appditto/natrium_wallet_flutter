import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';
import 'package:natrium_wallet_flutter/app_icons.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/dimens.dart';
import 'package:natrium_wallet_flutter/network/account_service.dart';
import 'package:natrium_wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/db/account.dart';
import 'package:natrium_wallet_flutter/ui/accounts/accountdetails_sheet.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheets.dart';
import 'package:natrium_wallet_flutter/ui/widgets/buttons.dart';
import 'package:natrium_wallet_flutter/ui/widgets/dialog.dart';
import 'package:natrium_wallet_flutter/styles.dart';
import 'package:natrium_wallet_flutter/util/caseconverter.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:logger/logger.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';

class AppAccountsSheet {
  List<Account> accounts;

  AppAccountsSheet(this.accounts);

  mainBottomSheet(BuildContext context) {
    AppSheets.showAppHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return AppAccountsWidget(accounts: accounts);
        });
  }
}

class AppAccountsWidget extends StatefulWidget {
  final List<Account> accounts;

  AppAccountsWidget({Key key, @required this.accounts}) : super(key: key);

  @override
  _AppAccountsWidgetState createState() => _AppAccountsWidgetState();
}

class _AppAccountsWidgetState extends State<AppAccountsWidget> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();

  bool _addingAccount;
  ScrollController _scrollController = new ScrollController();

  StreamSubscription<AccountModifiedEvent> _accountModifiedSub;
  bool _accountIsChanging;

  Future<bool> _onWillPop() async {
    if (_accountModifiedSub != null) {
      _accountModifiedSub.cancel();
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    this._addingAccount = false;
    this._accountIsChanging = false;
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  Future<void> _handleAccountsBalancesResponse(
      AccountsBalancesResponse resp) async {
    // Handle balances event
    widget.accounts.forEach((account) {
      resp.balances.forEach((address, balance) {
        address = address.replaceAll("xrb_", "nano_");
        String combinedBalance = (BigInt.tryParse(balance.balance) +
                BigInt.tryParse(balance.pending))
            .toString();
        if (account.address == address && combinedBalance != account.balance) {
          sl.get<DBHelper>().updateAccountBalance(account, combinedBalance);
          setState(() {
            account.balance = combinedBalance;
          });
        }
      });
    });
  }

  void _registerBus() {
    _accountModifiedSub = EventTaxiImpl.singleton()
        .registerTo<AccountModifiedEvent>()
        .listen((event) {
      if (event.deleted) {
        if (event.account.selected) {
          Future.delayed(Duration(milliseconds: 50), () {
            setState(() {
              widget.accounts
                  .where((a) =>
                      a.index ==
                      StateContainer.of(context).selectedAccount.index)
                  .forEach((account) {
                account.selected = true;
              });
            });
          });
        }
        setState(() {
          widget.accounts.removeWhere((a) => a.index == event.account.index);
        });
      } else {
        // Name change
        setState(() {
          widget.accounts.removeWhere((a) => a.index == event.account.index);
          widget.accounts.add(event.account);
          widget.accounts.sort((a, b) => a.index.compareTo(b.index));
        });
      }
    });
  }

  void _destroyBus() {
    if (_accountModifiedSub != null) {
      _accountModifiedSub.cancel();
    }
  }

  Future<void> _requestBalances(
      BuildContext context, List<Account> accounts) async {
    List<String> addresses = [];
    accounts.forEach((account) {
      if (account.address != null) {
        addresses.add(account.address);
      }
    });
    try {
      AccountsBalancesResponse resp =
          await sl.get<AccountService>().requestAccountsBalances(addresses);
      await _handleAccountsBalancesResponse(resp);
    } catch (e) {
      sl.get<Logger>().e("Error", e);
    }
  }

  Future<void> _changeAccount(Account account, StateSetter setState) async {
    // Change account
    widget.accounts.forEach((a) {
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
    await sl.get<DBHelper>().changeAccount(account);
    EventTaxiImpl.singleton()
        .fire(AccountChangedEvent(account: account, delayPop: true));
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
                margin: EdgeInsets.only(top: 30.0, bottom: 15),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 140),
                child: AutoSizeText(
                  CaseChange.toUpperCase(
                      AppLocalization.of(context).accounts, context),
                  style: AppStyles.textStyleHeader(context),
                  maxLines: 1,
                  stepGranularity: 0.1,
                ),
              ),

              //A list containing accounts
              Expanded(
                  key: expandedKey,
                  child: Stack(
                    children: <Widget>[
                      widget.accounts == null
                          ? Center(child: Text("Loading"))
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              itemCount: widget.accounts.length,
                              controller: _scrollController,
                              itemBuilder: (BuildContext buildContext, int index) {
                                return Column(
                                  children: [
                                    SizedBox(height: 2),
                                    _buildAccountListItem(buildContext,
                                        widget.accounts[index], setState),
                                  ],
                                );
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
                              begin: AlignmentDirectional(0.5, 1.0),
                              end: AlignmentDirectional(0.5, -1.0),
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
                              begin: AlignmentDirectional(0.5, 1.0),
                              end: AlignmentDirectional(0.5, -1.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 15),
              //A row with Add Account button
              Row(
                children: <Widget>[
                  widget.accounts == null ||
                          widget.accounts.length >= MAX_ACCOUNTS
                      ? SizedBox()
                      : AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY,
                          AppLocalization.of(context).addAccount,
                          dimens: Dimens.BUTTON_TOP_DIMENS,
                          disabled: _addingAccount,
                          onPressed: () {
                            if (!_addingAccount) {
                              setState(() {
                                _addingAccount = true;
                              });
                              StateContainer.of(context).getSeed().then((seed) {
                                sl
                                    .get<DBHelper>()
                                    .addAccount(seed,
                                        nameBuilder: AppLocalization.of(context)
                                            .defaultNewAccountName)
                                    .then((newAccount) {
                                  _requestBalances(context, [newAccount]);
                                  StateContainer.of(context)
                                      .updateRecentlyUsedAccounts();
                                  widget.accounts.add(newAccount);
                                  setState(() {
                                    _addingAccount = false;
                                    widget.accounts.sort(
                                        (a, b) => a.index.compareTo(b.index));
                                    // Scroll if list is full
                                    if (expandedKey.currentContext != null) {
                                      RenderBox box = expandedKey.currentContext
                                          .findRenderObject();
                                      if (widget.accounts.length * 72.0 >=
                                          box.size.height) {
                                        _scrollController.animateTo(
                                          newAccount.index * 72.0 >
                                                  _scrollController
                                                      .position.maxScrollExtent
                                              ? _scrollController.position
                                                      .maxScrollExtent +
                                                  72.0
                                              : newAccount.index * 72.0,
                                          curve: Curves.easeOut,
                                          duration:
                                              const Duration(milliseconds: 200),
                                        );
                                      }
                                    }
                                  });
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
                    dimens: Dimens.BUTTON_BOTTOM_DIMENS,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildAccountListItem(
      BuildContext context, Account account, StateSetter setState) {
    return Slidable(
        endActionPane: ActionPane(
            extentRatio: account.index > 0 ? 0.5 : 0.25,
            motion: const ScrollMotion(),
            children: _getSlideActionsForAccount(context, account, setState)),
        child:
            //!FlatButton => TextButton
            //!
            TextButton(
          style: ButtonStyle(
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0)))),
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
          child: Container(
            height: 70.0,
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
              width: 2,
              color: StateContainer.of(context).curTheme.text15,
            ))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Selected indicator
                StateContainer.of(context).natriconOn
                    ? Container(
                        height: 70,
                        width: 6,
                        color: account.selected
                            ? StateContainer.of(context).curTheme.primary
                            : Colors.transparent,
                      )
                    : SizedBox(),
                // Icon, Account Name, Address and Amount
                Expanded(
                  child: Container(
                    margin: EdgeInsetsDirectional.only(
                        start: StateContainer.of(context).natriconOn ? 8 : 20,
                        end: StateContainer.of(context).natriconOn ? 16 : 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            // natricon
                            StateContainer.of(context).natriconOn
                                ? Container(
                                    width: 64.0,
                                    height: 64.0,
                                    child: SvgPicture.network(
                                      UIUtil.getNatriconURL(
                                          account.address,
                                          StateContainer.of(context)
                                              .getNatriconNonce(
                                                  account.address)),
                                      key: Key(UIUtil.getNatriconURL(
                                          account.address,
                                          StateContainer.of(context)
                                              .getNatriconNonce(
                                                  account.address))),
                                      placeholderBuilder:
                                          (BuildContext context) => Container(
                                        child: FlareActor(
                                          "assets/ntr_placeholder_animation.flr",
                                          animation: "main",
                                          fit: BoxFit.contain,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .primary,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    child: Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Icon(
                                            AppIcons.accountwallet,
                                            color: account.selected
                                                ? StateContainer.of(context)
                                                    .curTheme
                                                    .success
                                                : StateContainer.of(context)
                                                    .curTheme
                                                    .primary,
                                            size: 30,
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 30,
                                            alignment:
                                                AlignmentDirectional(0, 0.3),
                                            child: Text(
                                                account
                                                    .getShortName()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color:
                                                      StateContainer.of(context)
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
                              width: (MediaQuery.of(context).size.width - 116) *
                                  0.5,
                              margin: EdgeInsetsDirectional.only(
                                  start: StateContainer.of(context).natriconOn
                                      ? 8.0
                                      : 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Account name
                                  AutoSizeText(
                                    account.name,
                                    style: TextStyle(
                                      fontFamily: "NunitoSans",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.0,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text,
                                    ),
                                    minFontSize: 8.0,
                                    stepGranularity: 0.1,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                  ),
                                  // Account address
                                  AutoSizeText(
                                    account.address.substring(0, 12) + "...",
                                    style: TextStyle(
                                      fontFamily: "OverpassMono",
                                      fontWeight: FontWeight.w100,
                                      fontSize: 14.0,
                                      color: StateContainer.of(context)
                                          .curTheme
                                          .text60,
                                    ),
                                    minFontSize: 8.0,
                                    stepGranularity: 0.1,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width:
                              (MediaQuery.of(context).size.width - 116) * 0.4,
                          alignment: AlignmentDirectional(1, 0),
                          child: AutoSizeText.rich(
                            TextSpan(
                              children: [
                                // Main balance text
                                TextSpan(
                                  text: (account.balance != null ? "Ӿ" : "") +
                                      (account.balance != null &&
                                              !account.selected
                                          ? NumberUtil.getRawAsUsableString(
                                              account.balance)
                                          : account.selected
                                              ? StateContainer.of(context)
                                                  .wallet
                                                  .getAccountBalanceDisplay()
                                              : ""),
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: "NunitoSans",
                                    fontWeight: FontWeight.w900,
                                    color: StateContainer.of(context)
                                        .curTheme
                                        .text,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            style: TextStyle(fontSize: 16.0),
                            stepGranularity: 0.1,
                            minFontSize: 1,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Selected indicator
                StateContainer.of(context).natriconOn
                    ? Container(
                        height: 70,
                        width: 6,
                        color: account.selected
                            ? StateContainer.of(context).curTheme.primary
                            : Colors.transparent,
                      )
                    : SizedBox()
              ],
            ),
          ),
        )
        /* FlatButton(
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
            children: <Widget>[
              Divider(
                height: 2,
                color: StateContainer.of(context).curTheme.text15,
              ),
              Container(
                height: 70.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Selected indicator
                    StateContainer.of(context).natriconOn
                        ? Container(
                            height: 70,
                            width: 6,
                            color: account.selected
                                ? StateContainer.of(context).curTheme.primary
                                : Colors.transparent,
                          )
                        : SizedBox(),
                    // Icon, Account Name, Address and Amount
                    Expanded(
                      child: Container(
                        margin: EdgeInsetsDirectional.only(
                            start:
                                StateContainer.of(context).natriconOn ? 8 : 20,
                            end: StateContainer.of(context).natriconOn
                                ? 16
                                : 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                // natricon
                                StateContainer.of(context).natriconOn
                                    ? Container(
                                        width: 64.0,
                                        height: 64.0,
                                        child: SvgPicture.network(
                                          UIUtil.getNatriconURL(
                                              account.address,
                                              StateContainer.of(context)
                                                  .getNatriconNonce(
                                                      account.address)),
                                          key: Key(UIUtil.getNatriconURL(
                                              account.address,
                                              StateContainer.of(context)
                                                  .getNatriconNonce(
                                                      account.address))),
                                          placeholderBuilder:
                                              (BuildContext context) =>
                                                  Container(
                                            child: FlareActor(
                                              "assets/ntr_placeholder_animation.flr",
                                              animation: "main",
                                              fit: BoxFit.contain,
                                              color: StateContainer.of(context)
                                                  .curTheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        child: Stack(
                                          children: <Widget>[
                                            Center(
                                              child: Icon(
                                                AppIcons.accountwallet,
                                                color: account.selected
                                                    ? StateContainer.of(context)
                                                        .curTheme
                                                        .success
                                                    : StateContainer.of(context)
                                                        .curTheme
                                                        .primary,
                                                size: 30,
                                              ),
                                            ),
                                            Center(
                                              child: Container(
                                                width: 40,
                                                height: 30,
                                                alignment: AlignmentDirectional(
                                                    0, 0.3),
                                                child: Text(
                                                    account
                                                        .getShortName()
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color: StateContainer.of(
                                                              context)
                                                          .curTheme
                                                          .backgroundDark,
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    )),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                // Account name and address
                                Container(
                                  width: (MediaQuery.of(context).size.width -
                                          116) *
                                      0.5,
                                  margin: EdgeInsetsDirectional.only(
                                      start:
                                          StateContainer.of(context).natriconOn
                                              ? 8.0
                                              : 20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Account name
                                      AutoSizeText(
                                        account.name,
                                        style: TextStyle(
                                          fontFamily: "NunitoSans",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 0.1,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                      ),
                                      // Account address
                                      AutoSizeText(
                                        account.address.substring(0, 12) +
                                            "...",
                                        style: TextStyle(
                                          fontFamily: "OverpassMono",
                                          fontWeight: FontWeight.w100,
                                          fontSize: 14.0,
                                          color: StateContainer.of(context)
                                              .curTheme
                                              .text60,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 0.1,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width - 116) *
                                  0.4,
                              alignment: AlignmentDirectional(1, 0),
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    // Main balance text
                                    TextSpan(
                                      text: (account.balance != null
                                              ? "Ӿ"
                                              : "") +
                                          (account.balance != null &&
                                                  !account.selected
                                              ? NumberUtil.getRawAsUsableString(
                                                  account.balance)
                                              : account.selected
                                                  ? StateContainer.of(context)
                                                      .wallet
                                                      .getAccountBalanceDisplay()
                                                  : ""),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w900,
                                        color: StateContainer.of(context)
                                            .curTheme
                                            .text,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                style: TextStyle(fontSize: 16.0),
                                stepGranularity: 0.1,
                                minFontSize: 1,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Selected indicator
                    StateContainer.of(context).natriconOn
                        ? Container(
                            height: 70,
                            width: 6,
                            color: account.selected
                                ? StateContainer.of(context).curTheme.primary
                                : Colors.transparent,
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ],
          )), */
        );
  }

  List<Widget> _getSlideActionsForAccount(
      BuildContext context, Account account, StateSetter setState) {
    List<Widget> _actions = [SizedBox(width: 2) /* for space */];
    _actions.add(
      SlidableAction(
        padding: EdgeInsets.all(2),
        onPressed: (context) {
          AccountDetailsSheet(account).mainBottomSheet(context);
        },
        backgroundColor: StateContainer.of(context).curTheme.primary,
        foregroundColor: StateContainer.of(context).curTheme.backgroundDark,
        icon: Icons.edit,
      ),
    );
    if (account.index > 0) {
      _actions.add(SizedBox(width: 2) /* for space */);
      _actions.add(
        SlidableAction(
          onPressed: (slContext) async {
            await AppDialogs.showConfirmDialog(
                slContext,
                AppLocalization.of(slContext).hideAccountHeader,
                AppLocalization.of(slContext)
                    .removeAccountText
                    .replaceAll("%1", AppLocalization.of(slContext).addAccount),
                CaseChange.toUpperCase(
                    AppLocalization.of(slContext).yes, slContext), () {
              // Remove account
              sl.get<DBHelper>().deleteAccount(account).then((id) {
                EventTaxiImpl.singleton().fire(
                    AccountModifiedEvent(account: account, deleted: true));
                setState(() {
                  widget.accounts.removeWhere((a) => a.index == account.index);
                });
              });
            },
                cancelText: CaseChange.toUpperCase(
                    AppLocalization.of(slContext).no, slContext));
          },
          backgroundColor: StateContainer.of(context).curTheme.primary,
          foregroundColor: StateContainer.of(context).curTheme.backgroundDark,
          icon: Icons.delete,
        ),
      );
    }

    return _actions;
  }
}
