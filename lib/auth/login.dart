import 'package:flutter/material.dart';

import 'package:vgc/auth/register.dart';
import 'package:vgc/helper/prefrence.dart';
import 'package:vgc/pages/home_page.dart';
import '/api/user_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

void _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await UserService().login(
        _emailController.text,
        _passwordController.text,
      );

      // Mencetak respons tetap berguna untuk debugging di masa depan
      print('RESPONS DARI SERVER: $response');

      setState(() => _isLoading = false);

      // KONDISI SUKSES DIUBAH: Kita anggap login sukses jika ada 'token' di dalam 'data'
      if (response != null && response['data']?['token'] != null) {
        // AMBIL DATA DARI LOKASI YANG BENAR (SESUAI RESPON API)
        final String token = response['data']['token'];
        final String nama = response['data']['user']['name'];

        // Simpan data yang sudah diambil
        await PreferenceHelper.saveToken(token);
        await PreferenceHelper.saveNama(
          nama,
        ); // Pastikan helper Anda menyimpan 'nama'

        print('Login sukses dan data disimpan. Menjalankan navigasi...');

        // Navigasi ke HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Jika kondisi di atas tidak terpenuhi, berarti login gagal
        final errorMessage =
            response?['message'] ?? 'Login gagal. Terjadi kesalahan.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      print('TERJADI ERROR DI BLOK CATCH: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
          ),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/logo.png', width: 150),
                SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: Text(_isLoading ? 'Loading...' : 'Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
                  },
                  child: Text("Belum punya akun? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
