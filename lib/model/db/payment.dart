
// Represents a SEND transaction
class PaymentTxn {
  final String blockHash; // Block hash (primary key)
  final String reference; // Reference, tag or note
  final PaymentProtocol protocol; // Protocol used to process the transaction
  final String protocolData; // Optional data associated with the protocol

  PaymentTxn(this.blockHash, this.reference, this.protocol, {this.protocolData});


  static PaymentProtocol methodFromInt(int ordinal) {
    switch (ordinal) {
      case 1: return PaymentProtocol.NONE;
      case 2: return PaymentProtocol.MANTA;
      case 3: return PaymentProtocol.HANDOFF;
      default: return null;
    }
  }

  static int methodToInt(PaymentProtocol method) {
    switch (method) {
      case PaymentProtocol.NONE:    return 1;
      case PaymentProtocol.MANTA:   return 2;
      case PaymentProtocol.HANDOFF: return 3;
      default: return 0;
    }
  }
}

enum PaymentProtocol {
  NONE, MANTA, HANDOFF
}

