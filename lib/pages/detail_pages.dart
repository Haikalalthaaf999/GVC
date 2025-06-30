// lib/pages/detail_pages.dart

import 'package:flutter/material.dart';
import 'package:vgc/models/model_film.dart';
import 'package:vgc/pages/jadwalpage.dart';

class FilmDetailPage extends StatelessWidget {
  final Datum film;
  const FilmDetailPage({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.red.shade900,
          title: Text(film.title, style: const TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tentang'),
              Tab(text: 'Jadwal'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTentangTab(),
            JadwalTab(filmId: film.id.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildTentangTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: film.imageUrl.isNotEmpty
                ? Image.network(
                    film.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white38,
                          size: 50,
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 250,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  )
                : Container(
                    height: 250,
                    color: Colors.grey.shade800,
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white38,
                        size: 50,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            film.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.movie_filter, 'Genre', film.genre),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.person, 'Sutradara', film.director),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.edit, 'Penulis', film.writer),
          const Divider(color: Colors.white24, height: 32),
          const Text(
            'Sinopsis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            film.description.isNotEmpty
                ? film.description
                : 'Tidak ada sinopsis tersedia.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'N/A',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
