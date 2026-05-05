// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/training_session.dart';
import '../state/training_sessions_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(trainingSessionsProvider);
    final summary = _ProgressSummary.fromSessions(sessions);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        const Text(
          'Прогресс',
          style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          sessions.isEmpty ? 'Добавьте тренировки, чтобы увидеть аналитику.' : 'Статистика по сохранённым тренировкам.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xB3F6F1E8)),
        ),
        if (sessions.isNotEmpty) ...[
          const SizedBox(height: 12),
          const _PeriodPill(),
        ],
        const SizedBox(height: 16),
        if (sessions.isEmpty)
          _EmptyProgressCard(onTap: () => context.push('/new-training'))
        else ...[
          _HeroProgressCard(summary: summary),
          const SizedBox(height: 12),
          _MetricGrid(summary: summary),
          const SizedBox(height: 12),
          _TypeDistributionCard(summary: summary),
          const SizedBox(height: 12),
          _RecentTrendCard(summary: summary),
        ],
      ],
    );
  }
}

class _ProgressSummary {
  const _ProgressSummary({
    required this.totalSessions,
    required this.totalMinutes,
    required this.averageIntensity,
    required this.typeCounts,
    required this.lastSession,
    required this.thisWeekSessions,
    required this.thisWeekMinutes,
  });

  factory _ProgressSummary.fromSessions(List<TrainingSession> sessions) {
    final typeCounts = <String, int>{};
    var totalMinutes = 0;
    var totalIntensity = 0;

    final sortedSessions = [...sessions]..sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    var thisWeekSessions = 0;
    var thisWeekMinutes = 0;

    for (final session in sessions) {
      totalMinutes += session.durationMinutes;
      totalIntensity += session.intensity;
      typeCounts[session.type] = (typeCounts[session.type] ?? 0) + 1;

      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      if (!sessionDate.isBefore(weekStart)) {
        thisWeekSessions += 1;
        thisWeekMinutes += session.durationMinutes;
      }
    }

    return _ProgressSummary(
      totalSessions: sessions.length,
      totalMinutes: totalMinutes,
      averageIntensity: sessions.isEmpty ? 0 : totalIntensity / sessions.length,
      typeCounts: typeCounts,
      lastSession: sortedSessions.isEmpty ? null : sortedSessions.first,
      thisWeekSessions: thisWeekSessions,
      thisWeekMinutes: thisWeekMinutes,
    );
  }

  final int totalSessions;
  final int totalMinutes;
  final double averageIntensity;
  final Map<String, int> typeCounts;
  final TrainingSession? lastSession;
  final int thisWeekSessions;
  final int thisWeekMinutes;

  String get totalTimeLabel => _durationLabel(totalMinutes);

  String get weekTimeLabel => _durationLabel(thisWeekMinutes);

  String get averageDurationLabel {
    if (totalSessions == 0) {
      return '—';
    }

    return _durationLabel(totalMinutes ~/ totalSessions);
  }

  String get averageIntensityLabel => averageIntensity.toStringAsFixed(1);

  String get totalSessionsLabel => '$totalSessions ${_sessionWord(totalSessions)}';

  String get weekSummaryLabel => '$thisWeekSessions ${_sessionWord(thisWeekSessions)} · $weekTimeLabel';

  String get topType {
    if (typeCounts.isEmpty) {
      return '—';
    }

    final entries = typeCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0x1FD4AF37),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x44D4AF37)),
        ),
        child: const Text(
          'Период: всё время',
          style: TextStyle(color: Color(0xFFECCB75), fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _EmptyProgressCard extends StatelessWidget {
  const _EmptyProgressCard({required this.onTap});

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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0x1FD4AF37),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.show_chart_rounded, color: Color(0xFFD4AF37), size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Пока нет данных',
            style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Создайте первую тренировку — здесь появятся часы, интенсивность и распределение по типам.',
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

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({required this.summary});

  final _ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final lastSession = summary.lastSession;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x5CD4AF37)),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Общий объём',
            style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            summary.totalTimeLabel,
            style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 34, fontWeight: FontWeight.w900, height: 1),
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.totalSessionsLabel} · средняя ${summary.averageDurationLabel}',
            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            lastSession == null ? 'Нет последней тренировки' : 'Последняя: ${lastSession.type} · ${lastSession.formattedDate}',
            style: const TextStyle(color: Color(0xDFF6F1E8), fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.summary});

  final _ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _MetricCard(label: 'Тренировок', value: '${summary.totalSessions}', icon: Icons.fitness_center_rounded),
        _MetricCard(label: 'Эта неделя', value: summary.weekTimeLabel, subtitle: '${summary.thisWeekSessions} ${_sessionWord(summary.thisWeekSessions)}', icon: Icons.calendar_view_week_rounded),
        _MetricCard(label: 'Средняя нагрузка', value: '${summary.averageIntensityLabel}/10', icon: Icons.local_fire_department_rounded),
        _MetricCard(label: 'Главный тип', value: summary.topType, icon: Icons.category_rounded),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon, this.subtitle});

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 20, fontWeight: FontWeight.w900)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ],
      ),
    );
  }
}

class _TypeDistributionCard extends StatelessWidget {
  const _TypeDistributionCard({required this.summary});

  final _ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final entries = summary.typeCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Распределение по типам', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          for (final entry in entries) ...[
            _TypeRow(type: entry.key, count: entry.value, total: summary.totalSessions),
            if (entry != entries.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  const _TypeRow({required this.type, required this.count, required this.total});

  final String type;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    final percent = (ratio * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(type, style: const TextStyle(color: Color(0xDFF6F1E8), fontSize: 14, fontWeight: FontWeight.w800))),
            Text('$count · $percent%', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: const Color(0x224C5560),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
          ),
        ),
      ],
    );
  }
}

class _RecentTrendCard extends StatelessWidget {
  const _RecentTrendCard({required this.summary});

  final _ProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0x1FD4AF37),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.trending_up_rounded, color: Color(0xFFD4AF37), size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'На этой неделе: ${summary.weekSummaryLabel}. Средняя интенсивность: ${summary.averageIntensityLabel}/10.',
              style: const TextStyle(color: Color(0xDFF6F1E8), fontSize: 14, height: 1.35, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

String _durationLabel(int minutesTotal) {
  final hours = minutesTotal ~/ 60;
  final minutes = minutesTotal % 60;

  if (hours == 0) {
    return '$minutes мин';
  }

  if (minutes == 0) {
    return '$hours ч';
  }

  return '$hours ч $minutes мин';
}

String _sessionWord(int count) {
  final mod100 = count % 100;
  final mod10 = count % 10;

  if (mod100 >= 11 && mod100 <= 14) {
    return 'тренировок';
  }

  if (mod10 == 1) {
    return 'тренировка';
  }

  if (mod10 >= 2 && mod10 <= 4) {
    return 'тренировки';
  }

  return 'тренировок';
}
