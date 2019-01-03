import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/api.dart' show KeyParameter;
import 'package:pointycastle/block/aes_fast.dart';
import 'package:flutter_nano_core/flutter_nano_core.dart';

/**
 * Encryption helpers using AES from pointycastle
 * 
 * Based on: https://github.com/leocavalcante/encrypt
 */
class AESEncrypter {
  final String key;
  final KeyParameter _params;
  final AESFastEngine _cipher = AESFastEngine();

  AESEncrypter(this.key) : _params = KeyParameter(Uint8List.fromList(key.codeUnits));

  String encrypt(String plainText) {
    _cipher
      ..reset()
      ..init(true, _params);

    final input = Uint8List.fromList(plainText.codeUnits);
    final output = _processBlocks(input);

    return NanoHelpers.byteToHex(output);
  }

  String decrypt(String cipherText) {
    _cipher
      ..reset()
      ..init(false, _params);

    final input = NanoHelpers.hexToBytes(cipherText);
    final output = _processBlocks(input);

    return String.fromCharCodes(output);
  }

  Uint8List _processBlocks(Uint8List input) {
    var output = Uint8List(input.lengthInBytes);

    for (int offset = 0; offset < input.lengthInBytes;) {
      offset += _cipher.processBlock(input, offset, output, offset);
    }

    return output;
  }

  static String generateEncryptionSecret() {
    String result = ""; // Resulting passcode
    String chars = "abcdefghijklmnopqrstuvwxyz0123456789!?&+\\-'."; // Characters a passcode may contain
    var rng = new Random.secure();
    for (int i = 0; i < 32; i ++) {
      result += chars[rng.nextInt(chars.length)];
    }
    return result;
  }
}