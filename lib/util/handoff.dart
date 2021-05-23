import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_channels.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_spec.dart';
import 'package:natrium_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:natrium_wallet_flutter/ui/send/send_sheet.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheet_util.dart';

import '../appstate_container.dart';
import '../localization.dart';
import '../service_locator.dart';

/// Static utility methods for the block handoff protocol.
class HandoffUtil {

  static final RegExp _uriRegex = RegExp(r"^nanohandoff:/*([\w=-]+)$", caseSensitive: false);


  static bool matchesUri(String val) {
    return _uriRegex.hasMatch(val);
  }

  /// Parses a handoff URI string, returning null if not a URI or invalid
  static HandoffPaymentSpec parseUri(String uri) {
    var match = _uriRegex.firstMatch(uri);
    if (match == null) return null;
    try {
      return HandoffPaymentSpec.fromBase64(match.group(1));
    } catch (e) {
      sl.get<Logger>().w("Invalid handoff spec in nanohandoff URI", e);
      return null;
    }
  }

  /// Handles a payment request, showing the payment screen.
  static void handlePayment(BuildContext context, HandoffPaymentSpec spec,
      HandoffChannel channel, {String quickSendAmount}) {
    if (!StateContainer.of(context).wallet.loading
        && spec.amount > StateContainer.of(context).wallet.accountBalance) {
      UIUtil.showSnackbar(AppLocalization.of(context).insufficientBalance, context);
    } else {
      if (spec.variableAmount) {
        // Variable amount, show entry sheet
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(
                localCurrency: StateContainer.of(context).curCurrency,
                handoffPaymentSpec: spec,
                handoffChannel: channel,
                quickSendAmount: quickSendAmount,
            )
        );
      } else {
        // Exact amount, show confirmation sheet
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendConfirmSheet(
                amountRaw: spec.amount.toString(),
                destination: spec.destinationAddress,
                handoffPaymentSpec: spec,
                handoffChannel: channel
            ));
      }
    }
  }

}