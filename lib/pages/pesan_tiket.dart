// lib/pages/pesan_tiket.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/tiket_service.dart';
import '../models/model_jadwal.dart';

class PesanTiketPage extends StatefulWidget {
  final JadwalDatum jadwal;

  const PesanTiketPage({Key? key, required this.jadwal}) : super(key: key);

  @override
  State<PesanTiketPage> createState() => _PesanTiketPageState();
}

class _PesanTiketPageState extends State<PesanTiketPage> {
  int _jumlahTiket = 1;
  bool _loading = false;
  String _nama = 'Guest';

  @override
  void initState() {
    super.initState();
    _loadNama();
  }

  Future<void> _loadNama() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? 'Guest';
    });
  }

  Future<void> _pesanTiket() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final success = await TiketService().pesanTiket(
      nama: _nama,
      token: token,
      jadwalId: widget.jadwal.id,
      jumlah: _jumlahTiket,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (success) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pemesanan Berhasil'),
          content: const Text('Tiket Anda telah berhasil dipesan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memesan tiket')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filmTitle = widget.jadwal.film?.title ?? 'Judul Film';
    final filmImageUrl = widget.jadwal.film?.imageUrl ?? '';
    final tanggal = widget.jadwal.startTime != null
        ? DateFormat(
            'EEEE, d MMMM yyyy',
            'id_ID',
          ).format(widget.jadwal.startTime!)
        : 'N/A';
    final jam = widget.jadwal.startTime != null
        ? DateFormat('HH:mm').format(widget.jadwal.startTime!)
        : 'N/A';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Pesan Tiket ($_nama)'),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.grey.shade900,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 150,
                    child: filmImageUrl.isNotEmpty
                        ? Image.network(filmImageUrl, fit: BoxFit.cover)
                        : Container(
                            color: Colors.black54,
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white24,
                              size: 40,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filmTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // ===================================================================
                        // PERBAIKAN DI SINI: Menampilkan info dengan aman
                        // ===================================================================
                        _buildInfoRow(
                          Icons.theaters,
                          // Jika studio kosong, tampilkan 'N/A'
                          widget.jadwal.studio.isNotEmpty
                              ? widget.jadwal.studio
                              : 'N/A',
                        ),
                        _buildInfoRow(Icons.calendar_today, tanggal),
                        _buildInfoRow(Icons.access_time, jam),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Jumlah Tiket',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.white,
                          ),
                          onPressed: _jumlahTiket > 1
                              ? () => setState(() => _jumlahTiket--)
                              : null,
                        ),
                        Text(
                          '$_jumlahTiket',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.white,
                          ),
                          onPressed: () => setState(() => _jumlahTiket++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _pesanTiket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Pesan Sekarang',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
