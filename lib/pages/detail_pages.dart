// FILE: film_detail_page.dart
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
          bottom: const TabBar(
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
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              film.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            film.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            film.description,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
