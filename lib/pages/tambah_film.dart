// lib/pages/tambah_film.dart

import 'dart:io';
import 'dart:convert'; // Library penting untuk Base64
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vgc/api/film_service.dart';

class TambahFilmPage extends StatefulWidget {
  const TambahFilmPage({Key? key}) : super(key: key);

  @override
  State<TambahFilmPage> createState() => _TambahFilmPageState();
}

class _TambahFilmPageState extends State<TambahFilmPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _sutradaraController = TextEditingController();
  final TextEditingController _penulisController = TextEditingController();

  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  // FUNGSI INI DIUBAH TOTAL UNTUK MENGGUNAKAN BASE64
  Future<void> _tambahFilm() async {
    // Validasi input
    if (_judulController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _genreController.text.isEmpty ||
        _sutradaraController.text.isEmpty ||
        _penulisController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi.")));
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Baca file gambar sebagai bytes
      final imageBytes = await _imageFile!.readAsBytes();
      // 2. Ubah bytes menjadi string Base64
      final String base64Image = base64Encode(imageBytes);

      // 3. Panggil fungsi service yang baru
      bool isSuccess = await FilmService().tambahFilmDenganBase64(
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        genre: _genreController.text,
        sutradara: _sutradaraController.text,
        penulis: _penulisController.text,
        imageBase64: base64Image,
      );

      if (mounted) {
        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Film berhasil ditambahkan.")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Gagal menambahkan film. Respons server tidak berhasil.",
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Terjadi error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Tambah Film',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[700],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Film',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _deskripsiController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _genreController,
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _sutradaraController,
                  decoration: const InputDecoration(
                    labelText: 'Sutradara',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _penulisController,
                  decoration: const InputDecoration(
                    labelText: 'Penulis',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                _imageFile == null
                    ? const Text("Belum ada gambar dipilih.")
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _tambahFilm,
                  child: Text(
                    _loading ? "Menyimpan..." : "Simpan Film",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
