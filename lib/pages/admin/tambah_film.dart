// lib/pages/tambah_film.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vgc/api/film_service.dart';
import 'package:vgc/theme/color.dart';

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

  Future<void> _tambahFilm() async {
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
      final imageBytes = await _imageFile!.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

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

  InputDecoration _buildInputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kAccentColor), // PERUBAHAN WARNA
      prefixIcon: icon != null
          ? Icon(icon, color: kAccentColor)
          : null, // PERUBAHAN WARNA
      filled: true,
      fillColor: kPrimaryBackground.withOpacity(0.5), // PERUBAHAN WARNA
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: kAccentColor,
          width: 2,
        ), // PERUBAHAN WARNA
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: kAccentColor.withOpacity(0.2),
          width: 1,
        ), // PERUBAHAN WARNA
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
      appBar: AppBar(
        title: const Text(
          'Tambah Film',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kPrimaryTextColor, // PERUBAHAN WARNA
          ),
        ),
        backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
        iconTheme: const IconThemeData(
          color: kPrimaryTextColor,
        ), // PERUBAHAN WARNA
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: kSecondaryBackground, // PERUBAHAN WARNA
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Detail Film Baru',
                    style: TextStyle(
                      color: kPrimaryTextColor, // PERUBAHAN WARNA
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _judulController,
                    style: const TextStyle(
                      color: kPrimaryTextColor,
                    ), // PERUBAHAN WARNA
                    decoration: _buildInputDecoration(
                      'Judul Film',
                      icon: Icons.movie,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deskripsiController,
                    maxLines: 3,
                    style: const TextStyle(
                      color: kPrimaryTextColor,
                    ), // PERUBAHAN WARNA
                    decoration: _buildInputDecoration(
                      'Deskripsi',
                      icon: Icons.description,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _genreController,
                    style: const TextStyle(
                      color: kPrimaryTextColor,
                    ), // PERUBAHAN WARNA
                    decoration: _buildInputDecoration(
                      'Genre',
                      icon: Icons.category,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sutradaraController,
                    style: const TextStyle(
                      color: kPrimaryTextColor,
                    ), // PERUBAHAN WARNA
                    decoration: _buildInputDecoration(
                      'Sutradara',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _penulisController,
                    style: const TextStyle(
                      color: kPrimaryTextColor,
                    ), // PERUBAHAN WARNA
                    decoration: _buildInputDecoration(
                      'Penulis',
                      icon: Icons.create,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _imageFile == null
                      ? Column(
                          children: [
                            const Text(
                              "Belum ada gambar dipilih.",
                              style: TextStyle(
                                color: kAccentColor,
                              ), // PERUBAHAN WARNA
                            ),
                            const SizedBox(height: 10),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(
                        Icons.image,
                        color: kPrimaryTextColor,
                      ), // PERUBAHAN WARNA
                      label: const Text(
                        "Pilih Gambar",
                        style: TextStyle(
                          color: kPrimaryTextColor,
                        ), // PERUBAHAN WARNA
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: kAccentColor,
                        ), // PERUBAHAN WARNA
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _tambahFilm,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: kPrimaryBackground, // PERUBAHAN WARNA
                        backgroundColor: kAccentColor, // PERUBAHAN WARNA
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                kPrimaryBackground, // PERUBAHAN WARNA
                              ),
                            )
                          : const Text(
                              'Simpan Film',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
