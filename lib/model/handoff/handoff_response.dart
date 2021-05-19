import 'package:json_annotation/json_annotation.dart';

import '../../localization.dart';

part 'handoff_response.g.dart';

@JsonSerializable(createToJson: false)
class HandoffResponse {
  @JsonKey(name: 'status', fromJson: _statusFromCode)
  final HandoffStatus status;

  @JsonKey(name: 'msg')
  final String message;

  @JsonKey(name: 'ref')
  final String reference;

  HandoffResponse(this.status, {this.message, this.reference});

  factory HandoffResponse.fromJson(Map<String, dynamic> json) => _$HandoffResponseFromJson(json);


  String formatMessage(AppLocalization localization) {
    var errorMsg = status.getErrorMessage(localization);
    if (errorMsg != null) {
      return errorMsg + (message != null ? ": $message" : "");
    } else {
      return message;
    }
  }
}

enum HandoffStatus {
  accepted, invalid, expired, service_failure, insufficient_work,
  incorrect_state, incorrect_amount, block_already_associated,
  payment_already_associated, block_already_published, unknown_error
}

extension HandoffStatusExt on HandoffStatus {
  bool isSuccessful() {
    return this == HandoffStatus.accepted;
  }

  /// Returns the localized error message, or null if successful
  String getErrorMessage(AppLocalization localization) {
    switch (this) {
      case HandoffStatus.accepted:
        return null;
      case HandoffStatus.expired:
        return localization.handoffExpired;
      case HandoffStatus.block_already_associated:
        return localization.handoffAlreadyCompleted;
      default:
        return localization.handoffFailure;
    }
  }
}


HandoffStatus _statusFromCode(int code) {
  if (code >= 0) return HandoffStatus.accepted;
  switch (code) {
    case -1: return HandoffStatus.invalid;
    case -2: return HandoffStatus.expired;
    case -3: return HandoffStatus.service_failure;
    case -4: return HandoffStatus.insufficient_work;
    case -5: return HandoffStatus.incorrect_state;
    case -6: return HandoffStatus.incorrect_amount;
    case -7: return HandoffStatus.block_already_associated;
    case -8: return HandoffStatus.payment_already_associated;
    case -9: return HandoffStatus.block_already_published;
    default: return HandoffStatus.unknown_error;
  }
}