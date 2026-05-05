import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/training_session.dart';
import '../state/training_sessions_provider.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  const WorkoutDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(trainingSessionsProvider);
    final session = _findSession(sessions, sessionId);

    if (session == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1D20),
        body: SafeArea(child: _MissingWorkoutView()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D20),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            const Text(
              'Дневник скалолаза',
              style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _BackButton(onTap: () => context.go('/diary')),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Детали тренировки',
                    style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 26, fontWeight: FontWeight.w900, height: 1.05),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HeroCard(session: session),
            const SizedBox(height: 12),
            _StatsGrid(session: session),
            const SizedBox(height: 12),
            _NotesCard(session: session),
            const SizedBox(height: 22),
            const _RemoveSectionLabel(),
            const SizedBox(height: 8),
            _DeleteButton(onTap: () => _confirmDelete(context, ref, session)),
          ],
        ),
      ),
    );
  }

  TrainingSession? _findSession(List<TrainingSession> sessions, String id) {
    for (final session in sessions) {
      if (session.id == id) {
        return session;
      }
    }

    return null;
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, TrainingSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF252A2F),
        title: const Text('Удалить тренировку?'),
        content: Text('Запись “${session.type}” будет удалена из дневника и локального хранилища.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Удалить', style: TextStyle(color: Color(0xFFFFB4AB))),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(trainingSessionsProvider.notifier).deleteSession(session.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF252A2F),
          content: Text('Тренировка удалена.', style: TextStyle(color: Color(0xFFF6F1E8), fontWeight: FontWeight.w700)),
        ),
      );

    context.go('/diary');
  }
}

class _MissingWorkoutView extends StatelessWidget {
  const _MissingWorkoutView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Дневник скалолаза', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 28),
          const Text('Тренировка не найдена', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Возможно, запись уже удалена.', style: TextStyle(color: Color(0xB3F6F1E8), fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          _BackButton(onTap: () => context.go('/diary')),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF252A2F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x164C5560)),
        ),
        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFFF6F1E8), size: 24),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.session});

  final TrainingSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x5CD4AF37)),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0x1FD4AF37),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(session.icon, color: const Color(0xFFD4AF37), size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.type, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 23, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(session.formattedDate, style: const TextStyle(color: Color(0xB3F6F1E8), fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(session.location, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.session});

  final TrainingSession session;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.65,
      children: [
        _StatCard(label: 'Длительность', value: session.durationLabel, icon: Icons.timer_outlined),
        _StatCard(label: 'Интенсивность', value: '${session.intensity}/10', icon: Icons.local_fire_department_rounded),
        _StatCard(label: 'Самочувствие', value: session.effort, icon: Icons.favorite_rounded),
        _StatCard(label: 'Место', value: session.location, icon: Icons.location_on_outlined),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

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
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.session});

  final TrainingSession session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Заметки', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.4)),
          const SizedBox(height: 10),
          Text(session.detail, style: const TextStyle(color: Color(0xDFF6F1E8), fontSize: 15, fontWeight: FontWeight.w700, height: 1.35)),
        ],
      ),
    );
  }
}

class _RemoveSectionLabel extends StatelessWidget {
  const _RemoveSectionLabel();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Управление записью',
      style: TextStyle(color: Color(0x99FFB4AB), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.4),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFFB4AB),
          side: const BorderSide(color: Color(0x66FFB4AB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        icon: const Icon(Icons.delete_outline_rounded, size: 20),
        label: const Text('Удалить тренировку', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
