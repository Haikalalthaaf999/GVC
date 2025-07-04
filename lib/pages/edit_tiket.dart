// lib/pages/edit_tiket.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/theme/color.dart';
import 'package:vgc/helper/toast_custom.dart'; // PERUBAHAN: Import helper toast baru
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
    _jumlahTiket = widget.tiket.jumlah;
  }

  Future<void> _updateTiket() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final success = await TiketService().editTiket(
      token: token,
      tiketId: widget.tiket.id,
      scheduleId: widget.tiket.jadwalId,
      jumlah: _jumlahTiket,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (success) {
      // PERUBAHAN: Menggunakan helper toast
      showCustomToast('Jumlah tiket berhasil diperbarui');
      Navigator.pop(context, true);
    } else {
      // PERUBAHAN: Menggunakan helper toast
      showCustomToast('Gagal memperbarui tiket');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... sisa kode build Anda tidak perlu diubah ...
    return Scaffold(
      backgroundColor: kPrimaryBackground,
      appBar: AppBar(
        title: const Text(
          'Edit Jumlah Tiket',
          style: TextStyle(color: kPrimaryTextColor),
        ),
        backgroundColor: kSecondaryBackground,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Film: ${widget.tiket.film?.title ?? widget.tiket.nama}',
              style: const TextStyle(
                color: kPrimaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              color: kSecondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ubah Jumlah Tiket',
                      style: TextStyle(color: kPrimaryTextColor, fontSize: 18),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: kAccentColor,
                          ),
                          onPressed: _jumlahTiket > 1
                              ? () => setState(() => _jumlahTiket--)
                              : null,
                        ),
                        Text(
                          '$_jumlahTiket',
                          style: const TextStyle(
                            color: kPrimaryTextColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: kAccentColor,
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
                backgroundColor: kAccentColor,
                foregroundColor: kPrimaryBackground,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: kPrimaryBackground)
                  : const Text(
                      'Simpan Perubahan',
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
}
