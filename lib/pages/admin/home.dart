// lib/pages/admin_home_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/auth/login.dart';
import 'package:vgc/helper/prefrence.dart';
import 'package:vgc/pages/admin/admin_select_film_page.dart';
import 'package:vgc/pages/admin/tambah_film.dart';
import 'package:vgc/theme/color.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminName = prefs.getString('nama') ?? 'Administrator';
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

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $feature akan segera hadir!'),
        duration: Duration(seconds: 2),
        backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
      appBar: AppBar(
        title: Text(
          'Dashboard Admin ($_adminName)',
          style: const TextStyle(color: kPrimaryTextColor),
        ), // PERUBAHAN WARNA
        backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
        iconTheme: const IconThemeData(
          color: kPrimaryTextColor,
        ), // PERUBAHAN WARNA
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 100,
                color: kAccentColor, // PERUBAHAN WARNA
              ),
              const SizedBox(height: 15),
              Text(
                'Selamat datang, $_adminName!',
                style: const TextStyle(
                  color: kPrimaryTextColor, // PERUBAHAN WARNA
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih opsi manajemen di bawah:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kAccentColor,
                  fontSize: 14,
                ), // PERUBAHAN WARNA
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: kSecondaryBackground, // PERUBAHAN WARNA
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildAdminOption(
                        icon: Icons.movie_filter,
                        label: 'Tambah Film Baru',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TambahFilmPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        color: kPrimaryBackground,
                        height: 1,
                      ), // PERUBAHAN WARNA
                      _buildAdminOption(
                        icon: Icons.calendar_month,
                        label: 'Tambah Jadwal Film',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminSelectFilmPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        color: kPrimaryBackground,
                        height: 1,
                      ), // PERUBAHAN WARNA
                      _buildAdminOption(
                        icon: Icons.edit_note,
                        label: 'Kelola Daftar Film',
                        onTap: () {
                          _showComingSoonSnackBar("Kelola Daftar Film");
                        },
                      ),
                      const Divider(
                        color: kPrimaryBackground,
                        height: 1,
                      ), // PERUBAHAN WARNA
                      _buildAdminOption(
                        icon: Icons.approval,
                        label: 'Persetujuan Edit Tiket',
                        onTap: () {
                          _showComingSoonSnackBar(
                            "Persetujuan Edit Tiket (membutuhkan API backend)",
                          );
                        },
                        iconColor: kAccentColor, // PERUBAHAN WARNA
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = kAccentColor, // PERUBAHAN WARNA
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(
        label,
        style: const TextStyle(
          color: kPrimaryTextColor,
          fontSize: 18,
        ), // PERUBAHAN WARNA
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: kAccentColor, // PERUBAHAN WARNA
        size: 20,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
  }
}
