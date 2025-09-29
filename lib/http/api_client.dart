import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';
 import 'package:spw/http/api_key_interceptor.dart';

class ApiClient {
  static final InterceptedClient client = InterceptedClient.build(
    interceptors: [ApiInterceptor()],
    requestTimeout: const Duration(seconds: 30),
  );

  // Helper methods for common HTTP operations
  static Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final mergedHeaders = {...?headers};
    return client.get(Uri.parse(url), headers: mergedHeaders);
  }

  static Future<http.Response> post(String url, {Map<String, String>? headers, Object? body}) async {
    final mergedHeaders = {...?headers};
    return client.post(Uri.parse(url), headers: mergedHeaders, body: body);
  }

  static Future<http.Response> put(String url, {Map<String, String>? headers, Object? body}) async {
    final mergedHeaders = {...?headers};
    return client.put(Uri.parse(url), headers: mergedHeaders, body: body);
  }

  static Future<http.Response> delete(String url, {Map<String, String>? headers}) async {
    final mergedHeaders = {...?headers};
    return client.delete(Uri.parse(url), headers: mergedHeaders);
  }

  // Method to make direct calls without interceptor (for oauth/postAuth)
  static Future<http.Response> directPost(String url, {Map<String, String>? headers, Object? body}) async {
    final mergedHeaders = {...?headers};
    return http.post(Uri.parse(url), headers: mergedHeaders, body: body);
  }
}