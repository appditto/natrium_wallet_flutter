import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';

import 'package:kalium_wallet_flutter/network/model/block_types.dart';

part 'state_block.g.dart';

@JsonSerializable()
class StateBlock {
  @JsonKey(name:'type')
  String type;

  @JsonKey(name:'previous')
  String previous;

  @JsonKey(name:'account')
  String account;

  @JsonKey(name:'representative')
  String representative;

  @JsonKey(name:'balance')
  String balance;

  @JsonKey(name:'link')
  String link;

  @JsonKey(name:'signature')
  String signature;

  // Represents the amount this block intends to send
  // should be used to calculate balance after this send
  @JsonKey(ignore:true)
  String sendAmount;
  // Represents subtype of this block: send/receive/change/openm
  @JsonKey(ignore:true)
  String subType;

  /// StateBlock constructor.
  /// subtype is one of "send", "receive", "change", "open"
  /// In the case of subtype == "send" or subtype == "receive", 
  /// then balance should be send amount (not balance after send).
  /// This is by design of this app, where we get previous balance in a server request 
  /// and update it later before signing
  StateBlock({@required String subtype, @required String previous, @required String representative,
              @required String balance, @required String link, @required String account}) {
    this.link = link;
    this.subType = subtype;
    this.type = BlockTypes.STATE;
    this.previous = previous;
    this.account = account;
    this.representative = representative;
    if (subtype == BlockTypes.SEND || subtype == BlockTypes.RECEIVE) {
      this.sendAmount = balance;
    } else {
      this.balance = balance;
    }
  }

  /// Used to set balance after receiving previous balance info from server
  void setBalance(String previousBalance) {
    if (this.sendAmount == null) { return null; }
    BigInt previous = BigInt.parse(previousBalance);
    if (this.subType == BlockTypes.SEND) {
      // Subtract sendAmount from previous balance
      this.balance = (previous - BigInt.parse(sendAmount)).toString();
    } else if (this.subType == BlockTypes.RECEIVE) {
      // Add previous balance to sendAmount
      this.balance = (previous + BigInt.parse(sendAmount)).toString();
    }
  }

  /// Sign block with private key
  /// Returns signature if signed, null if this block is invalid and can't be signed
  String sign(String privateKey) {
    if (this.balance == null) { return null; }
    String hash = NanoBlocks.computeStateHash(
                      NanoAccountType.BANANO,
                      this.account,
                      this.previous,
                      this.representative,
                      BigInt.parse(this.balance),
                      this.link
                  );

  }

  factory StateBlock.fromJson(Map<String, dynamic> json) => _$StateBlockFromJson(json);
  Map<String, dynamic> toJson() => _$StateBlockToJson(this);
}