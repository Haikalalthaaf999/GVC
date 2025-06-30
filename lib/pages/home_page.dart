// lib/pages/home_page.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/auth/login.dart';
import 'package:vgc/pages/detail_pages.dart';
import 'package:vgc/pages/tambah_film.dart';
import 'package:vgc/pages/tiket.dart';

import '/api/film_service.dart';
import '/models/model_film.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Datum> films = []; // <-- Tetap digunakan untuk Grid Film
  bool _isLoading = true;

  // ===================================================================
  // 1. DATA DUMMY DITEMPATKAN DI SINI
  // ===================================================================
  final List<Map<String, dynamic>> movieImages = [
    {
      'title': 'Inside Out 2',
      'imageUrl':
          'https://i.pinimg.com/736x/12/5b/8d/125b8d97e03823163e879432d07ad395.jpg',
    },
    {
      'title': 'Spider-Man: No Way Home',
      'imageUrl':
          'https://i.pinimg.com/736x/10/3f/e9/103fe93ccaba46975b8f6ab9fad2cbd5.jpg',
    },
    {
      'title': 'Doctor Strange Multiverse of Madness',
      'imageUrl':
          'https://i.pinimg.com/736x/68/6e/f1/686ef19247330b0530f17b65f1e7541f.jpg',
    },
    {
      'title': 'Sonic the Hedgehog 2',
      'imageUrl':
          'https://i.pinimg.com/736x/c3/ea/27/c3ea276736f2424ad341f5bef3349bb4.jpg',
    },
    {
      'title': '24H Limit',
      'imageUrl':
          'https://i.pinimg.com/736x/28/8b/b2/288bb226c16be6d37ad95576ab95bafc.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadFilms() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    final result = await FilmService().getAllFilms();
    if (mounted) {
      setState(() {
        films = result ?? [];
        _isLoading = false;
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nama');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // ===================================================================
  // 2. WIDGET CAROUSEL DIUBAH UNTUK MENGGUNAKAN DATA DUMMY
  // ===================================================================
  Widget _buildCarouselSlider() {
    return CarouselSlider(
      items: movieImages.map((movie) {
        // Setiap item sekarang hanya menampilkan gambar dari data dummy
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 2 / 2,
            child: Image.network(
              movie['imageUrl'],
              fit: BoxFit.cover,
              // Menambahkan loading & error builder untuk gambar dari internet
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.broken_image, color: Colors.white24),
                );
              },
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 250,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        viewportFraction: 0.40,
        enableInfiniteScroll: true,
      ),
    );
  }

  // Widget ini tidak diubah dan tetap menggunakan data dari API
  Widget _buildFilmGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: films.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final film = films[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FilmDetailPage(film: film)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: film.imageUrl.isNotEmpty
                      ? Image.network(
                          film.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade800,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white38,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade800,
                          child: const Center(
                            child: Icon(
                              Icons.movie_creation_outlined,
                              color: Colors.white38,
                              size: 40,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                film.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget ini tidak diubah
  Widget _buildFilmPageBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (films.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gagal memuat film atau tidak ada film tersedia.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loadFilms,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFilms,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Segera Tayang',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildCarouselSlider(),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Sedang Tayang',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFilmGrid(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget build utama tidak diubah
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildFilmPageBody(),
      const TiketListPage(),
      const Center(
        child: Text('Halaman Akun', style: TextStyle(color: Colors.white)),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.red[900],
        title: Text(
          _selectedIndex == 0
              ? "VGC Cinema"
              : _selectedIndex == 1
              ? "Tiket Saya"
              : "Akun Saya",
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.red[800],
              onPressed: () =>
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TambahFilmPage()),
                  ).then((isSuccess) {
                    if (isSuccess == true) {
                      _loadFilms();
                    }
                  }),
              tooltip: 'Tambah Film',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Film'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
