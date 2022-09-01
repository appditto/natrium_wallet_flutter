import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:devicelocale/devicelocale.dart';
import 'package:logger/logger.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/available_block_explorer.dart';
import 'package:natrium_wallet_flutter/model/wallet.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:natrium_wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:uni_links/uni_links.dart';
import 'package:natrium_wallet_flutter/themes.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';
import 'package:natrium_wallet_flutter/model/available_themes.dart';
import 'package:natrium_wallet_flutter/model/available_currency.dart';
import 'package:natrium_wallet_flutter/model/available_language.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/model/vault.dart';
import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/db/account.dart';
import 'package:natrium_wallet_flutter/util/ninja/api.dart';
import 'package:natrium_wallet_flutter/util/ninja/ninja_node.dart';
import 'package:natrium_wallet_flutter/network/model/block_types.dart';
import 'package:natrium_wallet_flutter/network/model/request/account_history_request.dart';
import 'package:natrium_wallet_flutter/network/model/request/fcm_update_request.dart';
import 'package:natrium_wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:natrium_wallet_flutter/network/model/response/callback_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/error_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/process_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/pending_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/pending_response_item.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:natrium_wallet_flutter/util/nanoutil.dart';
import 'package:natrium_wallet_flutter/network/account_service.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';

import 'util/sharedprefsutil.dart';

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

  StateContainer({@required this.child});

  // This is the secret sauce. Write your own 'of' method that will behave
  // Exactly like MediaQuery.of and Theme.of
  // It basically says 'get the data from the widget of this type.
  static StateContainerState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InheritedStateContainer>()
        .data;
  }

  @override
  StateContainerState createState() => StateContainerState();
}

/// App InheritedWidget
/// This is where we handle the global state and also where
/// we interact with the server and make requests/handle+propagate responses
///
/// Basically the central hub behind the entire app
class StateContainerState extends State<StateContainer> {
  final Logger log = sl.get<Logger>();

  // Minimum receive = 0.000001 NANO
  String receiveThreshold = BigInt.from(10).pow(24).toString();

  AppWallet wallet;
  String currencyLocale;
  Locale deviceLocale = Locale('en', 'US');
  AvailableCurrency curCurrency = AvailableCurrency(AvailableCurrencyEnum.USD);
  LanguageSetting curLanguage = LanguageSetting(AvailableLanguage.DEFAULT);
  AvailableBlockExplorer curBlockExplorer =
      AvailableBlockExplorer(AvailableBlockExplorerEnum.NANOCRAWLER);
  BaseTheme curTheme = NatriumTheme();
  // Currently selected account
  Account selectedAccount =
      Account(id: 1, name: "AB", index: 0, lastAccess: 0, selected: true);
  // Two most recently used accounts
  Account recentLast;
  Account recentSecondLast;

  // Natricon true
  bool natriconOn = true;
  Map<String, String> natriconNonce = Map<String, String>();

  // Active alert
  AlertResponseItem activeAlert;
  AlertResponseItem settingsAlert;
  bool activeAlertIsRead = true;

  // If callback is locked
  bool _locked = false;

  // Initial deep link
  String initialDeepLink;
  // Deep link changes
  StreamSubscription _deepLinkSub;

  List<String> pendingRequests = [];
  List<String> alreadyReceived = [];

  // List of Verified Nano Ninja Nodes
  bool nanoNinjaUpdated = false;
  List<NinjaNode> nanoNinjaNodes;

  // When wallet is encrypted
  String encryptedSecret;

  void updateNinjaNodes(List<NinjaNode> list) {
    setState(() {
      nanoNinjaNodes = list;
    });
  }

  void updateNatriconNonce(String address, int nonce) {
    setState(() {
      this.natriconNonce[address] = nonce.toString();
    });
  }

  void updateActiveAlert(
      AlertResponseItem active, AlertResponseItem settingsAlert) {
    setState(() {
      this.activeAlert = active;
      if (settingsAlert != null) {
        this.settingsAlert = settingsAlert;
      } else {
        this.settingsAlert = null;
        this.activeAlertIsRead = true;
      }
    });
  }

  void setAlertRead() {
    setState(() {
      this.activeAlertIsRead = true;
    });
  }

  void setAlertUnread() {
    setState(() {
      this.activeAlertIsRead = false;
    });
  }

