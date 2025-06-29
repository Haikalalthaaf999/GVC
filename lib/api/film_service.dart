import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/models/model_film.dart'; // Ubah sesuai struktur proyekmu

class FilmService {
  final String baseUrl = 'https://appbioskop.mobileprojp.com/api';

  // Ambil semua film
  Future<List<Datum>?> getAllFilms() async {
    final res = await http.get(Uri.parse('$baseUrl/films'));
    if (res.statusCode == 200) {
      final data = filmFromJson(res.body);
      return data.data;
    }
    return null;
  }

  // Tambah film
  Future<bool> tambahFilm(String judul, String deskripsi, String genre, String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/films'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;
    request.fields['genre'] = genre;
    request.files.add(await http.MultipartFile.fromPath('gambar', imagePath));

    final response = await request.send();
    return response.statusCode == 200;
  }

  // Ambil film berdasarkan ID
  Future<Datum?> getFilmById(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/films/$id'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body)['data'];
      return Datum.fromJson(data);
    }
    return null;
  }

  // Edit film
  Future<bool> editFilm(int id, String judul, String deskripsi, String genre, {String? imagePath}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/films/$id?_method=PUT'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;
    request.fields['genre'] = genre;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('gambar', imagePath));
    }

    final response = await request.send();
    return response.statusCode == 200;
  }

  // Hapus film
  Future<bool> hapusFilm(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.delete(
      Uri.parse('$baseUrl/films/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    return response.statusCode == 200;
  }
}
