import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

const String baseUrl = 'http://10.0.19.112/my-final-exam/backend/api/items.php';

class ApiService {
  static Future<List<Item>> getItems() async {
    try {
      final res = await http.get(Uri.parse(baseUrl));
      print('Response: ${res.body}');
      final List data = jsonDecode(res.body);
      return data.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<void> createItem(String name, String desc) async {
    await http.post(Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'description': desc}));
  }

  static Future<void> updateItem(int id, String name, String desc) async {
    await http.put(Uri.parse('$baseUrl?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'description': desc}));
  }

  static Future<void> deleteItem(int id) async {
    await http.delete(Uri.parse('$baseUrl?id=$id'));
  }
}