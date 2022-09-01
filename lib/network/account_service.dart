import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:natrium_wallet_flutter/network/model/response/alerts_response_item.dart';
import 'package:natrium_wallet_flutter/util/sharedprefsutil.dart';
import 'package:logger/logger.dart';
import 'package:natrium_wallet_flutter/model/wallet.dart';
import 'package:natrium_wallet_flutter/network/model/block_types.dart';
import 'package:natrium_wallet_flutter/network/model/request/account_info_request.dart';
import 'package:natrium_wallet_flutter/network/model/request/block_info_request.dart';
import 'package:natrium_wallet_flutter/network/model/response/account_info_response.dart';
import 'package:natrium_wallet_flutter/service_locator.dart';

import 'package:web_socket_channel/io.dart';
import 'package:package_info/package_info.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:synchronized/synchronized.dart';
import 'package:http/http.dart' as http;

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
const String _SERVER_ADDRESS = "wss://testapp.natrium.io";
const String _SERVER_ADDRESS_HTTP = "https://testapp.natrium.io/api";
const String _SERVER_ADDRESS_ALERTS = "https://testapp.natrium.io/alerts";

Map decodeJson(dynamic src) {
  return json.decode(src);
}

// AccountService singleton
class AccountService {
  final Logger log = sl.get<Logger>();

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
    initCommunication(unsuspend: true);
  }

  // Re-connect handling
  bool _isInRetryState = false;
  StreamSubscription<dynamic> reconnectStream;

  /// Retry up to once per 3 seconds
  Future<void> reconnectToService() async {
    if (_isInRetryState) {
      return;
    } else if (reconnectStream != null) {
      reconnectStream.cancel();
    }
    _isInRetryState = true;
    log.d("Retrying connection in 3 seconds...");
    Future<dynamic> delayed = new Future.delayed(new Duration(seconds: 3));
    delayed.then((_) {
      return true;
    });
    reconnectStream = delayed.asStream().listen((_) {
      log.d("Attempting connection to service");
      initCommunication(unsuspend: true);
      _isInRetryState = false;
    });
  }

  // Connect to server
  Future<void> initCommunication({bool unsuspend = false}) async {
    if (_isConnected || _isConnecting) {
      return;
    } else if (suspended && !unsuspend) {
      return;
    } else if (!unsuspend) {
      reconnectToService();
      return;
    }
    _isConnecting = true;
    try {
      var packageInfo = await PackageInfo.fromPlatform();

      _isConnecting = true;
      suspended = false;
      _channel = new IOWebSocketChannel.connect(_SERVER_ADDRESS,
          headers: {'X-Client-Version': packageInfo.buildNumber});
      log.d("Connected to service");
      _isConnecting = false;
      _isConnected = true;
      EventTaxiImpl.singleton()
          .fire(ConnStatusEvent(status: ConnectionStatus.CONNECTED));
      _channel.stream.listen(_onMessageReceived,
          onDone: connectionClosed, onError: connectionClosedError);
    } catch (e) {
      log.e("Error from service ${e.toString()}", e);
      _isConnected = false;
      _isConnecting = false;
      EventTaxiImpl.singleton()
          .fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
    }
  }

  // Connection closed (normally)
  void connectionClosed() {
    _isConnected = false;
    _isConnecting = false;
    clearQueue();
    log.d("disconnected from service");
    // Send disconnected message
    EventTaxiImpl.singleton()
        .fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
  }

  // Connection closed (with error)
  void connectionClosedError(e) {
    _isConnected = false;
    _isConnecting = false;
    clearQueue();
    log.w("disconnected from service with error ${e.toString()}");
    // Send disconnected message
    EventTaxiImpl.singleton()
        .fire(ConnStatusEvent(status: ConnectionStatus.DISCONNECTED));
  }

  // Close connection
  void reset({bool suspend = false}) {
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
      //log.d("Received $message");
      Map msg = await compute(decodeJson, message);
      // Determine response type
      if (msg.containsKey("uuid") ||
          (msg.containsKey("frontier") &&
              msg.containsKey("representative_block")) ||
          msg.containsKey("error") && msg.containsKey("currency")) {
        // Subscribe response
        SubscribeResponse resp = await compute(subscribeResponseFromJson, msg);
        // Post to callbacks
        EventTaxiImpl.singleton().fire(SubscribeEvent(response: resp));
      } else if (msg.containsKey("currency") &&
          msg.containsKey("price") &&
          msg.containsKey("btc")) {
        // Price info sent from server
        PriceResponse resp = PriceResponse.fromJson(msg);
        EventTaxiImpl.singleton().fire(PriceEvent(response: resp));
      } else if (msg.containsKey("block") &&
          msg.containsKey("hash") &&
          msg.containsKey("account")) {
        CallbackResponse resp = await compute(callbackResponseFromJson, msg);
        EventTaxiImpl.singleton().fire(CallbackEvent(response: resp));
      } else if (msg.containsKey("error")) {
        ErrorResponse resp = ErrorResponse.fromJson(msg);
        EventTaxiImpl.singleton().fire(ErrorEvent(response: resp));
      }
      return;
    });
  }

  /* Send Request */
  Future<void> sendRequest(BaseRequest request) async {
    // We don't care about order or server response in these requests
    //log.d("sending ${json.encode(request.toJson())}");
    _send(await compute(encodeRequestItem, request));
  }

  /* Enqueue Request */
  void queueRequest(BaseRequest request, {bool fromTransfer = false}) {
    //log.d("requetest ${json.encode(request.toJson())}, q length: ${_requestQueue.length}");
    _requestQueue.add(new RequestItem(request, fromTransfer: fromTransfer));
  }

  /* Process Queue */
  Future<void> processQueue() async {
    await _lock.synchronized(() async {
      //log.d("Request Queue length ${_requestQueue.length}");
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
          String requestJson =
              await compute(encodeRequestItem, requestItem.request);
          //log.d("Sending: $requestJson");
          await _send(requestJson);
        } else if (requestItem != null &&
            (DateTime.now().difference(requestItem.expireDt).inSeconds >
                RequestItem.EXPIRE_TIME_S)) {
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
        if ((requestItem.request is SubscribeRequest ||
                requestItem.request is AccountHistoryRequest ||
                requestItem.request is PendingRequest) &&
            !requestItem.isProcessing) {
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

  // HTTP API

  Future<dynamic> makeHttpRequest(BaseRequest request) async {
    http.Response response = await http.post(Uri.parse(_SERVER_ADDRESS_HTTP),
        headers: {'Content-type': 'application/json'},
        body: json.encode(request.toJson()));
    try {
      Map decoded = json.decode(response.body);
      if (decoded.containsKey("error")) {
        return ErrorResponse.fromJson(decoded);
      }
      return decoded;
    } catch (e) {
      return ErrorResponse(error: "Invalid response from server");
    }
  }

  Future<AccountInfoResponse> getAccountInfo(String account) async {
    AccountInfoRequest request = AccountInfoRequest(account: account);
    dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      if (response.error == "Account not found") {
        return AccountInfoResponse(unopened: true);
      }
      throw Exception("Received error ${response.error}");
    }
    AccountInfoResponse infoResponse = AccountInfoResponse.fromJson(response);
    return infoResponse;
  }

  Future<PendingResponse> getPending(String account, int count,
      {String threshold, bool includeActive = false}) async {
    threshold = threshold ?? BigInt.from(10).pow(24).toString();
    PendingRequest request = PendingRequest(
        account: account,
        count: count,
        threshold: threshold,
        includeActive: includeActive);
    dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    PendingResponse pr;
    if (response["blocks"] == "") {
      pr = PendingResponse(blocks: {});
    } else {
      pr = PendingResponse.fromJson(response);
    }
    return pr;
  }

  Future<BlockInfoItem> requestBlockInfo(String hash) async {
    BlockInfoRequest request = BlockInfoRequest(hash: hash);
    dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    BlockInfoItem item = BlockInfoItem.fromJson(response);
    return item;
  }

  Future<AccountHistoryResponse> requestAccountHistory(String account,
      {int count = 1}) async {
    AccountHistoryRequest request =
        AccountHistoryRequest(account: account, count: count);
    dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    if (response["history"] == "") {
      response["history"] = [];
    }
    return AccountHistoryResponse.fromJson(response);
  }

  Future<AccountsBalancesResponse> requestAccountsBalances(
      List<String> accounts) async {
    AccountsBalancesRequest request =
        AccountsBalancesRequest(accounts: accounts);
    dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    return AccountsBalancesResponse.fromJson(response);
  }

  Future<ProcessResponse> requestProcess(ProcessRequest request) async {
    dynamic response = await makeHttpRequest(request);
    if (response is ErrorResponse) {
      throw Exception("Received error ${response.error}");
    }
    ProcessResponse item = ProcessResponse.fromJson(response);
    return item;
  }

  Future<ProcessResponse> requestReceive(String representative, String previous,
      String balance, String link, String account, String privKey) async {
    StateBlock receiveBlock = StateBlock(
        subtype: BlockTypes.RECEIVE,
        previous: previous,
        representative: representative,
        balance: balance,
        link: link,
        account: account,
        privKey: privKey);

    BlockInfoItem previousInfo = await requestBlockInfo(previous);
    StateBlock previousBlock =
        StateBlock.fromJson(json.decode(previousInfo.contents));

    // Update data on our next pending request
    receiveBlock.representative = previousBlock.representative;
    receiveBlock.setBalance(previousBlock.balance);
    await receiveBlock.sign(privKey);

    // Process
    ProcessRequest processRequest = ProcessRequest(
        block: json.encode(receiveBlock.toJson()), subType: BlockTypes.RECEIVE);

    return await requestProcess(processRequest);
  }

  Future<ProcessResponse> requestSend(String representative, String previous,
      String sendAmount, String link, String account, String privKey,
      {bool max = false}) async {
    StateBlock sendBlock = StateBlock(
        subtype: BlockTypes.SEND,
        previous: previous,
        representative: representative,
        balance: max ? "0" : sendAmount,
        link: link,
        account: account,
        privKey: privKey);

    BlockInfoItem previousInfo = await requestBlockInfo(previous);
    StateBlock previousBlock =
        StateBlock.fromJson(json.decode(previousInfo.contents));

    // Update data on our next pending request
    sendBlock.representative = previousBlock.representative;
    sendBlock.setBalance(previousBlock.balance);
    await sendBlock.sign(privKey);

    // Process
    ProcessRequest processRequest = ProcessRequest(
        block: json.encode(sendBlock.toJson()), subType: BlockTypes.SEND);

    return await requestProcess(processRequest);
  }

  Future<ProcessResponse> requestOpen(
      String balance, String link, String account, String privKey,
      {String representative}) async {
    representative =
        representative ?? await sl.get<SharedPrefsUtil>().getRepresentative();
    StateBlock openBlock = StateBlock(
        subtype: BlockTypes.OPEN,
        previous: "0",
        representative: representative,
        balance: balance,
        link: link,
        account: account,
        privKey: privKey);

    // Sign
    await openBlock.sign(privKey);

    // Process
    ProcessRequest processRequest = ProcessRequest(
        block: json.encode(openBlock.toJson()), subType: BlockTypes.OPEN);

    return await requestProcess(processRequest);
  }

  Future<ProcessResponse> requestChange(String account, String representative,
      String previous, String balance, String privKey) async {
    StateBlock chgBlock = StateBlock(
        subtype: BlockTypes.CHANGE,
        previous: previous,
        representative: representative,
        balance: balance,
        link:
            "0000000000000000000000000000000000000000000000000000000000000000",
        account: account,
        privKey: privKey);

    BlockInfoItem previousInfo = await requestBlockInfo(previous);
    StateBlock previousBlock =
        StateBlock.fromJson(json.decode(previousInfo.contents));

    // Update data on our next pending request
    chgBlock.setBalance(previousBlock.balance);
    await chgBlock.sign(privKey);

    // Process
    ProcessRequest processRequest = ProcessRequest(
        block: json.encode(chgBlock.toJson()), subType: BlockTypes.CHANGE);

    return await requestProcess(processRequest);
  }

  Future<AlertResponseItem> getAlert(String lang) async {
    http.Response response = await http.get(
        Uri.parse(_SERVER_ADDRESS_ALERTS + "/" + lang),
        headers: {"Accept": "application/json"});
    if (response.statusCode == 200) {
      List<AlertResponseItem> alerts;
      alerts = (json.decode(response.body) as List)
          .map((i) => AlertResponseItem.fromJson(i))
          .toList();
      if (alerts.length > 0) {
        if (alerts[0].active) {
          return alerts[0];
        }
      }
    }
    return null;
  }
}
