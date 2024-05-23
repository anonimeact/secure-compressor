
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
Encrypt a string and compress it into a smaller size

## encrypt

Only encrypt:

    final compress = await compress(originData, keyString);
    
To encrypt and also compress the data:

    final compress = await compressAndEncrypt(originData, keyString);

## decrypt

Only decrypt:

    final uncompress = uncompress(compress, keyString);
To decrypt and also uncompress the data:

    final uncompress = uncompressAndDecrypt(compress, keyString);

