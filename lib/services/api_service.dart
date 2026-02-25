import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  static Future<List<dynamic>> fetchProducts({String? collection}) async {
    String url = "$baseUrl/products";

    if (collection != null) {
      url += "?collection=$collection";
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load products");
    }
  }

  static Future<Map<String, dynamic>> fetchProduct(String slug) async {
    final response =
        await http.get(Uri.parse("$baseUrl/products/$slug"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Product not found");
    }
  }
}