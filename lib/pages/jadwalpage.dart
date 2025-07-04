// lib/pages/jadwalpage.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vgc/pages/admin/tambah_jadwal_page.dart';
import 'package:vgc/pages/pesan_tiket.dart';
import 'package:vgc/pages/pilihbangku.dart';
import 'package:vgc/theme/color.dart'; // PERUBAHAN: Import palet warna

import '../api/jadwal_service.dart';
import '../models/model_jadwal.dart';
import 'package:vgc/helper/prefrence.dart';

class JadwalTab extends StatefulWidget {
  final String filmId;
  const JadwalTab({super.key, required this.filmId});

  @override
  State<JadwalTab> createState() => _JadwalTabState();
}

class _JadwalTabState extends State<JadwalTab> {
  List<JadwalDatum> _jadwalList = [];
  bool _loading = true;
  String? _errorMessage;

  Map<DateTime, Map<String, List<JadwalDatum>>> _groupedSchedules = {};
  List<DateTime> _availableDates = [];
  DateTime? _selectedDate;
  bool _isAdmin = false;

  String? _selectedFilterStudio;

  final List<String> _cinemaLocations = [
    'Semua Studio',
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

  @override
  void initState() {
    super.initState();
    _selectedFilterStudio = _cinemaLocations.first;
    _checkAdminStatusAndGetJadwal();
  }

  Future<void> _checkAdminStatusAndGetJadwal() async {
    _isAdmin = await PreferenceHelper.getIsAdmin();
    if (mounted) {
      _getJadwal();
    }
  }

  Future<void> _getJadwal() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _groupedSchedules.clear();
      _availableDates.clear();
      _selectedDate = null;
    });

    try {
      final semuaJadwal = await JadwalService().getAllJadwal();
      final filmIdInt = int.tryParse(widget.filmId);

      if (filmIdInt != null) {
        final jadwalTersaring = semuaJadwal.where((jadwal) {
          return jadwal.filmId == filmIdInt.toString() &&
              jadwal.startTime != null &&
              jadwal.studio != null &&
              jadwal.studio!.isNotEmpty;
        }).toList();

        for (var jadwal in jadwalTersaring) {
          final dateOnly = DateTime(
            jadwal.startTime!.year,
            jadwal.startTime!.month,
            jadwal.startTime!.day,
          );

          if (!_availableDates.contains(dateOnly)) {
            _availableDates.add(dateOnly);
          }

          _groupedSchedules.putIfAbsent(dateOnly, () => {});
          _groupedSchedules[dateOnly]!.putIfAbsent(jadwal.studio!, () => []);
          _groupedSchedules[dateOnly]![jadwal.studio!]!.add(jadwal);
        }

        _availableDates.sort((a, b) => a.compareTo(b));

        if (_availableDates.isNotEmpty) {
          _selectedDate = _availableDates.first;
        }

        _groupedSchedules.forEach((date, studios) {
          studios.forEach((studioName, schedules) {
            schedules.sort((a, b) => a.startTime!.compareTo(b.startTime!));
          });
        });

        setState(() {
          _jadwalList = jadwalTersaring;
          _loading = false;
        });
      } else {
        throw Exception("ID Film tidak valid.");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat jadwal. Silakan coba lagi.";
        _loading = false;
      });
    }
  }

  Future<void> _goToPesanTiket(JadwalDatum jadwal) async {
    int? ticketQuantity = await showDialog<int>(
      context: context,
      builder: (context) {
        int tempQuantity = 1;
        return AlertDialog(
          // Biarkan style default agar konsisten dengan dialog sistem
          title: const Text('Jumlah Tiket'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pilih berapa tiket yang ingin Anda pesan:'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          if (tempQuantity > 1) {
                            setState(() => tempQuantity--);
                          }
                        },
                      ),
                      Text(
                        '$tempQuantity',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: () {
                          setState(() => tempQuantity++);
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempQuantity),
              child: const Text('Pilih'),
            ),
          ],
        );
      },
    );

    if (ticketQuantity == null || ticketQuantity == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemesanan dibatalkan atau jumlah tiket tidak valid.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    final List<String>? selectedSeats = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeatSelectionPage(
          jadwalId: jadwal.id,
          ticketQuantity: ticketQuantity,
        ),
      ),
    );

    if (selectedSeats == null || selectedSeats.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda belum memilih bangku.')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PesanTiketPage(jadwal: jadwal, selectedSeats: selectedSeats),
      ),
    );
  }

  void _goToTambahJadwal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahJadwalPage(filmId: widget.filmId),
      ),
    );
    if (result == true) {
      _getJadwal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackground, // PERUBAHAN WARNA
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              backgroundColor: kAccentColor, // PERUBAHAN WARNA
              onPressed: _goToTambahJadwal,
              tooltip: 'Tambah Jadwal',
              child: const Icon(
                Icons.add,
                color: kPrimaryBackground,
              ), // PERUBAHAN WARNA
            )
          : null,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: kAccentColor,
        ), // PERUBAHAN WARNA
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: kAccentColor),
            ), // PERUBAHAN WARNA
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _getJadwal,
              child: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryBackground, // PERUBAHAN WARNA
                foregroundColor: kPrimaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_jadwalList.isEmpty || _availableDates.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada jadwal untuk film ini',
          style: TextStyle(color: kAccentColor), // PERUBAHAN WARNA
        ),
      );
    }

    return DefaultTabController(
      length: _availableDates.length,
      initialIndex: _selectedDate != null
          ? _availableDates.indexOf(_selectedDate!)
          : 0,
      child: Column(
        children: [
          // Tab Bar untuk Tanggal
          Container(
            color: kSecondaryBackground, // PERUBAHAN WARNA
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TabBar(
              isScrollable: true,
              labelColor: kPrimaryTextColor, // PERUBAHAN WARNA
              unselectedLabelColor: kAccentColor, // PERUBAHAN WARNA
              indicatorColor: kAccentColor, // PERUBAHAN WARNA
              onTap: (index) {
                setState(() {
                  _selectedDate = _availableDates[index];
                });
              },
              tabs: _availableDates.map((date) {
                final String dayName = DateFormat('EEEE', 'id_ID').format(date);
                final String dayMonth = DateFormat(
                  'd MMM',
                  'id_ID',
                ).format(date);
                return Tab(text: '$dayMonth ${dayName.toUpperCase()}');
              }).toList(),
            ),
          ),
          // Dropdown Filter Studio
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedFilterStudio,
              decoration: InputDecoration(
                labelText: 'Pilih Studio',
                labelStyle: const TextStyle(
                  color: kAccentColor,
                ), // PERUBAHAN WARNA
                prefixIcon: const Icon(
                  Icons.theaters,
                  color: kAccentColor,
                ), // PERUBAHAN WARNA
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: kAccentColor.withOpacity(0.3),
                  ), // PERUBAHAN WARNA
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: kAccentColor,
                  ), // PERUBAHAN WARNA
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: kSecondaryBackground.withOpacity(
                  0.5,
                ), // PERUBAHAN WARNA
              ),
              dropdownColor: kSecondaryBackground, // PERUBAHAN WARNA
              style: const TextStyle(
                color: kPrimaryTextColor,
              ), // PERUBAHAN WARNA
              icon: const Icon(
                Icons.arrow_drop_down,
                color: kAccentColor,
              ), // PERUBAHAN WARNA
              items: _cinemaLocations.map((String location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilterStudio = newValue;
                });
              },
            ),
          ),
          // Konten jadwal untuk tanggal dan studio yang dipilih
          Expanded(child: _buildJadwalForSelectedDate()),
        ],
      ),
    );
  }

  Widget _buildJadwalForSelectedDate() {
    if (_selectedDate == null ||
        !_groupedSchedules.containsKey(_selectedDate)) {
      return const Center(
        child: Text(
          'Tidak ada jadwal untuk tanggal ini.',
          style: TextStyle(color: kAccentColor), // PERUBAHAN WARNA
        ),
      );
    }

    final Map<String, List<JadwalDatum>> schedulesOnSelectedDate =
        _groupedSchedules[_selectedDate]!;

    Map<String, List<JadwalDatum>> filteredSchedules = {};
    if (_selectedFilterStudio == 'Semua Studio') {
      filteredSchedules = schedulesOnSelectedDate;
    } else if (_selectedFilterStudio != null &&
        schedulesOnSelectedDate.containsKey(_selectedFilterStudio!)) {
      filteredSchedules[_selectedFilterStudio!] =
          schedulesOnSelectedDate[_selectedFilterStudio!]!;
    }

    final sortedStudios = filteredSchedules.keys.toList()..sort();

    if (filteredSchedules.isEmpty) {
      return Center(
        child: Text(
          _selectedFilterStudio == 'Semua Studio'
              ? 'Tidak ada jadwal untuk film ini pada tanggal terpilih.'
              : 'Tidak ada jadwal di $_selectedFilterStudio untuk tanggal ini.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: kAccentColor,
            fontSize: 16,
          ), // PERUBAHAN WARNA
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sortedStudios.length,
      itemBuilder: (context, index) {
        final String studioName = sortedStudios[index];
        final List<JadwalDatum> jadwalPerStudio =
            filteredSchedules[studioName]!;

        final String hargaTipeStudio = studioName.toLowerCase().contains('4dx')
            ? 'Rp. 80.000'
            : 'Rp. 45.000';

        return Card(
          margin: const EdgeInsets.only(bottom: 20.0),
          color: kSecondaryBackground, // PERUBAHAN WARNA
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        studioName,
                        style: const TextStyle(
                          color: kPrimaryTextColor, // PERUBAHAN WARNA
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hargaTipeStudio,
                      style: const TextStyle(
                        color: kAccentColor, // PERUBAHAN WARNA
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: jadwalPerStudio.map((jadwal) {
                    final String jam = DateFormat(
                      'HH:mm',
                    ).format(jadwal.startTime!);
                    return ElevatedButton(
                      onPressed: () => _goToPesanTiket(jadwal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor, // PERUBAHAN WARNA
                        foregroundColor: kPrimaryBackground, // PERUBAHAN WARNA
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(80, 0),
                      ),
                      child: Text(
                        jam,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight
                              .bold, // Dibuat tebal agar lebih terbaca
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
