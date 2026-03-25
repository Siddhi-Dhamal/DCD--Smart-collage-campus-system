import 'package:flutter/material.dart';
import 'package:my_app/Student/campus_navigation.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:material_symbols_icons/symbols.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 236, 233, 233),
      backgroundColor: const Color.fromARGB(255, 246, 243, 243),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                // shape: Border.all(color: Colors.black),
                leading: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 40, 80, 227),
                  radius: 30,
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/12225/12225935.png",
                    ),
                    radius: 25,
                  ),
                ),
                title: Text(
                  "Welcome Back, ",
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color.fromRGBO(104, 104, 104, 1),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Shivam Devkar",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: Icon(Icons.notifications_rounded),
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
                  color: Color.fromARGB(70, 93, 125, 239),
                  border: Border.all(
                    color: Color.fromARGB(255, 40, 80, 227),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 50,
                // color: Color.fromARGB(193, 129, 152, 237),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.record_voice_over_outlined,
                      color: Color.fromARGB(255, 40, 80, 227),
                      // textDirection: TextDirection.ltr,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          "Important: Mid term results are out jsjdhfnfsda fsdfafdsf sjkdfhsadjkl",
                          style: TextStyle(
                            color: Color.fromARGB(255, 93, 119, 215),
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
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                      Size(double.infinity, 40),
                    ),
                    elevation: WidgetStatePropertyAll(5),
                  ),
                  onPressed: () {},
                  child: Center(
                    child: Row(
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          fontWeight: FontWeight.bold,
                          size: 25,
                        ),
                        Text(
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.event_note,
                    label: "Timetable",
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.school_rounded,
                    label: "Exam Prep",
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.insert_chart_outlined_sharp,
                    label: "Results",
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.map,
                    label: "Campus Map",
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const CampusNavigation(),
                      //   ),
                      // );
                    },
                  ),
                  _buildGridItem(
                    context: context,
                    icon: Icons.my_library_books_outlined,
                    label: "Resources",
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                // width: 200,
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
                        Icon(Icons.person, fill: 1, size: 20),
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
                  ),
                  _resourceContainer(
                    filename: "Resource filename",
                    subject: "PHYSICS",
                  ),
                ],
              ),
            ],
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
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // border: Border.all(
              // color: Color.fromARGB(255, 40, 80, 227),
              // width: 2,
              // ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Icon(
              icon,
              size: 30,
              color: Color.fromARGB(255, 40, 80, 227),
            ),
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

Widget _resourceContainer({required String filename, required String subject}) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(
          //   padding: const EdgeInsets.all(5),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: const Color.fromARGB(87, 255, 153, 0),
          //   ),
          //   child: Icon(Icons.picture_as_pdf, color: Colors.orange),
          // ),
          // const SizedBox(height: 8),
          Text(
            filename,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            subject,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    ),
  );
}
