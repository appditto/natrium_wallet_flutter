import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:logger/logger.dart';
import 'package:natrium_wallet_flutter/model/handoff/handoff_channels.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';

import '../address.dart';

part 'handoff_payment_req.g.dart';

/// Represents a payment request specification, containing payment and handoff
/// information. Entered into the app externally through QR or URI.
@JsonSerializable()
class HOPaymentRequest {

  @JsonKey(name:'id', required: true)
  String paymentId;

  @JsonKey(name:'c', required: true)
  Map<String, dynamic> channels;

  @JsonKey(name:'d')
  String destinationAddress;

  @JsonKey(name:'a', fromJson: _parseBigInt, toJson: _bigIntToString)
  BigInt amount;

  @JsonKey(name:'v', defaultValue: false)
  bool variableAmount;

  @JsonKey(name:'w', defaultValue: false)
  bool requiresWork;


  HOPaymentRequest(this.paymentId, this.channels, this.destinationAddress,
      this.amount, this.variableAmount, this.requiresWork);


  /// Infers, populates and validates properties post-construction
  void _processParams(String altAmount, String altAddr) {
    amount ??= altAddr != null ? BigInt.tryParse(altAmount) : null;
    destinationAddress ??= altAddr;

    if (amount == null || amount == BigInt.zero) {
      // No amount specified, assume any amount may be sent (>= 1 raw)
      amount = BigInt.one;
      variableAmount = true;
    }

    if (paymentId == null || channels.isEmpty || destinationAddress == null
        || !Address(destinationAddress).isValid()
        || (amount != null && amount <= BigInt.zero))
      throw 'Invalid handoff specification';
    if (requiresWork) //todo handoff implement wallet-provided work gen
      throw "Wallet doesn't support handoff work generation";
  }


  /// Returns the handoff channel processor object for the given [channel] if
  /// supported, or null if the channel type isn't available.
  HOChannelDispatcher getChannel(HOChannel channel) {
    var properties = channels[channel.name];
    if (properties != null) {
      try {
        return channel.parse(properties);
      } catch (e) {
        sl.get<Logger>().w("Failed to parse handoff channel ${channel.name} from spec", e);
      }
    }
    return null;
  }

  /// Returns the handoff channel object for the first of the given [channels]
  /// that are available, or null if none of the requested channels are
  /// available.
  HOChannelDispatcher selectChannel({List<HOChannel> channels = HOChannel.values}) {
    for (var cType in channels) {
      var channel = getChannel(cType);
      if (channel != null)
        return channel;
    }
    return null;
  }


  factory HOPaymentRequest.fromBase64(String data,
      {String altAmount, String altAddr}) {
    var jsonVal = utf8.decode(base64.decode(base64.normalize(data)));
    return HOPaymentRequest.fromJson(json.decode(jsonVal),
        altAmount: altAmount, altAddr: altAddr);
  }

  factory HOPaymentRequest.fromJson(Map<String, dynamic> json,
      {String altAmount, String altAddr}) {
    var spec = _$HandoffPaymentSpecFromJson(json);
    spec._processParams(altAmount, altAddr);
    return spec;
  }

  Map<String, dynamic> toJson() => _$HandoffPaymentSpecToJson(this);
}

BigInt _parseBigInt(val) => val != null ? BigInt.parse(val) : null;
String _bigIntToString(BigInt val) => val != null ? val.toString() : null;