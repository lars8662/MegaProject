import 'package:flutter/material.dart';

class TrainingSession {
  const TrainingSession({
    required this.id,
    required this.type,
    required this.date,
    required this.durationMinutes,
    required this.location,
    required this.intensity,
    required this.effort,
    required this.notes,
    this.exerciseName,
    this.source,
    this.rounds,
    this.repsPerRound,
    this.extraWeightKg,
    this.workSeconds,
    this.restSeconds,
    this.preparationSeconds,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: json['type'] as String? ?? 'Боулдеринг',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      durationMinutes: _intFromJson(json['durationMinutes']) ?? 0,
      location: json['location'] as String? ?? 'Скалодром',
      intensity: _intFromJson(json['intensity']) ?? 5,
      effort: json['effort'] as String? ?? 'Норма',
      notes: json['notes'] as String? ?? '',
      exerciseName: json['exerciseName'] as String?,
      source: json['source'] as String?,
      rounds: _intFromJson(json['rounds']),
      repsPerRound: _intFromJson(json['repsPerRound']),
      extraWeightKg: json['extraWeightKg']?.toString(),
      workSeconds: _intFromJson(json['workSeconds']),
      restSeconds: _intFromJson(json['restSeconds']),
      preparationSeconds: _intFromJson(json['preparationSeconds']),
    );
  }

  final String id;
  final String type;
  final DateTime date;
  final int durationMinutes;
  final String location;
  final int intensity;
  final String effort;
  final String notes;
  final String? exerciseName;
  final String? source;
  final int? rounds;
  final int? repsPerRound;
  final String? extraWeightKg;
  final int? workSeconds;
  final int? restSeconds;
  final int? preparationSeconds;

  static int? _intFromJson(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  TrainingSession copyWith({
    String? type,
    DateTime? date,
    int? durationMinutes,
    String? location,
    int? intensity,
    String? effort,
    String? notes,
    String? exerciseName,
    String? source,
    int? rounds,
    int? repsPerRound,
    String? extraWeightKg,
    int? workSeconds,
    int? restSeconds,
    int? preparationSeconds,
  }) {
    return TrainingSession(
      id: id,
      type: type ?? this.type,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      location: location ?? this.location,
      intensity: intensity ?? this.intensity,
      effort: effort ?? this.effort,
      notes: notes ?? this.notes,
      exerciseName: exerciseName ?? this.exerciseName,
      source: source ?? this.source,
      rounds: rounds ?? this.rounds,
      repsPerRound: repsPerRound ?? this.repsPerRound,
      extraWeightKg: extraWeightKg ?? this.extraWeightKg,
      workSeconds: workSeconds ?? this.workSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      preparationSeconds: preparationSeconds ?? this.preparationSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'location': location,
      'intensity': intensity,
      'effort': effort,
      'notes': notes,
      'exerciseName': exerciseName,
      'source': source,
      'rounds': rounds,
      'repsPerRound': repsPerRound,
      'extraWeightKg': extraWeightKg,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'preparationSeconds': preparationSeconds,
    };
  }

  String get formattedDate {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get durationLabel {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours == 0) {
      return '$minutes мин';
    }

    if (minutes == 0) {
      return '$hoursч';
    }

    return '$hoursч $minutesмин';
  }

  bool get isTimerSession => source == 'timer';

  String get displayTitle {
    final title = exerciseName?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }

    return type;
  }

  String get timerDetails {
    final parts = <String>[];
    if (rounds != null) {
      final reps = repsPerRound;
      if (reps != null) {
        parts.add('$rounds ${_roundsLabel(rounds!)} × $reps ${_repetitionsLabel(reps)}');
      } else {
        parts.add('$rounds ${_roundsLabel(rounds!)}');
      }
    }

    final weight = extraWeightKg?.trim();
    if (weight != null && weight.isNotEmpty) {
      parts.add('$weight кг');
    }

    if (workSeconds != null && restSeconds != null) {
      parts.add('работа/отдых: $workSeconds/$restSeconds сек');
    }

    if (preparationSeconds != null && preparationSeconds! > 0) {
      parts.add('подготовка: $preparationSeconds сек');
    }

    return parts.join(' · ');
  }

  String get detail {
    if (isTimerSession) {
      final details = timerDetails;
      if (details.isNotEmpty) {
        return details;
      }
    }

    if (notes.trim().isNotEmpty) {
      return notes.trim();
    }

    return 'Интенсивность $intensity/10, самочувствие: ${effort.toLowerCase()}.';
  }

  String get meta {
    if (isTimerSession) {
      return 'Источник: Таймер · Самочувствие: ${effort.toLowerCase()}';
    }

    return 'Место: $location · Самочувствие: ${effort.toLowerCase()}';
  }

  static String _roundsLabel(int rounds) {
    final lastTwoDigits = rounds % 100;
    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return 'раундов';
    }

    final lastDigit = rounds % 10;
    if (lastDigit == 1) {
      return 'раунд';
    }

    if (lastDigit >= 2 && lastDigit <= 4) {
      return 'раунда';
    }

    return 'раундов';
  }

  static String _repetitionsLabel(int repetitions) {
    final lastTwoDigits = repetitions % 100;
    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return 'повторений';
    }

    final lastDigit = repetitions % 10;
    if (lastDigit == 1) {
      return 'повторение';
    }

    if (lastDigit >= 2 && lastDigit <= 4) {
      return 'повторения';
    }

    return 'повторений';
  }

  IconData get icon {
    return switch (type) {
      'Боулдеринг' => Icons.landscape_rounded,
      'Трудность' => Icons.route_rounded,
      'Фингерборд' => Icons.back_hand_rounded,
      'Силовая' => Icons.fitness_center_rounded,
      'ОФП' => Icons.accessibility_new_rounded,
      'Восстановление' => Icons.spa_rounded,
      _ => Icons.fitness_center_rounded,
    };
  }
}
