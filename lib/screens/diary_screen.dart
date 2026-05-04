import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  static const _filters = ['Все', 'Боулдеринг', 'Трудность', 'ОФП'];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 4, 16, 96 + bottomInset),
      children: [
        Text(
          'Тренировочный дневник',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        _PremiumSummaryCard(accent: colorScheme.primary),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filters
              .map(
                (filter) => Chip(
                  label: Text(filter),
                  backgroundColor: filter == 'Все' ? colorScheme.primary.withValues(alpha: 0.18) : const Color(0xFF252A2F),
                  side: BorderSide(
                    color: filter == 'Все' ? colorScheme.primary.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.08),
                  ),
                  labelStyle: textTheme.labelMedium?.copyWith(
                    color: filter == 'Все' ? colorScheme.primary : const Color(0xFFF6F1E8),
                    fontWeight: FontWeight.w600,
                  ),
                  visualDensity: const VisualDensity(horizontal: -1, vertical: -2),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        ...const [
          _WorkoutCard(
            title: 'Боулдеринг · V5–V6',
            date: '3 мая, воскресенье',
            duration: '1ч 45м',
            badge: 'Прогресс',
            badgeColor: Color(0xFF7BD88F),
          ),
          SizedBox(height: 10),
          _WorkoutCard(
            title: 'Силовая ОФП',
            date: '1 мая, пятница',
            duration: '55м',
            badge: 'Восстановление',
            badgeColor: Color(0xFF81B7FF),
          ),
          SizedBox(height: 10),
          _WorkoutCard(
            title: 'Трудность · 6b+',
            date: '29 апреля, вторник',
            duration: '2ч 10м',
            badge: 'Тяжело',
            badgeColor: Color(0xFFFFB86B),
          ),
        ],
      ],
    );
  }
}

class _PremiumSummaryCard extends StatelessWidget {
  const _PremiumSummaryCard({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A3036), Color(0xFF23282E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Премиум-аналитика',
                  style: textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '4 тренировки за неделю, объём +12%',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: accent.withValues(alpha: 0.14),
            ),
            child: Text('PRO', style: textTheme.labelLarge?.copyWith(color: accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.title,
    required this.date,
    required this.duration,
    required this.badge,
    required this.badgeColor,
  });

  final String title;
  final String date;
  final String duration;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.17),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: textTheme.labelSmall?.copyWith(color: badgeColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(date, style: textTheme.bodyMedium?.copyWith(color: const Color(0xFFF6F1E8).withValues(alpha: 0.74))),
          const SizedBox(height: 4),
          Text('Длительность: $duration', style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
