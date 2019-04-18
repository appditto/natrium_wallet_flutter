import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';

import 'package:natrium_wallet_flutter/model/db/appdb.dart';
import 'package:natrium_wallet_flutter/model/db/account.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';

class NanoUtil {
  static String seedToPrivate(Map<dynamic, dynamic> params) {
    return NanoKeys.seedToPrivate(params['seed'], params['index']);
  }

  Future<String> seedToPrivateInIsolate(String seed, int index) async {
    return await compute(NanoUtil.seedToPrivate, {'seed':seed, 'index':index});
  }

  static String seedToAddress(Map<dynamic, dynamic> params) {
    return NanoAccounts.createAccount(NanoAccountType.NANO, NanoKeys.createPublicKey(seedToPrivate(params)));
  }

  Future<String> seedToAddressInIsolate(String seed, int index) async {
    return await compute(NanoUtil.seedToAddress, {'seed':seed, 'index':index});
  }

  Future<void> loginAccount(BuildContext context) async {
    Account selectedAcct = await sl.get<DBHelper>().getSelectedAccount();
    if (selectedAcct == null) {
      selectedAcct = Account(index: 0, lastAccess: 0, name: AppLocalization.of(context).defaultAccountName, selected: true);
      await sl.get<DBHelper>().saveAccount(selectedAcct);
    }
    await StateContainer.of(context).updateWallet(account: selectedAcct);
  }
}
