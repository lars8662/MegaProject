// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/training_session.dart';
import '../state/training_sessions_provider.dart';

const int _defaultPreparationSeconds = 5;
const Color _workColor = Color(0xFFD4AF37);
const Color _restColor = Color(0xFFA995E8);

class TimersScreen extends ConsumerStatefulWidget {
  const TimersScreen({super.key});

  @override
  ConsumerState<TimersScreen> createState() => _TimersScreenState();
}

class _TimersScreenState extends ConsumerState<TimersScreen> {
  static final _presets = [
    _TimerPreset(
      title: 'Repeaters 7/3',
      subtitle: 'Фингерборд · выносливость',
      workLabel: 'Вис',
      restLabel: 'Отдых',
      workSeconds: 7,
      restSeconds: 3,
      rounds: 6,
      preparationSeconds: _defaultPreparationSeconds,
      icon: Icons.back_hand_rounded,
    ),
    _TimerPreset(
      title: 'Repeaters 10/5',
      subtitle: 'Фингерборд · силовая выносливость',
      workLabel: 'Вис',
      restLabel: 'Отдых',
      workSeconds: 10,
      restSeconds: 5,
      rounds: 6,
      preparationSeconds: _defaultPreparationSeconds,
      icon: Icons.back_hand_rounded,
    ),
    _TimerPreset(
      title: 'PIMA 2/4',
      subtitle: 'Активная сила пальцев',
      workLabel: 'Тяга',
      restLabel: 'Пауза',
      workSeconds: 2,
      restSeconds: 4,
      rounds: 5,
      preparationSeconds: _defaultPreparationSeconds,
      icon: Icons.touch_app_rounded,
    ),
    _TimerPreset(
      title: 'CF Endurance 7/3 · 6 мин',
      subtitle: 'Критическая сила · 36 повторов',
      workLabel: 'Тяга',
      restLabel: 'Пауза',
      workSeconds: 7,
      restSeconds: 3,
      rounds: 36,
      preparationSeconds: _defaultPreparationSeconds,
      icon: Icons.bolt_rounded,
    ),
    _TimerPreset(
      title: 'Max Hang',
      subtitle: 'Максимальная сила',
      workLabel: 'Вис',
      restLabel: 'Отдых',
      workSeconds: 10,
      restSeconds: 180,
      rounds: 5,
      preparationSeconds: _defaultPreparationSeconds,
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
      preparationSeconds: _defaultPreparationSeconds,
      icon: Icons.timeline_rounded,
    ),
  ];

  late _TimerPreset _preset = _presets.first;
  late List<_TimerStage> _stages = _buildStages(_preset);
  int _stageIndex = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isActiveMode = false;
  bool _hasPromptedSave = false;
  Timer? _ticker;

  _TimerStage get _currentStage => _stages[_stageIndex];

