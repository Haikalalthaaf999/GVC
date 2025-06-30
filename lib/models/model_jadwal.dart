// lib/models/model_jadwal.dart

import 'dart:convert';
import 'model_film.dart';

List<JadwalDatum> listJadwalFromJson(String str) {
  try {
    final jsonData = json.decode(str);
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
  String studio; // <-- Field ini sudah benar
  DateTime? startTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  Datum? film;

  JadwalDatum({
    required this.id,
    required this.filmId,
    required this.studio,
    this.startTime,
    this.createdAt,
    this.updatedAt,
    this.film,
  });

  factory JadwalDatum.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    String safeString(dynamic value) {
      return value?.toString() ?? '';
    }

    return JadwalDatum(
      id: json["id"] ?? 0,
      filmId: json["film_id"]?.toString() ?? '',
      studio: safeString(
        json["studio"],
      ), // <-- Mencari key 'studio' sudah benar
      startTime: parseDate(json["start_time"]),
      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
      film: json["film"] == null ? null : Datum.fromJson(json["film"]),
    );
  }
}
