import 'dart:io';

class FileUtil {

  /// Check first 8-bytes of PNG
  /// This isn't 100% sufficient to determine if our download was successful,
  /// but it's probably good enough for most cases
  static Future<bool> pngHasValidSignature(File file) async {
    if (!await file.exists()) {
      return false;
    }
    List<int> asBytes = await file.readAsBytes();
    if (asBytes == null || asBytes.length < 8) {
      await file.delete();
      return false;
    }
    if (asBytes[0] == 137 &&
        asBytes[1] == 80 &&
        asBytes[2] == 78 &&
        asBytes[3] == 71 &&
        asBytes[4] == 13 &&
        asBytes[5] == 10 &&
        asBytes[6] == 26 &&
        asBytes[7] == 10) {
          return true;
    }
    // Not a valid PNG, delete it
    await file.delete();
    return false;
  }

  /// Return true if a SVG is valid
  static Future<bool> isValidSVG(File file) async {
    if (!await file.exists()) {
      return false;
    }
    RegExp svgRegex = RegExp(r'/^\s*(?:<\?xml[^>]*>\s*)?(?:<!doctype svg[^>]*\s*(?:\[?(?:\s*<![^>]*>\s*)*\]?)*[^>]*>\s*)?<svg[^>]*>[^]*<\/svg>\s*$/i');
    // Read file as string
    String svgContents = await file.readAsString();
    if (svgRegex.hasMatch(svgContents)) {
      return true;
    }
    await file.delete();
    return false;
  }
}