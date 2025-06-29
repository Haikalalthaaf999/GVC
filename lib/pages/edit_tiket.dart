import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vgc/api/tiket_service.dart';
import '../models/model_tiket.dart';


class EditTiketPage extends StatefulWidget {
  final Tiket tiket;

  const EditTiketPage({Key? key, required this.tiket}) : super(key: key);

  @override
  _EditTiketPageState createState() => _EditTiketPageState();
}

class _EditTiketPageState extends State<EditTiketPage> {
  final TextEditingController _jumlahController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _jumlahController.text = widget.tiket.jumlah.toString();
  }

  Future<void> _simpanPerubahan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Token tidak ditemukan")),
      );
      return;
    }

    setState(() => _loading = true);

    final success = await TiketService().editTiket(
      token: token,
      tiketId: widget.tiket.id,
      jumlah: int.tryParse(_jumlahController.text) ?? widget.tiket.jumlah,
    );

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tiket berhasil diubah")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengubah tiket")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Tiket"),
        backgroundColor: Colors.red[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Jumlah Tiket",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah tiket',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loading ? null : _simpanPerubahan,
              icon: Icon(Icons.save),
              label: Text(_loading ? 'Menyimpan...' : 'Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
