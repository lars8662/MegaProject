// ignore_for_file: prefer_const_constructors, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/training_session.dart';
import '../state/training_sessions_provider.dart';

class NewTrainingScreen extends ConsumerStatefulWidget {
  const NewTrainingScreen({super.key});

  @override
  ConsumerState<NewTrainingScreen> createState() => _NewTrainingScreenState();
}

class _NewTrainingScreenState extends ConsumerState<NewTrainingScreen> {
  static const _types = [
    _TrainingType('Боулдеринг', Icons.landscape_rounded),
    _TrainingType('Трудность', Icons.route_rounded),
    _TrainingType('Фингерборд', Icons.back_hand_rounded),
    _TrainingType('Силовая', Icons.fitness_center_rounded),
    _TrainingType('ОФП', Icons.accessibility_new_rounded),
    _TrainingType('Восстановление', Icons.spa_rounded),
  ];

  static const _efforts = ['Легко', 'Норма', 'Тяжело'];

  int _selectedTypeIndex = 0;
  int _intensity = 7;
  String _selectedEffort = 'Норма';
  DateTime _selectedDate = DateTime.now();

  final _durationController = TextEditingController(text: '120');
  final _locationController = TextEditingController(text: 'Скалодром');
  final _notesController = TextEditingController();
  String? _durationError;

  @override
  void dispose() {
    _durationController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/diary');
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Color(0xFF1A1D20),
              surface: Color(0xFF252A2F),
              onSurface: Color(0xFFF6F1E8),
            ),
            dialogBackgroundColor: const Color(0xFF1A1D20),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _saveTraining() async {
    final selectedType = _types[_selectedTypeIndex].label;
    final durationMinutes = int.tryParse(_durationController.text.trim());

    if (durationMinutes == null || durationMinutes <= 0) {
      setState(() => _durationError = 'Введите длительность в минутах');
      return;
    }

    setState(() => _durationError = null);

    final location = _locationController.text.trim().isEmpty ? 'Скалодром' : _locationController.text.trim();
    final notes = _notesController.text.trim();

    final session = TrainingSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: selectedType,
      date: _selectedDate,
      durationMinutes: durationMinutes,
      location: location,
      intensity: _intensity,
      effort: _selectedEffort,
      notes: notes,
    );

    await ref.read(trainingSessionsProvider.notifier).addSession(session);

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF252A2F),
          content: Text(
            'Тренировка “$selectedType” добавлена в дневник.',
            style: const TextStyle(color: Color(0xFFF6F1E8), fontWeight: FontWeight.w700),
          ),
        ),
      );

    context.go('/diary');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D20),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 24 + bottomInset),
          children: [
            const Text(
              'Дневник скалолаза',
              style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _BackButton(onTap: _goBack),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Новая тренировка', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 31, fontWeight: FontWeight.w900, height: 1)),
                      SizedBox(height: 6),
                      Text('Ключевые детали сессии.', style: TextStyle(color: Color(0xB3F6F1E8), fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Тип тренировки',
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _types.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.42,
                ),
                itemBuilder: (context, index) => _TypeTile(
                  type: _types[index],
                  selected: _selectedTypeIndex == index,
                  onTap: () => setState(() => _selectedTypeIndex = index),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DetailsFormCard(
              selectedDate: _selectedDate,
              onDateTap: _pickDate,
              durationController: _durationController,
              locationController: _locationController,
              durationError: _durationError,
              onDurationChanged: (_) {
                if (_durationError != null) setState(() => _durationError = null);
              },
            ),
            const SizedBox(height: 12),
            _IntensityCard(
              intensity: _intensity,
              selectedEffort: _selectedEffort,
              efforts: _efforts,
              onIntensityChanged: (value) => setState(() => _intensity = value.round()),
              onEffortChanged: (effort) => setState(() => _selectedEffort = effort),
            ),
            const SizedBox(height: 12),
            _NotesFormCard(controller: _notesController),
            const SizedBox(height: 16),
            _SaveButton(onTap: _saveTraining),
          ],
        ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF252A2F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x164C5560)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.4)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type, required this.selected, required this.onTap});
  final _TrainingType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF343039) : const Color(0xFF20252A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFFD4AF37) : const Color(0x144C5560), width: selected ? 1.4 : 1),
          boxShadow: selected ? const [BoxShadow(color: Color(0x20D4AF37), blurRadius: 16, offset: Offset(0, 8))] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: selected ? const Color(0xFFD4AF37) : const Color(0x99F6F1E8), size: 22),
            const SizedBox(height: 7),
            Text(type.label, textAlign: TextAlign.center, style: TextStyle(color: selected ? const Color(0xFFF6F1E8) : const Color(0xB3F6F1E8), fontSize: 13, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _DetailsFormCard extends StatelessWidget {
  const _DetailsFormCard({required this.selectedDate, required this.onDateTap, required this.durationController, required this.locationController, required this.onDurationChanged, this.durationError});

  final DateTime selectedDate;
  final VoidCallback onDateTap;
  final TextEditingController durationController;
  final TextEditingController locationController;
  final ValueChanged<String> onDurationChanged;
  final String? durationError;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Основное',
      child: Column(
        children: [
          _DateField(date: selectedDate, onTap: onDateTap),
          const SizedBox(height: 10),
          _EditableField(
            controller: durationController,
            icon: Icons.timer_outlined,
            label: 'Длительность',
            suffix: 'мин',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            errorText: durationError,
            onChanged: onDurationChanged,
          ),
          const SizedBox(height: 10),
          _EditableField(
            controller: locationController,
            icon: Icons.location_on_outlined,
            label: 'Место',
            hintText: 'Например: Скалодром',
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 6),
          child: Text('Дата', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF171A1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x124C5560)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Color(0x99F6F1E8), size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(_formatDate(date), style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w800))),
                const Icon(Icons.chevron_right_rounded, color: Color(0x80F6F1E8)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({required this.controller, required this.icon, required this.label, this.hintText, this.suffix, this.keyboardType, this.inputFormatters, this.errorText, this.onChanged, this.textCapitalization = TextCapitalization.none});

  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String? hintText;
  final String? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: const TextStyle(color: Color(0x99F6F1E8), fontSize: 12, fontWeight: FontWeight.w800)),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          style: const TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w800),
          decoration: _inputDecoration(icon: icon, hintText: hintText, suffix: suffix, errorText: errorText),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration({required IconData icon, String? hintText, String? suffix, String? errorText}) {
  return InputDecoration(
    filled: true,
    fillColor: const Color(0xFF171A1E),
    prefixIcon: Icon(icon, color: const Color(0x99F6F1E8), size: 20),
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0x66F6F1E8), fontWeight: FontWeight.w600),
    suffixText: suffix,
    suffixStyle: const TextStyle(color: Color(0x99F6F1E8), fontWeight: FontWeight.w800),
    errorText: errorText,
    errorStyle: const TextStyle(color: Color(0xFFFFB4AB), fontWeight: FontWeight.w700),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0x124C5560))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0x99D4AF37))),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0x99FFB4AB))),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFFB4AB))),
  );
}

