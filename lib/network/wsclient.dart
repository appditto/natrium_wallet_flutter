import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:web_socket_channel/io.dart';

// Wallet server
const String _SERVER_ADDRESS = "wss://kaba.banano.cc:443";

/**
 * Singleton websocket client wrapper
 */
class WebSocketsNotifications {
  WebSocketsNotifications._internal();
  static final WebSocketsNotifications _singleton = new WebSocketsNotifications._internal();
  static WebSocketsNotifications get inst => _singleton;

  // WS Channel
  IOWebSocketChannel _channel;

  bool _isConnected;
  
  // Methods to call on message receipt
  ObserverList<Function> _listeners = new ObserverList<Function>();

  // Connect to server
  initCommunication() async {
    reset();

    try {
      var packageInfo = await PackageInfo.fromPlatform();

      _channel = new IOWebSocketChannel
                      .connect(_SERVER_ADDRESS,
                               headers: {
                                'X-Client-Version': packageInfo.buildNumber
                               });
      _isConnected = true;
      _channel.stream.listen(_onReceptionOfMessageFromServer);
    } catch(e){
      // TODO - error handling
    }
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
    _listeners.forEach((Function callback){
      callback(message);
    });
  }
}