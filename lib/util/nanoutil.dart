import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';

import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/db/account.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';

class NanoUtil {
  static String seedToPrivate(String seed, int index) {
    return NanoKeys.seedToPrivate(seed, index);
  }

  static String seedToAddress(String seed, int index) {
    return NanoAccounts.createAccount(NanoAccountType.NANO, NanoKeys.createPublicKey(seedToPrivate(seed, index)));
  }

  Future<void> loginAccount(String seed, BuildContext context) async {
    Account selectedAcct = await sl.get<DBHelper>().getSelectedAccount(seed);
    if (selectedAcct == null) {
      selectedAcct = Account(index: 0, lastAccess: 0, name: AppLocalization.of(context).defaultAccountName, selected: true);
      await sl.get<DBHelper>().saveAccount(selectedAcct);
    }
    StateContainer.of(context).updateWallet(account: selectedAcct);
  }
}
