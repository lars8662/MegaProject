// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'dart:async';

import 'package:flutter/material.dart';

class TimersScreen extends StatefulWidget {
  const TimersScreen({super.key});

  @override
  State<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends State<TimersScreen> {
  static final _presets = [
    _TimerPreset(
      title: 'Repeaters 7/3',
      subtitle: 'Фингерборд · сила-выносливость',
      workLabel: 'Вис',
      restLabel: 'Отдых',
      workSeconds: 7,
      restSeconds: 3,
      rounds: 6,
      icon: Icons.back_hand_rounded,
    ),
    _TimerPreset(
      title: 'Max Hang',
      subtitle: 'Максимальная сила пальцев',
      workLabel: 'Вис',
      restLabel: 'Отдых',
      workSeconds: 10,
      restSeconds: 180,
      rounds: 5,
      icon: Icons.fitness_center_rounded,
    ),
    _TimerPreset(
      title: 'ARC / лёгкий объём',
      subtitle: 'Аэробная база и техника',
      workLabel: 'Лазание',
      restLabel: 'Пауза',
      workSeconds: 600,
      restSeconds: 120,
      rounds: 3,
      icon: Icons.route_rounded,
    ),
  ];

  late _TimerPreset _preset = _presets.first;
  late List<_TimerStage> _stages = _buildStages(_preset);
  int _stageIndex = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _ticker;

  _TimerStage get _currentStage => _stages[_stageIndex];

  int get _totalSeconds => _stages.fold(0, (total, stage) => total + stage.seconds);

  int get _completedSeconds {
    var completed = 0;
    for (var i = 0; i < _stageIndex; i++) {
      completed += _stages[i].seconds;
    }

    return completed + (_currentStage.seconds - _remainingSeconds);
  }

  double get _overallProgress {
    final total = _totalSeconds;
    if (total == 0) {
      return 0;
    }

    return (_completedSeconds / total).clamp(0, 1);
  }

  double get _stageProgress {
    final stageSeconds = _currentStage.seconds;
    if (stageSeconds == 0) {
      return 0;
    }

    return ((stageSeconds - _remainingSeconds) / stageSeconds).clamp(0, 1);
  }

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _currentStage.seconds;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _selectPreset(_TimerPreset preset) {
    _ticker?.cancel();
    setState(() {
      _preset = preset;
      _stages = _buildStages(preset);
      _stageIndex = 0;
      _remainingSeconds = _stages.first.seconds;
      _isRunning = false;
    });
  }

  void _toggleRunning() {
    if (_isRunning) {
      _pause();
    } else {
      _start();
    }
  }

  void _start() {
    _ticker?.cancel();
    setState(() => _isRunning = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _isRunning = false);
  }

  void _tick() {
    if (!mounted) {
      return;
    }

    if (_remainingSeconds > 1) {
      setState(() => _remainingSeconds -= 1);
      return;
    }

    _goToNextStage();
  }

  void _goToNextStage() {
    if (_stageIndex >= _stages.length - 1) {
      _ticker?.cancel();
      setState(() {
        _remainingSeconds = 0;
        _isRunning = false;
      });
      return;
    }

    setState(() {
      _stageIndex += 1;
      _remainingSeconds = _currentStage.seconds;
    });
  }

  void _skipStage() {
    _goToNextStage();
  }

  void _resetTimer() {
    _ticker?.cancel();
    setState(() {
      _stageIndex = 0;
      _remainingSeconds = _stages.first.seconds;
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 14, 16, 18 + bottomInset),
      children: [
        const Text(
          'Таймеры',
          style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Протоколы для фингерборда, силы и объёма.',
          style: TextStyle(color: Color(0xB3F6F1E8), fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _PresetSelector(
          presets: _presets,
          selected: _preset,
          onSelect: _selectPreset,
        ),
        const SizedBox(height: 16),
        _TimerCard(
          preset: _preset,
          stage: _currentStage,
          remainingSeconds: _remainingSeconds,
          stageProgress: _stageProgress,
          overallProgress: _overallProgress,
          isFinished: _remainingSeconds == 0 && _stageIndex == _stages.length - 1,
        ),
        const SizedBox(height: 14),
        _NextStageCard(
          stages: _stages,
          stageIndex: _stageIndex,
          remainingTotalLabel: _durationLabel((_totalSeconds - _completedSeconds).clamp(0, _totalSeconds)),
        ),
        const SizedBox(height: 16),
        _ControlsRow(
          isRunning: _isRunning,
          onReset: _resetTimer,
          onToggle: _toggleRunning,
          onSkip: _skipStage,
        ),
        const SizedBox(height: 12),
        _ProtocolSummaryCard(preset: _preset),
      ],
    );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({required this.presets, required this.selected, required this.onSelect});

  final List<_TimerPreset> presets;
  final _TimerPreset selected;
  final ValueChanged<_TimerPreset> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final preset = presets[index];
          final isSelected = preset == selected;
          return _PresetChip(preset: preset, selected: isSelected, onTap: () => onSelect(preset));
        },
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.preset, required this.selected, required this.onTap});

  final _TimerPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 194,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF343039) : const Color(0xFF252A2F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? const Color(0xFFD4AF37) : const Color(0x164C5560), width: selected ? 1.4 : 1),
          boxShadow: selected ? const [BoxShadow(color: Color(0x20D4AF37), blurRadius: 16, offset: Offset(0, 8))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(preset.icon, color: selected ? const Color(0xFFD4AF37) : const Color(0x99F6F1E8), size: 22),
            const Spacer(),
            Text(preset.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(preset.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.preset,
    required this.stage,
    required this.remainingSeconds,
    required this.stageProgress,
    required this.overallProgress,
    required this.isFinished,
  });

  final _TimerPreset preset;
  final _TimerStage stage;
  final int remainingSeconds;
  final double stageProgress;
  final double overallProgress;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    final stageColor = stage.isWork ? const Color(0xFFD4AF37) : const Color(0xFFBFA7FF);
    final displayLabel = isFinished ? 'Готово' : stage.label.toUpperCase();
    final timeLabel = isFinished ? '00:00' : _clockLabel(remainingSeconds);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(preset.title, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text('Раунд ${stage.round} из ${preset.rounds}', style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 13, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: stageColor.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
                child: Text(displayLabel, style: TextStyle(color: stageColor, fontSize: 12, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 224,
            height: 224,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: stageProgress,
                  strokeWidth: 14,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0x334C5560),
                  valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                ),
                Container(
                  margin: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1D2530), Color(0xFF11161D)],
                    ),
                    boxShadow: [BoxShadow(color: stageColor.withValues(alpha: 0.18), blurRadius: 24, spreadRadius: 2)],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(displayLabel, style: const TextStyle(color: Color(0xB3F6F1E8), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
                      const SizedBox(height: 6),
                      Text(timeLabel, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 42, fontWeight: FontWeight.w900, height: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 8,
              backgroundColor: const Color(0x224C5560),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Прогресс протокола', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${(overallProgress * 100).round()}%', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextStageCard extends StatelessWidget {
  const _NextStageCard({required this.stages, required this.stageIndex, required this.remainingTotalLabel});

  final List<_TimerStage> stages;
  final int stageIndex;
  final String remainingTotalLabel;

  @override
  Widget build(BuildContext context) {
    final hasNext = stageIndex < stages.length - 1;
    final nextStage = hasNext ? stages[stageIndex + 1] : null;

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
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0x1FD4AF37), borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.skip_next_rounded, color: Color(0xFFD4AF37), size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hasNext ? 'Следующий этап' : 'Финиш протокола', style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(hasNext ? '${nextStage!.label}: ${_clockLabel(nextStage.seconds)}' : 'Все этапы выполнены', style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Text(remainingTotalLabel, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({required this.isRunning, required this.onReset, required this.onToggle, required this.onSkip});

  final bool isRunning;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundControlButton(icon: Icons.restart_alt_rounded, onTap: onReset),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 58,
            child: ElevatedButton.icon(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1A1D20),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28),
              label: Text(isRunning ? 'Пауза' : 'Старт', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        _RoundControlButton(icon: Icons.skip_next_rounded, onTap: onSkip),
      ],
    );
  }
}

class _RoundControlButton extends StatelessWidget {
  const _RoundControlButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF252A2F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x164C5560)),
        ),
        child: Icon(icon, color: const Color(0xFFF6F1E8), size: 27),
      ),
    );
  }
}

