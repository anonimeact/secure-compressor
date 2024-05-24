part of '../secure_compressor.dart';

/// A utility class for secure data compression and encryption.
class SecureCompressor {
  /// Encrypts the given [data] using AES encryption with the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 16 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns a Base64 encoded string of the encrypted data.
  ///
  /// Throws an [ArgumentError] if [keyString] is not 32 characters long.
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

  /// Decrypts the given [data] using AES encryption with the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 16 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns the decrypted data as a string.
  ///
  /// Throws an [ArgumentError] if [keyString] is not 32 characters long.
  static String decrypt(String data, String keyString, {String? ivString}) {
    if (keyString.length != 32) {
      throw ArgumentError('keyString must be 32 characters long.');
    }
    final key = encriptor.Key.fromUtf8(keyString);
    final iv = encriptor.IV.fromUtf8(ivString ?? keyString.substring(0, 16));
    final encrypter = encriptor.Encrypter(encriptor.AES(key));
    return encrypter.decrypt64(data, iv: iv);
  }

  /// Compresses the given [data] using gzip.
  ///
  /// Returns the compressed data as a string.
  static String compress(String data) {
    return String.fromCharCodes(gzip.encode(utf8.encode(data)));
  }

  /// Decompresses the given [data] using gzip.
  ///
  /// Returns the decompressed data as a string.
  static String uncompress(String data) {
    return utf8.decode(gzip.decode(data.codeUnits));
  }

  /// Compresses and encrypts the given [data] using the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 16 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns the compressed and encrypted data as a string.
  static Future<String> compressAndEncrypt(String data, String keyString,
      {String? ivString}) async {
    final compressedData = compress(data);
    final encryptedData =
        await encrypt(compressedData, keyString, ivString: ivString);
    return compress(encryptedData);
  }

  /// Decompresses and decrypts the given [data] using the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 16 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns the decompressed and decrypted data as a string.
  static String uncompressAndDecrypt(String data, String keyString,
      {String? ivString}) {
    final uncompressedData = uncompress(data);
    final decryptedData =
        decrypt(uncompressedData, keyString, ivString: ivString);
    return uncompress(decryptedData);
  }

  /// Saves the given [data] to a local file with the provided [fileName].
  ///
  /// The file will be saved in the application's documents directory.
  static Future<void> saveDataToLocal(String fileName, String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsString(data);
  }
}
