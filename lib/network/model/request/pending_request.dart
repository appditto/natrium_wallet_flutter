import 'package:json_annotation/json_annotation.dart';
import 'package:natrium_wallet_flutter/network/model/request/actions.dart';
import 'package:natrium_wallet_flutter/network/model/base_request.dart';

part 'pending_request.g.dart';

@JsonSerializable()
class PendingRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:"account")
  String account;

  @JsonKey(name:"source")
  bool source;

  @JsonKey(name:"count")
  int count;

  @JsonKey(name:"include_active")
  bool includeActive;

  @JsonKey(name:"threshold", includeIfNull: false)
  String threshold;

  PendingRequest({this.action = Actions.PENDING, this.account, this.source = true, this.count, this.threshold, this.includeActive = true});

  factory PendingRequest.fromJson(Map<String, dynamic> json) => _$PendingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PendingRequestToJson(this);
}