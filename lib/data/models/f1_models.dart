import 'package:flutter/material.dart';

/// 1. Автодром / Трасса моделі
class F1Circuit {
  const F1Circuit({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.lengthKm,
    required this.turnsCount,
  });

  final String id;
  final String name;
  final String country;
  final String city;
  final double lengthKm;
  final int turnsCount;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'country': country,
        'city': city,
        'length_km': lengthKm,
        'turns_count': turnsCount,
      };

  factory F1Circuit.fromMap(Map<String, dynamic> map) => F1Circuit(
        id: map['id'] as String,
        name: map['name'] as String,
        country: map['country'] as String,
        city: map['city'] as String,
        lengthKm: (map['length_km'] as num).toDouble(),
        turnsCount: (map['turns_count'] as num).toInt(),
      );

  F1Circuit copyWith({
    String? id,
    String? name,
    String? country,
    String? city,
    double? lengthKm,
    int? turnsCount,
  }) =>
      F1Circuit(
        id: id ?? this.id,
        name: name ?? this.name,
        country: country ?? this.country,
        city: city ?? this.city,
        lengthKm: lengthKm ?? this.lengthKm,
        turnsCount: turnsCount ?? this.turnsCount,
      );
}

/// 2. Команда / Конструктор моделі
class F1Team {
  const F1Team({
    required this.id,
    required this.name,
    required this.baseCountry,
    required this.powerUnit,
    required this.points,
    required this.championships,
    required this.colorHex,
  });

  final String id;
  final String name;
  final String baseCountry;
  final String powerUnit;
  final int points;
  final int championships;
  final int colorHex;

  Color get color => Color(colorHex);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'base_country': baseCountry,
        'power_unit': powerUnit,
        'points': points,
        'championships': championships,
        'color_hex': colorHex,
      };

  factory F1Team.fromMap(Map<String, dynamic> map) => F1Team(
        id: map['id'] as String,
        name: map['name'] as String,
        baseCountry: map['base_country'] as String,
        powerUnit: map['power_unit'] as String,
        points: (map['points'] as num).toInt(),
        championships: (map['championships'] as num).toInt(),
        colorHex: (map['color_hex'] as num).toInt(),
      );

  F1Team copyWith({
    String? id,
    String? name,
    String? baseCountry,
    String? powerUnit,
    int? points,
    int? championships,
    int? colorHex,
  }) =>
      F1Team(
        id: id ?? this.id,
        name: name ?? this.name,
        baseCountry: baseCountry ?? this.baseCountry,
        powerUnit: powerUnit ?? this.powerUnit,
        points: points ?? this.points,
        championships: championships ?? this.championships,
        colorHex: colorHex ?? this.colorHex,
      );
}

/// 3. Жүргізуші (Пилот) моделі
class F1Driver {
  const F1Driver({
    required this.id,
    required this.teamId,
    required this.name,
    required this.code,
    required this.number,
    required this.country,
    required this.points,
    required this.podiums,
  });

  final String id;
  final String teamId;
  final String name;
  final String code;
  final int number;
  final String country;
  final int points;
  final int podiums;

  Map<String, dynamic> toMap() => {
        'id': id,
        'team_id': teamId,
        'name': name,
        'code': code,
        'number': number,
        'country': country,
        'points': points,
        'podiums': podiums,
      };

  factory F1Driver.fromMap(Map<String, dynamic> map) => F1Driver(
        id: map['id'] as String,
        teamId: map['team_id'] as String,
        name: map['name'] as String,
        code: map['code'] as String,
        number: (map['number'] as num).toInt(),
        country: map['country'] as String,
        points: (map['points'] as num).toInt(),
        podiums: (map['podiums'] as num).toInt(),
      );

  F1Driver copyWith({
    String? id,
    String? teamId,
    String? name,
    String? code,
    int? number,
    String? country,
    int? points,
    int? podiums,
  }) =>
      F1Driver(
        id: id ?? this.id,
        teamId: teamId ?? this.teamId,
        name: name ?? this.name,
        code: code ?? this.code,
        number: number ?? this.number,
        country: country ?? this.country,
        points: points ?? this.points,
        podiums: podiums ?? this.podiums,
      );
}

