// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons.dart';
import '../models/training_session.dart';
import '../state/training_sessions_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(trainingSessionsProvider);
    final summary = _HomeSummary.fromSessions(sessions);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      children: [
        Text(
          _todayLabel(),
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
        if (sessions.isEmpty)
          _EmptyHomeCard(onTap: () => context.push('/new-training'))
        else ...[
          _ReadinessCard(summary: summary, accent: colorScheme.primary),
          const SizedBox(height: 10),
          _LastWorkoutCard(session: summary.lastSession!, accent: colorScheme.primary),
          const SizedBox(height: 10),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.6,
            ),
            children: [
              _DashboardMetricCard(
                label: 'Тренировок',
                value: '${summary.totalSessions}',
                subtitle: 'всего',
                icon: Icons.fitness_center_rounded,
              ),
              _DashboardMetricCard(
                label: 'Эта неделя',
                value: summary.weekTimeLabel,
                subtitle: '${summary.thisWeekSessions} ${_sessionWord(summary.thisWeekSessions)}',
                icon: Icons.calendar_view_week_rounded,
              ),
              _DashboardMetricCard(
                label: 'Нагрузка',
                value: '${summary.weekAverageIntensityLabel}/10',
                subtitle: 'средняя за неделю',
                icon: Icons.local_fire_department_rounded,
              ),
              _DashboardMetricCard(
                label: 'Главный тип',
                value: summary.topType,
                subtitle: 'по записям',
                icon: Icons.category_rounded,
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        PrimaryButton(label: '+ Новая тренировка', onPressed: () => context.push('/new-training')),
      ],
    );
  }
}

class _HomeSummary {
  const _HomeSummary({
    required this.totalSessions,
    required this.totalMinutes,
    required this.thisWeekSessions,
    required this.thisWeekMinutes,
    required this.thisWeekAverageIntensity,
    required this.topType,
    required this.lastSession,
  });

  factory _HomeSummary.fromSessions(List<TrainingSession> sessions) {
    final sortedSessions = [...sessions]..sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final typeCounts = <String, int>{};
    var totalMinutes = 0;
    var thisWeekSessions = 0;
    var thisWeekMinutes = 0;
    var thisWeekIntensity = 0;

    for (final session in sessions) {
      totalMinutes += session.durationMinutes;
      typeCounts[session.type] = (typeCounts[session.type] ?? 0) + 1;

      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      if (!sessionDate.isBefore(weekStart)) {
        thisWeekSessions += 1;
        thisWeekMinutes += session.durationMinutes;
        thisWeekIntensity += session.intensity;
      }
    }

    final topType = _topType(typeCounts);

    return _HomeSummary(
      totalSessions: sessions.length,
      totalMinutes: totalMinutes,
      thisWeekSessions: thisWeekSessions,
      thisWeekMinutes: thisWeekMinutes,
      thisWeekAverageIntensity: thisWeekSessions == 0 ? 0 : thisWeekIntensity / thisWeekSessions,
      topType: topType,
      lastSession: sortedSessions.isEmpty ? null : sortedSessions.first,
    );
  }

  final int totalSessions;
  final int totalMinutes;
  final int thisWeekSessions;
  final int thisWeekMinutes;
  final double thisWeekAverageIntensity;
  final String topType;
  final TrainingSession? lastSession;

  String get totalTimeLabel => _durationLabel(totalMinutes);
  String get weekTimeLabel => _durationLabel(thisWeekMinutes);
  String get weekAverageIntensityLabel => thisWeekAverageIntensity == 0 ? '—' : thisWeekAverageIntensity.toStringAsFixed(1);

  int get readinessScore {
    if (thisWeekSessions == 0) {
      return 72;
    }

    final loadPenalty = (thisWeekAverageIntensity * 4).round();
    final volumePenalty = thisWeekSessions > 4 ? 8 : 0;
    final score = 92 - loadPenalty - volumePenalty;
    return score.clamp(45, 95);
  }

  String get readinessText {
    if (readinessScore >= 80) {
      return 'Хорошая готовность к нагрузкам';
    }

    if (readinessScore >= 65) {
      return 'Нагрузка умеренная, следи за восстановлением';
    }

    return 'Неделя плотная, лучше добавить восстановление';
  }
}

class _EmptyHomeCard extends StatelessWidget {
  const _EmptyHomeCard({required this.onTap});

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
            child: const Icon(Icons.add_task_rounded, color: Color(0xFFD4AF37), size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Начните дневник',
            style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Добавьте первую тренировку — здесь появится последняя сессия, объём недели и краткая сводка.',
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

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.summary, required this.accent});

  final _HomeSummary summary;
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
                  summary.readinessText,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Неделя: ${summary.weekTimeLabel} · ${summary.thisWeekSessions} ${_sessionWord(summary.thisWeekSessions)}',
                  style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          _ReadinessRing(accent: accent, value: summary.readinessScore),
        ],
      ),
    );
  }
}

class _ReadinessRing extends StatelessWidget {
  const _ReadinessRing({required this.accent, required this.value});

  final Color accent;
  final int value;

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
            value: value / 100,
            strokeWidth: 5,
            backgroundColor: accent.withValues(alpha: 0.16),
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
          Center(
            child: Text(
              '$value',
              style: textTheme.titleMedium?.copyWith(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastWorkoutCard extends StatelessWidget {
  const _LastWorkoutCard({required this.session, required this.accent});

  final TrainingSession session;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/workout/${session.id}'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF252A2F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x5CD4AF37)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0x1FD4AF37),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(session.icon, color: accent, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Последняя тренировка', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(session.type, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 17, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 3),
                  Text('${session.formattedDate} · ${session.durationLabel}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xB3F6F1E8), fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0x80F6F1E8)),
          ],
        ),
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({required this.label, required this.value, required this.icon, this.subtitle});

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;

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
              Icon(icon, size: 16, color: accent.withValues(alpha: 0.88)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(color: const Color(0xFFEDE6D8).withValues(alpha: 0.74)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.15, fontSize: 18),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ),
    );
  }
}

String _topType(Map<String, int> typeCounts) {
  if (typeCounts.isEmpty) {
    return '—';
  }

  final entries = typeCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  return entries.first.key;
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

String _todayLabel() {
  final now = DateTime.now();
  const weekdays = ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'];
  const months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];

  return '${now.day} ${months[now.month - 1]}, ${weekdays[now.weekday - 1]}';
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
