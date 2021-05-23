
// Represents a SEND transaction
class SendTransaction {
  final String blockHash; // Block hash (primary key)
  final String reference; // Reference, tag or note
  final SendTxnOrigin origin; // Method used to process the transaction
  final String originData; // Data associated with the method

  SendTransaction(this.blockHash, this.reference, this.origin, {this.originData});


  static SendTxnOrigin methodFromInt(int ordinal) {
    switch (ordinal) {
      case 1: return SendTxnOrigin.STANDARD;
      case 2: return SendTxnOrigin.MANTA;
      case 3: return SendTxnOrigin.HANDOFF;
      default: return null;
    }
  }

  static int methodToInt(SendTxnOrigin method) {
    switch (method) {
      case SendTxnOrigin.STANDARD: return 1;
      case SendTxnOrigin.MANTA:    return 2;
      case SendTxnOrigin.HANDOFF:  return 3;
      default: return 0;
    }
  }
}

enum SendTxnOrigin {
  STANDARD, MANTA, HANDOFF
}

