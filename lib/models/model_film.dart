// lib/models/model_film.dart

import 'dart:convert';

// Helper function to safely parse the JSON
List<Datum> listFilmFromJson(String str) {
  try {
    final jsonData = json.decode(str);
    if (jsonData['data'] == null || jsonData['data'] is! List) {
      return []; // Return empty list if 'data' is null or not a list
    }
    return List<Datum>.from(jsonData["data"].map((x) => Datum.fromJson(x)));
  } catch (e) {
    print("Error parsing film list: $e");
    return []; // Return empty list on any parsing error
  }
}

class Datum {
  int id;
  String title;
  String description;
  String genre;
  DateTime? createdAt;
  DateTime? updatedAt;
  String image;
  String director;
  String writer;
  String stats;
  String imageUrl;
  List<Schedule> schedules;

  Datum({
    required this.id,
    required this.title,
    required this.description,
    required this.genre,
    this.createdAt,
    this.updatedAt,
    required this.image,
    required this.director,
    required this.writer,
    required this.stats,
    required this.imageUrl,
    required this.schedules,
  });

  factory Datum.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse a date string
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    // Helper to ensure a string is never null
    String safeString(dynamic value) {
      return value?.toString() ?? ''; // If value is null, return empty string
    }

    return Datum(
      id: json["id"] ?? 0, // Default to 0 if id is null
      title: safeString(json["title"]),
      description: safeString(json["description"]),
      genre: safeString(json["genre"]),
      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
      image: safeString(json["image"]),
      director: safeString(json["director"]),
      writer: safeString(json["writer"]),
      stats: safeString(json["stats"]),
      imageUrl: safeString(json["image_url"]),
      schedules: json["schedules"] == null || json["schedules"] is! List
          ? [] // If schedules is null or not a list, provide an empty list
          : List<Schedule>.from(
              json["schedules"].map((x) => Schedule.fromJson(x)),
            ),
    );
  }
}

class Schedule {
  int id;
  String filmId;
  DateTime? startTime;
  DateTime? createdAt;
  DateTime? updatedAt;

  Schedule({
    required this.id,
    required this.filmId,
    this.startTime,
    this.createdAt,
    this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        return null;
      }
    }

    return Schedule(
      id: json["id"] ?? 0,
      filmId: json["film_id"]?.toString() ?? '',
      startTime: parseDate(json["start_time"]),
      createdAt: parseDate(json["created_at"]),
      updatedAt: parseDate(json["updated_at"]),
    );
  }
}
