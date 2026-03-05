import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Role Model
// ─────────────────────────────────────────────
enum UserRole { student, teacher, admin }

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.student:
        return 'STUDENT';
      case UserRole.teacher:
        return 'TEACHER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.student:
        return Icons.person_outline_rounded;
      case UserRole.teacher:
        return Icons.co_present_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}

// ─────────────────────────────────────────────
// Login Screen
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const _primaryBlue = Color(0xFF1A3FBF);
  static const _bgColor = Color(0xFFF0F4FA);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Returns email hint based on selected role
  String get _emailHint {
    switch (_selectedRole) {
      case UserRole.student:
        return 'student@university.edu';
      case UserRole.teacher:
        return 'teacher@university.edu';
      case UserRole.admin:
        return 'admin@university.edu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Logo / Icon Section (enlarged for future logo) ──
              _LogoSection(),

              const SizedBox(height: 16),

              // ── University Name ──
              const Text(
                'St. Andrews University',
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
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 32),

              // ── Role Selector ──
              _RoleSelector(
                selectedRole: _selectedRole,
                onRoleChanged: (role) {
                  setState(() {
                    _selectedRole = role;
                    _emailController.clear();
                    _passwordController.clear();
                  });
                },
              ),

              const SizedBox(height: 24),

              // ── Login Card ──
              _LoginCard(
                role: _selectedRole,
                emailController: _emailController,
                passwordController: _passwordController,
                emailHint: _emailHint,
                obscurePassword: _obscurePassword,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onSignIn: () {
                  // Handle sign in logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Signing in as ${_selectedRole.label}...',
                      ),
                      backgroundColor: _primaryBlue,
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // ── Footer ──
              RichText(
                text: TextSpan(
                  text: 'Need assistance? ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  children: const [
                    TextSpan(
                      text: 'Contact Support',
                      style: TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Logo Section Widget
// ─────────────────────────────────────────────
class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,   // <-- Larger size so you can drop your logo in easily
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE6F5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: Icon(
          Icons.school_rounded,
          size: 58,           // <-- Icon scales with container
          color: Color(0xFF1A3FBF),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Role Selector Widget
// ─────────────────────────────────────────────
class _RoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const _RoleSelector({
    required this.selectedRole,
    required this.onRoleChanged,
  });

  static const _primaryBlue = Color(0xFF1A3FBF);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: UserRole.values.map((role) {
        final isSelected = selectedRole == role;
        return Expanded(
          child: GestureDetector(
            onTap: () => onRoleChanged(role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? _primaryBlue : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    role.icon,
                    size: 28,
                    color: isSelected ? _primaryBlue : Colors.grey[400],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    role.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _primaryBlue : Colors.grey[400],
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
// Login Card Widget
// ─────────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  final UserRole role;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String emailHint;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSignIn;

  const _LoginCard({
    required this.role,
    required this.emailController,
    required this.passwordController,
    required this.emailHint,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSignIn,
  });

  static const _primaryBlue = Color(0xFF1A3FBF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title
          const Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B4B),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Enter your credentials to access the portal',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // Email Field
          _buildLabel('COLLEGE EMAIL'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: emailController,
            hint: emailHint,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),

          const SizedBox(height: 20),

          // Password Field
          _buildLabel('PASSWORD'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: passwordController,
            hint: '••••••••',
            obscureText: obscurePassword,
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: GestureDetector(
              onTap: onTogglePassword,
              child: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[400],
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onSignIn,
              icon: const SizedBox.shrink(),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: _primaryBlue,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Forgot Password
          TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: _primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15, color: Color(0xFF0D1B4B)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey[400], size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F7FC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF1A3FBF), width: 1.5),
        ),
      ),
    );
  }
}