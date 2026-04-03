import 'package:flutter/material.dart';
import 'package:my_app/Student/campus_navigation.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  static const Color _primaryBlue = Color.fromARGB(255, 40, 80, 227);
  static const Color _deepBlue = Color.fromARGB(255, 22, 53, 165);
  static const Color _accentSky = Color.fromARGB(255, 97, 187, 255);
  static const Color _surfaceTint = Color.fromARGB(255, 246, 248, 255);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceTint,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 236, 244, 255), Color(0xFFF6F2FF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withValues(alpha: 0.92),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(24, 26, 43, 128),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_primaryBlue, _accentSky],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromARGB(40, 40, 80, 227),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            "https://cdn-icons-png.flaticon.com/512/12225/12225935.png",
                          ),
                          radius: 25,
                        ),
                      ),
                    ),
                    title: const Text(
                      "Welcome Back, ",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(104, 104, 104, 1),
                      ),
                    ),
                    subtitle: const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        "Shivam Devkar",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 233, 240, 255),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.notifications_rounded,
                        color: _deepBlue,
                      ),
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE6F0FF), Color(0xFFE9E6FF)],
                    ),
                    border: Border.all(color: _primaryBlue, width: 1.4),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(20, 40, 80, 227),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.record_voice_over_outlined,
                        color: _deepBlue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            "Important: Mid term results are out so please check your results",
                            style: const TextStyle(
                              color: _deepBlue,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 90),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      elevation: 3,
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: Center(
                      child: Row(
                        spacing: 5,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 25),
                          const Text(
                            "Geo-fenced Attendence",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Quick Services",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 3,
                  // mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  // padding: const EdgeInsets.all(10),
                  childAspectRatio: 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    _buildGridItem(
                      context: context,
                      icon: Icons.edit_calendar_outlined,
                      label: "Attendance",
                      accentColor: const Color(0xFF2E7DFF),
                    ),
                    _buildGridItem(
                      context: context,
                      icon: Icons.event_note,
                      label: "Timetable",
                      accentColor: const Color(0xFF7A57E8),
                    ),
                    _buildGridItem(
                      context: context,
                      icon: Icons.school_rounded,
                      label: "Exam Prep",
                      accentColor: const Color(0xFF1B9E7A),
                    ),
                    _buildGridItem(
                      context: context,
                      icon: Icons.insert_chart_outlined_sharp,
                      label: "Results",
                      accentColor: const Color(0xFFE37B26),
                    ),
                    _buildGridItem(
                      context: context,
                      icon: Icons.map,
                      label: "Campus Map",
                      accentColor: const Color(0xFFD74A9D),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CampusNavigation(),
                          ),
                        );
                      },
                    ),
                    _buildGridItem(
                      context: context,
                      icon: Icons.my_library_books_outlined,
                      label: "Resources",
                      accentColor: const Color(0xFF006B78),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: Text(
                    "Current Standing",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 150,
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Color(0xFFEFF4FF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(24, 26, 43, 128),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Overall Attendence",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${85}%',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Color.fromRGBO(21, 228, 21, 0.166),
                            ),
                            child: Text(
                              "Safe Zone",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      CircularPercentIndicator(
                        radius: 55,
                        lineWidth: 10,
                        percent: 0.85,
                        progressColor: Color.fromRGBO(12, 49, 236, 1),
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        center: Icon(
                          Symbols.person_raised_hand_rounded,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Next Class",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "View Full",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Color(0xFFF4F8FF)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(18, 40, 80, 227),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Advanced Data Structures",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Room 402",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Row(
                        children: [
                          Icon(Symbols.access_time_filled, fill: 1, size: 20),
                          const SizedBox(width: 5),
                          Text(
                            "10:30 AM",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(width: 25),
                          Icon(
                            Icons.person,
                            fill: 1,
                            size: 20,
                            color: _deepBlue,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "Teacher Name",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: Text(
                    "Resources Shared",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _resourceContainer(
                      filename: "Resource filename sfsdgsd",
                      subject: "MATHEMATICS",
                      accentColor: const Color(0xFFFFB24C),
                    ),
                    _resourceContainer(
                      filename: "Resource filename",
                      subject: "PHYSICS",
                      accentColor: const Color(0xFF46A7FF),
                    ),
                  ],
                ),
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
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.3),
                ],
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 30, color: accentColor),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _resourceContainer({
  required String filename,
  required String subject,
  required Color accentColor,
}) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF7FAFF)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(22, 40, 80, 227),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: accentColor.withValues(alpha: 0.18),
            ),
            child: Icon(Icons.picture_as_pdf_rounded, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            filename,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            subject,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: accentColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    ),
  );
}
