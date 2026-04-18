import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Firestore Schema ──────────────────────────────────────────────────────────
// subjects/{docId}
//   teacherID: "FAC101", name: "Mathematics", code: "101"
//
// students/{studentId}
//   class, division, name, parentName, parentNumber, rollno, stream
//
// attendance/{autoId}
//   date, division, markedat, period, standard, stream,
//   subjectID, subjectName, teacherID
//   + subcollection: records/studentID → { studentDocId: "present"/"absent"/"late" }
// ──────────────────────────────────────────────────────────────────────────────

enum AttendanceStatus { present, absent, late, none }

class _StudentData {
  final String id;
  final String name;
  final int rollno;
  final String parentName;
  AttendanceStatus status;

  _StudentData({
    required this.id,
    required this.name,
    required this.rollno,
    required this.parentName,
    this.status = AttendanceStatus.none,
  });

  String get initials {
    final parts = name.trim().split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(1, 2)).toUpperCase();
  }

  Color get avatarColor {
    const colors = [
      Color(0xFF3B82F6), Color(0xFF10B981), Color(0xFFF59E0B),
      Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFFEC4899),
      Color(0xFF06B6D4), Color(0xFF84CC16),
    ];
    return colors[id.hashCode.abs() % colors.length];
  }
}

// ─── Page ──────────────────────────────────────────────────────────────────────
class MarkAttendancePage extends StatefulWidget {
  final String teacherID;   // e.g. "FAC101"
  final String teacherName; // e.g. "Ganesh Pawar"

  const MarkAttendancePage({
    super.key,
    required this.teacherID,
    required this.teacherName,
  });

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Subjects ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _subjects = [];
  int _selectedSubjectIndex = 0;
  bool _subjectsLoading = true;

  // ── Class Selection ───────────────────────────────────────────────────────
  String _selectedClass    = '11th';
  String _selectedDivision = 'A';
  String _selectedStream   = 'Science';
  int    _selectedPeriod   = 1;

  // ── Students ──────────────────────────────────────────────────────────────
  List<_StudentData> _students       = [];
  bool               _studentsLoading = false;
  String             _searchQuery    = '';

