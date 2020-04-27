// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_balances_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountsBalancesResponse _$AccountsBalancesResponseFromJson(
    Map<String, dynamic> json) {
  return AccountsBalancesResponse(
    balances: (json['balances'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k,
          e == null
              ? null
              : AccountBalanceItem.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$AccountsBalancesResponseToJson(
        AccountsBalancesResponse instance) =>
    <String, dynamic>{
      'balances': instance.balances,
    };
