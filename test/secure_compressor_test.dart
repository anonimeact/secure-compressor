import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_compressor/secure_compressor.dart';
import 'package:secure_compressor/src/channels/secure_compressor_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecureCompressorPlatform
    with MockPlatformInterfaceMixin
    implements SecureCompressorPlatform {
  @override
  Future<String?> getUnixId() => Future.value('42');
}

String readAsset(String name) => File('test/data/$name').readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('secure_compressor');
  const MethodChannel pathProvider = MethodChannel(
    'plugins.flutter.io/path_provider',
  );
  setUpAll(() async {
    // Mock method channel call
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'getUnixId') {
            return 'mocked-unix-id-1234567890';
          }
          return null;
        });
    final tmpDir = Directory.systemTemp.createTempSync();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (MethodCall call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return tmpDir.path;
          }
          return null;
        });
    final defaultKey = "50?thisIsEx4mplefor32EncryptKey!";

    final publicKey = readAsset('public_key.pam');
    final privateKey = readAsset('private_key.pam');
    SecureCompressor.initialize(publicKey: publicKey, privateKey: privateKey);
    await StorageHelper.initialize(
      'secure_compressor_test',
      isEncryptKeyAndValue: true,
      encryptionKey: defaultKey,
      isKeyEncrypted: true,
    );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, null);
  });

  group('encrypt decrrypt string', () {
    test('encrypt and decrypt string', () async {
      final defaultKey = "50?thisIsEx4mplefor32EncryptKey!";
      final encrypted = SecureCompressor.encrypt('test_string', defaultKey);
      final decrypted = SecureCompressor.decrypt(encrypted, defaultKey);
      expect(decrypted, 'test_string');
    });
    test('compress and decompress string', () {
      final compressed = SecureCompressor.compress('test_string');
      final decompressed = SecureCompressor.uncompress(compressed);
      expect(decompressed, 'test_string');
    });
    test('compress and encrypt string', () {
      final defaultKey = "50?thisIsEx4mplefor32EncryptKey!";
      final compressedAndEncrypted = SecureCompressor.compressAndEncrypt(
        'test_string',
        defaultKey,
      );
      final decompressedAndDecrypted = SecureCompressor.uncompressAndDecrypt(
        compressedAndEncrypted,
        defaultKey,
      );
      expect(decompressedAndDecrypted, 'test_string');
    });
  });

  group('encrypt decrypt RSA', () {
    test('encrypt and decrypt string RSA', () async {
      final encrypted = await SecureCompressor.encryptRsa('test_string');
      final decrypted = await SecureCompressor.decryptRsa(encrypted);
      expect(decrypted, 'test_string');
    });
  });

  group('storage helper test', () {
    test('string test', () {
      StorageHelper.saveString(key: 'test_key', value: 'test_value');
      final value = StorageHelper.getString(key: 'test_key');
      expect(value, 'test_value');
    });
    test('empty string test', () {
      StorageHelper.saveString(key: 'test_key', value: '');
      final value = StorageHelper.getString(key: 'test_key');
      expect(value, '');
    });
    test('bool test', () {
      StorageHelper.saveBoolean(key: 'test_key', value: true);
      final value = StorageHelper.getBoolean(key: 'test_key');
      expect(value, true);
    });
    test('int test', () {
      StorageHelper.saveInt(key: 'test_key', value: 10);
      final value = StorageHelper.getInt(key: 'test_key');
      expect(value, 10);
    });
    test('double test', () {
      StorageHelper.saveDouble(key: 'test_key', value: 10.0);
      final value = StorageHelper.getDouble(key: 'test_key');
      expect(value, 10.0);
    });
    test('num test', () {
      final num testNum = 10;
      final num testNumDouble = 10.1;
      StorageHelper.saveNum(key: 'test_key_num_int', value: testNum);
      final valueInt = StorageHelper.getNum(key: 'test_key_num_int');

      StorageHelper.saveNum(key: 'test_key_num_double', value: testNumDouble);
      final valueDouble = StorageHelper.getNum(key: 'test_key_num_double');

      expect(valueInt, testNum);
      expect(valueDouble, testNumDouble);
    });
  });
}
