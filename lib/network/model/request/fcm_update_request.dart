import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:natrium_wallet_flutter/network/model/request/actions.dart';
import 'package:natrium_wallet_flutter/network/model/base_request.dart';

part 'fcm_update_request.g.dart';

@JsonSerializable()
class FcmUpdateRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'account', includeIfNull: false)
  String account;

  @JsonKey(name:'fcm_token_v2', includeIfNull: false)
  String fcmToken;

  @JsonKey(name:'enabled')
  bool enabled;

  FcmUpdateRequest({@required String account, @required String fcmToken, @required bool enabled}) : super() {
    this.action = Actions.FCM_UPDATE;
    this.account = account;
    this.fcmToken = fcmToken;
    this.enabled = enabled;
  }

  factory FcmUpdateRequest.fromJson(Map<String, dynamic> json) => _$FcmUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FcmUpdateRequestToJson(this);
}