import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:kalium_wallet_flutter/network/model/base_request.dart';
import 'package:kalium_wallet_flutter/network/model/request_item.dart';
import 'package:kalium_wallet_flutter/network/model/request/account_history_request.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response.dart';
import 'package:kalium_wallet_flutter/network/model/response/account_history_response_item.dart';
import 'package:kalium_wallet_flutter/network/model/response/subscribe_response.dart';
import 'package:kalium_wallet_flutter/network/wsclient.dart';
import 'package:logging/logging.dart';

AccountService accountService = new AccountService();

/**
 * AccountService singleton
 */
class AccountService {
  static final AccountService _service = new AccountService._internal();
  final Logger log = new Logger("AccountService");

  Queue<RequestItem> _requestQueue;
  ObserverList<Function> _listeners = new ObserverList<Function>();

  factory AccountService(){
    return _service;
  }

  AccountService._internal() {
    // Initialize queue
    _requestQueue = new Queue();
    // Init connection
    sockets.initCommunication();
    // Add listener
    sockets.addListener(_onMessageReceived);
  }

  // Invoked when server sends a message
  _onMessageReceived(message) {
    log.fine("Received $message");
    if (message == "connected" || message == "disconnected") {
      // Post to callbacks
      _listeners.forEach((Function callback){
        callback(message);
      });
      return;
    }
    Map msg = json.decode(message);
    // Determine response type
    if (msg.containsKey("uuid") || (msg.containsKey("frontier") && msg.containsKey("representative_block")) ||
        msg.containsKey("error") && msg.containsKey("currency")) {
      // Subscribe response
      SubscribeResponse resp = SubscribeResponse.fromJson(msg);
      // Check next request to update block count
      if (resp.blockCount != null) {
        _requestQueue.forEach((requestItem) {
          if (requestItem.request is AccountHistoryRequest) {
            requestItem.request.count = resp.blockCount;
          }
        });
      }
      // Post to callbacks
      _listeners.forEach((Function callback){
        callback(resp);
      });
    } else if (msg.containsKey("currency") && msg.containsKey("price") && msg.containsKey("btc")) {
      // TODO handle price update, also get "nano" for banano
      // Server pushes these periodically un-prompted while connected
    } else if (msg.containsKey("history")) {
      // Account history response
      if (msg['history'] == "") {
        msg['history'] = new List<AccountHistoryResponseItem>();
      }
      AccountHistoryResponse resp = AccountHistoryResponse.fromJson(msg);
      _listeners.forEach((Function callback){
        callback(resp);
      });
    }
    if (_requestQueue.length > 0) {
      _requestQueue.removeFirst();
      processQueue();
    }
    return;
  }

  /* Enqueue Request */
  void queueRequest(BaseRequest request) {
    _requestQueue.add(new RequestItem(request));
  }

  /* Process Queue */
  void processQueue() {
    if (_requestQueue != null && _requestQueue.length > 0) {
      RequestItem requestItem = _requestQueue.first;
      if (requestItem != null && !requestItem.isProcessing) {
        if (!sockets.isConnected) {
          if (!sockets.isConnecting) {
            sockets.initCommunication();
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
        _requestQueue.removeFirst();
        processQueue();
      }
    }
  }

  void _send(String encodedData) {
    sockets.send(encodedData);
  }

  // Methods to add/remove callback
  addListener(Function callback){
    _listeners.add(callback);
  }
  removeListener(Function callback) {
    _listeners.remove(callback);
  }
}