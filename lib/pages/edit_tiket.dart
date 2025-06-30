// lib/pages/edit_tiket.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/tiket_service.dart';
import '../models/model_tiket.dart';

class EditTiketPage extends StatefulWidget {
  final Tiket tiket;
  const EditTiketPage({Key? key, required this.tiket}) : super(key: key);

  @override
  State<EditTiketPage> createState() => _EditTiketPageState();
}

class _EditTiketPageState extends State<EditTiketPage> {
  late int _jumlahTiket;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Ambil jumlah tiket awal dari data yang dikirim
    _jumlahTiket = widget.tiket.jumlah;
  }

  Future<void> _updateTiket() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    // ===================================================================
    // MEMANGGIL FUNGSI EDIT TIKET DENGAN PARAMETER YANG LENGKAP
    // ===================================================================
    final success = await TiketService().editTiket(
      token: token,
      tiketId: widget.tiket.id,
      scheduleId: widget.tiket.jadwalId, // <-- Mengirim scheduleId dari tiket
      jumlah: _jumlahTiket,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah tiket berhasil diperbarui')),
      );
      Navigator.pop(context, true); // Kembali dan beri sinyal refresh
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui tiket')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Jumlah Tiket'),
        backgroundColor: Colors.red.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Film: ${widget.tiket.film?.title ?? widget.tiket.nama}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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
                      'Ubah Jumlah Tiket',
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
              onPressed: _loading ? null : _updateTiket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
