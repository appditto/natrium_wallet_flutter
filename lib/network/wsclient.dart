import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:package_info/package_info.dart';
import 'package:web_socket_channel/io.dart';

// Wallet server
const String _SERVER_ADDRESS = "wss://kaba.banano.cc:443";

WebSocketsNotifications sockets = new WebSocketsNotifications();

/// Singleton websocket client wrapper
class WebSocketsNotifications {
  final Logger log = new Logger("WebSocketNotifications");
  static final WebSocketsNotifications _sockets = new WebSocketsNotifications._internal();

  factory WebSocketsNotifications(){
    return _sockets;
  }

  WebSocketsNotifications._internal();

  // WS Channel
  IOWebSocketChannel _channel;

  bool _isConnected;
  bool _isConnecting;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  // Methods to call on message receipt
  ObserverList<Function> _listeners = new ObserverList<Function>();

  // Connect to server
  initCommunication() async {
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
      _listeners.forEach((Function callback){
        callback("connected");
      });
      _channel.stream.listen(_onReceptionOfMessageFromServer, onDone: connectionClosed, onError: connectionClosedError);
    } catch(e){
      log.severe("Error from service ${e.toString()}");
      // TODO - error handling
      _isConnected = false;
      _isConnecting = false;
      _listeners.forEach((Function callback){
        callback("disconnected");
      });
    }
  }

  void connectionClosed() {
    _isConnected = false;
    log.fine("disconnected from service");
    // Send disconnected message
    _listeners.forEach((Function callback){
      callback("disconnected");
    });
  }

  void connectionClosedError(e) {
    _isConnected = false;
    log.fine("disconnected from service with error ${e.toString()}");
    // Send disconnected message
    _listeners.forEach((Function callback){
      callback("disconnected");
    });
  }

  // Close connection
  reset(){
    if (_channel != null){
      if (_channel.sink != null){
        _channel.sink.close();
        _isConnected = false;
      }
    }
  }

  // Send message
  send(String message){
    if (_channel != null){
      if (_channel.sink != null && _isConnected){
        _channel.sink.add(message);
      }
    }
  }

  // Callback listener helpers
  addListener(Function callback){
    _listeners.add(callback);
  }
  removeListener(Function callback){
    _listeners.remove(callback);
  }

  // Invoke the callbacks
  _onReceptionOfMessageFromServer(message){
    _isConnected = true;
    _isConnecting = false;
    _listeners.forEach((Function callback){
      callback(message);
    });
  }
}
