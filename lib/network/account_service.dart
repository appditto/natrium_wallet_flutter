import 'dart:collection';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'package:package_info/package_info.dart';
import 'package:logging/logging.dart';

import 'package:kalium_wallet_flutter/model/state_block.dart';
import 'package:kalium_wallet_flutter/network/model/base_request.dart';
import 'package:kalium_wallet_flutter/network/model/request_item.dart';
import 'package:kalium_wallet_flutter/network/model/request/subscribe_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/account_history_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/pending_request.dart';
import 'package:kalium_wallet_flutter/network/model/request/process_request.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/blocks_info_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/error_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:kalium_wallet_flutter/network/model/response/callback_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/price_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/pending_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/process_response.dart';
import 'package:kalium_wallet_flutter/bus/rxbus.dart';

// Server Connection String
const String _SERVER_ADDRESS = "wss://kaba.banano.cc:443";

// Bus event for connection status changing
enum ConnectionChanged { CONNECTED, DISCONNECTED }

/**
 * AccountService singleton
 */
class AccountService {
  static final AccountService _singleton = AccountService._internal();
  static AccountService get inst => _singleton;
  static final Logger log = new Logger("AccountService");

  // For all requests we place them on a queue with expiry to be processed sequentially
  final Queue<RequestItem> _requestQueue = Queue();

  // WS Client
  IOWebSocketChannel _channel;

  // WS connection status
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _suspended = false; // When the app explicity closes the connection

  // Singleton Constructor
  AccountService._internal() {
    initCommunication();
  }

  // Connect to server
  void initCommunication({bool unsuspend = false}) async {
    if (_isConnected || _isConnecting) {
      return;
    } else if (_suspended && !unsuspend) {
      return;
    }
    _suspended = false;
    reset();

    try {
      var packageInfo = await PackageInfo.fromPlatform();

      _isConnecting = true;
      _channel = new IOWebSocketChannel
                      .connect(_SERVER_ADDRESS,
                               headers: {
                                'X-Client-Version': packageInfo.buildNumber
                               });
      log.fine("Connected to service");
      _isConnecting = false;
      _isConnected = true;
      RxBus.inst.post(ConnectionChanged.CONNECTED, tag: RX_CONN_STATUS_TAG);
      _channel.stream.listen(_onMessageReceived, onDone: connectionClosed, onError: connectionClosedError);
    } catch(e){
      log.severe("Error from service ${e.toString()}");
      // TODO - error handling
      _isConnected = false;
      _isConnecting = false;
      RxBus.inst.post(ConnectionChanged.DISCONNECTED, tag: RX_CONN_STATUS_TAG);
    }
  }

  // Connection closed (normally)
  void connectionClosed() {
    _isConnected = false;
    _isConnecting = false;
    log.fine("disconnected from service");
    // Send disconnected message
    RxBus.inst.post(ConnectionChanged.DISCONNECTED, tag: RX_CONN_STATUS_TAG);
  }

  // Connection closed (with error)
  void connectionClosedError(e) {
    _isConnected = false;
    _isConnecting = false;
    log.fine("disconnected from service with error ${e.toString()}");
    // Send disconnected message
    RxBus.inst.post(ConnectionChanged.DISCONNECTED, tag: RX_CONN_STATUS_TAG);
  }

  // Close connection
  void reset({bool suspend = false}){
    _suspended = suspend;
    if (_channel != null){
      if (_channel.sink != null){
        _channel.sink.close();
        _isConnected = false;
        _isConnecting = false;
      }
    }
  }

  // Send message
  void _send(String message) {
    bool reset = false;
    try {
    if (_channel != null){
      if (_channel.sink != null && _isConnected){
        _channel.sink.add(message);
      } else {
        reset = true; // Re-establish connection
      }
    }
    } catch (e) {
      reset = true;
    } finally {
      if (reset) {
        // Reset queue item statuses
        _requestQueue.forEach((requestItem) {
          requestItem.isProcessing = false;
        });
        if (!_isConnecting) {
          initCommunication();
        }
      }
    }
  }

