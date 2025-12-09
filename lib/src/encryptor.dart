part of '../secure_compressor.dart';

/// A utility class for secure data compression and encryption.
class SecureCompressor {
  ///  Singleton class for secure compression and hybrid encryption.
  ///
  /// Use [SecureCompressor.instance] or the factory constructor [SecureCompressor()]
  /// to access the single instance of this class.

  /// The single shared instance of [SecureCompressor].
  static final SecureCompressor _instance = SecureCompressor._internal();

  /// Factory constructor that always returns the singleton instance.
  factory SecureCompressor() => _instance;

  /// Private constructor for singleton pattern.
  SecureCompressor._internal();

  // --- RSA key storage ---
  static RSAPublicKey? _publicKey;
  static RSAPrivateKey? _privateKey;
  static bool _initialized = false;

  /// Initializes the RSA keys for encryption/decryption.
  ///
  /// This method **must be called** if you intend to use RSA operations directly.
  /// If already initialized, calling this method again has no effect.
  ///
  /// Parameters:
  /// - [publicKey]: PEM-formatted RSA public key for encryption.
  /// - [privateKey]: PEM-formatted RSA private key for decryption.
  ///
  /// After initialization, [publicKey] and [privateKey] getters can be safely used.
  static Future<void> initialize({
    required String publicKey,
    required String privateKey,
  }) async {
    if (_initialized) return;

    _publicKey = RSAKeyParser().parse(publicKey) as RSAPublicKey;
    _privateKey = RSAKeyParser().parse(privateKey) as RSAPrivateKey;

    _initialized = true;
  }

