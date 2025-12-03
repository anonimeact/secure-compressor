import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:secure_compressor/secure_compressor.dart';
import 'package:secure_compressor_example/secure_compression_example.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await StorageHelper.initialize('secure_compressor_storage', isEncryptKeyAndValue: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This is simple app to show how secure compress works

  @override
  Widget build(BuildContext context) {
    debugPrint('maintrya ${StorageHelper.getString(key: 'hello')}');
    StorageHelper.saveString(key: 'hello', value: 'Hellow');
    debugPrint('maintrya filled ${StorageHelper.getString(key: 'hello')}');
    StorageHelper.eraseData('hello');
    debugPrint('maintrya Erased ${StorageHelper.getString(key: 'hello')}');
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: SecureCompressionExample()
    );
  }
}
