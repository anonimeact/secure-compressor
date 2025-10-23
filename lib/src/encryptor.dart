part of '../secure_compressor.dart';

/// A utility class for secure data compression and encryption.
class SecureCompressor {
  /// Encrypts the given [data] using AES encryption with the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 32 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns a Base64 encoded string of the encrypted data.
  ///
  /// Throws an [ArgumentError] if [keyString] is not 32 characters long.
  static String encrypt(String data, String keyString,
      {String? ivString, encriptor.AESMode mode = encriptor.AESMode.sic}) {
    if (data.isEmpty) {
      return '';
    } else if (keyString.length < 32) {
      return 'keyString length must be 32 characters.';
    }
    final key = encriptor.Key.fromUtf8(keyString.substring(0, 32));
    final iv = encriptor.IV.fromUtf8(ivString ?? keyString.substring(0, 16));
    final encrypter = encriptor.Encrypter(encriptor.AES(key, mode: mode));
    final encryptedData = encrypter.encrypt(data, iv: iv);
    return encryptedData.base64;
  }

  /// Decrypts the given [data] using AES encryption with the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 32 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns the decrypted data as a string.
  ///
  /// Throws an [ArgumentError] if [keyString] is not 32 characters long.
  static String decrypt(String data, String keyString,
      {String? ivString, encriptor.AESMode mode = encriptor.AESMode.sic}) {
    if (data.isEmpty) {
      return '';
    } else if (keyString.length < 32) {
      return 'keyString long must be 32 characters.';
    }
    final key = encriptor.Key.fromUtf8(keyString);
    final iv = encriptor.IV.fromUtf8(ivString ?? keyString.substring(0, 16));
    final encrypter = encriptor.Encrypter(encriptor.AES(key, mode: mode));
    try {
      return encrypter.decrypt64(data, iv: iv);
    } catch (_) {
      return '::: Error decrypting data';
    }
  }

  /// Compresses the given [data] using gzip.
  ///
  /// Returns the compressed data as a string.
  static String compress(String data) {
    try {
      return data.isEmpty
          ? ''
          : String.fromCharCodes(gzip.encode(utf8.encode(data)));
    } catch (_) {
      return ':::: Error uncompressing data';
    }
  }

  /// Decompresses the given [data] using gzip.
  ///
  /// Returns the decompressed data as a string.
  static String uncompress(String data) {
    try {
      return data.isEmpty ? '' : utf8.decode(gzip.decode(data.codeUnits));
    } catch (_) {
      return ':::: Error uncompressing data';
    }
  }

  /// Compresses and encrypts the given [data] using the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 32 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns the compressed and encrypted data as a string.
  static String compressAndEncrypt(String data, String keyString,
      {String? ivString, encriptor.AESMode mode = encriptor.AESMode.sic}) {
    if (data.isEmpty) return '';
    final compressedData = compress(data);
    final encryptedData =
        encrypt(compressedData, keyString, ivString: ivString, mode: mode);
    return compress(encryptedData);
  }

  /// Decompresses and decrypts the given [data] using the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 32 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns the decompressed and decrypted data as a string.
  static String uncompressAndDecrypt(String data, String keyString,
      {String? ivString, encriptor.AESMode mode = encriptor.AESMode.sic}) {
    if (data.isEmpty) return '';
    final uncompressedData = uncompress(data);
    final decryptedData =
        decrypt(uncompressedData, keyString, ivString: ivString, mode: mode);
    return uncompress(decryptedData);
  }

  /// Saves the given [data] to a local file with the provided [fileName].
  ///
  /// The file will be saved in the application's documents directory
  /// (Use android device explorer to access it).
  static Future<File?> saveDataToLocal(String fileName, String data) async {
    if (fileName.isEmpty || data.isEmpty) return null;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    return await file.writeAsString(data);
  }

  /// Share the given [data] to media platform with the provided [fileName].
  ///
  /// The file will be shared in the  media platform device used
  static Future<void> shareFile(String fileName, String data) async {
    if (fileName.isEmpty || data.isEmpty) return;
    final file = await saveDataToLocal(fileName, data);
    final params = ShareParams(text: 'Encrypted file', files: [XFile(file!.path)]);
    SharePlus.instance.share(params);
  }

  static Future<String?> getUnixId() {
    return SecureCompressorPlatform.instance.getUnixId();
  }
}
