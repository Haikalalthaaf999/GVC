import 'dart:convert';

Film filmFromJson(String str) => Film.fromJson(json.decode(str));

class Film {
  List<Datum> data;

  Film({required this.data});

  factory Film.fromJson(Map<String, dynamic> json) => Film(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );
}

class Datum {
  int id;
  String title;
  String description;
  String image;
  DateTime createdAt;
  DateTime updatedAt;

  Datum({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        image: json["image"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "image": image,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
