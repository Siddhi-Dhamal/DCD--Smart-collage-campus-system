import 'dart:math';
import 'package:flutter/material.dart';

// ─── Data ─────────────────────────────────────────────────────────────────────

class SubjectAttendance {
  final String name;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final int present;
  final int total;

  const SubjectAttendance({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.present,
    required this.total,
  });

  double get percent => present / total;

  Color get percentColor {
    if (percent >= 0.90) return const Color(0xFF059669);
    if (percent >= 0.75) return const Color(0xFF1A3DB5);
    return const Color(0xFFEA580C);
  }

  Color get barColor {
    if (percent >= 0.90) return const Color(0xFF059669);
    if (percent >= 0.75) return const Color(0xFF1A3DB5);
    return const Color(0xFFEA580C);
  }
}

const _subjects = [
  SubjectAttendance(
    name: 'Mathematics',
    icon: Icons.calculate_rounded,
    iconColor: Color(0xFF1A3DB5),
    iconBg: Color(0xFFECEFF8),
    present: 17,
    total: 20,
  ),
  SubjectAttendance(
    name: 'Data Structures',
    icon: Icons.storage_rounded,
    iconColor: Color(0xFFEA580C),
    iconBg: Color(0xFFFFF0E8),
    present: 13,
    total: 21,
  ),
  SubjectAttendance(
    name: 'Physics Lab',
    icon: Icons.science_rounded,
    iconColor: Color(0xFF7C3AED),
    iconBg: Color(0xFFEDE9FE),
    present: 15,
    total: 16,
  ),
  SubjectAttendance(
    name: 'English',
    icon: Icons.menu_book_rounded,
    iconColor: Color(0xFF059669),
    iconBg: Color(0xFFD1FAE5),
    present: 38,
    total: 40,
  ),
  SubjectAttendance(
    name: 'Computer Science',
    icon: Icons.computer_rounded,
    iconColor: Color(0xFFEA580C),
    iconBg: Color(0xFFFFF0E8),
    present: 32,
    total: 44,
  ),
];

const _trendData = [82.0, 85.0, 84.0, 87.0, 88.0, 86.0];
const _trendLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

// ─── Page ─────────────────────────────────────────────────────────────────────

class AttendanceDisplayPage extends StatefulWidget {
  const AttendanceDisplayPage({super.key});

  @override
  State<AttendanceDisplayPage> createState() => _AttendanceDisplayPageState();
}

class _AttendanceDisplayPageState extends State<AttendanceDisplayPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  final double _overallPercent = 0.82;

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
    _arcController.forward();
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCircularSection(),
                  const SizedBox(height: 24),
                  _buildSubjectBreakdown(),
                  const SizedBox(height: 24),
                  _buildAttendanceTrend(),
                  const SizedBox(height: 28),
                ],
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
                    color: Colors.white.withOpacity(0.15),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Circular Indicator Section ──────────────────────────────────────────────
  Widget _buildCircularSection() {
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
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _arcAnimation,
              builder: (_, __) => CustomPaint(
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
            const Text(
              'Good Standing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0D1B4B),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You need 75% for exam eligibility',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9098A3),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            // Mini stat row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniStat(label: 'Classes\nAttended', value: '74', color: const Color(0xFF059669)),
                  Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                  _MiniStat(label: 'Classes\nMissed', value: '16', color: const Color(0xFFEA580C)),
                  Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
                  _MiniStat(label: 'Total\nClasses', value: '90', color: const Color(0xFF1A3DB5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Subject Breakdown ───────────────────────────────────────────────────────
  Widget _buildSubjectBreakdown() {
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECEFF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Semester 4',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3DB5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._subjects.map((s) => _SubjectCard(subject: s)),
        ],
      ),
    );
  }

  // ── Attendance Trend ────────────────────────────────────────────────────────
  Widget _buildAttendanceTrend() {
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
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _LinechartPainter(
                  data: _trendData,
                  labels: _trendLabels,
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
  final SubjectAttendance subject;
  const _SubjectCard({required this.subject});

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
            color: Colors.black.withOpacity(0.05),
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
                  color: subject.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(subject.icon, color: subject.iconColor, size: 22),
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

    const minVal = 70.0;
    const maxVal = 100.0;

    // Grid lines + y labels
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final yValues = [70.0, 78.0, 86.0, 100.0];
    for (final y in yValues) {
      final dy =
          topPad + chartH * (1 - (y - minVal) / (maxVal - minVal));
      canvas.drawLine(
        Offset(leftPad, dy),
        Offset(size.width, dy),
        gridPaint..color = const Color(0xFFE5E7EB),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: y.toInt().toString(),
          style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9098A3),
              fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, dy - 6));
    }

    // X labels
    final step = chartW / (data.length - 1);
    for (int i = 0; i < labels.length; i++) {
      final dx = leftPad + i * step;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9098A3),
              fontWeight: FontWeight.w600),
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
            const Color(0xFF1A3DB5).withOpacity(0.18),
            const Color(0xFF1A3DB5).withOpacity(0.0),
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
  bool shouldRepaint(_LinechartPainter old) => false;
}