class _ProtocolSummaryCard extends StatelessWidget {
  const _ProtocolSummaryCard({required this.preset});

  final _TimerPreset preset;

  @override
  Widget build(BuildContext context) {
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
          const Text('Протокол', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          _ProtocolLine(label: 'Работа', value: '${preset.workLabel} · ${_clockLabel(preset.workSeconds)}'),
          _ProtocolLine(label: 'Отдых', value: '${preset.restLabel} · ${_clockLabel(preset.restSeconds)}'),
          _ProtocolLine(label: 'Раунды', value: '${preset.rounds}'),
          _ProtocolLine(label: 'Общее время', value: _durationLabel(preset.totalSeconds)),
        ],
      ),
    );
  }
}

class _ProtocolLine extends StatelessWidget {
  const _ProtocolLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 13, fontWeight: FontWeight.w800))),
          Text(value, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _TimerPreset {
  const _TimerPreset({
    required this.title,
    required this.subtitle,
    required this.workLabel,
    required this.restLabel,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String workLabel;
  final String restLabel;
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final IconData icon;

  int get totalSeconds => (workSeconds + restSeconds) * rounds - restSeconds;
}

class _TimerStage {
  const _TimerStage({required this.label, required this.seconds, required this.round, required this.isWork});

  final String label;
  final int seconds;
  final int round;
  final bool isWork;
}

List<_TimerStage> _buildStages(_TimerPreset preset) {
  final stages = <_TimerStage>[];

  for (var round = 1; round <= preset.rounds; round++) {
    stages.add(_TimerStage(label: preset.workLabel, seconds: preset.workSeconds, round: round, isWork: true));

    if (round != preset.rounds) {
      stages.add(_TimerStage(label: preset.restLabel, seconds: preset.restSeconds, round: round, isWork: false));
    }
  }

  return stages;
}

String _clockLabel(int secondsTotal) {
  final minutes = secondsTotal ~/ 60;
  final seconds = secondsTotal % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

String _durationLabel(int secondsTotal) {
  final hours = secondsTotal ~/ 3600;
  final minutes = (secondsTotal % 3600) ~/ 60;
  final seconds = secondsTotal % 60;

  if (hours > 0) {
    if (minutes == 0) {
      return '$hours ч';
    }

    return '$hours ч $minutes мин';
  }

  if (minutes > 0) {
    if (seconds == 0) {
      return '$minutes мин';
    }

    return '$minutes мин $seconds сек';
  }

  return '$seconds сек';
}
