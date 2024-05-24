import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:secure_compressor/secure_compressor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const keyString = 'abcdefghijklMNOPQRSTUVWXYZ123456'; // 32 characters
  const ivString = 'aBcDeFgH123456ij'; // 16 characters
  const originData = "Lorem ipsum dolor sit amet";

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (MethodCall methodCall) async {
      return './build';
    });
  });

  group('SecureCompressor Tests', () {
    test('encrypt and decrypt without IV', () async {
      final encryptedData =
          await SecureCompressor.encrypt(originData, keyString);
      final decryptedData = SecureCompressor.decrypt(encryptedData, keyString);
      expect(decryptedData, originData);
    });

    test('encrypt and decrypt with IV', () async {
      final encryptedData = await SecureCompressor.encrypt(
          originData, keyString,
          ivString: ivString);
      final decryptedData = SecureCompressor.decrypt(encryptedData, keyString,
          ivString: ivString);
      expect(decryptedData, originData);
    });

    test('compress and uncompress', () {
      final compressedData = SecureCompressor.compress(originData);
      final uncompressedData = SecureCompressor.uncompress(compressedData);
      expect(uncompressedData, originData);
    });

    test('compressAndEncrypt and uncompressAndDecrypt without IV', () async {
      final compressedAndEncryptedData =
          await SecureCompressor.compressAndEncrypt(originData, keyString);
      final uncompressedAndDecryptedData =
          SecureCompressor.uncompressAndDecrypt(
              compressedAndEncryptedData, keyString);
      expect(uncompressedAndDecryptedData, originData);
    });

    test('compressAndEncrypt and uncompressAndDecrypt with IV', () async {
      final compressedAndEncryptedData =
          await SecureCompressor.compressAndEncrypt(originData, keyString,
              ivString: ivString);
      final uncompressedAndDecryptedData =
          SecureCompressor.uncompressAndDecrypt(
              compressedAndEncryptedData, keyString,
              ivString: ivString);
      expect(uncompressedAndDecryptedData, originData);
    });

    test('saveDataToLocal', () async {
      const fileName = 'test_data.txt';
      const data = 'This is some test data';

      await SecureCompressor.saveDataToLocal(fileName, data);

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      final savedData = await file.readAsString();

      expect(savedData, data);
    });
  });
}
