import 'package:kalium_wallet_flutter/util/numberutil.dart';

/**
 * Represents the main wallet object
 */
class KaliumWallet {
  static const String defaultRepresentative = 'ban_1ka1ium4pfue3uxtntqsrib8mumxgazsjf58gidh1xeo5te3whsq8z476goo';

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


  KaliumWallet({String address, BigInt accountBalance, String frontier, String openBlock, String representativeBlock,
                String representative, String localCurrencyPrice, String nanoPrice, String btcPrice, int blockCount, String uuid}) {
    this._address = address;
    this._accountBalance = accountBalance ?? BigInt.from(-1);
    this._frontier = frontier;
    this._openBlock = openBlock;
    this._representativeBlock = representativeBlock;
    this._representative = representative;
    this._localCurrencyPrice = localCurrencyPrice ?? "0";
    this._nanoPrice = nanoPrice ?? "0";
    this._btcPrice = btcPrice ?? "0";
    this._blockCount = blockCount ?? 0;
    this._uuid = uuid;
  }

  String get address => _address;

  void set address(String address) {
    this._address = address;
  }

  BigInt get accountBalance => _accountBalance;

  void set accountBalance(BigInt accountBalance) {
    this._accountBalance = accountBalance;
  }

  // Get pretty account balance version
  String getAccountBalanceDisplay() {
    if (accountBalance == null || accountBalance < BigInt.zero) {
      return "-1";
    }
    return NumberUtil.getRawAsUsableString(_accountBalance.toString());
  }


  String get localCurrencyPrice => _localCurrencyPrice;

  set localCurrencyPrice(String value) {
    _localCurrencyPrice = value;
  }

  String get btcPrice => _btcPrice;

  set btcPrice(String value) {
    _btcPrice = value;
  }

  String get nanoPrice => _nanoPrice;

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


}