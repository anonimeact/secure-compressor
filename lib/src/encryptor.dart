part of '../secure_compressor.dart';

Future<String> encrypt(String data, String keyString, { String? ivString }) async {
  // Initialize enctiprion using AES
  final key = encriptor.Key.fromUtf8(keyString);

  // The initali vector will using part off key if the iv is null
  final iv = encriptor.IV.fromUtf8(ivString ?? keyString.substring(0, 16));
  final encrypter = encriptor.Encrypter(encriptor.AES(key));

  // Encrypt the data
  final encryptedData = encrypter.encrypt(data, iv: iv);
  return encryptedData.base64;
}

String decrypt(String data, String keyString, { String? ivString }) {
  // Decode base64 dan initialize decription menggunakan AES
  final key = encriptor.Key.fromUtf8(keyString);

  // The initali vector will using part off key if the iv is null
  final iv = encriptor.IV.fromUtf8(ivString ?? keyString.substring(0, 16));
  final encrypter = encriptor.Encrypter(encriptor.AES(key));

  // Decrypt the data
  return encrypter.decrypt64(data, iv: iv);
}

// Compress string data using gzip
String compress(String data) => String.fromCharCodes(gzip.encode(utf8.encode(data)));

// Uncompress string data using gzip
String uncompress(String data) => utf8.decode(gzip.decode(data.codeUnits));

// keyString must be 32 char
// ivString must be 16 char
Future<String> compressAndEncrypt(String data, String keyString, { String? ivString }) async {
  final encryptedData = await encrypt(compress(data), keyString, ivString: ivString);
  return compress(encryptedData);
}

// keyString must be 32 char
// ivString must be 16 char
String uncompressAndDecrypt(String data, String keyString, { String? ivString }) {
  final encryptedData = decrypt(uncompress(data), keyString, ivString: ivString);
  return uncompress(encryptedData);
}

// if you want to generate data and save data in data/data/files
// you can acces the data using, use Android Window Explorer
Future<void> saveDataToLocal(String fileName, String data) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$fileName';
  File(filePath).writeAsStringSync(data);
}