  String getNatriconNonce(String address) {
    if (this.natriconNonce.containsKey(address)) {
      return this.natriconNonce[address];
    }
    return "";
  }

  Future<void> checkAndUpdateAlerts() async {
    // Get active alert
    try {
      String localeString =
          (await sl.get<SharedPrefsUtil>().getLanguage()).getLocaleString();
      if (localeString == "DEFAULT") {
        List<Locale> languageLocales =
            await Devicelocale.preferredLanguagesAsLocales;
        if (languageLocales.length > 0) {
          localeString = languageLocales[0].languageCode;
        }
      }
      AlertResponseItem alert =
          await sl.get<AccountService>().getAlert(localeString);
      if (alert == null) {
        updateActiveAlert(null, null);
        return;
      } else if (await sl.get<SharedPrefsUtil>().shouldShowAlert(alert)) {
        // See if we should display this one again
        if (alert.link == null ||
            await sl.get<SharedPrefsUtil>().alertIsRead(alert)) {
          setAlertRead();
        } else {
          setAlertUnread();
        }
        updateActiveAlert(alert, alert);
      } else {
        if (alert.link == null ||
            await sl.get<SharedPrefsUtil>().alertIsRead(alert)) {
          setAlertRead();
        } else {
          setAlertUnread();
        }
        updateActiveAlert(null, alert);
      }
    } catch (e) {
      log.e("Error retrieving alert", e);
      return;
    }
  }

