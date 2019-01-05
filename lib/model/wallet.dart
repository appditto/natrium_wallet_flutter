import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:kalium_wallet_flutter/util/numberutil.dart';

/**
 * Represents the main wallet object
 */
class KaliumWallet {
  static const String defaultRepresentative = 'ban_1ka1ium4pfue3uxtntqsrib8mumxgazsjf58gidh1xeo5te3whsq8z476goo';

  bool _loading; // Whether or not app is initially loading
  String _address;
  BigInt _accountBalance;
  String _frontier;
  String _openBlock;
  String _representativeBlock;
  String _representative;
  String _localCurrencyPrice;
  String _nanoPrice;
  String _btcPrice;
  String _uuid;
  int _blockCount;
  List<AccountHistoryResponseItem> _history;


  KaliumWallet({String address, BigInt accountBalance, String frontier, String openBlock, String representativeBlock,
                String representative, String localCurrencyPrice, String nanoPrice, String btcPrice, int blockCount, String uuid,
                List<AccountHistoryResponseItem> history, bool loading}) {
    this._address = address;
    this._accountBalance = accountBalance ?? BigInt.zero;
    this._frontier = frontier;
    this._openBlock = openBlock;
    this._representativeBlock = representativeBlock;
    this._representative = representative;
    this._localCurrencyPrice = localCurrencyPrice ?? "0";
    this._nanoPrice = nanoPrice ?? "0";
    this._btcPrice = btcPrice ?? "0";
    this._blockCount = blockCount ?? 0;
    this._uuid = uuid;
    this._history = history ?? new List<AccountHistoryResponseItem>();
    this._loading = loading ?? true;
  }

  String get address => _address;

  set address(String address) {
    this._address = address;
  }

  BigInt get accountBalance => _accountBalance;

  set accountBalance(BigInt accountBalance) {
    this._accountBalance = accountBalance;
  }

  // Get pretty account balance version
  String getAccountBalanceDisplay() {
    if (accountBalance == null) {
      return "0";
    }
    return NumberUtil.getRawAsUsableString(_accountBalance.toString());
  }


  String get localCurrencyPrice {
    // TODO use real currency format
    Decimal converted = Decimal.parse(_localCurrencyPrice) * NumberUtil.getRawAsUsableDecimal(_accountBalance.toString());
    return NumberFormat.simpleCurrency(locale:"en_US").format(converted.toDouble());
  }

  set localCurrencyPrice(String value) {
    _localCurrencyPrice = value;
  }

  String get btcPrice {
    Decimal converted = Decimal.parse(_btcPrice) * NumberUtil.getRawAsUsableDecimal(_accountBalance.toString());
    return new NumberFormat("#,##0.00", "en_US").format(converted.toDouble());
  }

  set btcPrice(String value) {
    _btcPrice = value;
  }

  String get nanoPrice {
    Decimal converted = Decimal.parse(_nanoPrice) * NumberUtil.getRawAsUsableDecimal(_accountBalance.toString());
    return new NumberFormat("#,##0.00", "en_US").format(converted.toDouble());
  }

  set nanoPrice(String value) {
    _nanoPrice = value;
  }

  String get representative {
   return _representative ?? defaultRepresentative;
  }

  set representative(String value) {
    _representative = value;
  }

  String get representativeBlock => _representativeBlock;

  set representativeBlock(String value) {
    _representativeBlock = value;
  }

  String get openBlock => _openBlock;

  set openBlock(String value) {
    _openBlock = value;
  }

  String get frontier => _frontier;

  set frontier(String value) {
    _frontier = value;
  }

  int get blockCount => _blockCount;

  set blockCount(int value) {
    _blockCount = value;
  }

  String get uuid => _uuid;

  set uuid(String value) {
    _uuid = value;
  }

  List<AccountHistoryResponseItem> get history => _history;

  set history(List<AccountHistoryResponseItem> value) {
    _history = value;
  }

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
  }


}