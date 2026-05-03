import 'package:flutter/material.dart';

import '../components/buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _metrics = [
    _MetricItem('Последняя', 'Боулдеринг, 2ч назад'),
    _MetricItem('Сила пальцев', '+5% за месяц'),
    _MetricItem('Объём недели', '12.5к кг'),
    _MetricItem('Цель месяца', '85%'),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        Text(
          '3 мая, воскресенье',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.72),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Привет, Алекс',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        _ReadinessCard(accent: colorScheme.primary),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) => _DashboardMetricCard(item: _metrics[index]),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: '+ Новая тренировка', onPressed: () {}),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сегодня',
                  style: textTheme.bodySmall?.copyWith(
                    color: accent.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Твоё тело готово к нагрузкам',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.12),
              border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Center(
              child: Text(
                '80',
                style: textTheme.headlineSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.label,
            style: textTheme.bodySmall?.copyWith(color: const Color(0xFFEDE6D8).withValues(alpha: 0.72)),
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem(this.label, this.value);

  final String label;
  final String value;
}
