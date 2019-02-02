import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/network/model/response/blocks_info_response.dart';

class BlocksInfoEvent implements Event {
  final BlocksInfoResponse response;

  BlocksInfoEvent({this.response});
}