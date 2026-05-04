// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _records = [
    _RecordItem('Max Hang', '20мм edge, 10с', '+25 кг', Icons.fitness_center_rounded),
    _RecordItem('Max Volume', 'Перехватов за сессию', '340', Icons.stacked_line_chart_rounded),
    _RecordItem('Hardest Boulder', 'Проект завершён', '7b+', Icons.star_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
      children: [
        Text(
          'Аналитика',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 28,
                height: 1.05,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Сила, объём и прогресс категорий.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xB3F6F1E8),
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 14),
        const _PeriodTabs(),
        const SizedBox(height: 14),
        const _ReadinessAnalyticsCard(),
        const SizedBox(height: 12),
        const _FingerStrengthCard(),
        const SizedBox(height: 12),
        const _VolumeCard(),
        const SizedBox(height: 12),
        const _GradeProgressCard(),
        const SizedBox(height: 12),
        _RecordsCard(records: _records),
      ],
    );
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs();

  @override
  Widget build(BuildContext context) {
    const tabs = ['Неделя', 'Месяц', 'Год'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x224C5560)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Expanded(
              child: Container(
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == 1 ? const Color(0xFF3A3545) : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: i == 1 ? const Color(0xFFDCC6FF) : const Color(0x99F6F1E8),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReadinessAnalyticsCard extends StatelessWidget {
  const _ReadinessAnalyticsCard();

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(label: 'ВОССТАНОВЛЕНИЕ', icon: Icons.bolt_rounded),
          const SizedBox(height: 5),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '84%',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: '  готовность',
                  style: TextStyle(
                    color: Color(0x80F6F1E8),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 86,
            width: double.infinity,
            child: CustomPaint(painter: _ReadinessCurvePainter()),
          ),
        ],
      ),
    );
  }
}

class _FingerStrengthCard extends StatelessWidget {
  const _FingerStrengthCard();

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(label: 'СИЛА ПАЛЬЦЕВ', icon: Icons.back_hand_rounded, iconColor: Color(0xFFC7B7FF)),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '+2.5 ',
                  style: TextStyle(color: Color(0xFFDCCBFF), fontSize: 26, fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: 'кг  ',
                  style: TextStyle(color: Color(0xFFDCCBFF), fontSize: 17, fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: '(Max Hang)',
                  style: TextStyle(color: Color(0x80F6F1E8), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 78,
            width: double.infinity,
            child: CustomPaint(painter: _StrengthLinePainter()),
          ),
        ],
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  const _VolumeCard();

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(label: 'ОБЪЁМ', icon: Icons.fitness_center_rounded),
          const SizedBox(height: 5),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: '14',
                  style: TextStyle(color: Color(0xFFEDE6FF), fontSize: 30, fontWeight: FontWeight.w900, height: 1),
                ),
                TextSpan(
                  text: ' часов тренировок',
                  style: TextStyle(color: Color(0x80F6F1E8), fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(height: 98, width: double.infinity, child: CustomPaint(painter: _VolumeBarsPainter())),
        ],
      ),
    );
  }
}

class _GradeProgressCard extends StatelessWidget {
  const _GradeProgressCard();

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Прогресс категорий',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              const Icon(Icons.trending_up_rounded, color: Color(0xFFD4AF37), size: 20),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3036),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x164C5560)),
            ),
            child: Row(
              children: const [
                Expanded(child: _GradeColumn(label: 'Старт месяца', grade: '6b')),
                Icon(Icons.arrow_forward_rounded, color: Color(0x55F6F1E8), size: 22),
                Expanded(child: _GradeColumn(label: 'Текущий', grade: '7a', alignRight: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeColumn extends StatelessWidget {
  const _GradeColumn({required this.label, required this.grade, this.alignRight = false});

  final String label;
  final String grade;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0x80F6F1E8), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3545),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            grade,
            style: const TextStyle(color: Color(0xFFDCCBFF), fontSize: 13, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _RecordsCard extends StatelessWidget {
  const _RecordsCard({required this.records});

  final List<_RecordItem> records;

  @override
  Widget build(BuildContext context) {
    return _AnalyticsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Рекорды', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (var i = 0; i < records.length; i++) ...[
            _RecordRow(item: records[i]),
            if (i != records.length - 1) const SizedBox(height: 13),
          ],
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.item});

  final _RecordItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3545),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(item.icon, color: const Color(0xFFDCCBFF), size: 18),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(item.subtitle, style: const TextStyle(color: Color(0x80F6F1E8), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Text(item.value, style: const TextStyle(color: Color(0xFFDCCBFF), fontSize: 17, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x164C5560), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Color(0x16000000), blurRadius: 14, offset: Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.label, required this.icon, this.iconColor = const Color(0xFFD4AF37)});

  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.3),
        ),
        const Spacer(),
        Icon(icon, color: iconColor, size: 18),
      ],
    );
  }
}

class _ReadinessCurvePainter extends CustomPainter {
  const _ReadinessCurvePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final accent = const Color(0xFFD4AF37);
    final path = Path()
      ..moveTo(0, size.height * 0.56)
      ..cubicTo(size.width * 0.2, size.height * 0.72, size.width * 0.28, size.height * 0.22, size.width * 0.45, size.height * 0.34)
      ..cubicTo(size.width * 0.63, size.height * 0.48, size.width * 0.67, size.height * 0.86, size.width * 0.8, size.height * 0.62)
      ..cubicTo(size.width * 0.9, size.height * 0.4, size.width * 0.92, size.height * 0.18, size.width, size.height * 0.26);

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accent.withValues(alpha: 0.24), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ReadinessCurvePainter oldDelegate) => false;
}

class _StrengthLinePainter extends CustomPainter {
  const _StrengthLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final color = const Color(0xFFC7B7FF);
    final points = [
      Offset(0, size.height * 0.82),
      Offset(size.width * 0.18, size.height * 0.72),
      Offset(size.width * 0.38, size.height * 0.56),
      Offset(size.width * 0.62, size.height * 0.32),
      Offset(size.width * 0.88, size.height * 0.14),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      path.cubicTo((p0.dx + p1.dx) / 2, p0.dy, (p0.dx + p1.dx) / 2, p1.dy, p1.dx, p1.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(points.last, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _StrengthLinePainter oldDelegate) => false;
}

class _VolumeBarsPainter extends CustomPainter {
  const _VolumeBarsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final values = [0.42, 0.54, 0.34, 0.66, 0.86, 0.48, 0.98];
    final barWidth = size.width / (values.length * 1.75);
    final gap = (size.width - barWidth * values.length) / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final height = size.height * values[i];
      final left = i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - height, barWidth, height),
        const Radius.circular(4),
      );
      final isLast = i == values.length - 1;
      canvas.drawRRect(rect, Paint()..color = isLast ? const Color(0xFFC7B7FF) : const Color(0x33F6F1E8));
    }
  }

  @override
  bool shouldRepaint(covariant _VolumeBarsPainter oldDelegate) => false;
}

class _RecordItem {
  const _RecordItem(this.title, this.subtitle, this.value, this.icon);

  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
}
