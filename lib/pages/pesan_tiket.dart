import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/tiket_service.dart';

class PesanTiketPage extends StatefulWidget {
  final String jadwalId;

  const PesanTiketPage({Key? key, required this.jadwalId}) : super(key: key);

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
      jadwalId: int.parse(widget.jadwalId),
      jumlah: _jumlahTiket,
    );

    setState(() => _loading = false);
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memesan tiket')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Pesan Tiket ($_nama)'), // tampilkan nama user
        backgroundColor: Colors.red.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jumlah Tiket', style: TextStyle(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white),
                  onPressed: _jumlahTiket > 1 ? () => setState(() => _jumlahTiket--) : null,
                ),
                Text('$_jumlahTiket', style: const TextStyle(color: Colors.white, fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () => setState(() => _jumlahTiket++),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : _pesanTiket,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                minimumSize: const Size.fromHeight(50),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Pesan Tiket'),
            )
          ],
        ),
      ),
    );
  }
}
