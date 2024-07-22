import 'package:http/http.dart' as http;

class HttpUtils {
  static Future<http.Response> post(String path, {required Map<String, dynamic> body}) async {
    final String url = "http://localhost:3230/trips";
    return await http.post(Uri.parse(url), body: body);
  }
}