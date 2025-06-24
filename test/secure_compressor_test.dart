import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_compressor/secure_compressor.dart';
import 'package:secure_compressor/src/channels/secure_compressor_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSecureCompressorPlatform with MockPlatformInterfaceMixin implements SecureCompressorPlatform {
  @override
  Future<String?> getUnixId() => Future.value('42');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel channel = MethodChannel('secure_compressor');
  setUp(() async {
    // Mock method channel call
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      MethodCall methodCall,
    ) async {
      if (methodCall.method == 'getUnixId') {
        return 'mocked-unix-id-1234567890';
      }
      return null;
    });
    final defaultKey = "50?thisIsEx4mplefor32EncryptKey!";
    await StorageHelper.initialize(
      'secure_compressor_test',
      isEncryptKeyAndValue: true,
      encryptionKey: defaultKey,
      isKeyEncrypted: true,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
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
      final compressedAndEncrypted = SecureCompressor.compressAndEncrypt('test_string', defaultKey);
      final decompressedAndDecrypted = SecureCompressor.uncompressAndDecrypt(compressedAndEncrypted, defaultKey);
      expect(decompressedAndDecrypted, 'test_string');
    });
  });

  group('storage helper test', () {
    test('string test', () {
      StorageHelper.saveString('test_key', 'test_value');
      final value = StorageHelper.getString('test_key');
      expect(value, 'test_value');
    });
    test('empty string test', () {
      StorageHelper.saveString('test_key', '');
      final value = StorageHelper.getString('test_key');
      expect(value, '');
    });
    test('bool test', () {
      StorageHelper.saveBoolean('test_key', true);
      final value = StorageHelper.getBoolean('test_key');
      expect(value, true);
    });
    test('int test', () {
      StorageHelper.saveInt('test_key', 10);
      final value = StorageHelper.getInt('test_key');
      expect(value, 10);
    });
    test('double test', () {
      StorageHelper.saveDouble('test_key', 10.0);
      final value = StorageHelper.getDouble('test_key');
      expect(value, 10.0);
    });
  });
}
