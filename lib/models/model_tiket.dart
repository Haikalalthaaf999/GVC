class Tiket {
  int id;
  int userId;
  int jadwalId;
  String nama;
  int jumlah;
  String jam;
  String studio;
  DateTime createdAt;

  Tiket({
    required this.id,
    required this.userId,
    required this.jadwalId,
    required this.nama,
    required this.jumlah,
    required this.jam,
    required this.studio,
    required this.createdAt,
  });

  factory Tiket.fromJson(Map<String, dynamic> json) => Tiket(
        id: json['id'],
        userId: json['user_id'],
        jadwalId: json['jadwal_id'],
        nama: json['nama'],
        jumlah: json['jumlah'],
        jam: json['jadwal']['jam'],
        studio: json['jadwal']['studio'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "jadwal_id": jadwalId,
        "nama": nama,
        "jumlah": jumlah,
        "created_at": createdAt.toIso8601String(),
      };
}
