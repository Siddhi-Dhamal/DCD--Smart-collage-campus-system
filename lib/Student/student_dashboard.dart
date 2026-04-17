import 'package:flutter/material.dart';
import 'package:my_app/Student/attendance_display.dart';
import 'package:my_app/Student/campus_navigation.dart';
import 'package:my_app/services/user_profile_service.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';

class StudentDashboard extends StatelessWidget {
  final StudentProfile? profile;
  const StudentDashboard({super.key, this.profile});

  // static const Color _primaryBlue = Color.fromARGB(255, 40, 80, 227);
  // static const Color _deepBlue = Color.fromARGB(255, 22, 53, 165);
  // static const Color _accentSky = Color.fromARGB(255, 97, 187, 255);
  // static const Color _surfaceTint = Color.fromARGB(255, 246, 248, 255);

  @override
  Widget build(BuildContext context) {
    final student = profile ?? StudentProfile.empty();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── Header ──────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1A3DB5),
                        width: 2.5,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 26,
                      backgroundImage: NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/12225/12225935.png",
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        student.name.isEmpty ? "Student" : student.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D1B4B),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      color: Color(0xFF0D1B4B),
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Announcement Banner ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EFFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFF1A3DB5),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          'Important: Mid-term results are out! Check your portal now.',
                          style: const TextStyle(
                            color: Color(0xFF1A3DB5),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Geo-fenced Attendance Button ────────────────────────────────
              SizedBox(
                width: 250,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on_rounded, size: 20),
                  label: const Text(
                    'Geo-fenced Attendance',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3DB5),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0xFF1A3DB5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    // _buildGridItem(
                    //   context: context,
                    //   icon: Icons.my_library_books_outlined,
                    //   label: "Resources",
                    //   accentColor: const Color(0xFF006B78),
                    // ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ── Quick Services ──────────────────────────────────────────────
              const Text(
                'Quick Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B4B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildGridItem(
                    context: context,
                    icon: Icons.edit_calendar_outlined,
                    label: 'Attendance',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceDisplayPage(),
                        ),
                      );
                    },
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.event_note_rounded,
                    label: 'Timetable',
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.school_rounded,
                    label: 'Exam Prep',
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.insert_chart_outlined_sharp,
                    label: 'Results',
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.map_rounded,
                    label: 'Campus Map',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const CampusNavigation()));
                    },
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.my_library_books_outlined,
                    label: 'Resources',
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ── Current Standing ────────────────────────────────────────────
              const Text(
                'Current Standing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B4B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Attendance',
                          style: TextStyle(
                            color: Color(0xFF9098A3),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '85%',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D1B4B),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Text(
                            'Safe Zone',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    CircularPercentIndicator(
                      radius: 52,
                      lineWidth: 9,
                      percent: 0.85,
                      progressColor: const Color(0xFF1A3DB5),
                      backgroundColor: const Color(0xFFE8EFFE),
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      center: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EFFE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Symbols.person_raised_hand_rounded,
                          color: Color(0xFF1A3DB5),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── Next Class ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Next Class',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1B4B),
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View Full',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A3DB5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Advanced Data Structures',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0D1B4B),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Room 402 • Engineering Block',
                            style: TextStyle(
                              color: Color(0xFF9098A3),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: Color(0xFF9098A3),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                '10:30 AM',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.person_rounded,
                                size: 16,
                                color: Color(0xFF9098A3),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Dr. Emily Watson',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFFE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF1A3DB5),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ── Resources Shared ────────────────────────────────────────────
              const Text(
                'Resources Shared',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B4B),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _resourceCard(
                      icon: Icons.picture_as_pdf_rounded,
                      iconColor: Colors.white,
                      iconBg: const Color(0xFFEF4444),
                      filename: 'Lecture_Notes_0...',
                      subject: 'MATHEMATICS',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _resourceCard(
                      icon: Icons.insert_drive_file_rounded,
                      iconColor: Colors.white,
                      iconBg: const Color(0xFF3B82F6),
                      filename: 'Assignment_2.d...',
                      subject: 'NETWORKING',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // ── Bottom Navigation Bar ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_rounded, 'HOME', true),
                _navItem(Icons.insert_drive_file_rounded, 'RESULTS', false),
                _navItem(Icons.map_rounded, 'MAP', false),
                _navItem(Icons.chat_bubble_rounded, 'MESSAGES', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF1A3DB5)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isSelected ? const Color(0xFF1A3DB5) : const Color(0xFF9098A3),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? const Color(0xFF1A3DB5)
                : const Color(0xFF9098A3),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

Widget _resourceCard({
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  required String filename,
  required String subject,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          filename,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF0D1B4B),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subject,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
            color: Color(0xFF9098A3),
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}
