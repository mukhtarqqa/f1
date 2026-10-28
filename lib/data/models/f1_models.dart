import 'package:flutter/material.dart';

class F1Race {
  const F1Race({
    required this.id,
    required this.name,
    required this.country,
    required this.circuit,
    required this.date,
    required this.round,
    this.isCompleted = false,
  });

  final String id;
  final String name;
  final String country;
  final String circuit;
  final String date;
  final int round;
  final bool isCompleted;
}

class F1Standing {
  const F1Standing({required this.position, required this.name, required this.points,
    required this.team, required this.color});

  final int position;
  final String name;
  final int points;
  final String team;
  final Color color;
}

class F1Reminder {
  const F1Reminder({required this.id, required this.title, required this.raceId,
    required this.advanceMinutes});

  final String id;
  final String title;
  final String raceId;
  final int advanceMinutes;

  F1Reminder copyWith({String? title, String? raceId, int? advanceMinutes}) => F1Reminder(
    id: id,
    title: title ?? this.title,
    raceId: raceId ?? this.raceId,
    advanceMinutes: advanceMinutes ?? this.advanceMinutes,
  );
}
