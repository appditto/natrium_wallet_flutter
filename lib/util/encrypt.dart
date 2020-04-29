import 'dart:typed_data';

import 'package:pointycastle/api.dart' show ParametersWithIV, KeyParameter;
import 'package:pointycastle/stream/salsa20.dart';
import 'package:flutter_nano_ffi/flutter_nano_ffi.dart';

/**
 * Encryption using Salsa20 from pointycastle
 */
class Salsa20Encryptor {
  final String key;
  final String iv;
  final ParametersWithIV<KeyParameter> _params;
  final Salsa20Engine _cipher = Salsa20Engine();

  Salsa20Encryptor(this.key, this.iv)
      : _params = ParametersWithIV<KeyParameter>(
            KeyParameter(Uint8List.fromList(key.codeUnits)),
            Uint8List.fromList(iv.codeUnits));

  String encrypt(String plainText) {
    _cipher
      ..reset()
      ..init(true, _params);

    final input = Uint8List.fromList(plainText.codeUnits);
    final output = _cipher.process(input);

    return NanoHelpers.byteToHex(output);
  }

  String decrypt(String cipherText) {
    _cipher
      ..reset()
      ..init(false, _params);

    final input = NanoHelpers.hexToBytes(cipherText);
    final output = _cipher.process(input);

    return String.fromCharCodes(output);
  }
}