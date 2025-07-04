// lib/pages/admin_select_film_page.dart

import 'package:flutter/material.dart';
import 'package:vgc/api/film_service.dart';
import 'package:vgc/models/model_film.dart';
import 'package:vgc/pages/admin/tambah_jadwal_page.dart';
import 'package:vgc/theme/color.dart'; // PERUBAHAN: Import palet warna

class AdminSelectFilmPage extends StatefulWidget {
  const AdminSelectFilmPage({super.key});

  @override
  State<AdminSelectFilmPage> createState() => _AdminSelectFilmPageState();
}

class _AdminSelectFilmPageState extends State<AdminSelectFilmPage> {
  List<Datum> _films = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  Future<void> _loadFilms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await FilmService().getAllFilms();
      setState(() {
        _films = result ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat daftar film: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
      appBar: AppBar(
        title: const Text(
          'Pilih Film untuk Jadwal',
          style: TextStyle(color: kPrimaryTextColor), // PERUBAHAN WARNA
        ),
        backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
        iconTheme: const IconThemeData(
          color: kPrimaryTextColor,
        ), // PERUBAHAN WARNA
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kAccentColor),
            ) // PERUBAHAN WARNA
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: kAccentColor,
                    ), // PERUBAHAN WARNA
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadFilms,
                    child: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
                      foregroundColor: kPrimaryTextColor,
                    ),
                  ),
                ],
              ),
            )
          : _films.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada film yang tersedia untuk ditambahkan jadwal.',
                style: TextStyle(
                  color: kAccentColor,
                  fontSize: 16,
                ), // PERUBAHAN WARNA
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: _films.length,
              itemBuilder: (context, index) {
                final film = _films[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TambahJadwalPage(filmId: film.id.toString()),
                      ),
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    color: kSecondaryBackground, // PERUBAHAN WARNA
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: film.imageUrl.isNotEmpty
                              ? Image.network(
                                  film.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color:
                                            kPrimaryBackground, // PERUBAHAN WARNA
                                        child: const Icon(
                                          Icons.broken_image,
                                          color:
                                              kAccentColor, // PERUBAHAN WARNA
                                          size: 40,
                                        ),
                                      ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color:
                                                kAccentColor, // PERUBAHAN WARNA
                                          ),
                                        );
                                      },
                                )
                              : Container(
                                  color: kPrimaryBackground, // PERUBAHAN WARNA
                                  child: const Center(
                                    child: Icon(
                                      Icons.movie,
                                      color: kAccentColor, // PERUBAHAN WARNA
                                      size: 40,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            film.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kPrimaryTextColor, // PERUBAHAN WARNA
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            film.genre,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: kAccentColor, // PERUBAHAN WARNA
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
