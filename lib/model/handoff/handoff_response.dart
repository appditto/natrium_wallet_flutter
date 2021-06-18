import 'package:json_annotation/json_annotation.dart';

import '../../localization.dart';

part 'handoff_response.g.dart';

@JsonSerializable(createToJson: false)
class HOResponse {
  @JsonKey(name: 'status', fromJson: _statusFromCode)
  final HOStatus status;

  @JsonKey(name: 'msg')
  final String message;

  @JsonKey(name: 'ref')
  final String reference;

  @JsonKey(name: 'next_id')
  final String nextId;


  HOResponse(this.status, {this.message, this.reference, this.nextId});

  factory HOResponse.fromJson(Map<String, dynamic> json) => _$HandoffResponseFromJson(json);


  String formatMessage(AppLocalization localization) {
    var errorMsg = status.getErrorMessage(localization);
    if (errorMsg != null) {
      if (message != null && status != HOStatus.block_already_associated) {
        return "$errorMsg: $message";
      } else {
        return errorMsg;
      }
    } else {
      return message ?? "";
    }
  }
}

enum HOStatus {
  accepted, invalid, expired, service_failure, insufficient_work,
  incorrect_state, incorrect_amount, block_already_associated,
  payment_already_associated, block_already_published, unknown_error
}

extension HOStatusExt on HOStatus {
  bool isSuccessful() {
    return this == HOStatus.accepted;
  }

  /// Returns the localized error message, or null if successful
  String getErrorMessage(AppLocalization localization) {
    switch (this) {
      case HOStatus.accepted:
        return null;
      case HOStatus.expired:
        return localization.handoffExpired;
      case HOStatus.block_already_associated:
        return localization.handoffPaymentAlreadyComplete;
      default:
        return localization.handoffPaymentFailed;
    }
  }
}


HOStatus _statusFromCode(int code) {
  if (code >= 0) return HOStatus.accepted;
  switch (code) {
    case -1: return HOStatus.invalid;
    case -2: return HOStatus.expired;
    case -3: return HOStatus.service_failure;
    case -4: return HOStatus.insufficient_work;
    case -5: return HOStatus.incorrect_state;
    case -6: return HOStatus.incorrect_amount;
    case -7: return HOStatus.block_already_associated;
    case -8: return HOStatus.payment_already_associated;
    case -9: return HOStatus.block_already_published;
    default: return HOStatus.unknown_error;
  }
}