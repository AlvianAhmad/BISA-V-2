import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class BerandaMahasiswaPage
    extends
        StatefulWidget {
  const BerandaMahasiswaPage({
    super.key,
  });

  @override
  State<
    BerandaMahasiswaPage
  >
  createState() => _BerandaMahasiswaPageState();
}

class _BerandaMahasiswaPageState
    extends
        State<
          BerandaMahasiswaPage
        > {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(
    BuildContext context,
  ) {
    final bottomSafe = MediaQuery.of(
      context,
    ).padding.bottom;

    // tinggi navbar (≈56) + margin bottom navbar (16) + jarak aman (20)
    const floatingNavReserve = 92.0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        floatingNavReserve +
            bottomSafe,
      ),
      child: Column(
        children: [
          /// ======================
          /// CARD IPK & KURSUS
          /// ======================
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(
                    0xFF003182,
                  ),
                  Color(
                    0xFF0052A5,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(
                20,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatItem(
                  value: '3.9',
                  label: 'IPK',
                ),
                _StatItem(
                  value: '25',
                  label: 'Kursus Aktif',
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          /// ======================
          /// GRID MENU
          /// ======================
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 110, // ✅ tinggi item (atur 105-125)
            ),
            itemCount: 9,
            itemBuilder:
                (
                  context,
                  index,
                ) {
                  const items = [
                    (
                      Icons.schedule,
                      'Jadwal',
                    ),
                    (
                      Icons.school,
                      'Nilai',
                    ),
                    (
                      Icons.people,
                      'Presensi',
                    ),
                    (
                      Icons.assignment,
                      'Tugas',
                    ),
                    (
                      Icons.menu_book,
                      'Materi',
                    ),
                    (
                      Icons.payment,
                      'Biaya',
                    ),
                    (
                      Icons.bar_chart,
                      'Progress',
                    ),
                    (
                      Icons.question_answer,
                      'Kuesioner',
                    ),
                    (
                      Icons.emoji_events,
                      'Sertifikat',
                    ),
                  ];

                  final item = items[index];
                  return _MenuItem(
                    icon: item.$1,
                    title: item.$2,
                  );
                },
          ),

          /// ======================
          /// KALENDER
          /// ======================
          Container(
            padding: const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                18,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.05,
                  ),
                  blurRadius: 8,
                  offset: const Offset(
                    0,
                    3,
                  ),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(
                2020,
                1,
                1,
              ),
              lastDay: DateTime.utc(
                2030,
                12,
                31,
              ),
              focusedDay: _focusedDay,
              selectedDayPredicate:
                  (
                    day,
                  ) => isSameDay(
                    _selectedDay,
                    day,
                  ),
              onDaySelected:
                  (
                    selectedDay,
                    focusedDay,
                  ) {
                    setState(
                      () {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      },
                    );
                  },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(
                    0xFF003182,
                  ),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(
                    0xFF0052A5,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          Text(
            '© 2025 BISA LMS',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================
/// STAT ITEM
/// ======================
class _StatItem
    extends
        StatelessWidget {
  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

/// ======================
/// MENU ITEM
/// ======================
class _MenuItem
    extends
        StatelessWidget {
  final IconData icon;
  final String title;

  const _MenuItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        18,
      ),
      onTap: () {
        // TODO: navigasi ke halaman terkait
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            18,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: const Color(
                0xFF003182,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(
                  0xFF002F6C,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
