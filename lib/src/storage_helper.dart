part of '../secure_compressor.dart';

class StorageHelper {
  static late String _storageName;
  static late String _encryptionKey;
  static late bool _isEncrypKeyValue;
  static GetStorage get _box => GetStorage(_storageName);

  /// Initializes the storage helper with the given parameters.
  /// [storageName] is the name of the storage box.
  /// [encryptionKey] is the key used for encryption. It must be at least 32 characters long.
  /// [isKeyEncrypted] indicates whether the encryption key itself is encrypted.
  /// [isEncryptKeyAndValue] indicates whether both keys and values should be encrypted.
  ///
  static Future<void> initialize(
    String storageName, {
    String? encryptionKey,
    bool isKeyEncrypted = false,
    bool isEncryptKeyAndValue = true,
  }) async {
    _storageName = storageName;
    _isEncrypKeyValue = isEncryptKeyAndValue;
    if (encryptionKey != null && encryptionKey.length < 32) {
      throw ArgumentError('Encryption key must not be null or less thank 32 characters.');
    }
    String unixId = await SecureCompressor.getUnixId() ?? encryptionKey ?? _storageName;
    if (unixId.length < 32) {
      unixId += (encryptionKey ?? '') + _storageName;
      unixId = unixId.padRight(32, '0');
    }
    late String key;
    if (encryptionKey != null) {
      key = isKeyEncrypted ? SecureCompressor.encrypt(encryptionKey, unixId.substring(0, 32)) : encryptionKey;
    } else {
      key = unixId;
    }
    _encryptionKey = key.substring(0, 32);
  }

  /// Clears the storage.
  static Future<void> clear() async {
    await _box.erase();
  }

  /// Checks if the storage is initialized.
  static bool isInitialized() {
    return _storageName.isNotEmpty && _encryptionKey.isNotEmpty;
  }
  /// Checks if the storage is encrypted.
  static bool isEncrypted() {
    return _isEncrypKeyValue && _encryptionKey.isNotEmpty;
  }

  /// Checks if the storage is encrypted with a key.
  static bool isKeyEncrypted() {
    return _isEncrypKeyValue && _encryptionKey.isNotEmpty && _encryptionKey.length == 32;
  }

  /// Checks if the storage is encrypted with a key and value.
  static bool isKeyAndValueEncrypted() {
    return _isEncrypKeyValue && _encryptionKey.isNotEmpty && _encryptionKey.length == 32;
  }

  /// Saves a string value with the given key.
  /// If [_isEncrypKeyValue] is true, both the key and value will be encrypted using the [_encryptionKey].
  /// If [_isEncrypKeyValue] is false, the key and value will be stored as is.
  static void saveString(String key, String value) {
    final encKey = _isEncrypKeyValue ? SecureCompressor.encrypt(key, _encryptionKey) : key;
    final finalValue = _isEncrypKeyValue ? SecureCompressor.encrypt(value, _encryptionKey) : value;
    _box.write(encKey, finalValue);
  }

  /// Retrieves a string value for the given key.
  /// If [_isEncrypKeyValue] is true, both the key and value will be decrypted using the [_encryptionKey].
  /// If [_isEncrypKeyValue] is false, the key and value will be read as is.
  /// Returns an empty string if the key does not exist.
  static String getString(String key) {
    final encKey = _isEncrypKeyValue ? SecureCompressor.encrypt(key, _encryptionKey) : key;
    final value = _box.read(encKey) ?? '';
    return _isEncrypKeyValue ? SecureCompressor.decrypt(value, _encryptionKey) : value;
  }

  /// Saves a boolean value with the given key.
  /// If [_isEncrypKeyValue] is true, the key will be encrypted using the [_encryptionKey].
  /// If [_isEncrypKeyValue] is false, the key will be stored as is.
  /// The value will be stored as a boolean.
  static void saveBoolean(String key, bool value) {
    final encKey = _isEncrypKeyValue ? SecureCompressor.encrypt(key, _encryptionKey) : key;
    _box.write(encKey, value);
  }

  /// Retrieves a boolean value for the given key.
  /// If [_isEncrypKeyValue] is true, the key will be decrypted using the [_encryptionKey].
  /// If [_isEncrypKeyValue] is false, the key will be read as is.
  /// Returns false if the key does not exist or if the value is not a boolean.
  static bool getBoolean(String key) {
    final encKey = _isEncrypKeyValue ? SecureCompressor.encrypt(key, _encryptionKey) : key;
    return _box.read(encKey) ?? false;
  }

  /// Saves an integer value with the given key.
  /// If [_isEncrypKeyValue] is true, the key and value will be encrypted using the [_encryptionKey].
  /// If [_isEncrypKeyValue] is false, the key and value will be stored as is.
  /// The value will be stored as String if [_isEncrypKeyValue] is true.
  static void saveInt(String key, int value) {
    final encKey = _isEncrypKeyValue ? SecureCompressor.encrypt(key, _encryptionKey) : key;
    final finalValue = _isEncrypKeyValue ? SecureCompressor.encrypt(value.toString(), _encryptionKey) : value;
    _box.write(encKey, finalValue);
  }

  /// Retrieves an integer value for the given key.
  /// If [_isEncrypKeyValue] is true, the key and value will be decrypted using the [_encryptionKey].
  /// If [_isEncrypKeyValue] is false, the key and value will be read as is.
  /// Returns 0 if the key does not exist or if the value cannot be parsed as an integer.
  static int getInt(String key) {
    final encKey = SecureCompressor.encrypt(key, _encryptionKey);
    final value = _box.read(encKey) ?? 0;
    if (_isEncrypKeyValue) {
      final decryptedValue = SecureCompressor.decrypt(value, _encryptionKey);
      return int.tryParse(decryptedValue) ?? 0;
    }
    return value;
  }

  /// Saves a double value with the given key.
  /// If [_isEncrypKeyValue] is true, the key and value will be encrypted using the [_encryptionKey].
  /// If [_isEncrypKeyValue] is false, the key and value will be stored as is.
  /// The value will be stored as String if [_isEncrypKeyValue] is true.
  static void saveDouble(String key, double value) {
    final encKey = SecureCompressor.encrypt(key, _encryptionKey);
    final finalValue = _isEncrypKeyValue ? SecureCompressor.encrypt(value.toString(), _encryptionKey) : value;
    _box.write(encKey, finalValue);
  }

  /// Retrieves a double value for the given key.
  /// If [_isEncrypKeyValue] is true, the key and value will be decrypted using the [_encryptionKey].
  /// If [_isEncrypKeyValue] is false, the key and value will be read as is.
  /// Returns 0.0 if the key does not exist or if the value cannot be parsed as a double.
  static double getDouble(String key) {
    final encKey = SecureCompressor.encrypt(key, _encryptionKey);
    final value = _box.read(encKey) ?? 0.0;
    if (_isEncrypKeyValue) {
      final decryptedValue = SecureCompressor.decrypt(value, _encryptionKey);
      return double.tryParse(decryptedValue) ?? 0.0;
    }
    return value;
  }
}
