part of '../secure_compressor.dart';

class SecureCompressor {
  static Future<String> encrypt(String data, String keyString,
      {String? ivString}) async {
    if (keyString.length != 32) {
      throw ArgumentError('keyString must be 32 characters long.');
    }
    final key = encriptor.Key.fromUtf8(keyString);
    final iv = encriptor.IV.fromUtf8(ivString ?? keyString.substring(0, 16));
    final encrypter = encriptor.Encrypter(encriptor.AES(key));
    final encryptedData = encrypter.encrypt(data, iv: iv);
    return encryptedData.base64;
  }

  static String decrypt(String data, String keyString, {String? ivString}) {
    if (keyString.length != 32) {
      throw ArgumentError('keyString must be 32 characters long.');
    }
    final key = encriptor.Key.fromUtf8(keyString);
    final iv = encriptor.IV.fromUtf8(ivString ?? keyString.substring(0, 16));
    final encrypter = encriptor.Encrypter(encriptor.AES(key));
    return encrypter.decrypt64(data, iv: iv);
  }

  static String compress(String data) {
    return String.fromCharCodes(gzip.encode(utf8.encode(data)));
  }

  static String uncompress(String data) {
    return utf8.decode(gzip.decode(data.codeUnits));
  }

  static Future<String> compressAndEncrypt(String data, String keyString,
      {String? ivString}) async {
    final compressedData = compress(data);
    final encryptedData =
        await encrypt(compressedData, keyString, ivString: ivString);
    return compress(encryptedData);
  }

  static String uncompressAndDecrypt(String data, String keyString,
      {String? ivString}) {
    final uncompressedData = uncompress(data);
    final decryptedData =
        decrypt(uncompressedData, keyString, ivString: ivString);
    return uncompress(decryptedData);
  }

  static Future<void> saveDataToLocal(String fileName, String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(data);
  }
}
