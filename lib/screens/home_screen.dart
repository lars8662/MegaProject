import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _metrics = [
    _MetricItem('Последняя', 'Боулдеринг, 2ч назад', Icons.history_rounded),
    _MetricItem('Сила пальцев', '+5% за месяц', Icons.back_hand_rounded),
    _MetricItem('Объём недели', '12.5к кг', Icons.stacked_line_chart_rounded),
    _MetricItem('Цель месяца', '85%', Icons.flag_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      children: [
        Text(
          '3 мая, воскресенье',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.68),
            letterSpacing: 0.18,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Привет, Алекс',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 26,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        _ReadinessCard(accent: colorScheme.primary),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
          ),
          itemBuilder: (context, index) => _DashboardMetricCard(item: _metrics[index]),
        ),
        const SizedBox(height: 12),
        PrimaryButton(label: '+ Новая тренировка', onPressed: () => context.push('/new-training')),
      ],
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сегодня',
                  style: textTheme.labelMedium?.copyWith(
                    color: accent.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Твоё тело готово к нагрузкам',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _ReadinessRing(accent: accent),
        ],
      ),
    );
  }
}

class _ReadinessRing extends StatelessWidget {
  const _ReadinessRing({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 58,
      width: 58,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 0.8,
            strokeWidth: 5,
            backgroundColor: accent.withValues(alpha: 0.16),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
          Center(
            child: Text(
              '80',
              style: textTheme.titleMedium?.copyWith(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 16, color: accent.withValues(alpha: 0.88)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  style: textTheme.labelMedium?.copyWith(color: const Color(0xFFEDE6D8).withValues(alpha: 0.74)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, height: 1.15),
          ),
          const SizedBox(height: 7),
          if (item.label == 'Сила пальцев') _MiniTrendLine(accent: accent),
          if (item.label == 'Цель месяца') _GoalProgress(accent: accent),
        ],
      ),
    );
  }
}

class _MiniTrendLine extends StatelessWidget {
  const _MiniTrendLine({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      width: double.infinity,
      child: CustomPaint(painter: _TrendPainter(accent: accent)),
    );
  }
}

class _GoalProgress extends StatelessWidget {
  const _GoalProgress({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: 0.85,
        minHeight: 6,
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        valueColor: AlwaysStoppedAnimation<Color>(accent),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.78),
      Offset(size.width * 0.22, size.height * 0.62),
      Offset(size.width * 0.45, size.height * 0.68),
      Offset(size.width * 0.67, size.height * 0.4),
      Offset(size.width * 0.92, size.height * 0.2),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final c1 = Offset((p0.dx + p1.dx) / 2, p0.dy);
      final c2 = Offset((p0.dx + p1.dx) / 2, p1.dy);
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p1.dx, p1.dy);
    }

    final linePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [accent.withValues(alpha: 0.2), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);

    canvas.drawCircle(points.last, 2.8, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) => oldDelegate.accent != accent;
}

class _MetricItem {
  const _MetricItem(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}
