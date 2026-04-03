import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId = "";

  static String normalizeIndianPhone(String input) {
    final String trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Phone number is required.');
    }

    if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(trimmed)) {
      throw const FormatException(
        'Use only digits and optional + sign in phone number.',
      );
    }

    final String compact = trimmed.replaceAll(RegExp(r'[\s-]'), '');

    if (RegExp(r'^\+91\d{10}$').hasMatch(compact)) {
      return compact;
    }

    if (RegExp(r'^91\d{10}$').hasMatch(compact)) {
      return '+$compact';
    }

    if (RegExp(r'^\d{10}$').hasMatch(compact)) {
      return '+91$compact';
    }

    throw const FormatException(
      'Enter a valid number: 10 digits or +91XXXXXXXXXX.',
    );
  }

  Future<void> sendOTP({
    required String phoneNo,
    required Function(String error) onError,
    required Function() onCodeSent,
  }) async {
    final String normalizedPhone;
    try {
      normalizedPhone = normalizeIndianPhone(phoneNo);
    } on FormatException catch (e) {
      onError(e.message.toString());
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: normalizedPhone,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },

      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? "Verification Invalid");
      },

      codeSent: (String verifyId, int? resendToken) async {
        verificationId = verifyId;
        onCodeSent();
      },

      codeAutoRetrievalTimeout: (String verifyId) {
        verificationId = verifyId;
      },
    );
  }

  Future<User?> verifyOTP({
    required String otp,
    required Function(String error) onError,
  }) async {
    if (verificationId.isEmpty) {
      onError("Please request OTP first.");
      return null;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? "Invalid OTP");
    }

    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
