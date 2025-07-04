// lib/pages/tambah_jadwal.dart - PERBAIKAN FINAL OVERFLOW

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vgc/api/jadwal_service.dart';
import 'package:vgc/helper/prefrence.dart';
import 'package:vgc/theme/color.dart';

class TambahJadwalPage extends StatefulWidget {
  final String filmId;
  const TambahJadwalPage({Key? key, required this.filmId}) : super(key: key);

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _jamController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedStudio;

  final List<String> _cinemaLocations = [
    'Mall Grand Indonesia',
    'AEON MALL TANJUNG BARAT XXI',
    'AGORA MALL XXI',
    'ARION XXI',
    'ARTHA GADING XXI',
    'BASSURA XXI',
    'BAYWALK PLUIT XXI',
    'BLOK M SQUARE',
    'BLOK M XXI',
    'CIJANTUNG XXI',
  ];

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _selectedStudio = null;
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kSecondaryBackground,
              onPrimary: kPrimaryTextColor,
              surface: kPrimaryBackground,
              onSurface: kPrimaryTextColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kAccentColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat(
          'EEEE, d MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  Future<void> _pilihJam(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kSecondaryBackground,
              onPrimary: kPrimaryTextColor,
              surface: kPrimaryBackground,
              onSurface: kPrimaryTextColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: kAccentColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _jamController.text = picked.format(context);
      });
    }
  }

  Future<void> _simpanJadwal() async {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedStudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal, Jam, dan Studio wajib diisi.')),
      );
      return;
    }

    setState(() => _loading = true);

    final DateTime startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final String formattedStartTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(startDateTime);
    final int? newJadwalId = await JadwalService().tambahJadwal(
      filmId: int.parse(widget.filmId),
      startTime: formattedStartTime,
      tempat: _selectedStudio!,
    );

    setState(() => _loading = false);

    if (mounted) {
      if (newJadwalId != null) {
        await PreferenceHelper.addOrUpdateJadwalStudio(
          newJadwalId.toString(),
          _selectedStudio!,
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan jadwal')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackground,
      appBar: AppBar(
        title: const Text(
          'Tambah Jadwal',
          style: TextStyle(color: kPrimaryTextColor),
        ),
        backgroundColor: kSecondaryBackground,
        iconTheme: const IconThemeData(color: kPrimaryTextColor),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: kSecondaryBackground.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Atur Jadwal Tayang',
                    style: TextStyle(
                      color: kPrimaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _tanggalController,
                    style: const TextStyle(color: kPrimaryTextColor),
                    decoration: _inputDecoration(
                      'Tanggal Tayang',
                      Icons.calendar_today,
                    ),
                    readOnly: true,
                    onTap: () => _pilihTanggal(context),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _jamController,
                    style: const TextStyle(color: kPrimaryTextColor),
                    decoration: _inputDecoration(
                      'Jam Tayang',
                      Icons.access_time,
                    ),
                    readOnly: true,
                    onTap: () => _pilihJam(context),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStudio,
                    decoration: _inputDecoration(
                      'Pilih Tempat / Studio',
                      Icons.theaters,
                    ),
                    dropdownColor: kSecondaryBackground,
                    style: const TextStyle(color: kPrimaryTextColor),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: kAccentColor,
                    ),
                    // PERBAIKAN BARU
                    isExpanded: true,
                    selectedItemBuilder: (BuildContext context) {
                      return _cinemaLocations.map<Widget>((String item) {
                        return Text(item, overflow: TextOverflow.ellipsis);
                      }).toList();
                    },
                    items: _cinemaLocations.map((String location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStudio = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Studio tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        foregroundColor: kPrimaryBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _simpanJadwal,
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: kPrimaryBackground,
                            )
                          : const Text(
                              'Simpan Jadwal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kAccentColor),
      prefixIcon: Icon(icon, color: kAccentColor),
      filled: true,
      fillColor: kPrimaryBackground.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kAccentColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: kAccentColor.withOpacity(0.2), width: 1),
      ),
    );
  }
}
