import 'package:flutter_nano_core/flutter_nano_core.dart';


class NanoUtil {
  static String _seedToPrivate(String seed, int index) {
    return NanoKeys.seedToPrivate(seed, index);
  }

  static String seedToAddress(String seed) {
    return NanoAccounts.createAccount(NanoAccountType.BANANO, NanoKeys.createPublicKey(_seedToPrivate(seed, 0)));
  }
}
