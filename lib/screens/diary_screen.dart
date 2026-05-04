import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const filters = ['Все', 'Боулдеринг', 'Трудность', 'ОФП', 'Фингерборд', 'Заметки'];
    const workouts = [
      _WorkoutEntry(
        date: '12 мая 2026',
        type: 'Трудность · Скалодром «Вектор»',
        detail: '8 трасс, акцент на технику ног и длинные перехваты.',
        meta: 'Самочувствие: бодрое',
        durationBadge: '2ч 15мин',
      ),
      _WorkoutEntry(
        date: '10 мая 2026',
        type: 'Фингерборд · Интервалы',
        detail: 'Протокол Repeaters, 6 подходов по 7/3.',
        meta: 'Нагрузка: средняя',
        durationBadge: 'Repeaters 7/3',
      ),
      _WorkoutEntry(
        date: '8 мая 2026',
        type: 'ОФП · Домашняя сессия',
        detail: 'Кор и мобилити, работа на стабилизацию плеч.',
        meta: 'Пульс: ровный',
        durationBadge: '30 мин',
      ),
      _WorkoutEntry(
        date: '6 мая 2026',
        type: 'Боулдеринг · Зал «Куб»',
        detail: 'Проекты V4–V5, прогресс на силовых стартах.',
        meta: 'Комментарии: добавить видео разбора',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        const Text(
          'Тренировочный дневник',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Лента тренировок и заметок по самочувствию.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xB3F6F1E8)),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 20),
            itemBuilder: (context, index) => _FilterChip(label: filters[index], isSelected: index == 0),
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: filters.length,
          ),
        ),
        const SizedBox(height: 14),
        ...workouts.map(_WorkoutCard.new),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    const selectedGradient = LinearGradient(
      colors: [Color(0xFFE9C86D), Color(0xFFD4AF37)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: isSelected ? selectedGradient : null,
        color: isSelected ? null : const Color(0xFF2A2F34),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? const Color(0xFFF3D785) : const Color(0x334C5560)),
        boxShadow: isSelected
            ? const [
                BoxShadow(color: Color(0x40D4AF37), blurRadius: 12, offset: Offset(0, 4)),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? const Color(0xFF1F2226) : const Color(0xFFF6F1E8),
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard(this.entry);

  final _WorkoutEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF262B30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x334C5560)),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.date,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFF6F1E8)),
                ),
              ),
              if (entry.durationBadge != null) _DurationBadge(label: entry.durationBadge!),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            entry.type,
            style: const TextStyle(fontSize: 13.2, fontWeight: FontWeight.w600, color: Color(0xFFD9D5CD)),
          ),
          const SizedBox(height: 6),
          Text(
            entry.detail,
            style: const TextStyle(fontSize: 13, height: 1.3, color: Color(0xCFF6F1E8)),
          ),
          const SizedBox(height: 7),
          Text(
            entry.meta,
            style: const TextStyle(fontSize: 12.5, color: Color(0x99F6F1E8)),
          ),
        ],
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x1FD4AF37),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x5CD4AF37)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFECCB75)),
      ),
    );
  }
}

class _WorkoutEntry {
  const _WorkoutEntry({
    required this.date,
    required this.type,
    required this.detail,
    required this.meta,
    this.durationBadge,
  });

  final String date;
  final String type;
  final String detail;
  final String meta;
  final String? durationBadge;
}
