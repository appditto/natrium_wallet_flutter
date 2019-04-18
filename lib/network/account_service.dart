import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:web_socket_channel/io.dart';
import 'package:package_info/package_info.dart';
import 'package:logging/logging.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:synchronized/synchronized.dart';

import 'package:natrium_wallet_flutter/model/state_block.dart';
import 'package:natrium_wallet_flutter/network/model/base_request.dart';
import 'package:natrium_wallet_flutter/network/model/request_item.dart';
import 'package:natrium_wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:natrium_wallet_flutter/network/model/request/account_history_request.dart';
import 'package:natrium_wallet_flutter/network/model/request/accounts_balances_request.dart';
import 'package:natrium_wallet_flutter/network/model/request/pending_request.dart';
import 'package:natrium_wallet_flutter/network/model/request/process_request.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/block_info_item.dart';
import 'package:natrium_wallet_flutter/network/model/response/error_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:natrium_wallet_flutter/network/model/response/accounts_balances_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/callback_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/price_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/pending_response.dart';
import 'package:natrium_wallet_flutter/network/model/response/process_response.dart';
import 'package:natrium_wallet_flutter/bus/events.dart';

// Server Connection String
const String _SERVER_ADDRESS = "wss://app.natrium.io";

Map decodeJson(dynamic src) {
  return json.decode(src);
}

// AccountService singleton
class AccountService {
  static final Logger log = new Logger("AccountService");

  // For all requests we place them on a queue with expiry to be processed sequentially
  Queue<RequestItem> _requestQueue;

  // WS Client
  IOWebSocketChannel _channel;

  // WS connection status
  bool _isConnected;
  bool _isConnecting;
  bool suspended; // When the app explicity closes the connection

  // Lock instnace for synchronization
  Lock _lock;

  // Constructor
  AccountService() {
    _requestQueue = Queue();
    _isConnected = false;
    _isConnecting = false;
    suspended = false;
    _lock = Lock();
    initCommunication();
  }

  // Connect to server
  Future<void> initCommunication({bool unsuspend = false}) async {
    if (_isConnected || _isConnecting) {
      return;
    } else if (suspended && !unsuspend) {
      return;
    }

    try {
      var packageInfo = await PackageInfo.fromPlatform();

      _isConnecting = true;
      suspended = false;
      _channel = new IOWebSocketChannel
                      .connect(_SERVER_ADDRESS,
                               headers: {
                                'X-Client-Version': packageInfo.buildNumber
                               });
      log.fine("Connected to service");
      _isConnecting = false;
      _isConnected = true;
      EventTaxiImpl.singleton().fire(ConnStatusEvent(status: ConnectionStatus.CONNECTED));
      _channel.stream.listen(_onMessageReceived, onDone: connectionClosed, onError: connectionClosedError);
    } catch(e){
      log.severe("Error from service ${e.toString()}");
      _isConnected = false;
      _isConnecting = false;
      EventTaxiImpl.singleton().fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
    }
  }

  // Connection closed (normally)
  void connectionClosed() {
    _isConnected = false;
    _isConnecting = false;
    log.fine("disconnected from service");
    // Send disconnected message
    EventTaxiImpl.singleton().fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
  }

  // Connection closed (with error)
  void connectionClosedError(e) {
    _isConnected = false;
    _isConnecting = false;
    log.fine("disconnected from service with error ${e.toString()}");
    // Send disconnected message
    EventTaxiImpl.singleton().fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
  }

  // Close connection
  void reset({bool suspend = false}){
    suspended = suspend;
    if (_channel != null && _channel.sink != null) {
      _channel.sink.close();
      _isConnected = false;
      _isConnecting = false;
    }
  }

  // Send message
  Future<void> _send(String message) async {
    bool reset = false;
    try {
      if (_channel != null && _channel.sink != null && _isConnected) {
        _channel.sink.add(message);
      } else {
        reset = true; // Re-establish connection
      }
    } catch (e) {
      reset = true;
    } finally {
      if (reset) {
        // Reset queue item statuses
        _requestQueue.forEach((requestItem) {
          requestItem.isProcessing = false;
        });
        if (!_isConnecting && !suspended) {
          initCommunication();
        }
      }
    }
  }

