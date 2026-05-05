import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/training_session.dart';
import '../state/training_sessions_provider.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  static const _filters = ['Все', 'Боулдеринг', 'Трудность', 'ОФП', 'Фингерборд', 'Силовая', 'Восстановление'];

  String _selectedFilter = 'Все';

  @override
  Widget build(BuildContext context) {
    final savedSessions = ref.watch(trainingSessionsProvider);
    final filteredSessions = _filteredSessions(savedSessions);
    final filteredEntries = filteredSessions.map(_WorkoutEntry.fromSession).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Тренировочный дневник',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6),
                  _DiarySubtitle(),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _AddTrainingButton(onTap: () => context.push('/new-training')),
          ],
        ),
        if (savedSessions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _countLabel(totalCount: savedSessions.length, visibleCount: filteredSessions.length, filter: _selectedFilter),
            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 20),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              return _FilterChip(
                label: filter,
                isSelected: filter == _selectedFilter,
                onTap: () => setState(() => _selectedFilter = filter),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: _filters.length,
          ),
        ),
        const SizedBox(height: 14),
        if (savedSessions.isEmpty)
          _EmptyDiaryCard(onTap: () => context.push('/new-training'))
        else if (filteredEntries.isEmpty)
          _EmptyFilterCard(filter: _selectedFilter, onReset: () => setState(() => _selectedFilter = 'Все'))
        else
          ...filteredEntries.map(_WorkoutCard.new),
      ],
    );
  }

  List<TrainingSession> _filteredSessions(List<TrainingSession> sessions) {
    if (_selectedFilter == 'Все') {
      return sessions;
    }

    return sessions.where((session) => session.type == _selectedFilter).toList(growable: false);
  }

  static String _countLabel({required int totalCount, required int visibleCount, required String filter}) {
    if (filter == 'Все') {
      return _savedCountLabel(totalCount);
    }

    if (visibleCount == 0) {
      return 'Нет записей: $filter';
    }

    return '${_savedCountLabel(visibleCount)} · $filter';
  }

  static String _savedCountLabel(int count) {
    if (count == 1) {
      return '1 тренировка добавлена';
    }

    if (count >= 2 && count <= 4) {
      return '$count тренировки добавлены';
    }

    return '$count тренировок добавлено';
  }
}

class _DiarySubtitle extends ConsumerWidget {
  const _DiarySubtitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedSessions = ref.watch(trainingSessionsProvider);

    return Text(
      savedSessions.isEmpty ? 'Создайте первую запись, чтобы начать отслеживать прогресс.' : 'Фильтруйте записи по типу тренировки.',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xB3F6F1E8)),
    );
  }
}

class _AddTrainingButton extends StatelessWidget {
  const _AddTrainingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x30D4AF37), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Color(0xFF1A1D20), size: 26),
      ),
    );
  }
}

class _EmptyDiaryCard extends StatelessWidget {
  const _EmptyDiaryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0x1FD4AF37),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_task_rounded, color: Color(0xFFD4AF37), size: 26),
          ),
          const SizedBox(height: 14),
          const Text(
            'Пока нет тренировок',
            style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Добавьте первую запись: тип тренировки, интенсивность и самочувствие.',
            style: TextStyle(color: Color(0xB3F6F1E8), fontSize: 14, height: 1.35, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1A1D20),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Добавить тренировку', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFilterCard extends StatelessWidget {
  const _EmptyFilterCard({required this.filter, required this.onReset});

  final String filter;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0x1FD4AF37),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.filter_alt_off_rounded, color: Color(0xFFD4AF37), size: 25),
          ),
          const SizedBox(height: 14),
          Text(
            'Нет записей: $filter',
            style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'В этой категории пока нет тренировок. Можно сбросить фильтр или добавить новую запись.',
            style: TextStyle(color: Color(0xB3F6F1E8), fontSize: 14, height: 1.35, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFECCB75),
                side: const BorderSide(color: Color(0x66D4AF37)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 19),
              label: const Text('Показать все', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const selectedGradient = LinearGradient(
      colors: [Color(0xFFE9C86D), Color(0xFFD4AF37)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
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
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard(this.entry);

  final _WorkoutEntry entry;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF283038),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x5CD4AF37)),
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
                child: Row(
                  children: [
                    Icon(entry.icon, size: 16, color: const Color(0xFFD4AF37)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.date,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFF6F1E8)),
                      ),
                    ),
                  ],
                ),
              ),
              _DurationBadge(label: entry.durationBadge),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.type,
                  style: const TextStyle(fontSize: 13.2, fontWeight: FontWeight.w600, color: Color(0xFFD9D5CD)),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0x80F6F1E8), size: 20),
            ],
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

    return InkWell(
      onTap: () => context.push('/workout/${entry.id}'),
      borderRadius: BorderRadius.circular(16),
      child: card,
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
    required this.id,
    required this.date,
    required this.type,
    required this.detail,
    required this.meta,
    required this.durationBadge,
    required this.icon,
  });

  factory _WorkoutEntry.fromSession(TrainingSession session) {
    return _WorkoutEntry(
      id: session.id,
      date: session.formattedDate,
      type: '${session.type} · ${session.location}',
      detail: session.detail,
      meta: session.meta,
      durationBadge: session.durationLabel,
      icon: session.icon,
    );
  }

  final String id;
  final String date;
  final String type;
  final String detail;
  final String meta;
  final String durationBadge;
  final IconData icon;
}
