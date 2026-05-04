import 'package:flutter/material.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  static const _filters = ['Все', 'Боулдеринг', 'Трудность', 'Силовая', 'Фингерборд', 'Восстановление'];

  static const _entries = [
    _DiaryEntry(
      dayLabel: 'СЕГОДНЯ',
      type: 'Боулдеринг',
      detail: '2ч 15мин',
      intensity: 'Интенсивность 8/10',
      noteLabel: 'Состояние кожи',
      noteText: '«Пролез проект 7А»',
      icon: Icons.terrain_rounded,
    ),
    _DiaryEntry(
      dayLabel: 'ВЧЕРА',
      type: 'Фингерборд',
      detail: 'Repeaters 7/3',
      intensity: 'Интенсивность 9/10',
      noteLabel: 'Усталость ЦНС',
      noteText: null,
      icon: Icons.back_hand_rounded,
    ),
    _DiaryEntry(
      dayLabel: '12 ОКТ',
      type: 'Растяжка',
      detail: '30 мин',
      intensity: 'Восстановление',
      noteLabel: null,
      noteText: null,
      icon: Icons.self_improvement_rounded,
    ),
  ];

  String _selectedFilter = _filters.first;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        Text(
          'Дневник тренировок',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.08),
        ),
        const SizedBox(height: 8),
        Text(
          'Отслеживайте свой прогресс и интенсивность.',
          style: textTheme.bodyMedium?.copyWith(
            color: const Color(0xFFF6F1E8).withValues(alpha: 0.75),
            height: 1.25,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final selected = filter == _selectedFilter;
              return ChoiceChip(
                label: Text(filter),
                selected: selected,
                onSelected: (_) => setState(() => _selectedFilter = filter),
                labelStyle: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? const Color(0xFF1A1D20) : const Color(0xFFF6F1E8).withValues(alpha: 0.82),
                ),
                side: BorderSide(color: accent.withValues(alpha: selected ? 0 : 0.35)),
                backgroundColor: const Color(0xFF252A2F),
                selectedColor: accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        for (final entry in _entries) ...[
          _WorkoutEntryCard(entry: entry),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _WorkoutEntryCard extends StatelessWidget {
  const _WorkoutEntryCard({required this.entry});

  final _DiaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(entry.icon, size: 15, color: accent.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(
                entry.dayLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: accent.withValues(alpha: 0.88),
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(entry.type, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.05)),
          const SizedBox(height: 3),
          Text(
            entry.detail,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFF6F1E8).withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          _MetaRow(icon: Icons.whatshot_rounded, text: entry.intensity),
          if (entry.noteLabel != null) ...[
            const SizedBox(height: 6),
            _MetaRow(icon: Icons.monitor_heart_outlined, text: entry.noteLabel!),
          ],
          if (entry.noteText != null) ...[
            const SizedBox(height: 8),
            Text(
              entry.noteText!,
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFFF6F1E8).withValues(alpha: 0.74),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFE0B74A).withValues(alpha: 0.88)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFF6F1E8).withValues(alpha: 0.86),
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DiaryEntry {
  const _DiaryEntry({
    required this.dayLabel,
    required this.type,
    required this.detail,
    required this.intensity,
    required this.noteLabel,
    required this.noteText,
    required this.icon,
  });

  final String dayLabel;
  final String type;
  final String detail;
  final String intensity;
  final String? noteLabel;
  final String? noteText;
  final IconData icon;
}
