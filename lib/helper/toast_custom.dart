// lib/widgets/custom_toast.dart

import 'package:fluttertoast/fluttertoast.dart';
import 'package:vgc/theme/color.dart';

// Fungsi ini akan kita panggil dari halaman manapun untuk menampilkan toast
void showCustomToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    // PERUBAHAN UTAMA: Warna dibalik untuk kontras yang lebih tinggi
    backgroundColor: kAccentColor, // Latar belakang cerah
    textColor: kPrimaryBackground, // Teks gelap
    fontSize: 16.0,
  );
}
