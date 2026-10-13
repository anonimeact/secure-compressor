import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_compressor/secure_compressor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProvider = MethodChannel('plugins.flutter.io/path_provider');
  const secureCompressorChannel = MethodChannel('secure_compressor');
  const encryptionKey = '50?thisIsEx4mplefor32EncryptKey!';

  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('storage_helper_platform_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, (MethodCall call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return tmpDir.path;
      }
      return null;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProvider, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureCompressorChannel, null);
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  test('initialize does not call getUnixId on desktop (web-like path)', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    var getUnixIdCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureCompressorChannel, (
      MethodCall call,
    ) async {
      if (call.method == 'getUnixId') {
        getUnixIdCalls++;
      }
      return null;
    });

    await StorageHelper.initialize(
      'storage_helper_desktop_test',
      encryptionKey: encryptionKey,
    );

    expect(getUnixIdCalls, 0);
    expect(StorageHelper.isInitialized(), isTrue);
  });

  test('initialize calls getUnixId on Android', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    var getUnixIdCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureCompressorChannel, (
      MethodCall call,
    ) async {
      if (call.method == 'getUnixId') {
        getUnixIdCalls++;
        return '12345678901234567890123456789012';
      }
      return null;
    });

    await StorageHelper.initialize(
      'storage_helper_android_test',
      encryptionKey: encryptionKey,
    );

    expect(getUnixIdCalls, 1);
    expect(StorageHelper.isInitialized(), isTrue);
  });

  test('initialize without encryptionKey uses storage name on desktop', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureCompressorChannel, (
      MethodCall call,
    ) async {
      if (call.method == 'getUnixId') {
        fail('getUnixId must not be invoked on desktop');
      }
      return null;
    });

    await StorageHelper.initialize('short_name_storage_box');
    expect(StorageHelper.isInitialized(), isTrue);
  });
}
