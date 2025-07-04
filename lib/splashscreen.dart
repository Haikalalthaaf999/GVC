// lib/pages/splash_screen.dart (Versi dengan Animasi Baru yang Dinamis)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/auth/login.dart';
import 'package:vgc/pages/home_page.dart';
import 'package:vgc/theme/color.dart'; // PERBAIKAN: Path import yang benar

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ANIMASI BARU: Kita buat beberapa animasi untuk setiap elemen
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _indicatorFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      // Durasi dipercepat sedikit agar lebih energik
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // ANIMASI BARU: Animasi untuk LOGO (meluncur dari atas)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    // ANIMASI BARU: Animasi untuk TEKS (meluncur dari bawah)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
          ),
        );

    // ANIMASI BARU: Animasi untuk LOADING INDICATOR (hanya fade in)
    _indicatorFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _checkLoginStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Beri waktu lebih untuk animasi
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffDDE6ED), // Menggunakan warna dari tema
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // PERUBAHAN: Bungkus dengan SlideTransition dan FadeTransition
            SlideTransition(
              position: _logoSlideAnimation,
              child: FadeTransition(
                opacity: _logoFadeAnimation,
                child: Image.asset(
                  'assets/images/applogo.png', // Pastikan path logo Anda benar
                  width: 200,
                  height: 200,
                ),
              ),
            ),
            const SizedBox(height: 15),
            // PERUBAHAN: Bungkus dengan SlideTransition dan FadeTransition
            SlideTransition(
              position: _textSlideAnimation,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: const Text(
                  'VGC',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kSecondaryBackground,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // PERUBAHAN: Bungkus dengan FadeTransition
            FadeTransition(
              opacity: _indicatorFadeAnimation,
              child: const CircularProgressIndicator(color: kAccentColor),
            ),
          ],
        ),
      ),
    );
  }
}
