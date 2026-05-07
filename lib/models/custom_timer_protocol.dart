class CustomTimerProtocol {
  const CustomTimerProtocol({
    required this.id,
    required this.name,
    required this.workSeconds,
    required this.restSeconds,
    required this.rounds,
    required this.preparationSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomTimerProtocol.fromJson(Map<String, dynamic> json) {
    return CustomTimerProtocol(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? 'Свой протокол',
      workSeconds: json['workSeconds'] as int? ?? 1,
      restSeconds: json['restSeconds'] as int? ?? 0,
      rounds: json['rounds'] as int? ?? 1,
      preparationSeconds: json['preparationSeconds'] as int? ?? 0,
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
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'rounds': rounds,
      'preparationSeconds': preparationSeconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
