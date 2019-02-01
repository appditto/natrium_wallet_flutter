// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceResponse _$PriceResponseFromJson(Map<String, dynamic> json) {
  return PriceResponse()
    ..currency = json['currency'] as String
    ..price = json['price'] == null ? null : _toDouble(json['price'])
    ..btcPrice = json['btc'] == null ? null : _toDouble(json['btc']);
}

Map<String, dynamic> _$PriceResponseToJson(PriceResponse instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'price': instance.price,
      'btc': instance.btcPrice
    };
