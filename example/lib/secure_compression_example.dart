import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:secure_compressor/secure_compressor.dart';

class SecureCompressionExample extends StatefulWidget {
  const SecureCompressionExample({super.key});

  @override
  State<SecureCompressionExample> createState() => _SecureCompressionExampleState();
}

class _SecureCompressionExampleState extends State<SecureCompressionExample> {

  var dataResult = "";
  String? errorKeyString;
  final defaultKey = "50?thisIsEx4mplefor32EncryptKey!";
  final inputController = TextEditingController();
  final keyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadAd();
    const key = "duDluYlEkzk68D3fFcL80iG6FF9n1cvW"; // 32 karakter
    const iv = "h7EvzZ+vwkjns0vt"; // 16 karakter
    const originalText = "110317950632480998248";
    final encrypted = SecureCompressor.encrypt(originalText, key, ivString: iv);
    final decrypt = SecureCompressor.decrypt(encrypted, key, ivString: iv);
    print("SecureCompressor: enc $encrypted ${"/DPZMixdbBPJbUszJe4tuA==" == encrypted}");
    print("SecureCompressor: dec $decrypt");

    StorageHelper.saveString("test_key", "test_value");
    final data = StorageHelper.getString('test_key');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Text("Secure Compressor Generator",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
              const SizedBox(height: 16),
              TextField(
                controller: inputController,
                minLines: 1,
                maxLines: 10,
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                decoration: InputDecoration(
                    hintText: "Input your string data here",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffix: InkWell(
                      onTap: () => inputController.text = "",
                      child: const Icon(Icons.close, color: Colors.black, size: 20))
                    ),
                    
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                maxLength: 32,
                style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                decoration: InputDecoration(
                    hintText: "Input 32 character custom key (optional)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    suffix: InkWell(
                      onTap: () => keyController.text = "",
                      child: const Icon(Icons.close, color: Colors.black, size: 20)),
                      errorText: errorKeyString
                    ),
              ),
              Row(mainAxisSize: MainAxisSize.min, children: [
                const Text("Default Key:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300)),
                Padding(
                  padding: const EdgeInsets.only(left: 3, right: 10),
                  child: Text(defaultKey, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: defaultKey));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
                  },
                  child: const Icon(Icons.copy_outlined))
              ]),
              const SizedBox(height: 16),
              /** Button action widget */
              buttonActionWidget(),

              /** Showing the result */
              Visibility(
                  visible: dataResult.isNotEmpty,
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[200]),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                          width: double.infinity,
                        child: Text(dataResult,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: dataResult.contains("::: Error") ? Colors.red : Colors.black)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                  onTap: () => copyData(),
                                  child: const Icon(Icons.copy)),
                              const SizedBox(width: 12),
                              InkWell(
                                  onTap: () => shareData(),
                                  child: const Icon(Icons.share)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
              _bannerAd != null
                ? Container(
                    margin: const EdgeInsets.only(top: 16),
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  )
                : Container()
            ],
          ),
        ),
      ));
  }

  Widget buttonActionWidget() {
    final encryptionKey = keyController.text.isEmpty ? "50?thisIsEx4mplefor32EncryptKey!" : keyController.text;
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                final originData = inputController.text;
                setState(() {
                  if (isKeyStringValid()) {
                    dataResult = SecureCompressor.encrypt(originData, encryptionKey);
                  }
                  hideSoftKeyboard();
                });
              },
              child: const Text("Encrypt")),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () {
                final originData = inputController.text;
                setState(() {
                  if (isKeyStringValid()) {
                    dataResult = SecureCompressor.compressAndEncrypt(originData, encryptionKey);
                  }
                  hideSoftKeyboard();
                });
              },
              child: const Text("Encrypt & Compress")),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                final originData = inputController.text;
                setState(() {
                  if (isKeyStringValid()) {
                    dataResult = SecureCompressor.decrypt(originData, encryptionKey);
                  }
                  hideSoftKeyboard();
                });
              },
              child: const Text("Decrypt")),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () {
                final originData = inputController.text;
                setState(() {
                  if (isKeyStringValid()) {
                    dataResult = SecureCompressor.uncompressAndDecrypt(originData, encryptionKey);
                  }
                  hideSoftKeyboard();
                });
              },
              child: const Text("Decrypt & Uncompress")),
        ],
      ),
    ]);
  }

  bool isKeyStringValid() {
    final key = keyController.text;
    final isValid = key.isEmpty
        ? true
        : key.length == 32
            ? true
            : false;
    errorKeyString = isValid ? null : "Custom key must be 32 character" ;
    if (!isValid) {
      dataResult = "";
    }
    return isValid;
  }

  void hideSoftKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void copyData() {
    Clipboard.setData(ClipboardData(text: dataResult));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!")));
  }

  void shareData() {
    SecureCompressor.shareFile("sc_result${DateTime.now().millisecondsSinceEpoch}.txt", dataResult);
  }
  
  BannerAd? _bannerAd;
  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-2785838023943615/8094872898',
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
        },
        
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }
}