  void _onMessageReceived(message) {
    _isConnected = true;
    _isConnecting = false;
    log.fine("Received $message");
    Map msg = json.decode(message);
    // Determine response type
    if (msg.containsKey("uuid") || (msg.containsKey("frontier") && msg.containsKey("representative_block")) ||
        msg.containsKey("error") && msg.containsKey("currency")) {
      // Subscribe response
      SubscribeResponse resp = SubscribeResponse.fromJson(msg);
      // Post to callbacks
      RxBus.inst.post(resp, tag:RX_SUBSCRIBE_TAG);
    } else if (msg.containsKey("currency") && msg.containsKey("price") && msg.containsKey("btc")) {
      // Price info sent from server
      PriceResponse resp = PriceResponse.fromJson(msg);
      RxBus.inst.post(resp, tag: RX_PRICE_RESP_TAG);
    } else if (msg.containsKey("history")) {
      // Account history response
      if (msg['history'] == "") {
        msg['history'] = new List<AccountHistoryResponseItem>();
      }
      AccountHistoryResponse resp = AccountHistoryResponse.fromJson(msg);
      RxBus.inst.post(resp, tag: RX_HISTORY_TAG);
      RxBus.inst.post(resp, tag: RX_HISTORY_HOME_TAG);
    } else if (msg.containsKey("blocks")) {
      // This is either a 'blocks_info' response "or" a 'pending' response
      if (msg['blocks'] is Map && msg['blocks'].length > 0) {
        Map<String, dynamic> blockMap = msg['blocks'];
        if (blockMap != null && blockMap.length > 0) {
          if (blockMap[blockMap.keys.first].containsKey('block_account')) {
            // Blocks Info Response
            BlocksInfoResponse resp = BlocksInfoResponse.fromJson(msg);
            RxBus.inst.post(resp, tag: RX_BLOCKS_INFO_RESP_TAG);
          } else if (blockMap[blockMap.keys.first].containsKey('source')) {
            PendingResponse resp = PendingResponse.fromJson(msg);
            RxBus.inst.post(resp, tag: RX_PENDING_RESP_TAG);
          }
        }
      } else {
        // Possibly a response when there is no pendings
        pop();
        processQueue();
      }
    } else if (msg.containsKey("block") && msg.containsKey("hash") && msg.containsKey("account")) {
      CallbackResponse resp = CallbackResponse.fromJson(msg);
      RxBus.inst.post(resp, tag: RX_CALLBACK_TAG);
    } else if (msg.containsKey("hash")) {
      // process response
      ProcessResponse resp = ProcessResponse.fromJson(msg);
      RxBus.inst.post(resp, tag: RX_PROCESS_TAG);
    } else if (msg.containsKey("error")) {
      ErrorResponse resp = ErrorResponse.fromJson(msg);
      RxBus.inst.post(resp, tag: RX_ERROR_RESP_TAG);
    }
    return;
  }

  /* Enqueue Request */
  void queueRequest(BaseRequest request) {
    log.fine("requetest ${json.encode(request.toJson())}, q length: ${_requestQueue.length}");
    _requestQueue.add(new RequestItem(request));
  }

  /* Process Queue */
  void processQueue() {
    log.fine("Request Queue length ${_requestQueue.length}");
    if (_requestQueue != null && _requestQueue.length > 0) {
      RequestItem requestItem = _requestQueue.first;
      if (requestItem != null && !requestItem.isProcessing) {
        if (!_isConnected) {
          if (!_isConnecting) {
            initCommunication();
          }
          return;
        }
        requestItem.isProcessing = true;
        String requestJson = json.encode(requestItem.request.toJson());
        log.fine("Sending: $requestJson");
        _send(requestJson);
      } else if (requestItem != null && (DateTime
          .now()
          .difference(requestItem.expireDt)
          .inSeconds > RequestItem.EXPIRE_TIME_S)) {
        pop();
        processQueue();
      }
    }
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
  
  void clearQueue() {
    _requestQueue.clear();
  }

  Queue<RequestItem> get requestQueue => _requestQueue;
}