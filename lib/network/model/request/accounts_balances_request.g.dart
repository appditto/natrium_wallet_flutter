// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_balances_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountsBalancesRequest _$AccountsBalancesRequestFromJson(
    Map<String, dynamic> json) {
  return AccountsBalancesRequest(
    accounts: (json['accounts'] as List)?.map((e) => e as String)?.toList(),
  )..action = json['action'] as String;
}

Map<String, dynamic> _$AccountsBalancesRequestToJson(
        AccountsBalancesRequest instance) =>
    <String, dynamic>{
      'action': instance.action,
      'accounts': instance.accounts,
    };
