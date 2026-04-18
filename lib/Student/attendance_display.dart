import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class _SubjectAttendanceData {
  final String subjectId;
  final String name;
  int present = 0;
  int total = 0;

  _SubjectAttendanceData({
    required this.subjectId,
    required this.name,
  });

  double get percent => total == 0 ? 0 : present / total;

  Color get percentColor {
    if (percent >= 0.90) return const Color(0xFF059669);
    if (percent >= 0.75) return const Color(0xFF1A3DB5);
    return const Color(0xFFEA580C);
  }

  Color get barColor => percentColor;
}

// Rotating icon / color assignments for subjects loaded from Firestore
const _subjectIcons = [
  Icons.calculate_rounded,
  Icons.storage_rounded,
  Icons.science_rounded,
  Icons.menu_book_rounded,
  Icons.computer_rounded,
  Icons.architecture_rounded,
  Icons.language_rounded,
  Icons.analytics_rounded,
];

const _subjectIconColors = [
  Color(0xFF1A3DB5),
  Color(0xFFEA580C),
  Color(0xFF7C3AED),
  Color(0xFF059669),
  Color(0xFFEA580C),
  Color(0xFF1A3DB5),
  Color(0xFF7C3AED),
  Color(0xFF059669),
];

const _subjectIconBgs = [
  Color(0xFFECEFF8),
  Color(0xFFFFF0E8),
  Color(0xFFEDE9FE),
  Color(0xFFD1FAE5),
  Color(0xFFFFF0E8),
  Color(0xFFECEFF8),
  Color(0xFFEDE9FE),
  Color(0xFFD1FAE5),
];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AttendanceDisplayPage extends StatefulWidget {
  final String studentId;
  final String studentClass;
  final String division;
  final String stream;

  const AttendanceDisplayPage({
    super.key,
    required this.studentId,
    required this.studentClass,
    required this.division,
    required this.stream,
  });

  @override
  State<AttendanceDisplayPage> createState() => _AttendanceDisplayPageState();
}