  Future<void> _onMessageReceived(dynamic message) async {
    if (suspended) {
      return;
    }
    await _lock.synchronized(() async {
      _isConnected = true;
      _isConnecting = false;
      log.fine("Received ${message.length > 30 ? message.substring(0, 30) : message}");
      Map msg = await compute(decodeJson, message);
      // Determine response type
      if (msg.containsKey("uuid") || (msg.containsKey("frontier") && msg.containsKey("representative_block")) ||
          msg.containsKey("error") && msg.containsKey("currency")) {
        // Subscribe response
        SubscribeResponse resp = await compute(subscribeResponseFromJson, msg);
        // Post to callbacks
        EventTaxiImpl.singleton().fire(SubscribeEvent(response: resp));
      } else if (msg.containsKey("currency") && msg.containsKey("price") && msg.containsKey("btc")) {
        // Price info sent from server
        PriceResponse resp = PriceResponse.fromJson(msg);
        EventTaxiImpl.singleton().fire(PriceEvent(response: resp));
      } else if (msg.containsKey("history")) {
        // Account history response
        if (msg['history'] == "") {
          msg['history'] = new List<AccountHistoryResponseItem>();
        }
        AccountHistoryResponse resp = await compute(accountHistoryresponseFromJson, msg);
        EventTaxiImpl.singleton().fire(HistoryEvent(response: resp));
      } else if (msg.containsKey("blocks")) {
        // This is a 'pending' response
        if (msg['blocks'] is Map && msg['blocks'].length > 0) {
          Map<String, dynamic> blockMap = msg['blocks'];
          if (blockMap != null && blockMap.length > 0) {
            PendingResponse resp = await compute(pendingResponseFromJson, msg);
            EventTaxiImpl.singleton().fire(PendingEvent(response: resp));
          }
        } else {
          // Possibly a response when there is no pendings
          pop();
          processQueue();
        }
      } else if (msg.containsKey("block_account") && msg.containsKey("contents") && msg.containsKey("amount") && msg.containsKey("balance")) {
        // Block Info Response
        BlockInfoItem resp = await compute(blockInfoItemFromJson, msg);
        EventTaxiImpl.singleton().fire(BlocksInfoEvent(response: resp));
      } else if (msg.containsKey("block") && msg.containsKey("hash") && msg.containsKey("account")) {
        CallbackResponse resp = await compute(callbackResponseFromJson, msg);
        EventTaxiImpl.singleton().fire(CallbackEvent(response: resp));
      } else if (msg.containsKey("hash")) {
        // process response
        ProcessResponse resp = ProcessResponse.fromJson(msg);
        EventTaxiImpl.singleton().fire(ProcessEvent(response: resp));
      } else if (msg.containsKey("error")) {
        ErrorResponse resp = ErrorResponse.fromJson(msg);
        EventTaxiImpl.singleton().fire(ErrorEvent(response: resp));
      } else if (msg.containsKey("balances")) {
        // accounts_balances response
        if (msg['balances'] is Map && msg['balances'].length > 0) {
          Map<String, dynamic> balancesMap = msg['balances'];
          if (balancesMap != null && balancesMap.length > 0) {
            if (balancesMap[balancesMap.keys.first].containsKey('pending')) {
              RequestItem<dynamic> lastRequest = pop();
              AccountsBalancesResponse resp = await compute(accountsBalancesResponseFromJson, msg);
              EventTaxiImpl.singleton().fire(AccountsBalancesEvent(response: resp, transfer: lastRequest.fromTransfer));
              processQueue();
            }
          }
        }
      }
      return;
    });
  }

  /* Send Request */
  Future<void> sendRequest(BaseRequest request) async {
    // We don't care about order or server response in these requests
    log.fine("sending ${json.encode(request.toJson())}");
    _send(json.encode(request.toJson()));
  }

  /* Enqueue Request */
  void queueRequest(BaseRequest request, {bool fromTransfer = false}) {
    log.fine("requetest ${json.encode(request.toJson())}, q length: ${_requestQueue.length}");
    _requestQueue.add(new RequestItem(request, fromTransfer: fromTransfer));
  }

  /* Process Queue */
  Future<void> processQueue() async {
    await _lock.synchronized(() async {
      log.fine("Request Queue length ${_requestQueue.length}");
      if (_requestQueue != null && _requestQueue.length > 0) {
        RequestItem requestItem = _requestQueue.first;
        if (requestItem != null && !requestItem.isProcessing) {
          if (!_isConnected && !_isConnecting && !suspended) {
            initCommunication();
            return;
          } else if (suspended) {
            return;
          }
          requestItem.isProcessing = true;
          String requestJson = json.encode(requestItem.request.toJson());
          log.fine("Sending: $requestJson");
          await _send(requestJson);
        } else if (requestItem != null && (DateTime
            .now()
            .difference(requestItem.expireDt)
            .inSeconds > RequestItem.EXPIRE_TIME_S)) {
          pop();
          processQueue();
        }
      }
    });
  }

  // Queue Utilities
  bool queueContainsRequestWithHash(String hash) {
    if (_requestQueue != null || _requestQueue.length == 0) {
      return false;
    }
    _requestQueue.forEach((requestItem) {
      if (requestItem.request is ProcessRequest) {
        ProcessRequest request = requestItem.request;
        StateBlock block = StateBlock.fromJson(json.decode(request.block));
        if (block.hash == hash) {
          return true;
        }
      }
    });
    return false;
  }

  bool queueContainsOpenBlock() {
    if (_requestQueue != null || _requestQueue.length == 0) {
      return false;
    }
    _requestQueue.forEach((requestItem) {
      if (requestItem.request is ProcessRequest) {
        ProcessRequest request = requestItem.request;
        StateBlock block = StateBlock.fromJson(json.decode(request.block));
        if (BigInt.tryParse(block.previous) == BigInt.zero) {
          return true;
        }
      }
    });
    return false;
  }

  void removeSubscribeHistoryPendingFromQueue() {
    if (_requestQueue != null && _requestQueue.length > 0) {
      List<RequestItem> toRemove = new List();
      _requestQueue.forEach((requestItem) {
        if ((requestItem.request is SubscribeRequest || requestItem.request is AccountHistoryRequest || requestItem.request is PendingRequest)
              && !requestItem.isProcessing) {
          toRemove.add(requestItem);
        }
      });
      toRemove.forEach((requestItem) {
        _requestQueue.remove(requestItem);
      });
    }    
  }

  RequestItem pop() {
    return _requestQueue.length > 0 ? _requestQueue.removeFirst() : null;
  }

  RequestItem peek() {
    return _requestQueue.length > 0 ? _requestQueue.first : null;
  }
  
  /// Clear entire queue, except for AccountsBalancesRequest
  void clearQueue() {
    List<RequestItem> reQueue = List();
    _requestQueue.forEach((requestItem) {
      if (requestItem.request is AccountsBalancesRequest) {
        reQueue.add(requestItem);
      }
    });
    _requestQueue.clear();
    // Re-queue requests
    reQueue.forEach((requestItem) {
      requestItem.isProcessing = false;
      _requestQueue.add(requestItem);
    });
  }

  Queue<RequestItem> get requestQueue => _requestQueue;
}
