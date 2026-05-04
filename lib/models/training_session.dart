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
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      type: json['type'] as String? ?? 'Боулдеринг',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      location: json['location'] as String? ?? 'Скалодром',
      intensity: json['intensity'] as int? ?? 5,
      effort: json['effort'] as String? ?? 'Норма',
      notes: json['notes'] as String? ?? '',
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

  String get detail {
    if (notes.trim().isNotEmpty) {
      return notes.trim();
    }

    return 'Интенсивность $intensity/10, самочувствие: ${effort.toLowerCase()}.';
  }

  String get meta => 'Место: $location · Самочувствие: ${effort.toLowerCase()}';

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