class _AttendanceDisplayPageState extends State<AttendanceDisplayPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  bool _isLoading = true;
  List<_SubjectAttendanceData> _subjects = [];
  int _totalPresent = 0;
  int _totalClasses = 0;
  List<double> _trendData = [];
  List<String> _trendLabels = [];

  double get _overallPercent =>
      _totalClasses == 0 ? 0 : _totalPresent / _totalClasses;

  String get _standingText {
    if (_overallPercent >= 0.90) return 'Excellent Standing';
    if (_overallPercent >= 0.75) return 'Good Standing';
    if (_overallPercent >= 0.60) return 'Average Standing';
    return 'Low Attendance';
  }

  Color get _standingBadgeColor {
    if (_overallPercent >= 0.75) return const Color(0xFF059669);
    if (_overallPercent >= 0.60) return const Color(0xFFD97706);
    return const Color(0xFFE53E3E);
  }

  Color get _standingBadgeBg {
    if (_overallPercent >= 0.75) return const Color(0xFFD1FAE5);
    if (_overallPercent >= 0.60) return const Color(0xFFFFF3CD);
    return const Color(0xFFFEE2E2);
  }

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _arcAnimation = CurvedAnimation(
      parent: _arcController,
      curve: Curves.easeOutCubic,
    );
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  // ── Fetch attendance from Firestore ────────────────────────────────────────
  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);

    try {
      // 1. Fetch all attendance session documents
      final attendanceSnap =
      await FirebaseFirestore.instance.collection('attendance').get();

      // 2. Filter by this student's class / division / stream (in Dart to
      //    avoid composite-index requirement)
      final matchingSessions = attendanceSnap.docs.where((doc) {
        final d = doc.data();
        return d['standard'] == widget.studentClass &&
            d['division'] == widget.division &&
            (d['stream'] as String? ?? '').toLowerCase() ==
                widget.stream.toLowerCase();
      }).toList();

      if (matchingSessions.isEmpty) {
        setState(() {
          _isLoading = false;
          _subjects = [];
          _totalPresent = 0;
          _totalClasses = 0;
          _trendData = List.filled(6, 0);
          _trendLabels = _buildMonthLabels();
        });
        _arcController.forward();
        return;
      }

      // 3. Fetch the records sub-document for every matching session in parallel
      final recordFutures = matchingSessions.map((doc) async {
        final recSnap = await FirebaseFirestore.instance
            .collection('attendance')
            .doc(doc.id)
            .collection('records')
            .doc('studentID')
            .get();
        return MapEntry(doc, recSnap);
      });

      final results = await Future.wait(recordFutures);

      // 4. Aggregate by subject & collect monthly data
      final subjectMap = <String, _SubjectAttendanceData>{};
      final monthlyPresent = <String, int>{};
      final monthlyTotal = <String, int>{};
      int totalPresent = 0;
      int totalClasses = 0;

      for (final entry in results) {
        final doc = entry.key;
        final recSnap = entry.value;
        final data = doc.data();

        final subjectId = (data['subjectID'] ?? '').toString();
        final subjectName = (data['subjectName'] ?? 'Unknown').toString();
        final dateStr = (data['date'] ?? '').toString(); // "DD-MM-YYYY"

        // ── Per-subject aggregation ──
        subjectMap.putIfAbsent(
          subjectId,
              () => _SubjectAttendanceData(
            subjectId: subjectId,
            name: subjectName,
          ),
        );
        subjectMap[subjectId]!.total++;
        totalClasses++;

        // Check student presence in the records map
        // FIX: Records stored as strings "present"/"absent"/"late"
        // Also supports old bool format for backward compatibility
        bool isPresent = false;
        if (recSnap.exists) {
          final recs = recSnap.data();
          if (recs != null) {
            final val = recs[widget.studentId];
            isPresent = val == 'present' || val == 'late' || val == true;
          }
        }

        if (isPresent) {
          subjectMap[subjectId]!.present++;
          totalPresent++;
        }

        // ── Monthly trend aggregation ──
        if (dateStr.contains('-')) {
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            final monthKey = '${parts[1]}-${parts[2]}'; // "MM-YYYY"
            monthlyTotal[monthKey] = (monthlyTotal[monthKey] ?? 0) + 1;
            if (isPresent) {
              monthlyPresent[monthKey] = (monthlyPresent[monthKey] ?? 0) + 1;
            }
          }
        }
      }

      // 5. Build trend data for the last 6 months
      final now = DateTime.now();
      final trendData = <double>[];
      final trendLabels = <String>[];
      const monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final key =
            '${month.month.toString().padLeft(2, '0')}-${month.year}';
        final total = monthlyTotal[key] ?? 0;
        final present = monthlyPresent[key] ?? 0;
        final pct = total > 0 ? (present / total * 100) : 0.0;
        trendData.add(pct);
        trendLabels.add(monthNames[month.month - 1]);
      }

      setState(() {
        _subjects = subjectMap.values.toList()
          ..sort((a, b) => a.name.compareTo(b.name));
        _totalPresent = totalPresent;
        _totalClasses = totalClasses;
        _trendData = trendData;
        _trendLabels = trendLabels;
        _isLoading = false;
      });

      _arcController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading attendance: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  List<String> _buildMonthLabels() {
    final now = DateTime.now();
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - (5 - i), 1);
      return m[month.month - 1];
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A3DB5),
              ),
            )
                : RefreshIndicator(
              color: const Color(0xFF1A3DB5),
              onRefresh: _loadAttendanceData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCircularSection(),
                    const SizedBox(height: 24),
                    _buildSubjectBreakdown(),
                    const SizedBox(height: 24),
                    if (_trendData.isNotEmpty) _buildAttendanceTrend(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
              const Expanded(
                child: Text(
                  'Attendance',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _loadAttendanceData,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Circular Indicator Section ──────────────────────────────────────────────
  Widget _buildCircularSection() {
    final totalMissed = _totalClasses - _totalPresent;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A3DB5),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F6FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: _totalClasses == 0
            ? _buildEmptyState()
            : Column(
          children: [
            AnimatedBuilder(
              animation: _arcAnimation,
              builder: (_, _) => CustomPaint(
                size: const Size(180, 180),
                painter: _ArcPainter(
                  progress: _arcAnimation.value * _overallPercent,
                ),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(_arcAnimation.value * _overallPercent * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0D1B4B),
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PRESENT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9098A3),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _standingText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0D1B4B),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _standingBadgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _overallPercent >= 0.75
                    ? 'Safe Zone – above 75%'
                    : 'Below 75% – attend more classes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _standingBadgeColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Mini stat row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniStat(
                    label: 'Classes\nAttended',
                    value: '$_totalPresent',
                    color: const Color(0xFF059669),
                  ),
                  Container(
                      width: 1,
                      height: 36,
                      color: const Color(0xFFE5E7EB)),
                  _MiniStat(
                    label: 'Classes\nMissed',
                    value: '$totalMissed',
                    color: const Color(0xFFEA580C),
                  ),
                  Container(
                      width: 1,
                      height: 36,
                      color: const Color(0xFFE5E7EB)),
                  _MiniStat(
                    label: 'Total\nClasses',
                    value: '$_totalClasses',
                    color: const Color(0xFF1A3DB5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFECEFF8),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_busy_rounded,
                color: Color(0xFF9098A3), size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Attendance Records Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0D1B4B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Attendance will appear here once your\nteacher marks it',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF9098A3),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Subject Breakdown ───────────────────────────────────────────────────────
  Widget _buildSubjectBreakdown() {
    if (_subjects.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subject Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D1B4B),
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_subjects.length} Subjects',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3DB5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(_subjects.length, (i) {
            final s = _subjects[i];
            final idx = i % _subjectIcons.length;
            return _SubjectCard(
              subject: s,
              icon: _subjectIcons[idx],
              iconColor: _subjectIconColors[idx],
              iconBg: _subjectIconBgs[idx],
            );
          }),
        ],
      ),
    );
  }

  // ── Attendance Trend ────────────────────────────────────────────────────────
  Widget _buildAttendanceTrend() {
    // Only show trend if there is at least some data
    final hasData = _trendData.any((v) => v > 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D1B4B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: hasData
                ? SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _LinechartPainter(
                  data: _trendData,
                  labels: _trendLabels,
                ),
              ),
            )
                : SizedBox(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.show_chart_rounded,
                        color: const Color(0xFFD1D5DB), size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Trend data will appear after\na few weeks of attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9098A3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subject Card ─────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  final _SubjectAttendanceData subject;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _SubjectCard({
    required this.subject,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D1B4B),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${subject.present}/${subject.total} lectures attended',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9098A3),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(subject.percent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: subject.percentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: subject.percent,
              minHeight: 7,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(subject.barColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Present: ${subject.present}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9098A3),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Absent: ${subject.total - subject.present}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9098A3),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Total: ${subject.total}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9098A3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Mini Stat ────────────────────────────────────────────────────────────────

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9098A3),
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ─── Arc Painter ──────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  const _ArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const strokeWidth = 14.0;

    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFFE8ECF8)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1A3DB5), Color(0xFF4A70E8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ─── Line Chart Painter ───────────────────────────────────────────────────────

class _LinechartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;

  const _LinechartPainter({required this.data, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 36.0;
    const bottomPad = 28.0;
    const topPad = 10.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad - topPad;

    // Dynamic min / max with sensible defaults
    final rawMin = data.reduce(min);
    final rawMax = data.reduce(max);
    final minVal = (rawMin - 10).clamp(0.0, 90.0);
    final maxVal = (rawMax + 10).clamp(minVal + 10, 100.0);

    // Grid lines + y labels
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final range = maxVal - minVal;
    final ySteps = [0.0, 0.33, 0.66, 1.0];
    for (final frac in ySteps) {
      final y = minVal + range * frac;
      final dy = topPad + chartH * (1 - frac);
      canvas.drawLine(
        Offset(leftPad, dy),
        Offset(size.width, dy),
        gridPaint,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: y.toInt().toString(),
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9098A3),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, dy - 6));
    }

    // X labels
    final step = data.length > 1 ? chartW / (data.length - 1) : chartW;
    for (int i = 0; i < labels.length; i++) {
      final dx = leftPad + i * step;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9098A3),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(dx - tp.width / 2, size.height - 18));
    }

    // Points
    final points = List.generate(data.length, (i) {
      final dx = leftPad + i * step;
      final dy =
          topPad + chartH * (1 - (data[i] - minVal) / (maxVal - minVal));
      return Offset(dx, dy);
    });

    if (points.length < 2) return;

    // Fill under line
    final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      fillPath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points.last.dx, topPad + chartH);
    fillPath.lineTo(points.first.dx, topPad + chartH);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF1A3DB5).withValues(alpha: 0.18),
            const Color(0xFF1A3DB5).withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(
          Rect.fromLTWH(leftPad, topPad, chartW, chartH),
        )
        ..style = PaintingStyle.fill,
    );

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF4A70E8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final cp1 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset(
          (points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      linePath.cubicTo(
          cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    for (final p in points) {
      canvas.drawCircle(
          p,
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          p,
          5,
          Paint()
            ..color = const Color(0xFF1A3DB5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
    }
  }

  @override
  bool shouldRepaint(_LinechartPainter old) => true;
}