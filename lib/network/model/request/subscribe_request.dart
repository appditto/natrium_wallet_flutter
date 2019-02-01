import 'package:json_annotation/json_annotation.dart';
import 'package:kalium_wallet_flutter/network/model/request/actions.dart';
import 'package:kalium_wallet_flutter/network/model/base_request.dart';

part 'subscribe_request.g.dart';

@JsonSerializable()
class SubscribeRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'account', includeIfNull: false)
  String account;

  @JsonKey(name:'currency', includeIfNull: false)
  String currency;

  @JsonKey(name:'uuid', includeIfNull: false)
  String uuid;

  @JsonKey(name:'fcm_token_v2', includeIfNull: false)
  String fcmToken;

  @JsonKey(name:'notification_enabled')
  bool notificationEnabled;

  SubscribeRequest({String account, String currency, String uuid, String fcmToken, bool notificationEnabled}) : super() {
    this.action = Actions.SUBSCRIBE;
    this.currency = currency ?? null;
    if (uuid != null) {
      this.uuid = uuid;
      this.account = null;
    } else {
      this.account = account ?? null;
    }
    this.fcmToken = fcmToken ?? null;
    this.notificationEnabled = notificationEnabled;
  }

  factory SubscribeRequest.fromJson(Map<String, dynamic> json) => _$SubscribeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeRequestToJson(this);
}