  /// Encrypts the given [data] using AES encryption with the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 32 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns a Base64 encoded string of the encrypted data.
  ///
  /// Throws an [ArgumentError] if [keyString] is not 32 characters long.
  static String encrypt(
    String data,
    String keyString, {
    String? ivString,
    encriptor.AESMode mode = encriptor.AESMode.sic,
  }) {
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
  static String decrypt(
    String data,
    String keyString, {
    String? ivString,
    encriptor.AESMode mode = encriptor.AESMode.sic,
  }) {
    if (data.isEmpty) {
      return '';
    } else if (keyString.length < 32) {
      return 'keyString long must be 32 characters.';
    }
    final key = encriptor.Key.fromUtf8(keyString.substring(0, 32));
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
  static String compressAndEncrypt(
    String data,
    String keyString, {
    String? ivString,
    encriptor.AESMode mode = encriptor.AESMode.sic,
  }) {
    if (data.isEmpty) return '';
    final compressedData = compress(data);
    final encryptedData = encrypt(
      compressedData,
      keyString,
      ivString: ivString,
      mode: mode,
    );
    return compress(encryptedData);
  }

  /// Decompresses and decrypts the given [data] using the provided [keyString].
  ///
  /// The [keyString] must be 32 characters long. The optional [ivString] must be 32 characters long.
  /// If [ivString] is not provided, a part of [keyString] will be used as the initialization vector (IV).
  ///
  /// Returns the decompressed and decrypted data as a string.
  static String uncompressAndDecrypt(
    String data,
    String keyString, {
    String? ivString,
    encriptor.AESMode mode = encriptor.AESMode.sic,
  }) {
    if (data.isEmpty) return '';
    final uncompressedData = uncompress(data);
    final decryptedData = decrypt(
      uncompressedData,
      keyString,
      ivString: ivString,
      mode: mode,
    );
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

  /// Returns a Unix-based identifier for the current device.
  ///
  /// Note: This ID is **not suitable for global encryption** or as a secure key
  /// for cryptographic operations. It can be used for device-specific identification
  /// or local caching purposes.
  ///
  /// Returns a `Future<String?>` containing the Unix ID, or `null` if unavailable.
  static Future<String?> getUnixId() {
    return SecureCompressorPlatform.instance.getUnixId();
  }

  /// Gets the RSA public key used for encryption.
  ///
  /// Throws an [Exception] if the SecureCompressor has not been initialized.
  ///
  /// Returns an [RSAPublicKey] instance.
  static RSAPublicKey get publicKey {
    if (!_initialized) throw Exception('SecureCompressor not initialized!');
    return _publicKey!;
  }

  /// Gets the RSA private key used for decryption.
  ///
  /// Throws an [Exception] if the SecureCompressor has not been initialized.
  ///
  /// Returns an [RSAPrivateKey] instance.
  static RSAPrivateKey get privateKey {
    if (!_initialized) throw Exception('SecureCompressor not initialized!');
    return _privateKey!;
  }

  /// Encrypts the given plain text using AES-GCM and RSA hybrid encryption.
  ///
  /// This function performs the following steps:
  /// 1. Generates a random 32-byte AES key and a 12-byte IV (Initialization Vector).
  /// 2. Encrypts the provided [plainText] using AES in GCM mode.
  /// 3. Extracts the authentication tag (last 16 bytes) from the encrypted data.
  /// 4. Encrypts the AES key using RSA public key with OAEP padding.
  /// 5. Returns a `Map<String, String>` containing:
  ///    - `"encryptedKey"`: The RSA-encrypted AES key, base64 encoded.
  ///    - `"encryptedData"`: The AES-encrypted data without the authentication tag, hex encoded.
  ///    - `"authTag"`: The AES-GCM authentication tag, hex encoded.
  ///    - `"iv"`: The initialization vector used for AES-GCM, hex encoded.
  ///
  /// This method is useful for securely transmitting data by combining symmetric
  /// and asymmetric encryption.
  static Future<Map<String, String>> encryptRsa(String plainText) async {
    final aesKey = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(aesKey, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    final authTag = encrypted.bytes.sublist(encrypted.bytes.length - 16);
    final cipherTextWithoutTag = encrypted.bytes.sublist(
      0,
      encrypted.bytes.length - 16,
    );

    final rsaEncrypter = Encrypter(
      RSA(publicKey: publicKey, encoding: RSAEncoding.OAEP),
    );
    final encryptedKey = rsaEncrypter.encrypt(base64Encode(aesKey.bytes));

    return {
      "encryptedKey": encryptedKey.base64,
      "encryptedData": bytesToHex(cipherTextWithoutTag),
      "authTag": bytesToHex(authTag),
      "iv": bytesToHex(iv.bytes),
    };
  }

  /// Decrypts the data encrypted by [encryptRsa].
  ///
  /// This function performs the following steps:
  /// 1. Decrypts the AES key using the RSA private key with OAEP padding.
  /// 2. Combines the encrypted data and the authentication tag to reconstruct the full ciphertext.
  /// 3. Decrypts the combined ciphertext using AES-GCM with the decrypted AES key and provided IV.
  /// 4. Returns the original plain text as a `String`.
  ///
  /// The input [encryptedData] map must contain the following keys:
  /// - `"encryptedKey"`: The RSA-encrypted AES key (base64 encoded).
  /// - `"encryptedData"`: The AES-encrypted data without the auth tag (hex encoded).
  /// - `"authTag"`: The AES-GCM authentication tag (hex encoded).
  /// - `"iv"`: The initialization vector used for AES-GCM (hex encoded).
  ///
  /// Ensure that the `encryptedData` map comes from a trusted source, as
  /// tampering can cause decryption to fail or throw an exception.
  static Future<String> decryptRsa(Map<String, dynamic> encryptedData) async {
    final rsaDecrypter = Encrypter(
      RSA(privateKey: privateKey, encoding: RSAEncoding.OAEP),
    );
    final decryptedKey = base64.decode(
      rsaDecrypter.decrypt(Encrypted.fromBase64(encryptedData['encryptedKey'])),
    );
    final aesKey = Key(Uint8List.fromList(decryptedKey));

    final Uint8List encryptedDataBytes = hexToBytes(
      encryptedData['encryptedData']!,
    );
    final Uint8List authTagBytes = hexToBytes(encryptedData['authTag']!);
    final Uint8List combinedBytes = Uint8List.fromList([
      ...encryptedDataBytes,
      ...authTagBytes,
    ]);
    final iv = IV(hexToBytes(encryptedData['iv']));

    final encrypter = Encrypter(AES(aesKey, mode: AESMode.gcm));
    final decryptedText = encrypter.decrypt(Encrypted(combinedBytes), iv: iv);

    return decryptedText;
  }

  static String bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List hexToBytes(String hex) {
    return Uint8List.fromList(
      List.generate(
        hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
      ),
    );
  }
}
