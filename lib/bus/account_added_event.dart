import 'package:event_taxi/event_taxi.dart';
import 'package:natrium_wallet_flutter/model/db/account.dart';

class AccountAddedEvent implements Event {
  Account account;

  AccountAddedEvent({this.account});
}