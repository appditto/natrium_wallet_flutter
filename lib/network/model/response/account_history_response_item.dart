import 'package:json_annotation/json_annotation.dart';

import 'package:natrium_wallet_flutter/model/address.dart';
import 'package:natrium_wallet_flutter/util/numberutil.dart';

part 'account_history_response_item.g.dart';

int _toInt(String v) => v == null ? 0 : int.tryParse(v);

@JsonSerializable()
class AccountHistoryResponseItem {
  @JsonKey(name:'type')
  String type;

  @JsonKey(name:'account')
  String account;

  @JsonKey(name:'amount')
  String amount;

  @JsonKey(name:'hash')
  String hash;

  @JsonKey(name:'height', fromJson: _toInt)
  int height;

  @JsonKey(ignore: true)
  bool confirmed;

  AccountHistoryResponseItem({String type, String account, String amount, String hash, int height, this.confirmed}) {
    this.type = type;
    this.account = account;
    this.amount = amount;
    this.hash = hash;
    this.height = height;
  }

  String getShortString() {
    return new Address(this.account).getShortString();
  }

  String getShorterString() {
    return new Address(this.account).getShorterString();
  }

  /**
   * Return amount formatted for use in the UI
   */
  String getFormattedAmount() {
    return NumberUtil.getRawAsUsableString(amount);
  }

  factory AccountHistoryResponseItem.fromJson(Map<String, dynamic> json) => _$AccountHistoryResponseItemFromJson(json);
  Map<String, dynamic> toJson() => _$AccountHistoryResponseItemToJson(this);

  bool operator ==(o) => o is AccountHistoryResponseItem && o.hash == hash;
  int get hashCode => hash.hashCode;
}