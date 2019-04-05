import 'package:json_annotation/json_annotation.dart';
import 'package:natrium_wallet_flutter/network/model/request/actions.dart';
import 'package:natrium_wallet_flutter/network/model/base_request.dart';

part 'block_info_request.g.dart';

@JsonSerializable()
class BlockInfoRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'hash')
  String hash;

  BlockInfoRequest({String hash}) {
    this.action = Actions.BLOCK_INFO;
    this.hash = hash;
  }

  factory BlockInfoRequest.fromJson(Map<String, dynamic> json) => _$BlockInfoRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BlockInfoRequestToJson(this);
}