  int get _selectedPresetIndex => _presets.indexOf(_preset);

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
    _disableWakeLock();
    super.dispose();
  }

  void _enableWakeLock() {
    unawaited(WakelockPlus.enable());
  }

  void _disableWakeLock() {
    unawaited(WakelockPlus.disable());
  }

  void _selectPreset(_TimerPreset preset) {
    _ticker?.cancel();
    _disableWakeLock();
    setState(() {
      _preset = preset;
      _stages = _buildStages(preset);
      _stageIndex = 0;
      _remainingSeconds = _stages.first.seconds;
      _isRunning = false;
      _isActiveMode = false;
      _hasPromptedSave = false;
    });
  }

  void _enterActiveMode() {
    if (_isFinished) {
      _resetTimer();
    }

    _enableWakeLock();
    setState(() => _isActiveMode = true);
    _start();
  }

  Future<void> _openCustomProtocolForm() async {
    final customPreset = await showModalBottomSheet<_TimerPreset>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CustomProtocolSheet(),
    );

    if (customPreset == null || !mounted) {
      return;
    }

    _ticker?.cancel();
    _enableWakeLock();
    setState(() {
      _preset = customPreset;
      _stages = _buildStages(customPreset);
      _stageIndex = 0;
      _remainingSeconds = _stages.first.seconds;
      _isRunning = false;
      _isActiveMode = true;
      _hasPromptedSave = false;
    });
    unawaited(HapticFeedback.selectionClick());
    _start();
  }

  void _exitActiveMode() {
    _pause();
    _disableWakeLock();
    setState(() => _isActiveMode = false);
  }

  void _toggleRunning() {
    if (_isRunning) {
      _pause();
    } else {
      unawaited(HapticFeedback.selectionClick());
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
      _promptSaveFinishedSession();
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
      _hasPromptedSave = false;
    });
  }

  Future<void> _promptSaveFinishedSession() async {
    if (_hasPromptedSave || !mounted) {
      return;
    }

    _hasPromptedSave = true;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF252A2F),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Сохранить тренировку?', style: TextStyle(color: Color(0xFFF6F1E8), fontWeight: FontWeight.w900)),
          content: Text(
            'Протокол ${_preset.title} завершён. Добавить его в дневник тренировок?',
            style: const TextStyle(color: Color(0xB3F6F1E8), fontWeight: FontWeight.w700),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Не сейчас', style: TextStyle(color: Color(0x99F6F1E8), fontWeight: FontWeight.w800)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _workColor,
                foregroundColor: const Color(0xFF1A1D20),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (shouldSave != true || !mounted) {
      return;
    }

    await ref.read(trainingSessionsProvider.notifier).addSession(_sessionFromFinishedTimer());

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Тренировка сохранена в дневник')),
    );
  }

  TrainingSession _sessionFromFinishedTimer() {
    final totalMinutes = (_totalSeconds + 59) ~/ 60;

    return TrainingSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: _sessionTypeForPreset(_preset),
      date: DateTime.now(),
      durationMinutes: totalMinutes,
      location: 'Таймер',
      intensity: _intensityForPreset(_preset),
      effort: 'Норма',
      notes: 'Завершён таймер: ${_preset.title}. Работа: ${_clockLabel(_preset.workSeconds)}, отдых: ${_clockLabel(_preset.restSeconds)}, раунды: ${_preset.rounds}.',
    );
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
      selectedIndex: _selectedPresetIndex,
      onSelect: _selectPreset,
      onStart: _enterActiveMode,
      onCreateCustom: _openCustomProtocolForm,
    );
  }
}

class _PresetPickerView extends StatelessWidget {
  const _PresetPickerView({required this.presets, required this.selected, required this.selectedIndex, required this.onSelect, required this.onStart, required this.onCreateCustom});

  final List<_TimerPreset> presets;
  final _TimerPreset selected;
  final int selectedIndex;
  final ValueChanged<_TimerPreset> onSelect;
  final VoidCallback onStart;
  final VoidCallback onCreateCustom;

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
          selectedIndex: selectedIndex,
          onSelect: onSelect,
        ),
        const SizedBox(height: 16),
        _CreateCustomProtocolCard(onTap: onCreateCustom),
        const SizedBox(height: 16),
        _SelectedProtocolCard(preset: selected, onStart: onStart),
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
    final stageColor = _stageColor(stage);
    final roundLabel = stage.isPreparation ? 'Подготовка ${preset.preparationSeconds} сек' : 'Раунд ${stage.round} из ${preset.rounds}';
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
              Text(roundLabel, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(color: stageColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
          child: Text(label, style: TextStyle(color: stageColor, fontSize: 11, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({required this.presets, required this.selected, required this.selectedIndex, required this.onSelect});

  final List<_TimerPreset> presets;
  final _TimerPreset selected;
  final int selectedIndex;
  final ValueChanged<_TimerPreset> onSelect;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = ((screenWidth - 54) / 2).clamp(146.0, 164.0).toDouble();

    return Column(
      children: [
        SizedBox(
          height: 88,
          child: ListView.separated(
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(right: 20),
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final preset = presets[index];
              final isSelected = preset == selected;
              return _PresetChip(width: cardWidth, preset: preset, selected: isSelected, onTap: () => onSelect(preset));
            },
          ),
        ),
        const SizedBox(height: 10),
        _CarouselIndicator(count: presets.length, selectedIndex: selectedIndex),
      ],
    );
  }
}

class _CarouselIndicator extends StatelessWidget {
  const _CarouselIndicator({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isSelected = index == selectedIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: isSelected ? 16 : 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x99D4AF37) : const Color(0x224C5560),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.width, required this.preset, required this.selected, required this.onTap});

  final double width;
  final _TimerPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF302D35) : const Color(0xFF252A2F),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: selected ? const Color(0xCCD4AF37) : const Color(0x164C5560), width: selected ? 1.2 : 1),
          boxShadow: selected ? const [BoxShadow(color: Color(0x14D4AF37), blurRadius: 10, offset: Offset(0, 5))] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(preset.icon, color: selected ? _workColor : const Color(0x99F6F1E8), size: 19),
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


