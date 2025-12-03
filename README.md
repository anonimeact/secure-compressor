
<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.
For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).
For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# secure-compressor

`secure_compressor` is a Dart package that provides utilities for securely encrypting, decrypting, compressing, and decompressing string data using AES encryption and gzip compression.

## Features

- Encrypt and decrypt string data using AES encryption.
- Compress and decompress string data using gzip.
- Combine encryption and compression for secure and efficient data storage and transmission.
- Save encrypted and compressed data to local storage.
- Share encrypted and compressed data to media platform device (WA, email, etc).

## Installation

Add the following to your `pubspec.yaml` file:
```yaml

dependencies:

secure_compressor: <Latest-Version>

```

  

Then, run flutter pub get to fetch the package.

  

## Usages

    ::: Notes :::
     - keyString must be 32 character
     - Initialization Vector (IV) [ivString] must be 16 character

### Encrypt

Encrypt a string using AES encryption:
```dart

final result = await  SecureCompressor.encrypt(data, keyString, ivString: ivString);

```
Compress and then encrypt a string:
```dart

final result = await  SecureCompressor.compressAndEncrypt(data, keyString, ivString: ivString);

```
### Decrypt

Decrypt an AES encrypted string:
```dart

final result = SecureCompressor.decrypt(encryptedData, keyString, ivString: ivString);

```
Decrypt and then uncompress a string:
```dart

final result = SecureCompressor.uncompressAndDecrypt(compressedAndEncryptedData, keyString, ivString: ivString);

```

### Save Data to Local Storage

Save data to a local file:
```dart

	SecureCompressor.saveDataToLocal(fileName, data);

```

### Share Data to Media Platform Device (WA, email, etc)

Share data to a media platform device:
```dart

	SecureCompressor.shareFile(fileName, data);

```

### Generate Unix Key

If you wanna generate unix key, you can use this function.
NOTE: NEVER USE THIS FUNCTION TO ENCRYPT OR DECRYPT FROM OTHER DEVICE 

```dart

	await SecureCompressor.getUnixId()

```

### Save Primitif Data Type into Local Storage

Save primitif data type as string, boolean, int, and double into local storage using GetStorage.

Initializes the storage helper with the given parameters first befor run the app:
```dart
    await StorageHelper.initialize(
      'YOUR_STORAGE_NAME',
      isEncryptKeyAndValue: true, // Default true
      encryptionKey: "YOUR_ENCRYPTION_KEY_MUST_BE_32_CHAR", // If null, will use unix id from devices used
      isKeyEncrypted: false, // Default false
    );

```

```dart
	StorageHelper.saveString('test_key', 'test_value');
    final savedData = StorageHelper.getString('test_key');

```
Erase data by key

```dart
	StorageHelper.eraseData('test_key',);
```