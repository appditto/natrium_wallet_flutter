import 'package:json_annotation/json_annotation.dart';

import 'package:natrium_wallet_flutter/network/model/response/block_info_item.dart';

part 'blocks_info_response.g.dart';

@JsonSerializable()
class BlocksInfoResponse {
  @JsonKey(name:'blocks')
  Map<String, BlockInfoItem> blocks;

  BlocksInfoResponse({Map<String, BlockInfoItem> blocks}):super() {
    this.blocks = blocks;
  }

  factory BlocksInfoResponse.fromJson(Map<String, dynamic> json) => _$BlocksInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BlocksInfoResponseToJson(this);
}
