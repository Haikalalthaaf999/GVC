// lib/pages/admin_film_list_page.dart

import 'package:flutter/material.dart';

class AdminFilmListPage extends StatelessWidget {
  const AdminFilmListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Kelola Daftar Film'),
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Halaman ini akan menampilkan daftar film untuk di-edit/hapus.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}
