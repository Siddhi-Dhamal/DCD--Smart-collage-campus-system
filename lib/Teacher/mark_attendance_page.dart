import 'package:flutter/material.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

enum AttendanceStatus { present, absent, late, none }

class Student {
  final String id;
  final String name;
  final String rollNo;
  final String avatarInitials;
  final Color avatarColor;
  AttendanceStatus status;

  Student({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.avatarInitials,
    required this.avatarColor,
    this.status = AttendanceStatus.none,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<Map<String, String>> _classes = [
    {'name': 'Advanced Algorithms', 'code': 'CS-401', 'room': 'Room 402'},
    {'name': 'Introduction to AI', 'code': 'CS-302', 'room': 'Lab B1'},
    {'name': 'Data Structures', 'code': 'CS-201', 'room': 'Auditorium A'},
  ];
  int _selectedClass = 0;
  bool submitted = false;

  final List<Student> _students = [
    Student(
      id: '1',
      name: 'Aarav Sharma',
      rollNo: '001',
      avatarInitials: 'AS',
      avatarColor: const Color(0xFF3B82F6),
    ),
    Student(
      id: '2',
      name: 'Priya Mehta',
      rollNo: '002',
      avatarInitials: 'PM',
      avatarColor: const Color(0xFF10B981),
    ),
    Student(
      id: '3',
      name: 'Rohan Verma',
      rollNo: '003',
      avatarInitials: 'RV',
      avatarColor: const Color(0xFFF59E0B),
    ),
    Student(
      id: '4',
      name: 'Sneha Patel',
      rollNo: '004',
      avatarInitials: 'SP',
      avatarColor: const Color(0xFFEF4444),
    ),
    Student(
      id: '5',
      name: 'Kiran Joshi',
      rollNo: '005',
      avatarInitials: 'KJ',
      avatarColor: const Color(0xFF8B5CF6),
    ),
    Student(
      id: '6',
      name: 'Ananya Rao',
      rollNo: '006',
      avatarInitials: 'AR',
      avatarColor: const Color(0xFFEC4899),
    ),
    Student(
      id: '7',
      name: 'Dev Gupta',
      rollNo: '007',
      avatarInitials: 'DG',
      avatarColor: const Color(0xFF06B6D4),
    ),
    Student(
      id: '8',
      name: 'Meera Nair',
      rollNo: '008',
      avatarInitials: 'MN',
      avatarColor: const Color(0xFF84CC16),
    ),
    Student(
      id: '9',
      name: 'Arjun Singh',
      rollNo: '009',
      avatarInitials: 'AS',
      avatarColor: const Color(0xFFF97316),
    ),
    Student(
      id: '10',
      name: 'Tanvi Desai',
      rollNo: '010',
      avatarInitials: 'TD',
      avatarColor: const Color(0xFF6366F1),
    ),
    Student(
      id: '11',
      name: 'Vikram Bose',
      rollNo: '011',
      avatarInitials: 'VB',
      avatarColor: const Color(0xFF14B8A6),
    ),
    Student(
      id: '12',
      name: 'Ishaan Kapoor',
      rollNo: '012',
      avatarInitials: 'IK',
      avatarColor: const Color(0xFFA78BFA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students
        .where(
          (s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.rollNo.contains(_searchQuery),
        )
        .toList();
  }

  int get _presentCount =>
      _students.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount =>
      _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get _lateCount =>
      _students.where((s) => s.status == AttendanceStatus.late).length;
  int get _markedCount =>
      _students.where((s) => s.status != AttendanceStatus.none).length;

  void _markAll(AttendanceStatus status) {
    setState(() {
      for (final s in _students) {
        s.status = status;
      }
    });
  }

  void _submitAttendance() {
    if (_markedCount < _students.length) {
      _showIncompleteDialog();
      return;
    }
    setState(() => submitted = true);
    _showSuccessSheet();
  }

  void _showIncompleteDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Incomplete Attendance',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          '${_students.length - _markedCount} student(s) still unmarked. Please mark all students before submitting.',
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF1A3DB5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF059669),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Attendance Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0D1B4B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_classes[_selectedClass]['name']} • ${_nowDate()}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF9098A3)),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryPill(
                  label: 'Present',
                  count: _presentCount,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFD1FAE5),
                ),
                _SummaryPill(
                  label: 'Absent',
                  count: _absentCount,
                  color: const Color(0xFFE53E3E),
                  bg: const Color(0xFFFEE2E2),
                ),
                _SummaryPill(
                  label: 'Late',
                  count: _lateCount,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFF3CD),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3DB5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String _nowDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          _buildHeader(),
          _buildClassSelector(),
          _buildSummaryBar(),
          _buildSearchAndActions(),
          Expanded(child: _buildStudentList()),
          _buildSubmitBar(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A3DB5), Color(0xFF2451CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Mark Attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _nowDate(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _nowTime(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour > 12
        ? now.hour - 12
        : now.hour == 0
        ? 12
        : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  // ── Class Selector ──────────────────────────────────────────────────────────
  Widget _buildClassSelector() {
    return Container(
      color: const Color(0xFF1A3DB5),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F6FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Class',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _classes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final isSelected = _selectedClass == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedClass = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A3DB5)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFF1A3DB5)
                                : Colors.black,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _classes[i]['code']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white70
                                  : const Color(0xFF9098A3),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _classes[i]['name']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0D1B4B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _classes[i]['room']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.white60
                                  : const Color(0xFF9098A3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary Bar ─────────────────────────────────────────────────────────────
  Widget _buildSummaryBar() {
    final total = _students.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _StatChip(
            label: 'Total',
            count: total,
            color: const Color(0xFF1A3DB5),
            bg: const Color(0xFFECEFF8),
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Present',
            count: _presentCount,
            color: const Color(0xFF059669),
            bg: const Color(0xFFD1FAE5),
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Absent',
            count: _absentCount,
            color: const Color(0xFFE53E3E),
            bg: const Color(0xFFFEE2E2),
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: 'Late',
            count: _lateCount,
            color: const Color(0xFFD97706),
            bg: const Color(0xFFFFF3CD),
          ),
        ],
      ),
    );
  }

  // ── Search + Bulk Actions ───────────────────────────────────────────────────
  Widget _buildSearchAndActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0D1B4B),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search student by name or roll no…',
                hintStyle: const TextStyle(
                  color: Color(0xFF9098A3),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF9098A3),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Bulk action buttons
          Row(
            children: [
              const Text(
                'Mark All:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 8),
              _BulkButton(
                label: 'Present',
                color: const Color(0xFF059669),
                bg: const Color(0xFFD1FAE5),
                onTap: () => _markAll(AttendanceStatus.present),
              ),
              const SizedBox(width: 6),
              _BulkButton(
                label: 'Absent',
                color: const Color(0xFFE53E3E),
                bg: const Color(0xFFFEE2E2),
                onTap: () => _markAll(AttendanceStatus.absent),
              ),
              const SizedBox(width: 6),
              _BulkButton(
                label: 'Reset',
                color: const Color(0xFF6B7280),
                bg: const Color(0xFFF3F4F6),
                onTap: () => _markAll(AttendanceStatus.none),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Student List ────────────────────────────────────────────────────────────
  Widget _buildStudentList() {
    final list = _filteredStudents;
    return list.isEmpty
        ? const Center(
            child: Text(
              'No students found',
              style: TextStyle(color: Color(0xFF9098A3)),
            ),
          )
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            itemCount: list.length,
            itemBuilder: (_, i) => _StudentTile(
              student: list[i],
              onStatusChanged: (status) {
                setState(() => list[i].status = status);
              },
            ),
          );
  }

  // ── Submit Bar ──────────────────────────────────────────────────────────────
  Widget _buildSubmitBar() {
    final total = _students.length;
    final progress = _markedCount / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_markedCount / $total marked',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A3DB5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFECEFF8),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF1A3DB5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitAttendance,
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: const Text(
                'Submit Attendance',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3DB5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Student Tile ──────────────────────────────────────────────────────────────

class _StudentTile extends StatelessWidget {
  final Student student;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const _StudentTile({required this.student, required this.onStatusChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _borderForStatus(student.status),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: student.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                student.avatarInitials,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: student.avatarColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & Roll
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D1B4B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Roll No. ${student.rollNo}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9098A3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Status buttons
          Row(
            children: [
              _StatusButton(
                icon: Icons.check_rounded,
                tooltip: 'Present',
                activeColor: const Color(0xFF059669),
                activeBg: const Color(0xFFD1FAE5),
                isActive: student.status == AttendanceStatus.present,
                onTap: () => onStatusChanged(
                  student.status == AttendanceStatus.present
                      ? AttendanceStatus.none
                      : AttendanceStatus.present,
                ),
              ),
              const SizedBox(width: 6),
              _StatusButton(
                icon: Icons.close_rounded,
                tooltip: 'Absent',
                activeColor: const Color(0xFFE53E3E),
                activeBg: const Color(0xFFFEE2E2),
                isActive: student.status == AttendanceStatus.absent,
                onTap: () => onStatusChanged(
                  student.status == AttendanceStatus.absent
                      ? AttendanceStatus.none
                      : AttendanceStatus.absent,
                ),
              ),
              const SizedBox(width: 6),
              _StatusButton(
                icon: Icons.access_time_rounded,
                tooltip: 'Late',
                activeColor: const Color(0xFFD97706),
                activeBg: const Color(0xFFFFF3CD),
                isActive: student.status == AttendanceStatus.late,
                onTap: () => onStatusChanged(
                  student.status == AttendanceStatus.late
                      ? AttendanceStatus.none
                      : AttendanceStatus.late,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Border? _borderForStatus(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Border.all(
          color: const Color(0xFF059669).withValues(alpha: 0.4),
          width: 1.5,
        );
      case AttendanceStatus.absent:
        return Border.all(
          color: const Color(0xFFE53E3E).withValues(alpha: 0.4),
          width: 1.5,
        );
      case AttendanceStatus.late:
        return Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.4),
          width: 1.5,
        );
      default:
        return null;
    }
  }
}

// ─── Small Widgets ─────────────────────────────────────────────────────────────

class _StatusButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color activeColor;
  final Color activeBg;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusButton({
    required this.icon,
    required this.tooltip,
    required this.activeColor,
    required this.activeBg,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isActive ? activeBg : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? activeColor : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _BulkButton({
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;

  const _SummaryPill({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
