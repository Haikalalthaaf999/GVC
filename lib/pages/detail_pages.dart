// lib/pages/detail_pages.dart

import 'package:flutter/material.dart';
import 'package:vgc/models/model_film.dart';
import 'package:vgc/pages/jadwalpage.dart';
import 'package:vgc/theme/color.dart'; // PERUBAHAN: Import palet warna

class FilmDetailPage extends StatelessWidget {
  final Datum film;
  const FilmDetailPage({Key? key, required this.film}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 400.0,
              floating: false,
              pinned: true,
              backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
              iconTheme: const IconThemeData(
                color: kPrimaryTextColor,
              ), // PERUBAHAN WARNA
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
                                  color:
                                      kSecondaryBackground, // PERUBAHAN WARNA
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: kAccentColor,
                                      size: 50,
                                    ), // PERUBAHAN WARNA
                                  ),
                                ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: kSecondaryBackground, // PERUBAHAN WARNA
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: kAccentColor,
                                  ),
                                ), // PERUBAHAN WARNA
                              );
                            },
                          )
                        : Container(
                            color: kSecondaryBackground, // PERUBAHAN WARNA
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                color: kAccentColor,
                                size: 50,
                              ), // PERUBAHAN WARNA
                            ),
                          ),
                    // --- Overlay gelap untuk gambar latar belakang ---
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            // PERUBAHAN WARNA: Gradien disesuaikan dengan background baru
                            kPrimaryBackground,
                            Colors.transparent,
                            kPrimaryBackground,
                          ],
                          stops: [0.0, 0.5, 1.0],
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
                                      width: 120,
                                      height: 180,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Container(
                                            width: 120,
                                            height: 180,
                                            color:
                                                kSecondaryBackground, // PERUBAHAN WARNA
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: kAccentColor,
                                            ), // PERUBAHAN WARNA
                                          ),
                                    )
                                  : Container(
                                      width: 120,
                                      height: 180,
                                      color:
                                          kSecondaryBackground, // PERUBAHAN WARNA
                                      child: const Icon(
                                        Icons.movie,
                                        color: kAccentColor,
                                      ), // PERUBAHAN WARNA
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
                                      color:
                                          kPrimaryTextColor, // PERUBAHAN WARNA
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 8.0,
                                          color: Colors.black,
                                          offset: Offset(2, 2),
                                        ),
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
                  labelColor: kPrimaryTextColor, // PERUBAHAN WARNA
                  unselectedLabelColor: kAccentColor, // PERUBAHAN WARNA
                  indicatorColor: kAccentColor, // PERUBAHAN WARNA
                  tabs: const [
                    Tab(text: 'SINOPSIS'),
                    Tab(text: 'JADWAL'),
                  ],
                ),
              ),
              pinned: true,
            ),
            // --- TabBarView (Isi Konten Tab) ---
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  _buildTentangTab(),
                  JadwalTab(filmId: film.id.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Konten untuk Tab "Tentang" (Sinopsis) ---
  Widget _buildTentangTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.movie_filter, 'Genre', film.genre),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.person, 'Sutradara', film.director),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.edit, 'Penulis', film.writer),
          Divider(color: kSecondaryBackground, height: 40), // PERUBAHAN WARNA
          const Text(
            'Sinopsis',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryTextColor, // PERUBAHAN WARNA
            ),
          ),
          const SizedBox(height: 12),
          Text(
            film.description.isNotEmpty
                ? film.description
                : 'Tidak ada sinopsis tersedia untuk film ini.',
            style: const TextStyle(
              fontSize: 16,
              color: kAccentColor, // PERUBAHAN WARNA
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
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
        Icon(icon, color: kAccentColor, size: 20), // PERUBAHAN WARNA
        const SizedBox(width: 15),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            color: kAccentColor, // PERUBAHAN WARNA
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'N/A',
            style: const TextStyle(
              fontSize: 16,
              color: kPrimaryTextColor,
            ), // PERUBAHAN WARNA
            overflow: TextOverflow.ellipsis,
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: kPrimaryBackground, // PERUBAHAN WARNA
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
