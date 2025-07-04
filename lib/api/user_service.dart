import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'https://appbioskop.mobileprojp.com/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: <String, String>{
        'Content-Type':
            'application/json; charset=UTF-8', // Penting: Memberi tahu server formatnya JSON
      },
      body: jsonEncode(<String, String>{
        // Mengubah data menjadi string JSON
        'email': email,
        'password': password,
      }),
    );

    // Tetap tangani potensi non-JSON response di sini jika ada error HTTP
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Sukses (2xx)
      return json.decode(response.body);
    } else {
      // Jika status code bukan 2xx, kemungkinan ada error dari server.
      // Coba decode body-nya, siapa tahu server mengirim pesan error dalam JSON.
      try {
        return json.decode(response.body);
      } catch (e) {
        // Jika gagal decode, berarti respons bukan JSON (kemungkinan HTML error atau data tidak valid)
        throw Exception(
          'Failed to load login data or server returned non-JSON error: ${response.statusCode} ${response.body}',
        );
      }
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: <String, String>{
        'Content-Type':
            'application/json; charset=UTF-8', // Penting: Memberitahu server formatnya JSON
      },
      body: jsonEncode(<String, String>{
        // Mengubah data menjadi string JSON
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    // Sama seperti di login, tangani respons sesuai status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Sukses (2xx)
      return json.decode(response.body);
    } else {
      try {
        return json.decode(response.body);
      } catch (e) {
        // Jika gagal decode, berarti respons bukan JSON (kemungkinan HTML error atau data tidak valid)
        throw Exception(
          'Failed to load registration data or server returned non-JSON error: ${response.statusCode} ${response.body}',
        );
      }
    }
  }
}
