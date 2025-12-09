part of '../secure_compressor.dart';

class DecryptorParser {
  static Future<T> decryptAndParse<T>(
    dynamic encryptedData,
    T Function(Map<String, dynamic>) fromJson,
    String key,
  ) async {
    final decryptedString = SecureCompressor.decrypt(encryptedData, key);
    final decoded = jsonDecode(decryptedString);
    return fromJson(decoded);
  }

  static Future<List<T>> decryptAndParseList<T>(
    dynamic encryptedData,
    T Function(Map<String, dynamic>) fromJson,
    String key, {
    String fieldList = 'data',
  }) async {
    final decryptedString = SecureCompressor.encrypt(encryptedData, key);
    final decoded = jsonDecode(decryptedString);
    final data = decoded[fieldList];
    if (data is List) {
      return data.map<T>((e) => fromJson(e)).toList();
    } else {
      throw Exception('Expected List but got ${data.runtimeType}');
    }
  }
}