/// 4. Гран-при / Жарыс моделі
class F1Race {
  const F1Race({
    required this.id,
    required this.circuitId,
    required this.name,
    required this.country,
    required this.circuit,
    required this.date,
    required this.round,
    this.laps = 56,
    this.isCompleted = false,
    this.winnerDriverId,
  });

  final String id;
  final String circuitId;
  final String name;
  final String country;
  final String circuit;
  final String date;
  final int round;
  final int laps;
  final bool isCompleted;
  final String? winnerDriverId;

  Map<String, dynamic> toMap() => {
        'id': id,
        'circuit_id': circuitId,
        'name': name,
        'country': country,
        'circuit': circuit,
        'date': date,
        'round': round,
        'laps': laps,
        'is_completed': isCompleted ? 1 : 0,
        'winner_driver_id': winnerDriverId,
      };

  factory F1Race.fromMap(Map<String, dynamic> map) => F1Race(
        id: map['id'] as String,
        circuitId: map['circuit_id'] as String,
        name: map['name'] as String,
        country: map['country'] as String,
        circuit: map['circuit'] as String,
        date: map['date'] as String,
        round: (map['round'] as num).toInt(),
        laps: (map['laps'] as num?)?.toInt() ?? 56,
        isCompleted: (map['is_completed'] as int? ?? 0) == 1,
        winnerDriverId: map['winner_driver_id'] as String?,
      );

  F1Race copyWith({
    String? id,
    String? circuitId,
    String? name,
    String? country,
    String? circuit,
    String? date,
    int? round,
    int? laps,
    bool? isCompleted,
    String? winnerDriverId,
  }) =>
      F1Race(
        id: id ?? this.id,
        circuitId: circuitId ?? this.circuitId,
        name: name ?? this.name,
        country: country ?? this.country,
        circuit: circuit ?? this.circuit,
        date: date ?? this.date,
        round: round ?? this.round,
        laps: laps ?? this.laps,
        isCompleted: isCompleted ?? this.isCompleted,
        winnerDriverId: winnerDriverId ?? this.winnerDriverId,
      );
}

/// 5. Еске салғыш моделі
class F1Reminder {
  const F1Reminder({
    required this.id,
    required this.raceId,
    required this.title,
    required this.advanceMinutes,
    this.notes = '',
    this.createdAt = '',
  });

  final String id;
  final String raceId;
  final String title;
  final int advanceMinutes;
  final String notes;
  final String createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'race_id': raceId,
        'title': title,
        'advance_minutes': advanceMinutes,
        'notes': notes,
        'created_at': createdAt.isEmpty ? DateTime.now().toIso8601String() : createdAt,
      };

  factory F1Reminder.fromMap(Map<String, dynamic> map) => F1Reminder(
        id: map['id'] as String,
        raceId: map['race_id'] as String,
        title: map['title'] as String,
        advanceMinutes: (map['advance_minutes'] as num).toInt(),
        notes: (map['notes'] as String?) ?? '',
        createdAt: (map['created_at'] as String?) ?? '',
      );

  F1Reminder copyWith({
    String? id,
    String? raceId,
    String? title,
    int? advanceMinutes,
    String? notes,
    String? createdAt,
  }) =>
      F1Reminder(
        id: id ?? this.id,
        raceId: raceId ?? this.raceId,
        title: title ?? this.title,
        advanceMinutes: advanceMinutes ?? this.advanceMinutes,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// 6. Таңдаулы объект моделі
class F1Favorite {
  const F1Favorite({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
  });

  final String id;
  final String targetType; // 'race', 'driver', 'team'
  final String targetId;
  final String createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'target_type': targetType,
        'target_id': targetId,
        'created_at': createdAt,
      };

  factory F1Favorite.fromMap(Map<String, dynamic> map) => F1Favorite(
        id: map['id'] as String,
        targetType: map['target_type'] as String,
        targetId: map['target_id'] as String,
        createdAt: map['created_at'] as String,
      );
}

/// Чемпионат кестесіне арналған визуалды көрініс
class F1Standing {
  const F1Standing({
    required this.position,
    required this.name,
    required this.points,
    required this.team,
    required this.color,
  });

  final int position;
  final String name;
  final int points;
  final String team;
  final Color color;
}