class _CreateCustomProtocolCard extends StatelessWidget {
  const _CreateCustomProtocolCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2E34), Color(0xFF20252A)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x44D4AF37)),
          boxShadow: const [BoxShadow(color: Color(0x0DD4AF37), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: const Color(0x18D4AF37), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.add_rounded, color: _workColor, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Создать свой протокол', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 17, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('Один запуск без сохранения в пресеты', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0x99F6F1E8), size: 24),
          ],
        ),
      ),
    );
  }
}

class _CustomProtocolSheet extends StatefulWidget {
  const _CustomProtocolSheet();

  @override
  State<_CustomProtocolSheet> createState() => _CustomProtocolSheetState();
}

class _CustomProtocolSheetState extends State<_CustomProtocolSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Свой протокол');
  final _workController = TextEditingController(text: '5');
  final _restController = TextEditingController(text: '5');
  final _roundsController = TextEditingController(text: '2');
  final _preparationController = TextEditingController(text: '5');

  @override
  void dispose() {
    _titleController.dispose();
    _workController.dispose();
    _restController.dispose();
    _roundsController.dispose();
    _preparationController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите название';
    }

    return null;
  }

  String? _validateSeconds(String? value, {required bool allowZero}) {
    final number = int.tryParse(value ?? '');
    if (number == null) {
      return 'Введите секунды';
    }

    if (allowZero ? number < 0 : number <= 0) {
      return allowZero ? 'Не меньше 0' : 'Больше 0';
    }

    return null;
  }

  void _confirm() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    Navigator.of(context).pop(
      _TimerPreset(
        title: _titleController.text.trim(),
        subtitle: 'Пользовательский · один запуск',
        workLabel: 'Работа',
        restLabel: 'Отдых',
        workSeconds: int.parse(_workController.text),
        restSeconds: int.parse(_restController.text),
        rounds: int.parse(_roundsController.text),
        preparationSeconds: int.parse(_preparationController.text),
        icon: Icons.tune_rounded,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: const BoxDecoration(
          color: Color(0xFF252A2F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(color: const Color(0x334C5560), borderRadius: BorderRadius.circular(999)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Создать свой протокол', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text('Запустим таймер сразу после подтверждения. Пресет не будет сохранён.', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  _CustomProtocolField(
                    controller: _titleController,
                    label: 'Название',
                    icon: Icons.edit_note_rounded,
                    validator: _validateTitle,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomProtocolField(
                          controller: _workController,
                          label: 'Работа, seconds',
                          icon: Icons.flash_on_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateSeconds(value, allowZero: false),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CustomProtocolField(
                          controller: _restController,
                          label: 'Отдых, seconds',
                          icon: Icons.self_improvement_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateSeconds(value, allowZero: true),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomProtocolField(
                          controller: _roundsController,
                          label: 'Раунды',
                          icon: Icons.repeat_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateSeconds(value, allowZero: false),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CustomProtocolField(
                          controller: _preparationController,
                          label: 'Подготовка, seconds',
                          icon: Icons.hourglass_top_rounded,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validateSeconds(value, allowZero: true),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _confirm(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _workColor,
                        foregroundColor: const Color(0xFF1A1D20),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text('Создать и начать', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomProtocolField extends StatelessWidget {
  const _CustomProtocolField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final isNumber = keyboardType == TextInputType.number;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(color: Color(0xFFF6F1E8), fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0x99F6F1E8), fontWeight: FontWeight.w700),
        prefixIcon: Icon(icon, color: const Color(0x99F6F1E8), size: 20),
        filled: true,
        fillColor: const Color(0xFF1F2429),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x164C5560)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xCCD4AF37), width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE57373)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE57373), width: 1.2),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x164C5560)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: const Color(0x18D4AF37), borderRadius: BorderRadius.circular(14)),
                child: Icon(preset.icon, color: _workColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      preset.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProtocolMetricsStrip(
            metrics: [
              _ProtocolMetric(label: 'Работа', value: _clockLabel(preset.workSeconds)),
              _ProtocolMetric(label: 'Отдых', value: _clockLabel(preset.restSeconds)),
              _ProtocolMetric(label: 'Раунды', value: '${preset.rounds}'),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFF1F2429), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_rounded, color: Color(0x99F6F1E8), size: 18),
                const SizedBox(width: 8),
                const Expanded(child: Text('Общее время с подготовкой', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800))),
                Text(_durationLabel(preset.totalSecondsWithPreparation), style: const TextStyle(color: Color(0xDDF6F1E8), fontSize: 14, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: _workColor,
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

class _ProtocolMetric {
  const _ProtocolMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class _ProtocolMetricsStrip extends StatelessWidget {
  const _ProtocolMetricsStrip({required this.metrics});

  final List<_ProtocolMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2429),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x104C5560)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < metrics.length; index++) ...[
            Expanded(child: _ProtocolMetricColumn(metric: metrics[index])),
            if (index < metrics.length - 1) Container(width: 1, height: 30, color: const Color(0x144C5560)),
          ],
        ],
      ),
    );
  }
}

