import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class ApiInterceptor implements InterceptorContract {
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    // Skip adding headers for oauth and postAuth endpoints
    if (request.url.path.contains('api/oauth') || request.url.path.contains('api/postAuth')) {
      return request;
    }

    // Get tokens from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? nextToken = prefs.getString('nextToken');

    // Generate keys
    final String idempotencyKey = _generateKey();
    final String encryptedKey = _crypt(idempotencyKey);

    // Add headers to the request
    if (request is http.Request) {
      request.headers['idempotencykey'] = idempotencyKey;
      request.headers['key'] = encryptedKey;
      
      if (token != null && token.isNotEmpty) {
        request.headers['token'] = token;
      }
      if (nextToken != null && nextToken.isNotEmpty) {
        request.headers['nextToken'] = nextToken;
      }

      print('🔧 Interceptor - Added headers to: ${request.url}');
      print('🔧 Interceptor - IdempotencyKey: $idempotencyKey');
      print('🔧 Interceptor - Encrypted Key: $encryptedKey');
    }

    return request;
  }

  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    // You can handle response interception here if needed
    // For example, update tokens from response headers
    if (response is http.Response && response.statusCode == 200) {
      try {
        final responseBody = json.decode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Update tokens if present in response
        if (responseBody['nextToken'] != null) {
          await prefs.setString('nextToken', responseBody['nextToken'].toString());
        }
        if (responseBody['token'] != null) {
          await prefs.setString('token', responseBody['token'].toString());
        }
        
        print('🔧 Interceptor - Updated tokens from response');
      } catch (e) {
        print('🔧 Interceptor - Error parsing response: $e');
      }
    }
    
    return response;
  }

  @override
  Future<bool> shouldInterceptRequest() async {
    // Intercept all requests except oauth and postAuth
    return true;
  }

  @override
  Future<bool> shouldInterceptResponse() async {
    // Intercept all responses
    return true;
  }

  // Key generation methods
  String _generateString(int length) {
    const characters = "abcdefghijklmnopqrstuvwxyz0123456789";
    String result = "";
    final random = Random();
    
    for (int i = 0; i < length; i++) {
      result += characters[random.nextInt(characters.length)];
    }
    return result;
  }

  String _generateKey() {
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

  String _crypt(String key) {
    String passphrase = "RCq8@aSvhMn47s";
    String data = key + passphrase;
    var bytes = utf8.encode(data);
    var digest = sha512.convert(bytes);
    return digest.toString();
  }
}