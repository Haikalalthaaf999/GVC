import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadTiket();
  }

  Future<void> _loadTiket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final result = await TiketService().getTiketByToken(token);
    setState(() {
      tiketList = result ?? [];
      _loading = false;
    });
  }

  Future<void> _hapusTiket(int tiketId) async {
    final success = await TiketService().hapusTiket(tiketId);
    if (success) {
      _loadTiket();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus tiket')),
      );
    }
  }

  Future<void> _editTiket(Tiket tiket) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTiketPage(tiket: tiket),
      ),
    );
    if (result == true) {
      _loadTiket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Tiket Saya'),
        backgroundColor: Colors.red.shade900,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : tiketList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada tiket',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: tiketList.length,
                  itemBuilder: (context, index) {
                    final tiket = tiketList[index];
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          tiket.nama,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Jam: ${tiket.jam}\nStudio: ${tiket.studio}\nJumlah: ${tiket.jumlah}\nTanggal Beli: ${tiket.createdAt.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _editTiket(tiket),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusTiket(tiket.id),
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
