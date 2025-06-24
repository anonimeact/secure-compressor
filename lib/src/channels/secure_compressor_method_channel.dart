import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'secure_compressor_platform_interface.dart';

/// An implementation of [SecureCompressorPlatform] that uses method channels.
class MethodChannelSecureCompressor extends SecureCompressorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('secure_compressor');

  @override
  Future<String?> getUnixId() async {
    final version = await methodChannel.invokeMethod<String>('getUnixId');
    return version;
  }
}
