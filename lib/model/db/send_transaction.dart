
// Represents a SEND transaction
class SendTransaction {
  final String blockHash; // Block hash (primary key)
  final String reference; // Reference, tag or note
  final SendProtocol protocol; // Protocol used to process the transaction
  final String protocolData; // Optional data associated with the protocol

  SendTransaction(this.blockHash, this.reference, this.protocol, {this.protocolData});


  static SendProtocol methodFromInt(int ordinal) {
    switch (ordinal) {
      case 1: return SendProtocol.NONE;
      case 2: return SendProtocol.MANTA;
      case 3: return SendProtocol.HANDOFF;
      default: return null;
    }
  }

  static int methodToInt(SendProtocol method) {
    switch (method) {
      case SendProtocol.NONE:    return 1;
      case SendProtocol.MANTA:   return 2;
      case SendProtocol.HANDOFF: return 3;
      default: return 0;
    }
  }
}

enum SendProtocol {
  NONE, MANTA, HANDOFF
}

