import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'secure_compressor_method_channel.dart';

abstract class SecureCompressorPlatform extends PlatformInterface {
  /// Constructs a SecureCompressorPlatform.
  SecureCompressorPlatform() : super(token: _token);

  static final Object _token = Object();

  static SecureCompressorPlatform _instance = MethodChannelSecureCompressor();

  /// The default instance of [SecureCompressorPlatform] to use.
  ///
  /// Defaults to [MethodChannelSecureCompressor].
  static SecureCompressorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SecureCompressorPlatform] when
  /// they register themselves.
  static set instance(SecureCompressorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getUnixId() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
