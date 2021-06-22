
// Represents a SEND transaction
class PaymentInfo {
  final String reference; // Reference text, tag or label
  final PaymentProtocol protocol; // Protocol used to process the transaction
  final String protocolData; // Optional data associated with the protocol

  PaymentInfo(this.reference, this.protocol, {this.protocolData});
}


enum PaymentProtocol {
  NONE, MANTA, HANDOFF
}

extension PaymentProtocolExt on PaymentProtocol {
  static PaymentProtocol fromInt(int ordinal) {
    switch (ordinal) {
      case 1: return PaymentProtocol.NONE;
      case 2: return PaymentProtocol.MANTA;
      case 3: return PaymentProtocol.HANDOFF;
      default: return null;
    }
  }

  int get intVal {
    switch (this) {
      case PaymentProtocol.NONE:    return 1;
      case PaymentProtocol.MANTA:   return 2;
      case PaymentProtocol.HANDOFF: return 3;
      default: return 0; // Null or unknown
    }
  }
}