import 'package:json_annotation/json_annotation.dart';
import 'package:natrium_wallet_flutter/network/model/request/actions.dart';
import 'package:natrium_wallet_flutter/network/model/base_request.dart';

part 'accounts_balances_request.g.dart';

@JsonSerializable()
class AccountsBalancesRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'accounts')
  List<String> accounts;

  AccountsBalancesRequest({List<String> accounts}) {
    this.action = Actions.ACCOUNTS_BALANCES;
    this.accounts = accounts ?? [];
  }

  factory AccountsBalancesRequest.fromJson(Map<String, dynamic> json) => _$AccountsBalancesRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AccountsBalancesRequestToJson(this);
}