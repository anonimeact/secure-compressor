import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:secure_compressor/secure_compressor.dart';

class SecureCompressionExample extends StatefulWidget {
  const SecureCompressionExample({super.key});

  @override
  State<SecureCompressionExample> createState() => _SecureCompressionExampleState();
}

class _SecureCompressionExampleState extends State<SecureCompressionExample> {

  var dataResult = "";
  final inputController = TextEditingController();
  final keyController = TextEditingController();

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
                      child: const Icon(Icons.close, color: Colors.black, size: 20))
                    ),
              ),

              /** Button action widget */
              buttonActionWidget(),

              /** Showing the result */
              Visibility(
                  visible: dataResult.isNotEmpty,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
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
                  ))
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
                  dataResult = SecureCompressor.encrypt(originData, encryptionKey);
                  hideSoftKeyboard();
                });
              },
              child: const Text("Encrypt")),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () {
                final originData = inputController.text;
                setState(() {
                  dataResult = SecureCompressor.compressAndEncrypt(originData, encryptionKey);
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
                  dataResult = SecureCompressor.decrypt(originData, encryptionKey);
                  hideSoftKeyboard();
                });
              },
              child: const Text("Decrypt")),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: () {
                final originData = inputController.text;
                setState(() {
                  dataResult = SecureCompressor.uncompressAndDecrypt(originData, encryptionKey);
                  hideSoftKeyboard();
                });
              },
              child: const Text("Decrypt & Uncompress")),
        ],
      ),
    ]);
  }

  void hideSoftKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void copyData() {
    Clipboard.setData(ClipboardData(text: dataResult));
  }

  void shareData() {
    SecureCompressor.shareFile("sc_result${DateTime.now().millisecondsSinceEpoch}.txt", dataResult);
  }
}