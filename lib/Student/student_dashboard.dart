import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 10),
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
                  minimumSize: WidgetStatePropertyAll(Size(double.infinity, 40)),
                  elevation: WidgetStatePropertyAll(5),
                ),
                onPressed: (){}, 
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
          ],
        ),
      ),
    );
  }
}
