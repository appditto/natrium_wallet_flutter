import 'package:logging/logging.dart';
import 'package:manta_dart/manta_wallet.dart';
import 'package:manta_dart/messages.dart';
import 'package:pointycastle/asymmetric/api.dart' show RSAPublicKey;

class MantaUtil {
  final Logger log = Logger("MantaUtil");

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
}