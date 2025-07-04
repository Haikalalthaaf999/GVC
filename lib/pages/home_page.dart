// lib/pages/home_page.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/auth/login.dart';
import 'package:vgc/pages/detail_pages.dart';
import 'package:vgc/pages/admin/tambah_film.dart';
import 'package:vgc/pages/tiket.dart';
import 'package:vgc/pages/user.dart';
import 'package:vgc/custom/bottom.dart';
import 'package:vgc/helper/prefrence.dart';
import 'package:vgc/theme/color.dart';

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

  String _userName = 'Pengguna';
  String _userEmail = 'user@example.com';
  bool _isAdmin = false;

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
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('nama') ?? 'Pengguna';
      _userEmail = prefs.getString('email') ?? 'email@example.com';
      _isAdmin = prefs.getBool('isAdmin') ?? false;
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
    await PreferenceHelper.clear();
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
                  color: kSecondaryBackground, // PERUBAHAN WARNA
                  child: const Icon(Icons.broken_image, color: kAccentColor),
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
    if (_filteredFilms.isEmpty &&
        !_isLoading &&
        _searchController.text.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Tidak ada film yang cocok dengan pencarian Anda.',
            style: TextStyle(
              color: kAccentColor,
              fontSize: 16,
            ), // PERUBAHAN WARNA
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
                              child: CircularProgressIndicator(
                                color: kAccentColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: kSecondaryBackground, // PERUBAHAN WARNA
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: kAccentColor, // PERUBAHAN WARNA
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: kSecondaryBackground, // PERUBAHAN WARNA
                          child: const Center(
                            child: Icon(
                              Icons.movie_creation_outlined,
                              color: kAccentColor, // PERUBAHAN WARNA
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
                  color: kPrimaryTextColor, // PERUBAHAN WARNA
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
      return const Center(
        child: CircularProgressIndicator(color: kAccentColor),
      );
    }

    if (films.isEmpty && _searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gagal memuat film atau tidak ada film tersedia.',
              style: TextStyle(
                color: kAccentColor,
                fontSize: 16,
              ), // PERUBAHAN WARNA
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loadFilms,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
                foregroundColor: kPrimaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFilms,
      color: kAccentColor, // PERUBAHAN WARNA
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: kSecondaryBackground, // PERUBAHAN WARNA
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  cursorColor: kAccentColor, // PERUBAHAN WARNA
                  style: const TextStyle(
                    color: kPrimaryTextColor,
                  ), // PERUBAHAN WARNA
                  decoration: const InputDecoration(
                    hintText: 'Cari film...',
                    hintStyle: TextStyle(
                      color: kAccentColor,
                    ), // PERUBAHAN WARNA
                    prefixIcon: Icon(
                      Icons.search,
                      color: kAccentColor, // PERUBAHAN WARNA
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
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
                  color: kPrimaryTextColor, // PERUBAHAN WARNA
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
                  color: kPrimaryTextColor, // PERUBAHAN WARNA
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
    final List<Widget> pages = [
      _buildFilmPageBodyWithSearch(),
      const TiketListPage(),
      const Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(
            color: kPrimaryTextColor,
            fontSize: 20,
          ), // PERUBAHAN WARNA
        ),
      ),
      const UserPage(),
    ];

    return Scaffold(
      backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0 && _isAdmin
          ? FloatingActionButton(
              backgroundColor: kAccentColor, // PERUBAHAN WARNA
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
              child: const Icon(
                Icons.add,
                color: kPrimaryBackground,
              ), // PERUBAHAN WARNA
            )
          : null,
      bottomNavigationBar: CurvedNavigationBar(
        items: const [
          Icon(
            Icons.home,
            size: 24.0,
            color: kPrimaryBackground,
          ), // PERUBAHAN WARNA
          Icon(
            Icons.confirmation_number,
            size: 24.0,
            color: kPrimaryBackground,
          ), // PERUBAHAN WARNA
          Icon(
            Icons.history,
            size: 24.0,
            color: kPrimaryBackground,
          ), // PERUBAHAN WARNA
          Icon(
            Icons.person,
            size: 24.0,
            color: kPrimaryBackground,
          ), // PERUBAHAN WARNA
        ],
        index: _selectedIndex,
        color: kSecondaryBackground, // PERUBAHAN WARNA
        buttonBackgroundColor: kAccentColor, // PERUBAHAN WARNA
        backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
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
  