String _formatDate(DateTime date) {
  const months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class _IntensityCard extends StatelessWidget {
  const _IntensityCard({required this.intensity, required this.selectedEffort, required this.efforts, required this.onIntensityChanged, required this.onEffortChanged});
  final int intensity;
  final String selectedEffort;
  final List<String> efforts;
  final ValueChanged<double> onIntensityChanged;
  final ValueChanged<String> onEffortChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF252A2F), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x164C5560))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Expanded(child: Text('Интенсивность', style: TextStyle(color: Color(0xFFF6F1E8), fontSize: 15, fontWeight: FontWeight.w800))), Text('$intensity/10', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.w900))]),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(activeTrackColor: const Color(0xFFD4AF37), inactiveTrackColor: const Color(0x334C5560), thumbColor: const Color(0xFFE4C052), overlayColor: const Color(0x22D4AF37), trackHeight: 7, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8), overlayShape: const RoundSliderOverlayShape(overlayRadius: 18)),
            child: Slider(value: intensity.toDouble(), min: 1, max: 10, divisions: 9, onChanged: onIntensityChanged),
          ),
          const SizedBox(height: 8),
          const Text('Самочувствие', style: TextStyle(color: Color(0x99F6F1E8), fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(children: [for (var i = 0; i < efforts.length; i++) ...[Expanded(child: _EffortChip(label: efforts[i], selected: efforts[i] == selectedEffort, onTap: () => onEffortChanged(efforts[i]))), if (i != efforts.length - 1) const SizedBox(width: 8)]]),
        ],
      ),
    );
  }
}

class _EffortChip extends StatelessWidget {
  const _EffortChip({required this.label, required this.onTap, this.selected = false});
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: selected ? const Color(0xFF343039) : const Color(0xFF171A1E), borderRadius: BorderRadius.circular(13), border: Border.all(color: selected ? const Color(0xFFD4AF37) : const Color(0x224C5560))),
        child: Text(label, style: TextStyle(color: selected ? const Color(0xFFD4AF37) : const Color(0xB3F6F1E8), fontSize: 13, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _NotesFormCard extends StatelessWidget {
  const _NotesFormCard({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Заметки',
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 7,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Color(0xFFF6F1E8), height: 1.35, fontSize: 15, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF171A1E),
          hintText: 'Как прошла тренировка? Ощущения, кожа, сон, проекты…',
          hintStyle: const TextStyle(color: Color(0x66F6F1E8), height: 1.35, fontWeight: FontWeight.w600),
          contentPadding: const EdgeInsets.all(14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0x124C5560))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0x99D4AF37))),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF1A1D20), elevation: 0, shadowColor: const Color(0x55D4AF37), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        icon: const Icon(Icons.save_rounded, size: 19),
        label: const Text('Сохранить тренировку', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _TrainingType {
  const _TrainingType(this.label, this.icon);
  final String label;
  final IconData icon;
}
