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
        backgroundColor: const Color(0xFF0F121C), // Background gelap konsisten
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 400.0, // Tinggi AppBar saat diperluas
              floating: false,
              pinned: true, // AppBar tetap terlihat saat scroll
              backgroundColor: const Color(0xFF0F121C), // Warna AppBar saat menyusut
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // --- Gambar Poster Besar sebagai Latar Belakang ---
                    film.imageUrl.isNotEmpty
                        ? Image.network(
                            film.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.white38, size: 50),
                              ),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade800,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white)),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: Icon(Icons.movie,
                                  color: Colors.white38, size: 50),
                            ),
                          ),
                    // --- Overlay gelap untuk gambar latar belakang ---
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                            const Color(0xFF0F121C).withOpacity(0.9), // Match body background
                            const Color(0xFF0F121C),
                          ],
                          stops: const [0.0, 0.4, 0.8, 1.0],
                        ),
                      ),
                    ),
                    // --- Detail Film di Atas Poster Latar Belakang ---
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Poster Kecil
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: film.imageUrl.isNotEmpty
                                  ? Image.network(
                                      film.imageUrl,
                                      width: 120, // Ukuran poster kecil
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(
                                        width: 120,
                                        height: 180,
                                        color: Colors.grey.shade700,
                                        child: const Icon(Icons.broken_image,
                                            color: Colors.white38),
                                      ),
                                    )
                                  : Container(
                                      width: 120,
                                      height: 180,
                                      color: Colors.grey.shade700,
                                      child: const Icon(Icons.movie,
                                          color: Colors.white38),
                                    ),
                            ),
                            const SizedBox(width: 20),
                            // Judul Film dan Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    film.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                            blurRadius: 8.0,
                                            color: Colors.black,
                                            offset: Offset(2, 2))
                                      ],
                                    ),
                                  ),
                                
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // --- TabBar di bawah Header ---
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: Colors.redAccent, // Warna indikator yang menonjol
                  tabs: const [
                    Tab(text: 'SINOPSIS'),
                    Tab(text: 'JADWAL'),
                  ],
                ),
              ),
              pinned: true, // Agar TabBar tetap di atas saat scroll
            ),
            // --- TabBarView (Isi Konten Tab) ---
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  _buildTentangTab(), // Konten untuk tab "Tentang"
                  JadwalTab(filmId: film.id.toString()), // Konten untuk tab "Jadwal"
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget untuk menampilkan rating bintang ---
  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.yellow, size: 20));
      } else if (hasHalfStar && i == fullStars) {
        stars.add(const Icon(Icons.star_half, color: Colors.yellow, size: 20));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.grey, size: 20));
      }
    }
    return Row(children: stars);
  }

  // --- Konten untuk Tab "Tentang" (Sinopsis) ---
  Widget _buildTentangTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20), // Padding yang lebih konsisten
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Tambahan (Genre, Sutradara, Penulis)
          _buildInfoRow(Icons.movie_filter, 'Genre', film.genre),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.person, 'Sutradara', film.director),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.edit, 'Penulis', film.writer),
          const Divider(color: Colors.white24, height: 40), // Divider lebih tebal
          const Text(
            'Sinopsis',
            style: TextStyle(
              fontSize: 22, // Ukuran judul sinopsis lebih besar
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            film.description.isNotEmpty
                ? film.description
                : 'Tidak ada sinopsis tersedia untuk film ini.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.6, // Jarak antar baris lebih longgar
            ),
            textAlign: TextAlign.justify, // Teks sinopsis rata kanan-kiri
          ),
        ],
      ),
    );
  }

  // --- Widget pembantu untuk baris info (Genre, Sutradara, Penulis) ---
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 15), // Jarak ikon ke teks
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
            overflow: TextOverflow.ellipsis, // Tangani teks panjang
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

// --- Delegate kustom untuk TabBar agar bisa di-pin di SliverAppBar ---
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0F121C), // Background TabBar, sesuaikan dengan body Scaffold
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false; // Karena TabBar tidak berubah
  }
}