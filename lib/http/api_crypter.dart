import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class ApiCrypter {
  

  // Key generation methods
 static String _generateString(int length) {
    const characters = "abcdefghijklmnopqrstuvwxyz0123456789";
    String result = "";
    final random = Random();
    
    for (int i = 0; i < length; i++) {
      result += characters[random.nextInt(characters.length)];
    }
    return result;
  }

static  String generateKey() {
    String key =
        _generateString(8) +
        "-" +
        _generateString(4) +
        "-" +
        _generateString(4) +
        "-" +
        _generateString(4) +
        "-" +
        _generateString(12);
    return key;
  }

 static String crypt(String key) {
    String passphrase = "RCq8@aSvhMn47s";
    String data = key + passphrase;
    var bytes = utf8.encode(data);
    var digest = sha512.convert(bytes);
    return digest.toString();
  }

}