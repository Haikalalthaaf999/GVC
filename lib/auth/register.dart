import 'package:flutter/material.dart';
import '/api/user_service.dart'; // Pastikan path ini benar
import 'login.dart'; // Pastikan path ini benar

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // To toggle password visibility

  void _register() async {
    // Validasi awal di form (misal: field tidak boleh kosong, email valid)
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails
    }

    // --- Validasi Kompleksitas Password di Sisi Klien (untuk SnackBar) ---
    final String password = _passwordController.text;
    final bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    final bool hasDigits = password.contains(RegExp(r'[0-9]'));
    final bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password minimal 8 karakter.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return; // Hentikan proses jika password kurang dari 8 karakter
    }

    if (!hasUppercase ||
        !hasLowercase ||
        (!hasDigits && !hasSpecialCharacters)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password harus mengandung huruf besar, kecil, dan angka/simbol.', style: TextStyle(color: Colors.white),
          ),          
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return; // Hentikan proses jika kompleksitas tidak terpenuhi
    }
    // --- Akhir Validasi Kompleksitas Password ---

    setState(() => _isLoading = true);

    try {
      final response = await UserService().register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      print('RESPONS DARI SERVER: $response'); // Untuk debugging

      setState(() => _isLoading = false);

      if (response != null && (response['message'] == 'Registrasi berhasil')) {
        // Registrasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );

        // Arahkan ke halaman login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } else {
        // Registrasi gagal (dari respons server, jika ada validasi tambahan di server)
        String errorMessage = 'Registrasi gagal.'; // Pesan default

        if (response != null) {
          // Cek jika ada 'message' umum dari server
          if (response['message'] != null && response['message'] is String) {
            errorMessage = response['message'];
          }
          // Cek jika ada 'errors' yang lebih detail (khususnya untuk validasi input)
          if (response['errors'] != null && response['errors'] is Map) {
            List<String> detailedErrors = [];
            response['errors'].forEach((key, value) {
              if (value is List) {
                detailedErrors.addAll(List<String>.from(value));
              } else if (value is String) {
                detailedErrors.add(value);
              }
            });

            if (detailedErrors.isNotEmpty) {
              errorMessage =
                  'Registrasi gagal:\n- ' + detailedErrors.join('\n- ');
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(
              seconds: 4,
            ), // Durasi SnackBar lebih panjang untuk pesan detail
          ),
        );
      }
    } catch (e) {
      print('TERJADI ERROR DI BLOK CATCH: $e');
      setState(() => _isLoading = false);

      String displayMessage =
          'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';

      if (e is Exception) {
        if (e.toString().contains('302') &&
            e.toString().contains('Redirecting to')) {
          displayMessage =
              'Gagal terhubung ke API. Server mengalihkan permintaan. Mohon periksa konfigurasi server atau URL API.';
        } else if (e.toString().contains('Failed to load')) {
          displayMessage =
              'Gagal memuat data dari server. Pastikan URL API benar dan server berjalan.';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(displayMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepOrange[900]!,
              Colors.deepPurple[700]!,
              Colors.deepPurple[500]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/Asset 2.png', width: 100),
                      SizedBox(height: 30),
                      Text(
                        'Buat Akun Baru',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Bergabunglah dengan petualangan ini.',
                        style: TextStyle(color: Colors.grey[300], fontSize: 16),
                      ),
                      SizedBox(height: 40),

                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[300]!,
                              width: 2,
                            ),
                          ),
                          errorStyle: TextStyle(color: Colors.orangeAccent),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[300]!,
                              width: 2,
                            ),
                          ),
                          errorStyle: TextStyle(color: Colors.orangeAccent),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[400],
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.deepPurple[300]!,
                              width: 2,
                            ),
                          ),
                          errorStyle: TextStyle(color: Colors.orangeAccent),
                        ),
                        validator: (value) {
                          // Validator ini hanya untuk pengecekan dasar (tidak kosong)
                          // Validasi kompleksitas akan ditangani di _register() dan ditampilkan di SnackBar
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          // Anda bisa menambahkan validasi panjang minimal di sini jika ingin
                          // agar tidak terlalu banyak request ke server untuk password yang sangat pendek.
                          if (value.length < 6) {
                            // Contoh: minimal 6 karakter untuk validasi awal
                            return 'Password minimal 6 karakter.';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepPurpleAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: Colors.deepPurpleAccent.withOpacity(
                              0.6,
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                )
                              : Text(
                                  'DAFTAR SEKARANG',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        },
                        child: Text(
                          "Sudah punya akun? Masuk di sini.",
                          style: TextStyle(
                            color: Colors.deepPurple[300],
                            fontSize: 15,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.deepPurple[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
