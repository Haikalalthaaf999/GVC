// lib/pages/jadwalpage.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vgc/pages/pesan_tiket.dart';
import 'package:vgc/pages/tambah_jadwal_page.dart';
import '../api/jadwal_service.dart';
import '../models/model_jadwal.dart';

class JadwalTab extends StatefulWidget {
  final String filmId;
  const JadwalTab({super.key, required this.filmId});

  @override
  State<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<JadwalTab> {
  List<JadwalDatum> _jadwalList = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getJadwal();
  }

  Future<void> _getJadwal() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final semuaJadwal = await JadwalService().getAllJadwal();
      final filmIdInt = int.tryParse(widget.filmId);
      if (filmIdInt != null) {
        final jadwalTersaring = semuaJadwal.where((jadwal) {
          return jadwal.filmId == filmIdInt.toString();
        }).toList();

        setState(() {
          _jadwalList = jadwalTersaring;
          _loading = false;
        });
      } else {
        throw Exception("ID Film tidak valid.");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat jadwal. Silakan coba lagi.";
        _loading = false;
      });
    }
  }

  void _goToPesanTiket(JadwalDatum jadwal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PesanTiketPage(jadwal: jadwal)),
    );
  }

  void _goToTambahJadwal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahJadwalPage(filmId: widget.filmId),
      ),
    );
    if (result == true) {
      _getJadwal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        onPressed: _goToTambahJadwal,
        tooltip: 'Tambah Jadwal',
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
              onPressed: _getJadwal,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_jadwalList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada jadwal untuk film ini',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _jadwalList.length,
      itemBuilder: (context, index) {
        final item = _jadwalList[index];
        final String tanggal = item.startTime != null
            ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(item.startTime!)
            : 'N/A';
        final String jam = item.startTime != null
            ? DateFormat('HH:mm').format(item.startTime!)
            : 'N/A';

        return Card(
          color: Colors.white10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            // ===================================================================
            // PERUBAHAN TEPAT DI BARIS INI
            // ===================================================================
            title: Text(
              'Tempat: ${item.studio}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Tanggal: $tanggal\nJam Tayang: $jam',
              style: const TextStyle(color: Colors.white70, height: 1.5),
            ),
            trailing: ElevatedButton(
              onPressed: () => _goToPesanTiket(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Pesan', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }
}
