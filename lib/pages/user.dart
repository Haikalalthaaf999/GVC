// lib/pages/user.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/auth/login.dart';
import 'package:vgc/helper/prefrence.dart';
import 'package:vgc/pages/admin/home.dart';
import 'package:vgc/theme/color.dart'; // PERUBAHAN: Import palet warna

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _userName = 'Pengguna';
  String _userEmail = 'user@example.com';
  final String _userPhone = '+62 123456789'; // Contoh nomor telepon
  bool _isAdmin = false; // Tambahkan variabel untuk status admin

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('nama') ?? 'Pengguna Tidak Dikenal';
      _userEmail = prefs.getString('email') ?? 'email@example.com';
      _isAdmin = prefs.getBool('isAdmin') ?? false; // Muat status admin
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

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Fitur ini akan segera hadir!',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xffE14434), // PERUBAHAN WARNA
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            color: kSecondaryBackground.withOpacity(0.5), // PERUBAHAN WARNA
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kPrimaryBackground, // PERUBAHAN WARNA
                      border: Border.all(
                        color: kAccentColor,
                        width: 3,
                      ), // PERUBAHAN WARNA
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 60,
                      color: kAccentColor, // PERUBAHAN WARNA
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryTextColor, // PERUBAHAN WARNA
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _userEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      color: kAccentColor, // PERUBAHAN WARNA
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: kPrimaryBackground.withOpacity(
                      0.5,
                    ), // PERUBAHAN WARNA
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet, // Ganti ikon
                                color: kAccentColor, // PERUBAHAN WARNA
                                size: 25,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rp 0', // Placeholder untuk saldo
                                    style: TextStyle(
                                      color:
                                          kPrimaryTextColor, // PERUBAHAN WARNA
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _userPhone,
                                    style: const TextStyle(
                                      color: kAccentColor, // PERUBAHAN WARNA
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _showComingSoonSnackBar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAccentColor, // PERUBAHAN WARNA
                              foregroundColor:
                                  kPrimaryBackground, // PERUBAHAN WARNA
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Top Up',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Opsi Menu Lainnya
                  _buildProfileOption(
                    icon: Icons.admin_panel_settings,

                    iconColor: kAccentColor, // PERUBAHAN WARNA
                    label: 'Admin Dashboard',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminHomePage(),
                        ),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.vpn_key,
                    label: 'Ubah Password',
                    onTap: _showComingSoonSnackBar,
                  ),
                  _buildProfileOption(
                    icon: Icons.receipt_long,
                    label: 'Voucher Saya',
                    onTap: _showComingSoonSnackBar,
                  ),
                  _buildProfileOption(
                    icon: Icons.help_outline,
                    label: 'Pusat Bantuan',
                    onTap: _showComingSoonSnackBar,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(
                        Icons.logout,
                        color: kPrimaryTextColor, // PERUBAHAN WARNA
                        size: 24,
                      ),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          color: kPrimaryTextColor, // PERUBAHAN WARNA
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(
                          0xffC5172E,
                        ), // Tetap merah untuk aksi logout
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = kAccentColor, // PERUBAHAN WARNA
    Color labelColor = kPrimaryTextColor, // PERUBAHAN WARNA
    bool isVisible = true,
  }) {
    if (!isVisible) return const SizedBox.shrink();
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor, size: 24),
          title: Text(label, style: TextStyle(color: labelColor, fontSize: 16)),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: kAccentColor, // PERUBAHAN WARNA
            size: 18,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
        ),
        Divider(
          color: kPrimaryBackground.withOpacity(0.5),
          height: 1,
        ), // PERUBAHAN WARNA
      ],
    );
  }
}
