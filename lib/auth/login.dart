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

  final response = await UserService().login(
    _emailController.text,
    _passwordController.text,
  );

  setState(() => _isLoading = false);

  if (response['success']) {
    // Simpan token dan nama ke SharedPreferences via helper
    await PreferenceHelper.saveToken(response['token']);
    await PreferenceHelper.saveNama(response['nama']); // pastikan 'nama' ada di response

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response['message'] ?? 'Login gagal')),
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
