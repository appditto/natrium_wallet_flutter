import 'package:json_annotation/json_annotation.dart';
import 'package:kalium_wallet_flutter/network/model/request/actions.dart';

part 'subscribe_request.g.dart';

@JsonSerializable()
class SubscribeRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'account')
  String account;

  @JsonKey(name:'currency')
  String currency;

  @JsonKey(name:'uuid')
  String uuid;

  @JsonKey(name:'fcm_token')
  String fcmToken;

  SubscribeRequest({String account, String currency, String uuid, String fcmToken}) {
    this.account = Actions.SUBSCRIBE_ACTION;
    this.currency = currency ?? null;
    if (uuid != null) {
      this.uuid = uuid;
      this.account = null;
    } else {
      this.account = account ?? null;
    }
    this.fcmToken = fcmToken ?? null;
  }

  factory SubscribeRequest.fromJson(Map<String, dynamic> json) => _$SubscribeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeRequestToJson(this);
}