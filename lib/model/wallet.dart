
/**
 * State representing the main wallet
 */
class WalletState {
  final String privateKey;
  final String publicKey;
  final String address;
  final String representative;
  final String frontierBlock;
  final String uuid;
  final BigInt accountBalance;
  final int blockCount;

  WalletState({this.privateKey,
               this.publicKey,
               this.address,
               this.representative,
               this.frontierBlock,
               this.uuid,
               this.accountBalance,
               this.blockCount = 0});

  factory WalletState.initial() =>
    new WalletState();
}