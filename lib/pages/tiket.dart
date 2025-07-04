// lib/pages/tiket.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/helper/prefrence.dart'; // Import PreferenceHelper
import 'package:vgc/theme/color.dart'; // PERBAIKAN: Path import yang benar

import '/models/model_tiket.dart';
import '../api/tiket_service.dart';
import 'edit_tiket.dart';

class TiketListPage extends StatefulWidget {
  const TiketListPage({super.key});

  @override
  State<TiketListPage> createState() => _TiketListPageState();
}

class _TiketListPageState extends State<TiketListPage> {
  List<Tiket> tiketList = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTiket();
  }

  // PERUBAHAN UTAMA DI FUNGSI INI
  Future<void> _loadTiket() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) {
        throw Exception("Token tidak ditemukan, silakan login kembali.");
      }

      // Langkah 1: Ambil data tiket dari server (mungkin belum lengkap)
      final resultFromServer = await TiketService().getTiketByToken(token);

      if (mounted) {
        if (resultFromServer != null) {
          // Ambil nama pengguna dari SharedPreferences
          final String userName = prefs.getString('nama') ?? 'Anda';

          // Langkah 2: Lengkapi setiap tiket dengan data lokal (Studio)
          for (var tiket in resultFromServer) {
            // Mengisi nama tiket dengan nama pengguna yang login
            tiket.nama = userName;

            // Mengambil nama studio dari SharedPreferences berdasarkan jadwalId
            final String? studioName =
                await PreferenceHelper.getStudioForJadwal(
                  tiket.jadwalId.toString(),
                );
            if (studioName != null) {
              tiket.studio = studioName;
            } else {
              tiket.studio ??= 'N/A (Lokal)'; // Jika tidak ada, gunakan default
            }
          }
        }

        // Langkah 3: Tampilkan data yang sudah lengkap
        setState(() {
          tiketList = resultFromServer ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memuat tiket. Silakan coba lagi.";
          _loading = false;
        });
      }
    }
  }

  Future<void> _hapusTiket(int tiketId) async {
    bool? hapus = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kSecondaryBackground,
          title: const Text(
            'Konfirmasi',
            style: TextStyle(color: kPrimaryTextColor),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus tiket ini?',
            style: TextStyle(color: kAccentColor),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: kAccentColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (hapus == true) {
      final success = await TiketService().hapusTiket(tiketId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tiket berhasil dihapus')),
          );
          _loadTiket();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus tiket')),
          );
        }
      }
    }
  }

  Future<void> _editTiket(Tiket tiket) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTiketPage(tiket: tiket)),
    );
    if (result == true) {
      _loadTiket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: kPrimaryBackground, body: _buildBody());
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: kAccentColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: kAccentColor)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadTiket,
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryBackground,
                foregroundColor: kPrimaryTextColor,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (tiketList.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadTiket,
        backgroundColor: kSecondaryBackground,
        color: kPrimaryTextColor,
        child: Stack(
          children: [
            ListView(), // Child dibutuhkan oleh RefreshIndicator
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.theaters, color: kSecondaryBackground, size: 80),
                  SizedBox(height: 16),
                  Text(
                    'Anda belum memiliki tiket',
                    style: TextStyle(color: kAccentColor, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTiket,
      backgroundColor: kSecondaryBackground,
      color: kPrimaryTextColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: tiketList.length,
        itemBuilder: (context, index) {
          final tiket = tiketList[index];
          final tanggalBeli = tiket.createdAt != null
              ? DateFormat(
                  'EEEE, d MMMM yyyy',
                  'id_ID',
                ).format(tiket.createdAt!)
              : 'N/A';

          return Card(
            color: kSecondaryBackground,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: kAccentColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: kPrimaryBackground.withOpacity(0.5),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          color: kPrimaryTextColor,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      title: Text(
                        'Atas Nama: ${tiket.nama}', // Nama sekarang akan muncul
                        style: const TextStyle(
                          color: kPrimaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Studio: ${tiket.studio}\nJam: ${tiket.jam}\nJumlah: ${tiket.jumlah} Tiket\nDibeli pada: $tanggalBeli', // Studio sekarang akan muncul
                          style: const TextStyle(
                            color: kAccentColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            child: const Icon(
                              Icons.edit,
                              color: kAccentColor,
                              size: 20,
                            ),
                            onTap: () => _editTiket(tiket),
                          ),
                          InkWell(
                            child: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            onTap: () => _hapusTiket(tiket.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
