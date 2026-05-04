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

  final String id;
  final String type;
  final DateTime date;
  final int durationMinutes;
  final String location;
  final int intensity;
  final String effort;
  final String notes;

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
      return hours.toString() + 'ч';
    }

    return hours.toString() + 'ч ' + minutes.toString() + 'мин';
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
