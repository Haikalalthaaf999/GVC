import 'dart:convert';

// Fungsi untuk parsing dari JSON ke model
List<JadwalDatum> listJadwalFromJson(String str) =>
    List<JadwalDatum>.from(json.decode(str)["data"].map((x) => JadwalDatum.fromJson(x)));

// Fungsi untuk konversi balik ke JSON
String listJadwalToJson(List<JadwalDatum> data) =>
    json.encode({"data": List<dynamic>.from(data.map((x) => x.toJson()))});

class JadwalDatum {
  int id;
  int filmId;
  String jam;
  String tempat;
  DateTime createdAt;
  DateTime updatedAt;

  JadwalDatum({
    required this.id,
    required this.filmId,
    required this.jam,
    required this.tempat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JadwalDatum.fromJson(Map<String, dynamic> json) => JadwalDatum(
        id: json['id'],
        filmId: json['film_id'],
        jam: json['jam'],
        tempat: json['tempat'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "film_id": filmId,
        "jam": jam,
        "tempat": tempat,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
