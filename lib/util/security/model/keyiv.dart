import 'dart:typed_data';

/// A key/iv pair for aes encryption
class KeyIV {
  Uint8List key; // 32 bytes
  Uint8List iv;  // 16 bytes

  KeyIV(this.key, this.iv);
}