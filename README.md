
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