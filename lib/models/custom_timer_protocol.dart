class CustomTimerProtocol {
  const CustomTimerProtocol({
    required this.id,
    required this.name,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    required this.preparationSeconds,
    this.repsPerRound,
    this.extraWeightKg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomTimerProtocol.fromJson(Map<String, dynamic> json) {
    return CustomTimerProtocol(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Свой протокол',
      workSeconds: _intFromJson(json['workSeconds']) ?? 1,
      restSeconds: _intFromJson(json['restSeconds']) ?? 0,
      rounds: _intFromJson(json['rounds']) ?? 1,
      preparationSeconds: _intFromJson(json['preparationSeconds']) ?? 0,
      repsPerRound: _intFromJson(json['repsPerRound']),
      extraWeightKg: json['extraWeightKg']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  final String id;
  final String name;
  final int workSeconds;
  final int restSeconds;
  final int rounds;
  final int preparationSeconds;
  final int? repsPerRound;
  final String? extraWeightKg;
  final DateTime createdAt;
  final DateTime updatedAt;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'rounds': rounds,
      'preparationSeconds': preparationSeconds,
      'repsPerRound': repsPerRound,
      'extraWeightKg': extraWeightKg,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
