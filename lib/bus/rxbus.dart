import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

// Tags for event bus listeners
const String RX_CONN_STATUS_TAG = 'fkalium_conn_status_tag';
const String RX_SUBSCRIBE_TAG = 'fkalium_sub_tag';
const String RX_HISTORY_TAG = 'fkalium_history_tag';
const String RX_HISTORY_HOME_TAG = 'fkalium_history_home_tag';
const String RX_PRICE_RESP_TAG = 'fkalium_price_response_tag';
const String RX_BLOCKS_INFO_RESP_TAG = 'fkalium_blocks_info_response_tag';
const String RX_PROCESS_TAG = 'fkalium_process_tag';
const String RX_CALLBACK_TAG = 'fkalium_callback_tag';
const String RX_SEND_COMPLETE_TAG = 'fkalium_send_complete_tag';
const String RX_PENDING_RESP_TAG = 'fkalium_pending_response';
const String RX_ERROR_RESP_TAG = 'fkalium_err_response';
const String RX_REP_CHANGED_TAG = 'fkalium_rep_changed_tag';
const String RX_SEND_FAILED_TAG = 'fkalium_send_failed_tag';
// Contact added/removed on settings sheet
const String RX_CONTACT_ADDED_TAG = 'fkalium_contact_added_tag';
const String RX_CONTACT_REMOVED_TAG = 'fkalium_contact_removed_tag';
// Contact added/removed for home page
const String RX_CONTACT_ADDED_ALT_TAG = 'fkalium_contact_added_alt_tag';
const String RX_CONTACT_MODIFIED_TAG = 'fkalium_contact_modified_tag';
// UI Event for monKey overlay closing
const String RX_MONKEY_OVERLAY_CLOSED_TAG = 'fkalium_monkey_closed_tag';
// UI Event for deep link processed
const String RX_DEEP_LINK_TAG = 'fkalium_deep_link_tag';
// Related to Trasnfer feature
const String RX_ACCOUNTS_BALANCES_TAG = 'fkalium_accounts_balances_tag';

/**
 * RXBus using RXDart
 * 
 * Based on https://github.com/huclengyue/FlutterRxBus
 */
class Bus {
  PublishSubject _subject;
  String _tag;

  PublishSubject get subject => _subject;

  String get tag => _tag;

  Bus(String tag) {
    this._tag = tag;
    _subject = PublishSubject();
  }
}

class RxBus {
  static final RxBus _singleton = new RxBus._internal();

  RxBus._internal();

  factory RxBus() {
    return _singleton;
  }

  static List<Bus> _list = List();

  /// Listen for events. Each time the listener is turned on, a new [PublishSubject] will be created to prevent duplicate listen events.
  static Observable<T> register<T>({@required String tag}) {
    Bus _eventBus;
    //The tag that has already been registered does not need to be re-registered.
    if (_list.isNotEmpty) {
      _list.forEach((bus) {
        if (bus.tag == tag) {
          _eventBus = bus;
          return;
        }
      });
      if (_eventBus == null) {
        _eventBus = Bus(tag);
        _list.add(_eventBus);
      }
    } else {
      _eventBus = Bus(tag);
      _list.add(_eventBus);
    }

    if (T == dynamic) {
      return _eventBus.subject.stream;
    } else {
      return _eventBus.subject.stream.where((event) => event is T).cast<T>();
    }
  }

  /// Send Event
  static void post(event, {@required tag}) {
    _list.forEach((rxBus) {
      if (rxBus.tag == tag) {
        rxBus.subject.sink.add(event);
      }
    });
  }

  /// Event Closed
  static void destroy({@required tag}) {
    List<Bus> toRemove = List();
    _list.forEach((rxBus) {
      if (rxBus.tag == tag) {
        rxBus.subject.close();
        toRemove.add(rxBus);
      }
    });
    toRemove.forEach((rxBus) {
      _list.remove(rxBus);
    });
  }
}