// lib/pages/pilihbangku.dart (Ikon sudah diubah menjadi sofa)

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Impor helper yang asli, bukan membuat dummy
import 'package:vgc/helper/prefrence.dart';

// Palet Warna Sesuai Desain
const Color kBackgroundColor = Color(0xFF222831);
const Color kPrimaryColor = Color(0xFF393E46);
const Color kSelectedSeatColor = Color(0xFF1ee3cf);
const Color kReservedSeatColor = Color(0xFFe2435b);
const Color kAvailableSeatColor = Colors.white54;
const Color kScreenGlowColor = Color(0xFFF5F0CD);

class SeatSelectionPage extends StatefulWidget {
  final int jadwalId;
  final int ticketQuantity;

  const SeatSelectionPage({
    super.key,
    required this.jadwalId,
    required this.ticketQuantity,
  });

  @override
  State<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  List<String> _selectedSeats = [];
  List<String> _occupiedSeats = [];
  bool _isLoading = true;

  final Map<String, String> seatLayout = {
    'A': 'AA_AAAA_AA',
    'B': 'AAAAAAAAAA',
    'C': 'AAAAAAAAAA',
    'D': 'AAAAAAAAAA',
    'E': 'AAAAAAAAAA',
  };

  @override
  void initState() {
    super.initState();
    _loadOccupiedSeats();
  }

  Future<void> _loadOccupiedSeats() async {
    setState(() => _isLoading = true);
    // Menggunakan PreferenceHelper asli dari helper/prefrence.dart
    _occupiedSeats = await PreferenceHelper.getOccupiedSeatsForJadwal(
      widget.jadwalId.toString(),
    );
    setState(() => _isLoading = false);
  }

  void _toggleSeatSelection(String seatName) {
    setState(() {
      if (_occupiedSeats.contains(seatName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bangku ini sudah terisi!'),
            backgroundColor: kReservedSeatColor,
          ),
        );
      } else if (_selectedSeats.contains(seatName)) {
        _selectedSeats.remove(seatName);
      } else {
        if (_selectedSeats.length < widget.ticketQuantity) {
          _selectedSeats.add(seatName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Anda hanya bisa memilih ${widget.ticketQuantity} bangku.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _confirmSelection() {
    if (_selectedSeats.length == widget.ticketQuantity) {
      _selectedSeats.sort((a, b) {
        String rowA = a.substring(0, 1);
        int colA = int.parse(a.substring(1));
        String rowB = b.substring(0, 1);
        int colB = int.parse(b.substring(1));

        int rowComparison = rowA.compareTo(rowB);
        if (rowComparison != 0) return rowComparison;
        return colA.compareTo(colB);
      });
      Navigator.pop(context, _selectedSeats);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silakan pilih ${widget.ticketQuantity} bangku.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Sisa kode UI untuk SeatSelectionPage... (build, _buildHeader, etc.)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kBackgroundColor, kPrimaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildScreenDisplay(),
                    const SizedBox(height: 40),
                    Expanded(child: _buildSeatGrid()),
                    _buildSeatStatusLegend(),
                    const SizedBox(height: 20),
                    _buildConfirmButton(),
                    const SizedBox(height: 10),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Choose Seats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildScreenDisplay() {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width * 0.7, 25),
      painter: _ScreenPainter(),
    );
  }

  Widget _buildSeatGrid() {
    return Column(
      children: seatLayout.entries.map((entry) {
        String rowId = entry.key;
        String layoutStr = entry.value;
        int seatNumberInRow = 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: layoutStr.runes.map((rune) {
              String char = String.fromCharCode(rune);
              if (char == '_') {
                return const SizedBox(width: 24.0);
              } else {
                String seatName = '$rowId$seatNumberInRow';
                seatNumberInRow++;

                Color seatColor;
                if (_occupiedSeats.contains(seatName)) {
                  seatColor = kReservedSeatColor;
                } else if (_selectedSeats.contains(seatName)) {
                  seatColor = kSelectedSeatColor;
                } else {
                  seatColor = kAvailableSeatColor;
                }

                return InkWell(
                  onTap: () => _toggleSeatSelection(seatName),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FaIcon(
                      FontAwesomeIcons.couch, // <<< PERUBAHAN DI SINI
                      color: seatColor,
                      size: 22.0,
                    ),
                  ),
                );
              }
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSeatStatusLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(kAvailableSeatColor, 'Available'),
          _legendItem(kReservedSeatColor, 'Reserved'),
          _legendItem(kSelectedSeatColor, 'Selected'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ElevatedButton(
        onPressed: _confirmSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff526D82),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Confirm Seats (${_selectedSeats.length}/${widget.ticketQuantity})',
          style: const TextStyle(
            color: Color(0xFFDDE6ED),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kScreenGlowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2,
      -size.height,
      size.width,
      size.height,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