class _ProtocolMetricColumn extends StatelessWidget {
  const _ProtocolMetricColumn({required this.metric});

  final _ProtocolMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          metric.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(metric.label, style: const TextStyle(color: Color(0x8CF6F1E8), fontSize: 11, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _FocusedTimerCard extends StatelessWidget {
  const _FocusedTimerCard({
    required this.stage,
    required this.remainingSeconds,
    required this.stageProgress,
    required this.overallProgress,
    required this.isFinished,
  });

  final _TimerStage stage;
  final int remainingSeconds;
  final double stageProgress;
  final double overallProgress;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    final stageColor = _stageColor(stage);
    final displayLabel = isFinished ? 'ГОТОВО' : stage.label.toUpperCase();
    final timeLabel = isFinished ? '00:00' : _clockLabel(remainingSeconds);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final ringSize = (screenWidth * 0.68).clamp(246.0, 292.0).toDouble();
    final ringStroke = (ringSize * 0.055).clamp(13.0, 16.0).toDouble();
    final innerMargin = (ringSize * 0.115).clamp(28.0, 34.0).toDouble();
    final timeFontSize = (ringSize * 0.22).clamp(54.0, 64.0).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
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
                    boxShadow: [BoxShadow(color: stageColor.withValues(alpha: 0.18), blurRadius: 24, spreadRadius: 3)],
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
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 7,
              backgroundColor: const Color(0x224C5560),
              valueColor: const AlwaysStoppedAnimation<Color>(_workColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Прогресс протокола', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${(overallProgress * 100).round()}%', style: const TextStyle(color: _workColor, fontSize: 12, fontWeight: FontWeight.w900)),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: const Color(0x18D4AF37), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.skip_next_rounded, color: _workColor, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hasNext ? 'Следующий этап' : 'Финиш протокола', style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 11, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(hasNext ? '${nextStage!.label}: ${_clockLabel(nextStage.seconds)}' : 'Все этапы выполнены', style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Text(remainingTotalLabel, style: const TextStyle(color: _workColor, fontSize: 12, fontWeight: FontWeight.w900)),
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
                backgroundColor: _workColor,
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

class _TimerPreset {
  const _TimerPreset({
    required this.title,
    required this.subtitle,
    required this.workLabel,
    required this.restLabel,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    required this.preparationSeconds,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String workLabel;
  final String restLabel;
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final int preparationSeconds;
  final IconData icon;

  int get totalSeconds => (workSeconds + restSeconds) * rounds - restSeconds;

  int get totalSecondsWithPreparation => totalSeconds + preparationSeconds;
}

class _TimerStage {
  const _TimerStage({required this.label, required this.seconds, required this.round, required this.isWork, required this.isPreparation});

  final String label;
  final int seconds;
  final int round;
  final bool isWork;
  final bool isPreparation;
}

List<_TimerStage> _buildStages(_TimerPreset preset) {
  final stages = <_TimerStage>[];

  if (preset.preparationSeconds > 0) {
    stages.add(_TimerStage(label: 'Подготовка', seconds: preset.preparationSeconds, round: 1, isWork: false, isPreparation: true));
  }

  for (var round = 1; round <= preset.rounds; round++) {
    stages.add(_TimerStage(label: preset.workLabel, seconds: preset.workSeconds, round: round, isWork: true, isPreparation: false));

    if (round != preset.rounds && preset.restSeconds > 0) {
      stages.add(_TimerStage(label: preset.restLabel, seconds: preset.restSeconds, round: round, isWork: false, isPreparation: false));
    }
  }

  return stages;
}

Color _stageColor(_TimerStage stage) {
  if (stage.isPreparation || stage.isWork) {
    return _workColor;
  }

  return _restColor;
}

String _sessionTypeForPreset(_TimerPreset preset) {
  if (preset.title.contains('ARC')) {
    return 'Трудность';
  }

  return 'Фингерборд';
}

int _intensityForPreset(_TimerPreset preset) {
  if (preset.title == 'Max Hang') {
    return 8;
  }

  if (preset.title.contains('ARC')) {
    return 4;
  }

  return 7;
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
