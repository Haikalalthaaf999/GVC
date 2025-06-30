// lib/models/model_tiket.dart

import 'dart:convert';
import 'model_film.dart'; // Pastikan model film di-import jika ada relasi

// Helper function untuk parsing yang aman
List<Tiket> listTiketFromJson(String str) {
  try {
    final jsonData = json.decode(str);
    if (jsonData['data'] == null || jsonData['data'] is! List) {
      return []; // Kembalikan list kosong jika data null atau bukan list
    }
    return List<Tiket>.from(jsonData["data"].map((x) => Tiket.fromJson(x)));
  } catch (e) {
    print("Error parsing tiket list: $e");
    return []; // Kembalikan list kosong jika ada error parsing
  }
}

class Tiket {
  int id;
  int userId;
  int jadwalId;
  String nama;
  int jumlah;
  String jam;
  String studio;
  DateTime? createdAt;
  Datum? film; // Menambahkan relasi ke film untuk menampilkan detailnya

  Tiket({
    required this.id,
    required this.userId,
    required this.jadwalId,
    required this.nama,
    required this.jumlah,
    required this.jam,
    required this.studio,
    this.createdAt,
    this.film,
  });

  factory Tiket.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic value) => value?.toString() ?? '';
    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Ambil data jadwal dengan aman
    final jadwalData =
        json['schedule']
            as Map<String, dynamic>?; // Mungkin server mengirim 'schedule'

    return Tiket(
      id: safeInt(json['id']),
      userId: safeInt(json['user_id']),
      // ===============================================================
      // PERBAIKAN UTAMA ADA DI SINI
      // ===============================================================
      jadwalId: safeInt(json['schedule_id']), // <-- Membaca 'schedule_id'
      nama: safeString(json['nama']),
      jumlah: safeInt(json['quantity']), // <-- Membaca 'quantity'
      // Membaca jam dan studio dari objek 'schedule' jika ada
      jam: jadwalData != null
          ? safeString(jadwalData['start_time']).split(' ')[1].substring(0, 5)
          : 'N/A',
      studio: jadwalData != null ? safeString(jadwalData['studio']) : 'N/A',

      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),

      // Membaca data film dari objek 'schedule' jika ada
      film: (jadwalData != null && jadwalData['film'] != null)
          ? Datum.fromJson(jadwalData['film'])
          : null,
    );
  }
}
