import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/model_tiket.dart';

class TiketService {
  final String baseUrl = 'https://appbioskop.mobileprojp.com/api';

  Future<bool> pesanTiket({
    required String token,
    required int jadwalId,
    required String nama,
    required int jumlah,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tiket'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'jadwal_id': jadwalId.toString(),
        'nama': nama,
        'jumlah': jumlah.toString(),
      },
    );
    return response.statusCode == 200;
  }

  Future<List<Tiket>?> getTiketByToken(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/tiket'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final List data = json.decode(res.body)['data'];
      return data.map((e) => Tiket.fromJson(e)).toList();
    }
    return null;
  }

  Future<bool> hapusTiket(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/tiket/$id'));
    return res.statusCode == 200;
  }
  Future<bool> editTiket({
  required String token,
  required int tiketId,
  required int jumlah,
}) async {
  final url = Uri.parse('$baseUrl/tiket/$tiketId');
  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $token',
    },
    body: {
      'jumlah': jumlah.toString(),
    },
  );

  return response.statusCode == 200;
}

}
