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
      subtitle: 'Фингерборд · выносливость',
      workLabel: 'Вис',
      restLabel: 'Отдых',
      workSeconds: 7,
      restSeconds: 3,
      rounds: 6,
      icon: Icons.back_hand_rounded,
    ),
    _TimerPreset(
      title: 'Max Hang',
      subtitle: 'Максимальная сила',
      workLabel: 'Вис',
      restLabel: 'Отдых',
      workSeconds: 10,
      restSeconds: 180,
      rounds: 5,
      icon: Icons.fitness_center_rounded,
    ),
    _TimerPreset(
      title: 'ARC / лёгкий объём',
      subtitle: 'Аэробная база',
      workLabel: 'Лазание',
      restLabel: 'Пауза',
      workSeconds: 600,
      restSeconds: 120,
      rounds: 3,
      icon: Icons.timeline_rounded,
    ),
  ];

  late _TimerPreset _preset = _presets.first;
  late List<_TimerStage> _stages = _buildStages(_preset);
  int _stageIndex = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isActiveMode = false;
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

  bool get _isFinished => _remainingSeconds == 0 && _stageIndex == _stages.length - 1;

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
      _isActiveMode = false;
    });
  }

  void _enterActiveMode() {
    if (_isFinished) {
      _resetTimer();
    }

    setState(() => _isActiveMode = true);
    _start();
  }

  void _exitActiveMode() {
    _pause();
    setState(() => _isActiveMode = false);
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
    if (mounted) {
      setState(() => _isRunning = false);
    }
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
    if (_isActiveMode) {
      return _ActiveTimerView(
        preset: _preset,
        stages: _stages,
        stageIndex: _stageIndex,
        currentStage: _currentStage,
        remainingSeconds: _remainingSeconds,
        stageProgress: _stageProgress,
        overallProgress: _overallProgress,
        remainingTotalLabel: _durationLabel((_totalSeconds - _completedSeconds).clamp(0, _totalSeconds)),
        isRunning: _isRunning,
        isFinished: _isFinished,
        onBack: _exitActiveMode,
        onReset: _resetTimer,
        onToggle: _toggleRunning,
        onSkip: _skipStage,
      );
    }

    return _PresetPickerView(
      presets: _presets,
      selected: _preset,
      onSelect: _selectPreset,
      onStart: _enterActiveMode,
    );
  }
}

class _PresetPickerView extends StatelessWidget {
  const _PresetPickerView({required this.presets, required this.selected, required this.onSelect, required this.onStart});

  final List<_TimerPreset> presets;
  final _TimerPreset selected;
  final ValueChanged<_TimerPreset> onSelect;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 18 + bottomInset),
      children: [
        const Text(
          'Таймеры',
          style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        const Text(
          'Выберите протокол и начните тренировку.',
          style: TextStyle(color: Color(0xB3F6F1E8), fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _PresetSelector(
          presets: presets,
          selected: selected,
          onSelect: onSelect,
        ),
        const SizedBox(height: 16),
        _SelectedProtocolCard(preset: selected, onStart: onStart),
        const SizedBox(height: 14),
        _ProtocolSummaryCard(preset: selected),
      ],
    );
  }
}

class _ActiveTimerView extends StatelessWidget {
  const _ActiveTimerView({
    required this.preset,
    required this.stages,
    required this.stageIndex,
    required this.currentStage,
    required this.remainingSeconds,
    required this.stageProgress,
    required this.overallProgress,
    required this.remainingTotalLabel,
    required this.isRunning,
    required this.isFinished,
    required this.onBack,
    required this.onReset,
    required this.onToggle,
    required this.onSkip,
  });

  final _TimerPreset preset;
  final List<_TimerStage> stages;
  final int stageIndex;
  final _TimerStage currentStage;
  final int remainingSeconds;
  final double stageProgress;
  final double overallProgress;
  final String remainingTotalLabel;
  final bool isRunning;
  final bool isFinished;
  final VoidCallback onBack;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 6, 16, 18 + bottomInset),
      children: [
        _ActiveTimerHeader(preset: preset, stage: currentStage, isFinished: isFinished, onBack: onBack),
        const SizedBox(height: 10),
        _FocusedTimerCard(
          preset: preset,
          stage: currentStage,
          remainingSeconds: remainingSeconds,
          stageProgress: stageProgress,
          overallProgress: overallProgress,
          isFinished: isFinished,
        ),
        const SizedBox(height: 12),
        _ControlsRow(
          isRunning: isRunning,
          isFinished: isFinished,
          onReset: onReset,
          onToggle: onToggle,
          onSkip: onSkip,
        ),
        const SizedBox(height: 12),
        _NextStageCard(
          stages: stages,
          stageIndex: stageIndex,
          remainingTotalLabel: remainingTotalLabel,
        ),
      ],
    );
  }
}

