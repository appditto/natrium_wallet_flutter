import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/network/model/response/accounts_balances_response.dart';

class AccountsBalancesEvent implements Event {
  final AccountsBalancesResponse response;
  final bool transfer;

  AccountsBalancesEvent({this.response, this.transfer});
}