  // ── Session ───────────────────────────────────────────────────────────────
  String? _existingSessionId;
  bool    _submitting = false;

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String get _todayStored {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}-'
        '${n.month.toString().padLeft(2, '0')}-${n.year}';
  }

  String get _todayDisplay {
    final n = DateTime.now();
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    const d = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${d[n.weekday - 1]}, ${m[n.month - 1]} ${n.day}, ${n.year}';
  }

  String _nowTime() {
    final n  = DateTime.now();
    final h  = n.hour > 12 ? n.hour - 12 : n.hour == 0 ? 12 : n.hour;
    final mi = n.minute.toString().padLeft(2, '0');
    return '$h:$mi ${n.hour >= 12 ? "PM" : "AM"}';
  }

  Map<String, dynamic>? get _selectedSubject =>
      _subjects.isEmpty ? null : _subjects[_selectedSubjectIndex];

  int get _presentCount =>
      _students.where((s) => s.status == AttendanceStatus.present).length;
  int get _absentCount =>
      _students.where((s) => s.status == AttendanceStatus.absent).length;
  int get _lateCount =>
      _students.where((s) => s.status == AttendanceStatus.late).length;
  int get _markedCount =>
      _students.where((s) => s.status != AttendanceStatus.none).length;

  List<_StudentData> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    final q = _searchQuery.toLowerCase();
    return _students
        .where((s) =>
    s.name.toLowerCase().contains(q) ||
        s.rollno.toString().contains(q))
        .toList();
  }

  // ─── Init ─────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // DEBUG: Print the teacherID being used — check this in your Flutter console
    debugPrint('✅ MarkAttendancePage opened');
    debugPrint('✅ teacherID received: "${widget.teacherID}"');
    debugPrint('✅ teacherName received: "${widget.teacherName}"');

    _loadSubjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Load Subjects ────────────────────────────────────────────────────────
  Future<void> _loadSubjects() async {
    setState(() => _subjectsLoading = true);

    // FIX: Always trim the teacherID to avoid whitespace mismatches
    final tid = widget.teacherID.trim();

    debugPrint('🔍 Querying: subjects where teacherID == "$tid"');

    try {
      final snap = await FirebaseFirestore.instance
          .collection('subjects')
          .where('teacherID', isEqualTo: tid)
          .get();

      debugPrint('📦 Subjects found: ${snap.docs.length}');
      for (final doc in snap.docs) {
        debugPrint('   → ${doc.id}: ${doc.data()}');
      }

      final loaded = snap.docs.map((doc) => <String, dynamic>{
        'docId': doc.id,
        'name' : (doc.data()['name']  ?? '').toString(),
        'code' : (doc.data()['code']  ?? '').toString(),
      }).toList();

      setState(() {
        _subjects        = loaded;
        _subjectsLoading = false;
      });

      if (_subjects.isNotEmpty) _loadStudents();

    } catch (e, stack) {
      debugPrint('🔴 Subject load error: $e\n$stack');
      setState(() => _subjectsLoading = false);
      _showSnack('Error loading subjects: $e', error: true);
    }
  }

  // ─── Load Students ────────────────────────────────────────────────────────
  Future<void> _loadStudents() async {
    setState(() {
      _studentsLoading = true;
      _students        = [];
    });

    try {
      final snap = await FirebaseFirestore.instance
          .collection('students')
          .get();

      debugPrint('📦 Total students in DB: ${snap.docs.length}');

      final students = snap.docs.where((doc) {
        final d = doc.data();
        return d['class']    == _selectedClass &&
            d['division'] == _selectedDivision &&
            (d['stream'] as String? ?? '')
                .toLowerCase() == _selectedStream.toLowerCase();
      }).map((doc) {
        final d       = doc.data();
        final rawRoll = d['rollno'];
        final rollno  = rawRoll is int
            ? rawRoll
            : int.tryParse(rawRoll?.toString() ?? '0') ?? 0;
        return _StudentData(
          id:         doc.id,
          name:       (d['name']       ?? '').toString(),
          rollno:     rollno,
          parentName: (d['parentName'] ?? '').toString(),
        );
      }).toList()
        ..sort((a, b) => a.rollno.compareTo(b.rollno));

      debugPrint('👥 Students matching class filter: ${students.length}');

      // Check for existing session today
      String? existingId;
      if (_selectedSubject != null) {
        final existing = await FirebaseFirestore.instance
            .collection('attendance')
            .where('subjectID', isEqualTo: _selectedSubject!['code'])
            .where('date',      isEqualTo: _todayStored)
            .where('period',    isEqualTo: _selectedPeriod)
            .where('standard',  isEqualTo: _selectedClass)
            .where('division',  isEqualTo: _selectedDivision)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          existingId = existing.docs.first.id;
          final recSnap = await FirebaseFirestore.instance
              .collection('attendance')
              .doc(existingId)
              .collection('records')
              .doc('studentID')
              .get();

          if (recSnap.exists) {
            final recs = recSnap.data() as Map<String, dynamic>;
            for (final s in students) {
              final val = recs[s.id];
              // FIX: Support both string format (new) and bool format (old)
              if (val == 'present' || val == true)          s.status = AttendanceStatus.present;
              else if (val == 'late')                       s.status = AttendanceStatus.late;
              else if (val == 'absent' || val == false)     s.status = AttendanceStatus.absent;
            }
          }
        }
      }

      setState(() {
        _students          = students;
        _existingSessionId = existingId;
        _studentsLoading   = false;
      });

    } catch (e, stack) {
      debugPrint('🔴 Student load error: $e\n$stack');
      setState(() => _studentsLoading = false);
      _showSnack('Error loading students: $e', error: true);
    }
  }

  // ─── Mark All ─────────────────────────────────────────────────────────────
  void _markAll(AttendanceStatus status) {
    setState(() {
      for (final s in _students) s.status = status;
    });
  }

  // ─── Submit Attendance ────────────────────────────────────────────────────
  Future<void> _submitAttendance() async {
    if (_submitting) return;

    // FIX: Show clear errors instead of silently doing nothing
    if (_students.isEmpty) {
      _showSnack('No students loaded. Select a class first.', error: true);
      return;
    }

    if (_selectedSubject == null) {
      _showSnack(
        'No subject found for "${widget.teacherID.trim()}". '
            'Add one in Firestore → subjects with teacherID = "${widget.teacherID.trim()}"',
        error: true,
      );
      return;
    }

    // Warn about unmarked students
    if (_markedCount < _students.length) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Incomplete Attendance',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          content: Text(
            '${_students.length - _markedCount} student(s) are still unmarked.\n\n'
                'Unmarked students will be treated as Absent. Submit anyway?',
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF9098A3), fontWeight: FontWeight.w700)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit Anyway',
                  style: TextStyle(color: Color(0xFF1A3DB5), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      setState(() {
        for (final s in _students) {
          if (s.status == AttendanceStatus.none) s.status = AttendanceStatus.absent;
        }
      });
    }

    setState(() => _submitting = true);

    try {
      final db = FirebaseFirestore.instance;
      final bool isNewSession = _existingSessionId == null;

      final sessionRef = isNewSession
          ? db.collection('attendance').doc()
          : db.collection('attendance').doc(_existingSessionId);

      debugPrint('📝 Writing to attendance/${sessionRef.id}');

      await sessionRef.set({
        'date'       : _todayStored,
        'division'   : _selectedDivision,
        'markedat'   : FieldValue.serverTimestamp(),
        'period'     : _selectedPeriod,
        'standard'   : _selectedClass,
        'stream'     : _selectedStream.toLowerCase(),
        'subjectID'  : _selectedSubject!['code'],
        'subjectName': _selectedSubject!['name'],
        'teacherID'  : widget.teacherID.trim(),
      });

      // FIX: Store string status so Late is preserved correctly
      final Map<String, String> records = {};
      for (final s in _students) {
        switch (s.status) {
          case AttendanceStatus.present: records[s.id] = 'present'; break;
          case AttendanceStatus.late:    records[s.id] = 'late';    break;
          default:                       records[s.id] = 'absent';  break;
        }
      }

      await sessionRef.collection('records').doc('studentID').set(records);

      debugPrint('✅ Attendance saved! records: $records');

      setState(() {
        _existingSessionId = sessionRef.id;
        _submitting        = false;
      });

      _showSuccessSheet(isNewSession: isNewSession);

    } catch (e, stack) {
      debugPrint('🔴 Submit error: $e\n$stack');
      setState(() => _submitting = false);
      _showSnack('Failed to save: $e', error: true);
    }
  }

  // ─── Snack ────────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : const Color(0xFF059669),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: error ? 6 : 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ─── Success Sheet ────────────────────────────────────────────────────────
  void _showSuccessSheet({required bool isNewSession}) {
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
              width: 72, height: 72,
              decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF059669), size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              isNewSession ? 'Attendance Submitted!' : 'Attendance Updated!',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0D1B4B)),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedSubject?['name'] ?? ''} • $_todayDisplay',
              style: const TextStyle(fontSize: 13, color: Color(0xFF9098A3)),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryPill(label: 'Present', count: _presentCount,
                    color: const Color(0xFF059669), bg: const Color(0xFFD1FAE5)),
                _SummaryPill(label: 'Absent', count: _absentCount,
                    color: const Color(0xFFE53E3E), bg: const Color(0xFFFEE2E2)),
                _SummaryPill(label: 'Late', count: _lateCount,
                    color: const Color(0xFFD97706), bg: const Color(0xFFFFF3CD)),
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
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Done',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          _buildHeader(),
          _buildClassSelector(),
          _buildSubjectSelector(),
          _buildSummaryBar(),
          _buildSearchAndActions(),
          Expanded(child: _buildStudentList()),
          _buildSubmitBar(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
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
              Row(children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                const Expanded(
                  child: Text('Mark Attendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.w800, letterSpacing: -0.3),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedPeriod,
                      dropdownColor: const Color(0xFF1A3DB5),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                      icon: const Icon(Icons.expand_more_rounded,
                          color: Colors.white70, size: 16),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedPeriod = v);
                          _loadStudents();
                        }
                      },
                      items: List.generate(8, (i) => i + 1)
                          .map((p) => DropdownMenuItem(value: p, child: Text('Period $p')))
                          .toList(),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(children: [
                  _HeaderChip(Icons.calendar_today_rounded, _todayDisplay),
                  const SizedBox(width: 8),
                  _HeaderChip(Icons.access_time_rounded, _nowTime()),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Class Selector ────────────────────────────────────────────────────────
  Widget _buildClassSelector() {
    return Container(
      color: const Color(0xFF1A3DB5),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F6FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Class',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
            const SizedBox(height: 10),
            Row(children: [
              // FIX: Use Flexible so chips shrink on small screens
              Flexible(
                flex: 2,
                child: _DropdownChip(
                  value: _selectedClass,
                  items: ['11th', '12th'],
                  onChanged: (v) { setState(() => _selectedClass = v!); _loadStudents(); },
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: 1,
                child: _DropdownChip(
                  value: _selectedDivision,
                  items: ['A', 'B', 'C', 'D'],
                  onChanged: (v) { setState(() => _selectedDivision = v!); _loadStudents(); },
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                flex: 3,
                child: _DropdownChip(
                  value: _selectedStream,
                  items: ['Science', 'Commerce', 'Arts'],
                  onChanged: (v) { setState(() => _selectedStream = v!); _loadStudents(); },
                ),
              ),
            ]),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Subject Selector ──────────────────────────────────────────────────────
  Widget _buildSubjectSelector() {
    if (_subjectsLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_subjects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53E3E), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No subjects for ID: "${widget.teacherID.trim()}"\n'
                    'Go to Firestore → subjects → add teacherID: "${widget.teacherID.trim()}"',
                style: const TextStyle(
                    color: Color(0xFFE53E3E), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            GestureDetector(
              onTap: _loadSubjects,
              child: const Icon(Icons.refresh_rounded, color: Color(0xFFE53E3E), size: 20),
            ),
          ]),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _subjects.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final isSelected = _selectedSubjectIndex == i;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedSubjectIndex = i);
                _loadStudents();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A3DB5) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(
                    color: isSelected
                        ? const Color(0xFF1A3DB5).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8, offset: const Offset(0, 3),
                  )],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_subjects[i]['code'] ?? '',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white70 : const Color(0xFF9098A3))),
                    const SizedBox(height: 3),
                    Text(_subjects[i]['name'] ?? '',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : const Color(0xFF0D1B4B))),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Summary Bar ───────────────────────────────────────────────────────────
  Widget _buildSummaryBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(children: [
        _StatChip('Total',   _students.length, const Color(0xFF1A3DB5), const Color(0xFFECEFF8)),
        const SizedBox(width: 8),
        _StatChip('Present', _presentCount, const Color(0xFF059669), const Color(0xFFD1FAE5)),
        const SizedBox(width: 8),
        _StatChip('Absent',  _absentCount,  const Color(0xFFE53E3E), const Color(0xFFFEE2E2)),
        const SizedBox(width: 8),
        _StatChip('Late',    _lateCount,    const Color(0xFFD97706), const Color(0xFFFFF3CD)),
      ]),
    );
  }

  // ── Search + Bulk Actions ─────────────────────────────────────────────────
  Widget _buildSearchAndActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            style: const TextStyle(fontSize: 14, color: Color(0xFF0D1B4B)),
            decoration: const InputDecoration(
              hintText: 'Search student by name or roll no…',
              hintStyle: TextStyle(color: Color(0xFF9098A3), fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF9098A3), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          const Text('Mark All:',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
          const SizedBox(width: 8),
          _BulkButton('Present', const Color(0xFF059669), const Color(0xFFD1FAE5),
                  () => _markAll(AttendanceStatus.present)),
          const SizedBox(width: 6),
          _BulkButton('Absent', const Color(0xFFE53E3E), const Color(0xFFFEE2E2),
                  () => _markAll(AttendanceStatus.absent)),
          const SizedBox(width: 6),
          _BulkButton('Reset', const Color(0xFF6B7280), const Color(0xFFF3F4F6),
                  () => _markAll(AttendanceStatus.none)),
        ]),
      ]),
    );
  }

  // ── Student List ──────────────────────────────────────────────────────────
  Widget _buildStudentList() {
    if (_studentsLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1A3DB5)));
    }
    if (_students.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.group_off_rounded, size: 56, color: Color(0xFFD1D5DB)),
          const SizedBox(height: 12),
          const Text('No students found',
              style: TextStyle(
                  color: Color(0xFF9098A3), fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text('$_selectedClass · $_selectedStream · Div $_selectedDivision',
              style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 12)),
        ]),
      );
    }
    final list = _filteredStudents;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final student = list[i];
        return _StudentTile(
          student: student,
          // FIX: Update by student ID (not list index) — works correctly during search
          onStatusChanged: (status) => setState(() {
            final idx = _students.indexWhere((s) => s.id == student.id);
            if (idx != -1) _students[idx].status = status;
          }),
        );
      },
    );
  }

  // ── Submit Bar ────────────────────────────────────────────────────────────
  Widget _buildSubmitBar() {
    final total    = _students.length;
    final progress = total == 0 ? 0.0 : _markedCount / total;
    final isEdit   = _existingSessionId != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Color(0x10000000), blurRadius: 16, offset: Offset(0, -4))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$_markedCount / $total marked',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
          if (isEdit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('EDIT MODE',
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFD97706))),
            ),
          Text('${(progress * 100).toInt()}%',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A3DB5))),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress, minHeight: 6,
            backgroundColor: const Color(0xFFECEFF8),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF1A3DB5)),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : _submitAttendance,
            icon: _submitting
                ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Icon(isEdit ? Icons.edit_rounded : Icons.check_circle_rounded, size: 20),
            label: Text(
              isEdit ? 'Update Attendance' : 'Submit Attendance',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEdit ? const Color(0xFFD97706) : const Color(0xFF1A3DB5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Student Tile ──────────────────────────────────────────────────────────────
class _StudentTile extends StatelessWidget {
  final _StudentData student;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  const _StudentTile({required this.student, required this.onStatusChanged});

  Border? _border(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return Border.all(color: const Color(0xFF059669).withOpacity(0.4), width: 1.5);
      case AttendanceStatus.absent:
        return Border.all(color: const Color(0xFFE53E3E).withOpacity(0.4), width: 1.5);
      case AttendanceStatus.late:
        return Border.all(color: const Color(0xFFD97706).withOpacity(0.4), width: 1.5);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: _border(student.status),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Avatar — slightly smaller on tiny screens
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: student.avatarColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(student.initials,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: student.avatarColor))),
        ),
        const SizedBox(width: 10),
        // Name + roll — Expanded so it takes remaining space and ellipses if needed
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(student.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D1B4B))),
          const SizedBox(height: 2),
          Text('Roll No. ${student.rollno}',
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9098A3), fontWeight: FontWeight.w500)),
        ])),
        const SizedBox(width: 6),
        // FIX: mainAxisSize.min so buttons don't try to expand and overflow
        Row(mainAxisSize: MainAxisSize.min, children: [
          _StatusBtn(Icons.check_rounded, 'Present',
              const Color(0xFF059669), const Color(0xFFD1FAE5),
              student.status == AttendanceStatus.present,
                  () => onStatusChanged(student.status == AttendanceStatus.present
                  ? AttendanceStatus.none : AttendanceStatus.present)),
          const SizedBox(width: 5),
          _StatusBtn(Icons.close_rounded, 'Absent',
              const Color(0xFFE53E3E), const Color(0xFFFEE2E2),
              student.status == AttendanceStatus.absent,
                  () => onStatusChanged(student.status == AttendanceStatus.absent
                  ? AttendanceStatus.none : AttendanceStatus.absent)),
          const SizedBox(width: 5),
          _StatusBtn(Icons.access_time_rounded, 'Late',
              const Color(0xFFD97706), const Color(0xFFFFF3CD),
              student.status == AttendanceStatus.late,
                  () => onStatusChanged(student.status == AttendanceStatus.late
                  ? AttendanceStatus.none : AttendanceStatus.late)),
        ]),
      ]),
    );
  }
}

