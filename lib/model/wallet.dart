
/**
 * Represents the main wallet object
 */
class KaliumWallet {
  String _address;

  KaliumWallet({String address}) {
    this._address = address;
  }

  String get address => _address;

  void set address(String address) {
    this._address = address;
  }
}