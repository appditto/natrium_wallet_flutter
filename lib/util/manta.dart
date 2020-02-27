import 'package:flutter/material.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:manta_dart/messages.dart';
import 'package:natrium_wallet_flutter/appstate_container.dart';
import 'package:natrium_wallet_flutter/localization.dart';
import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/ui/send/send_confirm_sheet.dart';
import 'package:natrium_wallet_flutter/ui/util/ui_util.dart';
import 'package:natrium_wallet_flutter/ui/widgets/sheet_util.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';
import 'package:pointycastle/asymmetric/api.dart' show RSAPublicKey;

class MantaUtil {
  // Utilities for the manta protocol
  static Future<PaymentRequestMessage> getPaymentDetails(MantaWallet manta) async {
    await manta.connect();
    final RSAPublicKey cert = await manta.getCertificate();
    final PaymentRequestEnvelope payReqEnv = await manta.getPaymentRequest(
      cryptoCurrency: "NANO");
    if (!payReqEnv.verify(cert)) {
      throw 'Certificate verification failure';
    }
    final PaymentRequestMessage payReq = payReqEnv.unpack();
    return payReq;
  }

  static void processPaymentRequest(BuildContext context, MantaWallet manta, PaymentRequestMessage paymentRequest) {
      // Validate account balance and destination as valid
      Destination dest = paymentRequest.destinations[0];
      String rawAmountStr = NumberUtil.getAmountAsRaw(dest.amount.toString());
      BigInt rawAmount = BigInt.tryParse(rawAmountStr);
      if (!Address(dest.destination_address).isValid()) {
        UIUtil.showSnackbar(AppLocalization.of(context).qrInvalidAddress, context);
      } else if (rawAmount == null || rawAmount > StateContainer.of(context).wallet.accountBalance) {
        UIUtil.showSnackbar(AppLocalization.of(context).insufficientBalance, context);
      } else if (rawAmount < BigInt.from(10).pow(24)) {
        UIUtil.showSnackbar(AppLocalization.of(context).minimumSend.replaceAll("%1", "0.000001"), context);
      } else {
        // Is valid, proceed
        Sheets.showAppHeightNineSheet(
          context: context,
          widget: SendConfirmSheet(
                    amountRaw: rawAmountStr,
                    destination: dest.destination_address,
                    manta: manta,
                    paymentRequest: paymentRequest
          )
        );
      }    
  }
}