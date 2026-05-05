// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/buttons.dart';
import '../models/training_session.dart';
import '../state/training_sessions_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _weeklyGoal = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(trainingSessionsProvider);
    final summary = _HomeSummary.fromSessions(sessions, weeklyGoal: _weeklyGoal);
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
          _WeeklyGoalCard(summary: summary, accent: colorScheme.primary),
          const SizedBox(height: 10),
          _LastWorkoutCard(session: summary.lastSession!, accent: colorScheme.primary),
        ],
        const SizedBox(height: 12),
        PrimaryButton(label: '+ Новая тренировка', onPressed: () => context.push('/new-training')),
      ],
    );
  }
}

class _HomeSummary {
  const _HomeSummary({
    required this.weeklyGoal,
    required this.thisWeekSessions,
    required this.thisWeekMinutes,
    required this.thisWeekAverageIntensity,
    required this.lastSession,
  });

  factory _HomeSummary.fromSessions(List<TrainingSession> sessions, {required int weeklyGoal}) {
    final sortedSessions = [...sessions]..sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    var thisWeekSessions = 0;
    var thisWeekMinutes = 0;
    var thisWeekIntensity = 0;

    for (final session in sessions) {
      final sessionDate = DateTime(session.date.year, session.date.month, session.date.day);
      if (!sessionDate.isBefore(weekStart)) {
        thisWeekSessions += 1;
        thisWeekMinutes += session.durationMinutes;
        thisWeekIntensity += session.intensity;
      }
    }

    return _HomeSummary(
      weeklyGoal: weeklyGoal,
      thisWeekSessions: thisWeekSessions,
      thisWeekMinutes: thisWeekMinutes,
      thisWeekAverageIntensity: thisWeekSessions == 0 ? 0 : thisWeekIntensity / thisWeekSessions,
      lastSession: sortedSessions.isEmpty ? null : sortedSessions.first,
    );
  }

  final int weeklyGoal;
  final int thisWeekSessions;
  final int thisWeekMinutes;
  final double thisWeekAverageIntensity;
  final TrainingSession? lastSession;

  double get goalProgress => (thisWeekSessions / weeklyGoal).clamp(0, 1);

  String get weekTimeLabel => _durationLabel(thisWeekMinutes);

  String get weekAverageIntensityLabel => thisWeekAverageIntensity == 0 ? '—' : thisWeekAverageIntensity.toStringAsFixed(1);

  int get readinessScore {
    if (thisWeekSessions == 0) {
      return 82;
    }

    final loadPenalty = (thisWeekAverageIntensity * 4).round();
    final volumePenalty = thisWeekSessions > weeklyGoal ? 8 : 0;
    final score = 94 - loadPenalty - volumePenalty;
    return score.clamp(45, 95);
  }

  String get readinessText {
    if (thisWeekSessions == 0) {
      return 'Сегодня можно запланировать первую тренировку';
    }

    if (readinessScore >= 80) {
      return 'Хорошая готовность к следующей тренировке';
    }

    if (readinessScore >= 65) {
      return 'Умеренная нагрузка — держите баланс';
    }

    return 'Лучше восстановиться сегодня';
  }

  String get nextStepText {
    if (thisWeekSessions == 0) {
      return 'Добавьте первую тренировку недели';
    }

    if (thisWeekSessions < weeklyGoal) {
      final left = weeklyGoal - thisWeekSessions;
      return 'До цели осталось $left ${_sessionWord(left)}';
    }

    if (readinessScore < 65) {
      return 'Цель выполнена — запланируйте восстановление';
    }

    return 'Цель выполнена — поддерживайте качество';
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
            'Добавьте первую тренировку — здесь появится статус дня, цель недели и последняя запись.',
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
                    fontWeight: FontWeight.w700,
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

class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard({required this.summary, required this.accent});

  final _HomeSummary summary;
  final Color accent;

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
        children: [
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 18, color: accent),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Цель недели', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 16, fontWeight: FontWeight.w900)),
              ),
              Text('${(summary.goalProgress * 100).round()}%', style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${summary.thisWeekSessions} из ${summary.weeklyGoal} тренировок',
            style: const TextStyle(color: Color(0xDFF6F1E8), fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: summary.goalProgress,
              minHeight: 8,
              backgroundColor: const Color(0x224C5560),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.nextStepText,
            style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800),
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
