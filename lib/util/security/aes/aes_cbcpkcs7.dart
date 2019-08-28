import 'dart:typed_data';

import 'package:pointycastle/api.dart';

/// AES Encrypt/Decrypt using CBC block cipher and PKCS7 padding
class AesCbcPkcs7 {
  /// AES/CBC/PKCS7 Encrypt
  static Uint8List encrypt(Uint8List value, { Uint8List key, Uint8List iv }) {
    if (key == null) {
      key = Uint8List(1);
    }
    if (iv == null) {
      iv = Uint8List(1);
    }
    CipherParameters params = PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(key), iv), null);
    BlockCipher encryptionCipher = PaddedBlockCipher("AES/CBC/PKCS7");
    encryptionCipher.init(true, params);
    return encryptionCipher.process(value);    
  }

  /// AES/CBC/PKCS7 Decrypt
  static Uint8List decrypt(Uint8List encrypted, { Uint8List key, Uint8List iv }) {
    if (key == null) {
      key = Uint8List(1);
    }
    if (iv == null) {
      iv = Uint8List(1);
    }
    CipherParameters params = PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(key), iv), null);
    BlockCipher decryptionCipher = PaddedBlockCipher("AES/CBC/PKCS7");
    decryptionCipher.init(false, params);
    return decryptionCipher.process(encrypted);    
  }
}