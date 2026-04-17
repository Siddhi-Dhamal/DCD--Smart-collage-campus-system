import 'package:flutter/material.dart';
// import 'package:my_app/create_user_credentials.dart';
import 'package:my_app/services/phone_auth.dart';
import 'package:my_app/services/user_profile_service.dart';
import 'package:my_app/Student/student_dashboard.dart';
import 'package:my_app/Teacher/professor_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  PhoneAuth phoneAuth = PhoneAuth();
  final List<String> userRoles = ['Student', 'Teacher', 'Admin'];
  String selectedRole = 'Student';
  bool isLoading = false;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 243, 243),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width:
                      110, // <-- Larger size so you can drop your logo in easily
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/college_logo.png",
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Dahiwadi College',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D1B4B),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              Text(
                'Campus Management Portal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                children: userRoles.map((role) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: RoleSelector(
                        role: role,
                        isSelected: selectedRole == role,
                        onTap: () {
                          setState(() {
                            selectedRole = role;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Text(
                      "Welcome!!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 13, 27, 75),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Enter your credentials to access the portal',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[500],
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    _buildLabel("PHONE NUMBER"),
                    const SizedBox(height: 8),

                    _buildTextField(
                      hintText: "Phone Number (10 digits or +91...)",
                      prefix: Icons.phone,
                      input: TextInputType.number,
                      controller: phoneController,
                    ),
                    const SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: () async {
                        final phone = phoneController.text.trim();
                        if (phone.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter phone number.'),
                            ),
                          );
                          return;
                        }

                        final String normalizedPhone;
                        try {
                          normalizedPhone = PhoneAuth.normalizeIndianPhone(
                            phone,
                          );
                        } on FormatException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message.toString())),
                          );
                          return;
                        }

                        setState(() {
                          isLoading = true;
                        });

                        await phoneAuth.sendOTP(
                          phoneNo: normalizedPhone,
                          onError: (error) {
                            if (!mounted) return;
                            setState(() {
                              isLoading = false;
                            });
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                          },

                          onCodeSent: () {
                            if (!mounted) return;
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("OTP sent.")),
                            );
                          },
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 26, 63, 191),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 4,
                        shadowColor: Color.fromARGB(255, 26, 63, 191),
                      ),
                      child: Text(
                        "Get OTP",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildLabel("OTP"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hintText: "Enter OTP",
                      prefix: Icons.check_circle,
                      input: TextInputType.number,
                      controller: otpController,
                    ),

                    const SizedBox(height: 28),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          final otp = otpController.text.trim();
                          if (otp.isEmpty) return;

                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final user = await phoneAuth.verifyOTP(
                              otp: otp,
                              onError: (error) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(error)));
                              },
                            );

                            if (user == null) return;

                            final authPhone = user.phoneNumber;
                            if (authPhone == null || authPhone.isEmpty) {
                              await phoneAuth.signOut();

                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Verified phone not available. Login again.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (selectedRole == 'Student') {
                              final student = await UserProfileService.instance
                                  .fetchStudentByVerifiedPhone(authPhone);

                              if (student == null) {
                                await phoneAuth.signOut();
                                if (!mounted) return;
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Student not registered"),
                                  ),
                                );
                                return;
                              }

                              if (!mounted) return;
                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDashboard(profile: student),
                                ),
                              );
                              return;
                            }

                            if (selectedRole == 'Teacher') {
                              final teacher = await UserProfileService.instance
                                  .fetchFacultyByVerifiedPhone(authPhone);

                              if (teacher == null) {
                                await phoneAuth.signOut();
                                if (!mounted) return;
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Teacher not registered'),
                                  ),
                                );
                                return;
                              }

                              if (!mounted) return;
                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardPage(profile: teacher),
                                ),
                              );
                              return;
                            }

                            await phoneAuth.signOut();
                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Admin phone flow is not configured yet.',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Login Failed: $e")),
                            );
                          } finally {
                            setState(() => isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 26, 63, 191),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                          shadowColor: Color.fromARGB(255, 26, 63, 191),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Need Assistance?", style: TextStyle(fontSize: 14)),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Contact Support",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleSelector extends StatelessWidget {
  final String role;
  final bool isSelected;
  final Function() onTap;

  const RoleSelector({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color.fromRGBO(12, 49, 236, 1)
                : const Color.fromARGB(255, 246, 243, 243),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              Icons.person,
              size: 30,
              color: isSelected
                  ? const Color.fromRGBO(12, 49, 236, 1)
                  : Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              role,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color.fromRGBO(12, 49, 236, 1)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLabel(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color.fromARGB(255, 13, 27, 75),
        letterSpacing: 0.3,
      ),
    ),
  );
}

Widget _buildTextField({
  required String hintText,
  IconData? prefix,
  TextInputType? input,
  required TextEditingController controller,
}) {
  return TextField(
    keyboardType: input,
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Color.fromRGBO(232, 240, 255, 0.477),
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
      prefixIcon: Icon(prefix),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(169, 158, 158, 158),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 26, 63, 191),
          width: 1.5,
        ),
      ),
    ),
  );
}
