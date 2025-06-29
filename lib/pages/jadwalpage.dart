// FILE: jadwal_tab.dart
import 'package:flutter/material.dart';
import '../api/jadwal_service.dart';
import '../models/model_jadwal.dart';
import 'tambah_jadwal_page.dart';

class JadwalTab extends StatefulWidget {
  final String filmId;
  const JadwalTab({super.key, required this.filmId});

  @override
  State<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<JadwalTab> {
  List<JadwalDatum> _jadwalList = [];
  bool _loading = true;

  Future<void> _getJadwal() async {
     final filmId = int.tryParse(widget.filmId);
  if (filmId == null) return;
    final data = await JadwalService().getJadwalByFilmId(filmId);
    setState(() {
      _jadwalList = data;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getJadwal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        child: const Icon(Icons.add),
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TambahJadwalPage(filmId: widget.filmId)),
          );
          if (refresh == true) _getJadwal();
        },
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _jadwalList.isEmpty
              ? const Center(child: Text('Belum ada jadwal', style: TextStyle(color: Colors.white70)))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _jadwalList.length,
                  itemBuilder: (context, index) {
                    final item = _jadwalList[index];
                    return Card(
                      color: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text('${item.createdAt.toLocal().toString().split(" ")[0]} | ${item.jam}', style: const TextStyle(color: Colors.white)),
                        subtitle: Text('${item.tempat}', style: const TextStyle(color: Colors.white70)),
                      ),
                    );
                  },
                ),
    );
  }
}