class _ActiveTimerHeader extends StatelessWidget {
  const _ActiveTimerHeader({required this.preset, required this.stage, required this.isFinished, required this.onBack});

  final _TimerPreset preset;
  final _TimerStage stage;
  final bool isFinished;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final stageColor = stage.isWork ? const Color(0xFFD4AF37) : const Color(0xFFBFA7FF);
    final label = isFinished ? 'ГОТОВО' : stage.label.toUpperCase();

    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF252A2F),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x164C5560)),
            ),
            child: const Icon(Icons.keyboard_arrow_left_rounded, color: Color(0xFFF6F1E8), size: 30),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(preset.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text('Раунд ${stage.round} из ${preset.rounds}', style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(color: stageColor.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999)),
          child: Text(label, style: TextStyle(color: stageColor, fontSize: 12, fontWeight: FontWeight.w900)),
        ),
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
      height: 96,
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
        width: 174,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF343039) : const Color(0xFF252A2F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? const Color(0xFFD4AF37) : const Color(0x164C5560), width: selected ? 1.4 : 1),
          boxShadow: selected ? const [BoxShadow(color: Color(0x20D4AF37), blurRadius: 14, offset: Offset(0, 7))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(preset.icon, color: selected ? const Color(0xFFD4AF37) : const Color(0x99F6F1E8), size: 21),
            const Spacer(),
            Text(preset.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(preset.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _SelectedProtocolCard extends StatelessWidget {
  const _SelectedProtocolCard({required this.preset, required this.onStart});

  final _TimerPreset preset;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: const Color(0x1FD4AF37), borderRadius: BorderRadius.circular(16)),
                child: Icon(preset.icon, color: const Color(0xFFD4AF37), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(preset.title, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 3),
                    Text(preset.subtitle, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _MetricPill(label: 'Работа', value: _clockLabel(preset.workSeconds))),
              const SizedBox(width: 10),
              Expanded(child: _MetricPill(label: 'Отдых', value: _clockLabel(preset.restSeconds))),
              const SizedBox(width: 10),
              Expanded(child: _MetricPill(label: 'Раунды', value: '${preset.rounds}')),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1A1D20),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text('Начать тренировку', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFF1F2429), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _FocusedTimerCard extends StatelessWidget {
  const _FocusedTimerCard({
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
    final displayLabel = isFinished ? 'ГОТОВО' : stage.label.toUpperCase();
    final timeLabel = isFinished ? '00:00' : _clockLabel(remainingSeconds);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ringSize = (screenWidth * 0.68).clamp(246.0, 292.0).toDouble();
    final ringStroke = (ringSize * 0.055).clamp(13.0, 16.0).toDouble();
    final innerMargin = (ringSize * 0.115).clamp(28.0, 34.0).toDouble();
    final timeFontSize = (ringSize * 0.22).clamp(54.0, 64.0).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: stageProgress,
                  strokeWidth: ringStroke,
                  strokeCap: StrokeCap.round,
                  backgroundColor: const Color(0x334C5560),
                  valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                ),
                Container(
                  margin: EdgeInsets.all(innerMargin),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1D2530), Color(0xFF11161D)],
                    ),
                    boxShadow: [BoxShadow(color: stageColor.withValues(alpha: 0.2), blurRadius: 26, spreadRadius: 3)],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(displayLabel, style: TextStyle(color: stageColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.8)),
                      const SizedBox(height: 8),
                      Text(timeLabel, style: TextStyle(color: const Color(0xFFF6F1E8), fontSize: timeFontSize, fontWeight: FontWeight.w900, height: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 7,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: const Color(0x1FD4AF37), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.skip_next_rounded, color: Color(0xFFD4AF37), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hasNext ? 'Следующий этап' : 'Финиш протокола', style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(hasNext ? '${nextStage!.label}: ${_clockLabel(nextStage.seconds)}' : 'Все этапы выполнены', style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Text(remainingTotalLabel, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({required this.isRunning, required this.isFinished, required this.onReset, required this.onToggle, required this.onSkip});

  final bool isRunning;
  final bool isFinished;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundControlButton(icon: Icons.restart_alt_rounded, onTap: onReset),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 58,
            child: ElevatedButton.icon(
              onPressed: isFinished ? onReset : onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF1A1D20),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: Icon(isFinished ? Icons.replay_rounded : isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 28),
              label: Text(isFinished ? 'Заново' : isRunning ? 'Пауза' : 'Старт', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
        const SizedBox(width: 12),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF252A2F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x164C5560)),
        ),
        child: Icon(icon, color: const Color(0xFFF6F1E8), size: 26),
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
