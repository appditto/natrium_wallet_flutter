import 'package:json_annotation/json_annotation.dart';
import 'package:natrium_wallet_flutter/network/model/request/actions.dart';
import 'package:natrium_wallet_flutter/network/model/base_request.dart';

part 'process_request.g.dart';

@JsonSerializable()
class ProcessRequest extends BaseRequest {
  @JsonKey(name:'action')
  String action;

  @JsonKey(name:'block')
  String block;

  // Kalium/Natrium server accepts an optional do_work parameter. If true server will add work to this block for us
  @JsonKey(name:'do_work')
  bool doWork;

  @JsonKey(name: 'subtype')
  String subType;

  ProcessRequest({String block, bool doWork = true, String subType}) {
    this.action = Actions.PROCESS;
    this.block = block;
    this.doWork = doWork;
    this.subType = subType;
  }

  factory ProcessRequest.fromJson(Map<String, dynamic> json) => _$ProcessRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessRequestToJson(this);
}