// ─── Small Widgets ─────────────────────────────────────────────────────────────
class _StatusBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color activeColor, activeBg;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusBtn(this.icon, this.tooltip, this.activeColor,
      this.activeBg, this.isActive, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: isActive ? activeBg : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18,
          color: isActive ? activeColor : const Color(0xFFCBD5E1)),
    ),
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color, bg;

  const _StatChip(this.label, this.count, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text('$count', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: color.withOpacity(0.8))),
      ]),
    ),
  );
}

class _BulkButton extends StatelessWidget {
  final String label;
  final Color color, bg;
  final VoidCallback onTap;

  const _BulkButton(this.label, this.color, this.bg, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ),
  );
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color, bg;

  const _SummaryPill({required this.label, required this.count,
    required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Column(children: [
      Text('$count', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w900, color: color)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: color.withOpacity(0.8))),
    ]),
  );
}

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(children: [
      Icon(icon, color: Colors.white70, size: 13),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _DropdownChip extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownChip({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
    // FIX: Take full width so Flexible can size it correctly
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6, offset: const Offset(0, 2))],
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isDense: true,
        isExpanded: true, // FIX: fills the container width
        dropdownColor: Colors.white,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0D1B4B)),
        icon: const Icon(Icons.expand_more_rounded,
            color: Color(0xFF9098A3), size: 16),
        items: items.map((i) =>
            DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}