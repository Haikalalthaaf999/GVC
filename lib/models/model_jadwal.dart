// lib/models/model_jadwal.dart (FINAL - Studio menjadi Nullable & Disesuaikan)

import 'dart:convert';
import 'package:vgc/models/model_film.dart'; // Pastikan ini diimpor

// Fungsi listJadwalFromJson diubah jika struktur respons API adalah objek { "data": [...] }
List<JadwalDatum> listJadwalFromJson(String str) {
  try {
    final jsonData = json.decode(str);
    // Jika API mengembalikan {'data': [...]}
    if (jsonData['data'] == null || jsonData['data'] is! List) return [];
    return List<JadwalDatum>.from(
      jsonData["data"].map((x) => JadwalDatum.fromJson(x)),
    );
  } catch (e) {
    print("Error parsing jadwal list: $e");
    return [];
  }
}

class JadwalDatum {
  int id;
  String filmId;
  DateTime? startTime;
  String? studio; // !!! PENTING: Studio diubah menjadi nullable (String?) !!!
  DateTime? createdAt;
  DateTime? updatedAt;
  Datum? film; // Film terkait, bisa null

  JadwalDatum({
    required this.id,
    required this.filmId,
    this.startTime,
    this.studio, // !!! PENTING: Hapus 'required' dari konstruktor !!!
    this.createdAt,
    this.updatedAt,
    this.film,
  });

  factory JadwalDatum.fromJson(Map<String, dynamic> json) => JadwalDatum(
    id: json["id"] ?? 0,
    filmId: json["film_id"]?.toString() ?? '',
    startTime: json["start_time"] != null
        ? DateTime.parse(json["start_time"])
        : null,
    studio: json["studio"]
        ?.toString(), // !!! PENTING: Ambil studio jika ada dari API (mungkin null/kosong), biarkan null jika tidak ada !!!
    createdAt: json["created_at"] != null
        ? DateTime.parse(json["created_at"])
        : null,
    updatedAt: json["updated_at"] != null
        ? DateTime.parse(json["updated_at"])
        : null,
    film: json["film"] != null ? Datum.fromJson(json["film"]) : null,
  );

  // Metode toJson() tidak wajib jika objek JadwalDatum tidak dikirim lengkap ke API
  // Map<String, dynamic> toJson() => {
  //     "id": id,
  //     "film_id": filmId,
  //     "start_time": startTime?.toIso8601String(),
  //     "studio": studio,
  //     "created_at": createdAt?.toIso8601String(),
  //     "updated_at": updatedAt?.toIso8601String(),
  //     "film": film?.toJson(),
  // };
}
