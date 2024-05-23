import 'package:flutter_test/flutter_test.dart';
import 'package:secure_compressor/secure_compressor.dart';

void main() {
  test('compress without IV', () async {
    const keyString = 'abcdefghijklMNOPQRSTUVWXYZ123456';
    const originData = "Lorem ipsum dolor sit amet";
    final compress = await compressAndEncrypt(originData, keyString);
    final uncompress = uncompressAndDecrypt(compress, keyString);
    expect(uncompress, originData);
  });
  test('compress with IV', () async {
    const keyString = 'abcdefghijklMNOPQRSTUVWXYZ123456';
    const ivString = 'aBcDeFgH123456ij';
    const originData = "aBcDeFgH";
    final compress = await compressAndEncrypt(originData, keyString, ivString: ivString);
    final uncompress = uncompressAndDecrypt(compress, keyString, ivString: ivString);
    expect(uncompress, originData);
  });
}
