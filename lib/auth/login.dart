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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // To toggle password visibility

  void _login() async {
    // Validate all fields in the form
    if (!_formKey.currentState!.validate()) {
      return; // Stop if validation fails (fields are empty)
    }

    setState(() => _isLoading = true);

    try {
      final response = await UserService().login(
        _emailController.text,
        _passwordController.text,
      );

      print('RESPONS DARI SERVER: $response'); // For debugging

      setState(() => _isLoading = false);

      if (response != null && response['data']?['token'] != null) {
        // Login successful
        final String token = response['data']['token'];
        final String nama = response['data']['user']['name'];
        final String email = _emailController.text;

        await PreferenceHelper.saveToken(token);
        await PreferenceHelper.saveNama(nama);
        await PreferenceHelper.saveEmail(email);

        print('Login successful and data saved. Navigating...');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login berhasil! Selamat datang, $nama.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Login failed, check message from API
        String errorMessage;
        if (response != null && response['message'] != null) {
          // Assuming API returns specific messages like "Invalid credentials"
          if (response['message'].contains('credentials') || response['message'].contains('email') || response['message'].contains('password')) {
            errorMessage = 'Email atau password salah. Silakan coba lagi.';
          } else {
            errorMessage = response['message'];
          }
        } else {
          errorMessage = 'Login gagal. Terjadi kesalahan yang tidak diketahui.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('TERJADI ERROR DI BLOK CATCH: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900], // Deeper, richer background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple[900]!, // Darkest purple
              Colors.deepPurple[700]!, // Slightly lighter purple
              Colors.deepPurple[500]!, // Even lighter at the bottom
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Consistent padding around the card
            child: Form(
              key: _formKey, // Attach form key for validation
              child: Card(
                elevation: 12, // More pronounced shadow for the card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded card corners
                ),
                color: Colors.white.withOpacity(0.1), // Semi-transparent card
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Wrap content tightly
                    children: [
                      // Logo
                      Image.asset('assets/images/Logo.png', width: 180),
                      SizedBox(height: 30),

                      // Title
                      Text(
                        'Masuk Akun Anda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Silakan masuk untuk melanjutkan.',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 40),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.email, color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.deepPurple[300]!, width: 2),
                          ),
                          errorStyle: TextStyle(color: Colors.orangeAccent), // Error text style
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          // Optional: Add more robust email format validation
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Masukkan email yang valid';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Password Field
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
                              _obscureText ? Icons.visibility : Icons.visibility_off,
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
                            borderSide: BorderSide(color: Colors.deepPurple[300]!, width: 2),
                          ),
                          errorStyle: TextStyle(color: Colors.orangeAccent),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.deepPurpleAccent, // Strong accent color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: Colors.deepPurpleAccent.withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : Text(
                                  'MASUK',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Register Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()));
                        },
                        child: Text(
                          "Belum punya akun? Daftar Sekarang",
                          style: TextStyle(
                            color: Colors.deepPurple[300], // Matching the accent color
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