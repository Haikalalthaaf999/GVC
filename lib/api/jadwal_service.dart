import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/model_jadwal.dart';

class JadwalService {
  final String baseUrl = 'https://appbioskop.mobileprojp.com/api';

  // GET - Ambil semua jadwal untuk film tertentu
  Future<List<JadwalDatum>> getJadwalByFilmId(int filmId) async {
    final url = Uri.parse('$baseUrl/films/jadwal/$filmId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return listJadwalFromJson(response.body);
    } else {
      throw Exception('Gagal mengambil jadwal film');
    }
  }

  // POST - Tambah jadwal baru
  Future<bool> tambahJadwal({
    required int filmId,
    required String jam,
    required String tempat,
  }) async {
    final url = Uri.parse('$baseUrl/jadwal');
    final response = await http.post(
      url,
      body: {
        'film_id': filmId.toString(),
        'jam': jam,
        'tempat': tempat,
      },
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // DELETE - Hapus jadwal
  Future<bool> hapusJadwal(int jadwalId) async {
    final url = Uri.parse('$baseUrl/jadwal/$jadwalId');
    final response = await http.delete(url);

    return response.statusCode == 200;
  }

  // PUT/POST - Update jadwal (kalau API tersedia)
  Future<bool> updateJadwal({
    required int id,
    required String jam,
    required String tempat,
  }) async {
    final url = Uri.parse('$baseUrl/jadwal/$id');
    final response = await http.put(
      url,
      body: {
        'jam': jam,
        'tempat': tempat,
      },
    );

    return response.statusCode == 200;
  }
}
