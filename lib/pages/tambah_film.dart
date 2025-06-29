import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class TambahFilmPage extends StatefulWidget {
  const TambahFilmPage({Key? key}) : super(key: key);

  @override
  State<TambahFilmPage> createState() => _TambahFilmPageState();
}

class _TambahFilmPageState extends State<TambahFilmPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _tambahFilm() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (_judulController.text.isEmpty ||
        _deskripsiController.text.isEmpty ||
        _genreController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Semua data wajib diisi.")),
      );
      return;
    }

    setState(() => _loading = true);

    final uri = Uri.parse('https://appbioskop.mobileprojp.com/api/films');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['judul'] = _judulController.text;
    request.fields['deskripsi'] = _deskripsiController.text;
    request.fields['genre'] = _genreController.text;

    request.files.add(await http.MultipartFile.fromPath(
      'gambar',
      _imageFile!.path,
      filename: path.basename(_imageFile!.path),
    ));

    final response = await request.send();

    setState(() => _loading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Film berhasil ditambahkan.")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menambahkan film.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Tambah Film',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    labelText: 'Judul Film',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _deskripsiController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _genreController,
                  decoration: InputDecoration(
                    labelText: 'Genre',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                _imageFile == null
                    ? Text("Belum ada gambar dipilih.")
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, height: 200),
                      ),
                SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text("Pilih Gambar"),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _tambahFilm,
                  child: Text(
                    _loading ? "Menyimpan..." : "Simpan Film",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
