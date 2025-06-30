// lib/pages/tiket.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/tiket_service.dart';
import '/models/model_tiket.dart';
import 'edit_tiket.dart';

class TiketListPage extends StatefulWidget {
  const TiketListPage({Key? key}) : super(key: key);

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
      final result = await TiketService().getTiketByToken(token);
      if (mounted) {
        setState(() {
          tiketList = result ?? [];
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
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            'Konfirmasi',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus tiket ini?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
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
    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar tidak diperlukan jika halaman ini diakses dari HomePage
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadTiket,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (tiketList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.theaters, color: Colors.white24, size: 80),
            SizedBox(height: 16),
            Text(
              'Anda belum memiliki tiket',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTiket,
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
            color: Colors.grey.shade900,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.red.shade900.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Bagian kiri dengan ikon tiket
                  Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withOpacity(0.8),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                  // Bagian kanan dengan detail tiket
                  Expanded(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      title: Text(
                        'Atas Nama: ${tiket.nama}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Studio: ${tiket.studio}\nJam: ${tiket.jam}\nJumlah: ${tiket.jumlah} Tiket\nDibeli pada: $tanggalBeli',
                          style: const TextStyle(
                            color: Colors.white70,
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
                              color: Colors.amber,
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
