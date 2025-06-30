// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. IMPORT LIBRARY INI
import 'auth/login.dart';
import 'pages/home_page.dart';
import 'splashscreen.dart';

void main() {
  // 2. PANGGIL FUNGSI INISIALISASI DI SINI SEBELUM MENJALANKAN APLIKASI
  // Ini akan memuat data lokalisasi untuk bahasa Indonesia ('id_ID')
  initializeDateFormatting('id_ID', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Seluruh kode UI Anda di sini tidak perlu diubah sama sekali
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Bioskop',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.red.shade900,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
