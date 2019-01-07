import 'package:json_annotation/json_annotation.dart';
import 'package:kalium_wallet_flutter/network/model/request/actions.dart';
import 'package:kalium_wallet_flutter/network/model/base_request.dart';

part 'blocks_info_request.g.dart';

@JsonSerializable()
class BlocksInfoRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'hashes')
  List<String> hashes;

  @JsonKey(name:'balance')
  bool balance;

  BlocksInfoRequest({List<String> hashes, bool balance}) {
    this.action = Actions.BLOCKS_INFO;
    this.hashes = hashes;
    this.balance = balance ?? true;
  }

  factory BlocksInfoRequest.fromJson(Map<String, dynamic> json) => _$BlocksInfoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BlocksInfoRequestToJson(this);
}