// lib/pages/tambah_jadwal_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/jadwal_service.dart';

class TambahJadwalPage extends StatefulWidget {
  final String filmId;
  const TambahJadwalPage({Key? key, required this.filmId}) : super(key: key);

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final TextEditingController _tempatController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jamController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _loading = false;

  // Fungsi untuk menampilkan pemilih tanggal
  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat(
          'EEEE, d MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  // Fungsi untuk menampilkan pemilih waktu
  Future<void> _pilihJam(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _jamController.text = picked.format(context);
      });
    }
  }

  Future<void> _simpanJadwal() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _tempatController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua data wajib diisi.')));
      return;
    }

    setState(() => _loading = true);

    // Gabungkan tanggal dan waktu menjadi satu objek DateTime
    final DateTime startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Format menjadi string "YYYY-MM-DD HH:MM:SS" yang siap dikirim ke API
    final String formattedStartTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(startDateTime);

    final success = await JadwalService().tambahJadwal(
      filmId: int.parse(widget.filmId),
      startTime: formattedStartTime,
      tempat: _tempatController.text,
    );

    setState(() => _loading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true); // Kembali dan beri sinyal refresh
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan jadwal')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tambah Jadwal'),
        backgroundColor: Colors.red.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Tanggal
            TextFormField(
              controller: _tanggalController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                'Tanggal Tayang',
                Icons.calendar_today,
              ),
              readOnly: true, // Agar tidak bisa diketik manual
              onTap: () => _pilihTanggal(context),
            ),
            const SizedBox(height: 16),
            // Input Jam
            TextFormField(
              controller: _jamController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Jam Tayang', Icons.access_time),
              readOnly: true,
              onTap: () => _pilihJam(context),
            ),
            const SizedBox(height: 16),
            // Input Tempat
            TextFormField(
              controller: _tempatController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Tempat / Studio', Icons.theaters),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loading ? null : _simpanJadwal,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Simpan Jadwal',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }
}
