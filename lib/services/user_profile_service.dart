import 'package:cloud_firestore/cloud_firestore.dart';

class StudentProfile {
  final String docId;       // Firestore document ID (e.g. "student1")
  final String name;
  final String className;
  final String division;
  final String rollNo;
  final String stream;
  final String parentName;
  final String parentNumber;
  // final String? avatarUrl;

  const StudentProfile({
    required this.docId,
    required this.name,
    required this.className,
    required this.division,
    required this.rollNo,
    required this.stream,
    required this.parentName,
    required this.parentNumber,
    // this.avatarUrl,
  });

  factory StudentProfile.fromMap(Map<String, dynamic> map, {String docId = ''}) {
    return StudentProfile(
      docId: docId,
      name: (map['name'] ?? '').toString(),
      className: (map['class'] ?? '').toString(),
      division: (map['division'] ?? '').toString(),
      rollNo: (map['rollno'] ?? map['rollNo'] ?? '').toString(),
      stream: (map['stream'] ?? '').toString(),
      parentName: (map['parentName'] ?? '').toString(),
      parentNumber: (map['parentNumber'] ?? '').toString(),
      // avatarUrl: map['avatarUrl']?.toString(),
    );
  }

  factory StudentProfile.empty() {
    return const StudentProfile(
      docId: '',
      name: 'Student',
      className: '',
      division: '',
      rollNo: '',
      stream: '',
      parentName: '',
      parentNumber: '',
      // avatarUrl: null,
    );
  }
}

class FacultyProfile {
  final String teacherID; // Firestore document ID
  final String name;
  final String email;
  final String phoneNumber;
  final String subject;
  // final String? avatarUrl;

  const FacultyProfile({
    required this.teacherID,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.subject,
    // this.avatarUrl,
  });

  factory FacultyProfile.fromMap(Map<String, dynamic> map, {String docId = ''}) {
    return FacultyProfile(
      teacherID: docId,
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phoneNumber: (map['phoneNumber'] ?? '').toString(),
      subject: (map['subject'] ?? '').toString(),
      // avatarUrl: map['avatarUrl']?.toString(),
    );
  }

  factory FacultyProfile.empty() {
    return const FacultyProfile(
      teacherID: '',
      name: 'Faculty',
      email: '',
      phoneNumber: '',
      subject: '',
      // avatarUrl: null,
    );
  }
}

class UserProfileService {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String toPhone10(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) return digits;
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    throw const FormatException('Unable to convert phone to 10-digit format.');
  }

  static List<String> phoneVariants(String authPhone) {
    final p10 = toPhone10(authPhone);
    return <String>[p10, '+91$p10', '91$p10'];
  }

  Future<StudentProfile?> fetchStudentByVerifiedPhone(String authPhone) async {
    final candidates = phoneVariants(authPhone);

    for (final candidate in candidates) {
      final query = await _firestore
          .collection('students')
          .where('parentNumber', isEqualTo: candidate)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return StudentProfile.fromMap(query.docs.first.data(), docId: query.docs.first.id);
      }
    }
    return null;
  }

  Future<FacultyProfile?> fetchFacultyByVerifiedPhone(String authPhone) async {
    final candidates = phoneVariants(authPhone);

    for (final candidate in candidates) {
      final query = await _firestore
          .collection('faculty')
          .where('phoneNumber', isEqualTo: candidate)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return FacultyProfile.fromMap(query.docs.first.data(), docId: query.docs.first.id);
      }
    }
    return null;
  }
}