  Future<void> checkAndCacheNinjaAPIResponse() async {
    List<NinjaNode> nodes;
    if ((await sl.get<SharedPrefsUtil>().getNinjaAPICache()) == null) {
      nodes = await NinjaAPI.getVerifiedNodes();
      setState(() {
        nanoNinjaNodes = nodes;
        nanoNinjaUpdated = true;
      });
    } else {
      nodes = await NinjaAPI.getCachedVerifiedNodes();
      setState(() {
        nanoNinjaNodes = nodes;
        nanoNinjaUpdated = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Register RxBus
    _registerBus();
    // Set currency locale here for the UI to access
    sl.get<SharedPrefsUtil>().getCurrency(deviceLocale).then((currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    // Get default language setting
    sl.get<SharedPrefsUtil>().getLanguage().then((language) {
      setState(() {
        curLanguage = language;
      });
    });
    // Get theme default
    sl.get<SharedPrefsUtil>().getTheme().then((theme) {
      updateTheme(theme, setIcon: false);
    });
    // Get default block explorer
    sl.get<SharedPrefsUtil>().getBlockExplorer().then((explorer) {
      setState(() {
        curBlockExplorer = explorer;
      });
    });
    // Get initial deep link
    getInitialLink().then((initialLink) {
      setState(() {
        initialDeepLink = initialLink;
      });
    });
    // Cache ninja API if don't already have it
    checkAndCacheNinjaAPIResponse();
    // Update alert
    checkAndUpdateAlerts();
    // Get natricon pref
    sl.get<SharedPrefsUtil>().getUseNatricon().then((useNatricon) {
      setNatriconOn(useNatricon);
    });
  }

  // Subscriptions
  StreamSubscription<ConnStatusEvent> _connStatusSub;
  StreamSubscription<SubscribeEvent> _subscribeEventSub;
  StreamSubscription<PriceEvent> _priceEventSub;
  StreamSubscription<CallbackEvent> _callbackSub;
  StreamSubscription<ErrorEvent> _errorSub;
  StreamSubscription<FcmUpdateEvent> _fcmUpdateSub;
  StreamSubscription<AccountModifiedEvent> _accountModifiedSub;

  // Register RX event listenerss
  void _registerBus() {
    _subscribeEventSub =
        EventTaxiImpl.singleton().registerTo<SubscribeEvent>().listen((event) {
      handleSubscribeResponse(event.response);
    });
    _priceEventSub =
        EventTaxiImpl.singleton().registerTo<PriceEvent>().listen((event) {
      // PriceResponse's get pushed periodically, it wasn't a request we made so don't pop the queue
      setState(() {
        wallet.btcPrice = event.response.btcPrice.toString();
        wallet.localCurrencyPrice = event.response.price.toString();
      });
    });
    _connStatusSub =
        EventTaxiImpl.singleton().registerTo<ConnStatusEvent>().listen((event) {
      if (event.status == ConnectionStatus.CONNECTED) {
        requestUpdate();
      } else if (event.status == ConnectionStatus.DISCONNECTED &&
          !sl.get<AccountService>().suspended) {
        sl.get<AccountService>().initCommunication();
      }
    });
    _callbackSub =
        EventTaxiImpl.singleton().registerTo<CallbackEvent>().listen((event) {
      handleCallbackResponse(event.response);
    });
    _errorSub =
        EventTaxiImpl.singleton().registerTo<ErrorEvent>().listen((event) {
      handleErrorResponse(event.response);
    });
    _fcmUpdateSub =
        EventTaxiImpl.singleton().registerTo<FcmUpdateEvent>().listen((event) {
      if (wallet != null) {
        sl.get<SharedPrefsUtil>().getNotificationsOn().then((enabled) {
          sl.get<AccountService>().sendRequest(FcmUpdateRequest(
              account: wallet.address,
              fcmToken: event.token,
              enabled: enabled));
        });
      }
    });
    // Account has been deleted or name changed
    _accountModifiedSub = EventTaxiImpl.singleton()
        .registerTo<AccountModifiedEvent>()
        .listen((event) {
      if (!event.deleted) {
        if (event.account.index == selectedAccount.index) {
          setState(() {
            selectedAccount.name = event.account.name;
          });
        } else {
          updateRecentlyUsedAccounts();
        }
      } else {
        // Remove account
        updateRecentlyUsedAccounts().then((_) {
          if (event.account.index == selectedAccount.index &&
              recentLast != null) {
            sl.get<DBHelper>().changeAccount(recentLast);
            setState(() {
              selectedAccount = recentLast;
            });
            EventTaxiImpl.singleton()
                .fire(AccountChangedEvent(account: recentLast, noPop: true));
          } else if (event.account.index == selectedAccount.index &&
              recentSecondLast != null) {
            sl.get<DBHelper>().changeAccount(recentSecondLast);
            setState(() {
              selectedAccount = recentSecondLast;
            });
            EventTaxiImpl.singleton().fire(
                AccountChangedEvent(account: recentSecondLast, noPop: true));
          } else if (event.account.index == selectedAccount.index) {
            getSeed().then((seed) {
              sl.get<DBHelper>().getMainAccount(seed).then((mainAccount) {
                sl.get<DBHelper>().changeAccount(mainAccount);
                setState(() {
                  selectedAccount = mainAccount;
                });
                EventTaxiImpl.singleton().fire(
                    AccountChangedEvent(account: mainAccount, noPop: true));
              });
            });
          }
        });
        updateRecentlyUsedAccounts();
      }
    });
    // Deep link has been updated
    _deepLinkSub = getLinksStream().listen((String link) {
      setState(() {
        initialDeepLink = link;
      });
    });
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  void _destroyBus() {
    if (_connStatusSub != null) {
      _connStatusSub.cancel();
    }
    if (_subscribeEventSub != null) {
      _subscribeEventSub.cancel();
    }
    if (_priceEventSub != null) {
      _priceEventSub.cancel();
    }
    if (_callbackSub != null) {
      _callbackSub.cancel();
    }
    if (_errorSub != null) {
      _errorSub.cancel();
    }
    if (_fcmUpdateSub != null) {
      _fcmUpdateSub.cancel();
    }
    if (_accountModifiedSub != null) {
      _accountModifiedSub.cancel();
    }
    if (_deepLinkSub != null) {
      _deepLinkSub.cancel();
    }
  }

  // Update the global wallet instance with a new address
  Future<void> updateWallet({Account account}) async {
    String address = NanoUtil.seedToAddress(await getSeed(), account.index);
    account.address = address;
    selectedAccount = account;
    updateRecentlyUsedAccounts();
    setState(() {
      wallet = AppWallet(address: address, loading: true);
      requestUpdate();
    });
  }

  Future<void> updateRecentlyUsedAccounts() async {
    List<Account> otherAccounts =
        await sl.get<DBHelper>().getRecentlyUsedAccounts(await getSeed());
    if (otherAccounts != null && otherAccounts.length > 0) {
      if (otherAccounts.length > 1) {
        setState(() {
          recentLast = otherAccounts[0];
          recentSecondLast = otherAccounts[1];
        });
      } else {
        setState(() {
          recentLast = otherAccounts[0];
          recentSecondLast = null;
        });
      }
    } else {
      setState(() {
        recentLast = null;
        recentSecondLast = null;
      });
    }
  }

  // Change language
  void updateLanguage(LanguageSetting language) {
    if (language != null &&
        curLanguage != null &&
        curLanguage.language != language.language) {
      checkAndUpdateAlerts();
    }
    setState(() {
      curLanguage = language;
    });
  }

  // Change block explorer
  void updateBlockExplorer(AvailableBlockExplorer explorer) {
    setState(() {
      curBlockExplorer = explorer;
    });
  }

  // Set encrypted secret
  void setEncryptedSecret(String secret) {
    setState(() {
      encryptedSecret = secret;
    });
  }

  // Reset encrypted secret
  void resetEncryptedSecret() {
    setState(() {
      encryptedSecret = null;
    });
  }

  // Change theme
  void updateTheme(ThemeSetting theme, {bool setIcon = true}) {
    setState(() {
      curTheme = theme.getTheme();
    });
    if (setIcon) {
      AppIcon.setAppIcon(theme.getTheme().appIcon);
    }
  }

  // Change natricon setting
  void setNatriconOn(bool natriconOn) {
    setState(() {
      this.natriconOn = natriconOn;
    });
  }

  void disconnect() {
    sl.get<AccountService>().reset(suspend: true);
  }

  void reconnect() {
    sl.get<AccountService>().initCommunication(unsuspend: true);
  }

  void lockCallback() {
    _locked = true;
  }

  void unlockCallback() {
    _locked = false;
  }

  ///
  /// When an error is returned from server
  ///
  Future<void> handleErrorResponse(ErrorResponse errorResponse) async {
    sl.get<AccountService>().processQueue();
    if (errorResponse.error == null) {
      return;
    }
  }

  /// Handle account_subscribe response
  void handleSubscribeResponse(SubscribeResponse response) {
    // Combat spam by raising minimum receive if pending block count is large enough
    if (response.pendingCount != null && response.pendingCount > 50) {
      // Bump min receive to 0.05 NANO
      receiveThreshold = BigInt.from(5).pow(28).toString();
    }
    // Set currency locale here for the UI to access
    sl.get<SharedPrefsUtil>().getCurrency(deviceLocale).then((currency) {
      setState(() {
        currencyLocale = currency.getLocale().toString();
        curCurrency = currency;
      });
    });
    // Server gives us a UUID for future requests on subscribe
    if (response.uuid != null) {
      sl.get<SharedPrefsUtil>().setUuid(response.uuid);
    }
    EventTaxiImpl.singleton().fire(ConfirmationHeightChangedEvent(
        confirmationHeight: response.confirmationHeight));
    setState(() {
      wallet.loading = false;
      wallet.frontier = response.frontier;
      wallet.representative = response.representative;
      wallet.representativeBlock = response.representativeBlock;
      wallet.openBlock = response.openBlock;
      wallet.blockCount = response.blockCount;
      wallet.confirmationHeight = response.confirmationHeight;
      if (response.balance == null) {
        wallet.accountBalance = BigInt.from(0);
      } else {
        wallet.accountBalance = BigInt.tryParse(response.balance);
      }
      wallet.localCurrencyPrice = response.price.toString();
      wallet.btcPrice = response.btcPrice.toString();
      sl.get<AccountService>().pop();
      sl.get<AccountService>().processQueue();
    });
  }

  /// Handle callback response
  /// Typically this means we need to pocket transactions
  Future<void> handleCallbackResponse(CallbackResponse resp) async {
    if (_locked) {
      return;
    }
    log.d("Received callback ${json.encode(resp.toJson())}");
    if (resp.isSend != "true") {
      sl.get<AccountService>().processQueue();
      return;
    }
    PendingResponseItem pendingItem = PendingResponseItem(
        hash: resp.hash, source: resp.account, amount: resp.amount);
    String receivedHash = await handlePendingItem(pendingItem);
    if (receivedHash != null) {
      AccountHistoryResponseItem histItem = AccountHistoryResponseItem(
          type: BlockTypes.RECEIVE,
          account: resp.account,
          amount: resp.amount,
          hash: receivedHash);
      if (!wallet.history.contains(histItem)) {
        setState(() {
          wallet.history.insert(0, histItem);
          wallet.accountBalance += BigInt.parse(resp.amount);
          // Send list to home screen
          EventTaxiImpl.singleton()
              .fire(HistoryHomeEvent(items: wallet.history));
        });
      }
    }
  }

  Future<String> handlePendingItem(PendingResponseItem item) async {
    if (pendingRequests.contains(item.hash)) {
      return null;
    }
    pendingRequests.add(item.hash);
    BigInt amountBigInt = BigInt.tryParse(item.amount);
    sl.get<Logger>().d("Handling ${item.hash} pending");
    if (amountBigInt != null) {
      if (amountBigInt < BigInt.parse(receiveThreshold)) {
        pendingRequests.remove(item.hash);
        return null;
      }
    }
    if (wallet.openBlock == null) {
      // Publish open
      sl.get<Logger>().d("Handling ${item.hash} as open");
      try {
        ProcessResponse resp = await sl.get<AccountService>().requestOpen(
            item.amount, item.hash, wallet.address, await _getPrivKey());
        wallet.openBlock = resp.hash;
        wallet.frontier = resp.hash;
        pendingRequests.remove(item.hash);
        alreadyReceived.add(item.hash);
        return resp.hash;
      } catch (e) {
        pendingRequests.remove(item.hash);
        sl.get<Logger>().e("Error creating open", e);
      }
    } else {
      // Publish receive
      sl.get<Logger>().d("Handling ${item.hash} as receive");
      try {
        ProcessResponse resp = await sl.get<AccountService>().requestReceive(
            wallet.representative,
            wallet.frontier,
            item.amount,
            item.hash,
            wallet.address,
            await _getPrivKey());
        wallet.frontier = resp.hash;
        pendingRequests.remove(item.hash);
        alreadyReceived.add(item.hash);
        return resp.hash;
      } catch (e) {
        pendingRequests.remove(item.hash);
        sl.get<Logger>().e("Error creating receive", e);
      }
    }
    return null;
  }

  /// Request balances for accounts in our database
  Future<void> _requestBalances() async {
    List<Account> accounts =
        await sl.get<DBHelper>().getAccounts(await getSeed());
    List<String> addressToRequest = List();
    accounts.forEach((account) {
      if (account.address != null) {
        addressToRequest.add(account.address);
      }
    });
    AccountsBalancesResponse resp = await sl
        .get<AccountService>()
        .requestAccountsBalances(addressToRequest);
    sl.get<DBHelper>().getAccounts(await getSeed()).then((accounts) {
      accounts.forEach((account) {
        resp.balances.forEach((address, balance) {
          String combinedBalance = (BigInt.tryParse(balance.balance) +
                  BigInt.tryParse(balance.pending))
              .toString();
          if (address == account.address &&
              combinedBalance != account.balance) {
            sl.get<DBHelper>().updateAccountBalance(account, combinedBalance);
          }
        });
      });
    });
  }

  Future<void> requestUpdate({bool pending = true}) async {
    if (wallet != null &&
        wallet.address != null &&
        Address(wallet.address).isValid()) {
      String uuid = await sl.get<SharedPrefsUtil>().getUuid();
      String fcmToken;
      bool notificationsEnabled;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        notificationsEnabled =
            await sl.get<SharedPrefsUtil>().getNotificationsOn();
      } catch (e) {
        fcmToken = null;
        notificationsEnabled = false;
      }
      sl.get<AccountService>().clearQueue();
      sl.get<AccountService>().queueRequest(SubscribeRequest(
          account: wallet.address,
          currency: curCurrency.getIso4217Code(),
          uuid: uuid,
          fcmToken: fcmToken,
          notificationEnabled: notificationsEnabled));
      sl.get<AccountService>().processQueue();
      // Request account history

      // Choose correct blockCount to minimize bandwidth
      // This is can still be improved because history excludes change/open, blockCount doesn't
      // Get largest count we have + 5 (just a safe-buffer)
      int count = 500;
      if (wallet.history != null && wallet.history.length > 1) {
        count = 50;
      }
      try {
        AccountHistoryResponse resp = await sl
            .get<AccountService>()
            .requestAccountHistory(wallet.address, count: count);
        _requestBalances();
        bool postedToHome = false;
        // Iterate list in reverse (oldest to newest block)
        for (AccountHistoryResponseItem item in resp.history) {
          // If current list doesn't contain this item, insert it and the rest of the items in list and exit loop
          if (!wallet.history.contains(item)) {
            int startIndex = 0; // Index to start inserting into the list
            int lastIndex = resp.history.indexWhere((item) => wallet.history
                .contains(
                    item)); // Last index of historyResponse to insert to (first index where item exists in wallet history)
            lastIndex = lastIndex <= 0 ? resp.history.length : lastIndex;
            setState(() {
              wallet.history
                  .insertAll(0, resp.history.getRange(startIndex, lastIndex));
              // Send list to home screen
              EventTaxiImpl.singleton()
                  .fire(HistoryHomeEvent(items: wallet.history));
            });
            postedToHome = true;
            break;
          }
        }
        setState(() {
          wallet.historyLoading = false;
        });
        if (!postedToHome) {
          EventTaxiImpl.singleton()
              .fire(HistoryHomeEvent(items: wallet.history));
        }
        sl.get<AccountService>().pop();
        sl.get<AccountService>().processQueue();
        // Receive pendings
        if (pending) {
          pendingRequests.clear();
          PendingResponse pendingResp = await sl
              .get<AccountService>()
              .getPending(wallet.address, max(wallet.blockCount ?? 0, 10),
                  threshold: receiveThreshold);
          // Initiate receive/open request for each pending
          for (String hash in pendingResp.blocks.keys) {
            PendingResponseItem pendingResponseItem = pendingResp.blocks[hash];
            pendingResponseItem.hash = hash;
            String receivedHash = await handlePendingItem(pendingResponseItem);
            if (receivedHash != null) {
              AccountHistoryResponseItem histItem = AccountHistoryResponseItem(
                  type: BlockTypes.RECEIVE,
                  account: pendingResponseItem.source,
                  amount: pendingResponseItem.amount,
                  hash: receivedHash);
              if (!wallet.history.contains(histItem)) {
                setState(() {
                  wallet.history.insert(0, histItem);
                  wallet.accountBalance +=
                      BigInt.parse(pendingResponseItem.amount);
                  // Send list to home screen
                  EventTaxiImpl.singleton()
                      .fire(HistoryHomeEvent(items: wallet.history));
                });
              }
            }
          }
        }
      } catch (e) {
        // TODO handle account history error
        sl.get<Logger>().e("account_history e", e);
      }
    }
  }

  Future<void> requestSubscribe() async {
    if (wallet != null &&
        wallet.address != null &&
        Address(wallet.address).isValid()) {
      String uuid = await sl.get<SharedPrefsUtil>().getUuid();
      String fcmToken;
      bool notificationsEnabled;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        notificationsEnabled =
            await sl.get<SharedPrefsUtil>().getNotificationsOn();
      } catch (e) {
        fcmToken = null;
        notificationsEnabled = false;
      }
      sl.get<AccountService>().removeSubscribeHistoryPendingFromQueue();
      sl.get<AccountService>().queueRequest(SubscribeRequest(
          account: wallet.address,
          currency: curCurrency.getIso4217Code(),
          uuid: uuid,
          fcmToken: fcmToken,
          notificationEnabled: notificationsEnabled));
      sl.get<AccountService>().processQueue();
    }
  }

  void logOut() {
    setState(() {
      wallet = AppWallet();
      encryptedSecret = null;
    });
    sl.get<DBHelper>().dropAccounts();
    sl.get<AccountService>().clearQueue();
  }

  Future<String> _getPrivKey() async {
    String seed = await getSeed();
    return NanoUtil.seedToPrivate(seed, selectedAccount.index);
  }

  Future<String> getSeed() async {
    String seed;
    if (encryptedSecret != null) {
      seed = NanoHelpers.byteToHex(NanoCrypt.decrypt(
          encryptedSecret, await sl.get<Vault>().getSessionKey()));
    } else {
      seed = await sl.get<Vault>().getSeed();
    }
    return seed;
  }

  // Simple build method that just passes this state through
  // your InheritedWidget
  @override
  Widget build(BuildContext context) {
    return _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }
}
