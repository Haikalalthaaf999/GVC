// lib/pages/home_page.dart (Versi FINAL dengan CurvedNavigationBar)

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/auth/login.dart';
import 'package:vgc/pages/detail_pages.dart';
import 'package:vgc/pages/tambah_film.dart';
import 'package:vgc/pages/tiket.dart';
import 'package:vgc/pages/user.dart'; 
import 'package:vgc/custom/bottom.dart';


import '/api/film_service.dart';
import '/models/model_film.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Datum> films = [];
  List<Datum> _filteredFilms = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.addListener(_filterFilms);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFilms);
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadFilms() async {
    setState(() {
      _isLoading = true;
    });
    final result = await FilmService().getAllFilms();
    if (mounted) {
      setState(() {
        films = result ?? [];
        _filteredFilms = films;
        _isLoading = false;
      });
    }
  }

  void _filterFilms() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFilms = films.where((film) {
        return film.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('nama');
    await prefs.remove('email');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildCarouselSlider() {
    return CarouselSlider(
      items: movieImages.map((movie) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 2 / 2,
            child: Image.network(
              movie['imageUrl'],
              fit: BoxFit.cover,
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

  Widget _buildFilmGrid() {
    if (_filteredFilms.isEmpty && !_isLoading && _searchController.text.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Tidak ada film yang cocok dengan pencarian Anda.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredFilms.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        final film = _filteredFilms[index];
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

  Widget _buildFilmPageBodyWithSearch() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
    }

    if (films.isEmpty && _searchController.text.isEmpty) {
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
      color: Colors.redAccent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: _searchController,
                  cursorColor: Colors.redAccent,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari film...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    // Menyesuaikan urutan pages agar sesuai dengan ikon di CurvedNavigationBar
    // Icons.home (index 0) -> Film
    // Icons.confirmation_number (index 1) -> Tiket
    // Icons.history (index 2) -> Halaman Riwayat
    // Icons.person (index 3) -> Akun
    final List<Widget> pages = [
      _buildFilmPageBodyWithSearch(), // Halaman Film (Home)
      const TiketListPage(),          // Halaman Tiket
      const Center(child: Text('Halaman Riwayat (History)', style: TextStyle(color: Colors.white, fontSize: 20))), // Halaman Riwayat (placeholder)
      const UserPage(),               // Halaman Akun
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
                  : _selectedIndex == 2
                      ? "Riwayat" // Judul untuk halaman Riwayat
                      : "Profil Pengguna", // Judul untuk halaman Akun
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          // Tombol logout hanya muncul di halaman Profil
          if (_selectedIndex == 3) // Profil Pengguna adalah index 3
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              color: Colors.white,
            ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 // FAB hanya muncul di halaman Film (index 0)
          ? FloatingActionButton(
              backgroundColor: Colors.red[800],
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahFilmPage()),
              ).then((isSuccess) {
                if (isSuccess == true) {
                  _loadFilms();
                }
              }),
              tooltip: 'Tambah Film',
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      // --- Mengganti BottomNavigationBar dengan CurvedNavigationBar ---
      bottomNavigationBar: CurvedNavigationBar(
        items: const [
          Icon(Icons.home, size: 24.0, color: Colors.black), // Film (index 0)
          Icon(Icons.confirmation_number, size: 24.0, color: Colors.black), // Tiket (index 1)
          Icon(Icons.history, size: 24.0, color: Colors.black), // Riwayat (index 2)
          Icon(Icons.person, size: 24.0, color: Colors.black), // Akun (index 3)
        ],
        index: _selectedIndex,
        color: const Color(0xffFFF1D5), // Warna latar belakang bar
        buttonBackgroundColor: Colors.white, // Warna latar belakang tombol aktif
        backgroundColor: const Color(0xff0000), // Warna latar belakang Scaffold di bawah CurvedNav
        height: 75.0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}