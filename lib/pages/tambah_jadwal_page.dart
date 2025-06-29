import 'package:flutter/material.dart';
import '../api/jadwal_service.dart';

class TambahJadwalPage extends StatefulWidget {
  final String filmId;
  const TambahJadwalPage({Key? key, required this.filmId}) : super(key: key);

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final _formKey = GlobalKey<FormState>();
  String tanggal = '';
  String jam = '';
  String tempat = '';
  bool _loading = false;

  Future<void> _simpanJadwal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _loading = true);

      final success = await JadwalService().tambahJadwal(
        filmId: int.parse(widget.filmId),
        jam: jam,
        tempat: tempat,
      );

      setState(() => _loading = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan jadwal')),
        );
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: _inputDecoration('Tanggal (YYYY-MM-DD)'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Tanggal wajib diisi' : null,
                onSaved: (value) => tanggal = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Jam (HH:MM)'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Jam wajib diisi' : null,
                onSaved: (value) => jam = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Tempat / Studio'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Tempat wajib diisi' : null,
                onSaved: (value) => tempat = value!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: _loading ? null : _simpanJadwal,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Jadwal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }
}
