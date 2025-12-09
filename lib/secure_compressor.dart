library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encriptor;
import 'package:encrypt/encrypt.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:secure_compressor/src/channels/secure_compressor_platform_interface.dart';


part 'src/decryptor_parser.dart';
part 'src/encryptor.dart';
part 'src/storage_helper.dart';
