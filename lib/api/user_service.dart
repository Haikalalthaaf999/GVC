import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'https://appbioskop.mobileprojp.com/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'email': email, 'password': password},
    );

    final data = json.decode(response.body);
    return data;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'name': name, 'email': email, 'password': password},
    );
    return json.decode(response.body);
  }
}
