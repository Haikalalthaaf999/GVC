// lib/pages/pesan_tiket.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/helper/toast_custom.dart'; // PERUBAHAN: Import toast
import 'package:vgc/theme/color.dart'; // PERUBAHAN: Import palet warna
import '../api/tiket_service.dart';
import '../models/model_jadwal.dart';
import 'package:vgc/helper/prefrence.dart';

class PesanTiketPage extends StatefulWidget {
  final JadwalDatum jadwal;
  final List<String> selectedSeats;

  const PesanTiketPage({
    Key? key,
    required this.jadwal,
    required this.selectedSeats,
  }) : super(key: key);

  @override
  State<PesanTiketPage> createState() => _PesanTiketPageState();
}

class _PesanTiketPageState extends State<PesanTiketPage> {
  late int _jumlahTiket;
  bool _loading = false;
  String _nama = 'Guest';

  @override
  void initState() {
    super.initState();
    _jumlahTiket = widget.selectedSeats.length;
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
      await PreferenceHelper.addOccupiedSeats(
        widget.jadwal.id.toString(),
        widget.selectedSeats,
      );

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
          title: const Text(
            'Pemesanan Berhasil',
            style: TextStyle(color: kPrimaryTextColor),
          ),
          content: Text(
            'Tiket Anda telah berhasil dipesan untuk bangku: ${widget.selectedSeats.join(', ')}.',
            style: const TextStyle(color: kAccentColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: kAccentColor)),
            ),
          ],
        ),
      );
      Navigator.pop(context, true);
    } else {
      // PERUBAHAN: Menggunakan toast kustom
      showCustomToast('Gagal memesan tiket');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filmTitle = widget.jadwal.film?.title ?? 'Judul Film';
    final filmImageUrl = widget.jadwal.film?.imageUrl ?? '';

    final tanggal = widget.jadwal.startTime != null
        ? DateFormat('EEEE, d MMMM y', 'id_ID').format(widget.jadwal.startTime!)
        : 'N/A';

    final jam = widget.jadwal.startTime != null
        ? DateFormat('HH:mm').format(widget.jadwal.startTime!)
        : 'N/A';

    return Scaffold(
      backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
      appBar: AppBar(
        title: Text(
          'Pesan Tiket ($_nama)',
          style: const TextStyle(color: kPrimaryTextColor),
        ), // PERUBAHAN WARNA
        backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
        iconTheme: const IconThemeData(
          color: kPrimaryTextColor,
        ), // PERUBAHAN WARNA
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: kSecondaryBackground, // PERUBAHAN WARNA
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
                            color: kPrimaryBackground, // PERUBAHAN WARNA
                            child: const Icon(
                              Icons.movie,
                              color: kAccentColor, // PERUBAHAN WARNA
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
                            color: kPrimaryTextColor, // PERUBAHAN WARNA
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.theaters,
                          widget.jadwal.studio?.isNotEmpty ?? false
                              ? widget.jadwal.studio!
                              : 'N/A (Tempat)',
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
              color: kSecondaryBackground, // PERUBAHAN WARNA
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jumlah Tiket',
                      style: TextStyle(
                        color: kPrimaryTextColor,
                        fontSize: 18,
                      ), // PERUBAHAN WARNA
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_jumlahTiket Tiket',
                      style: const TextStyle(
                        color: kPrimaryTextColor, // PERUBAHAN WARNA
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bangku Dipilih:',
                      style: TextStyle(
                        color: kAccentColor,
                        fontSize: 16,
                      ), // PERUBAHAN WARNA
                    ),
                    Text(
                      widget.selectedSeats.isEmpty
                          ? 'Belum ada bangku dipilih'
                          : widget.selectedSeats.join(', '),
                      style: const TextStyle(
                        color: kPrimaryTextColor, // PERUBAHAN WARNA
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _pesanTiket,
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentColor, // PERUBAHAN WARNA
                foregroundColor: kPrimaryBackground, // PERUBAHAN WARNA
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: kPrimaryBackground)
                  : const Text(
                      'Pesan Sekarang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
          Icon(icon, color: kAccentColor, size: 16), // PERUBAHAN WARNA
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: kAccentColor,
              fontSize: 14,
            ), // PERUBAHAN WARNA
          ),
        ],
      ),
    );
  }
}
