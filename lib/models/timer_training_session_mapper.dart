import 'training_session.dart';

TrainingSession trainingSessionFromFinishedTimer({
  required String id,
  required DateTime date,
  required String timerTitle,
  required bool isCustom,
  required int totalSeconds,
  required int workSeconds,
  required int restSeconds,
  required int rounds,
  required int preparationSeconds,
  int? repsPerRound,
  String? extraWeightKg,
}) {
  final totalMinutes = (totalSeconds + 59) ~/ 60;

  return TrainingSession(
    id: id,
    type: _sessionTypeForTimer(timerTitle: timerTitle, isCustom: isCustom),
    date: date,
    durationMinutes: totalMinutes,
    location: isCustom ? '' : 'Таймер',
    intensity: _intensityForTimer(timerTitle),
    effort: 'Норма',
    notes: isCustom
        ? ''
        : 'Завершён таймер: $timerTitle. '
            'Работа: ${_clockLabel(workSeconds)}, '
            'отдых: ${_clockLabel(restSeconds)}, раунды: $rounds.',
    exerciseName: isCustom ? timerTitle : null,
    source: isCustom ? 'timer' : null,
    rounds: isCustom ? rounds : null,
    repsPerRound: isCustom ? repsPerRound : null,
    extraWeightKg: isCustom ? extraWeightKg : null,
    workSeconds: isCustom ? workSeconds : null,
    restSeconds: isCustom ? restSeconds : null,
    preparationSeconds: isCustom ? preparationSeconds : null,
  );
}

String _sessionTypeForTimer({
  required String timerTitle,
  required bool isCustom,
}) {
  if (isCustom) {
    return 'ОФП';
  }

  if (timerTitle.contains('ARC')) {
    return 'Трудность';
  }

  return 'Фингерборд';
}

int _intensityForTimer(String timerTitle) {
  if (timerTitle == 'Max Hang') {
    return 8;
  }

  if (timerTitle.contains('ARC')) {
    return 4;
  }

  return 7;
}

String _clockLabel(int secondsTotal) {
  final minutes = secondsTotal ~/ 60;
  final seconds = secondsTotal % 60;
  final paddedMinutes = minutes.toString().padLeft(2, '0');
  final paddedSeconds = seconds.toString().padLeft(2, '0');
  return '$paddedMinutes:$paddedSeconds';
}
