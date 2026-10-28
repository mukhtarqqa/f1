import 'package:flutter/material.dart';
import '../models/f1_models.dart';

/// Static example content for demonstrating UI and navigation.
/// This is NOT a live timing feed, nor verified 2026 standings/calendar.
abstract final class DemoRepository {
  static const races = <F1Race>[
    F1Race(id: 'australia', name: 'Австралия Гран-приі', country: 'Австралия', circuit: 'Albert Park', date: 'Үлгі күнтізбе', round: 1, isCompleted: true),
    F1Race(id: 'japan', name: 'Жапония Гран-приі', country: 'Жапония', circuit: 'Suzuka International Racing Course', date: 'Үлгі күнтізбе', round: 2, isCompleted: true),
    F1Race(id: 'monaco', name: 'Монако Гран-приі', country: 'Монако', circuit: 'Circuit de Monaco', date: 'Үлгі күнтізбе', round: 3, isCompleted: true),
    F1Race(id: 'usa', name: 'АҚШ Гран-приі', country: 'АҚШ', circuit: 'Circuit of the Americas, Austin', date: '23–25 ҚАЗ • ДЕМО', round: 4),
    F1Race(id: 'mexico', name: 'Мексика Гран-приі', country: 'Мексика', circuit: 'Autódromo Hermanos Rodríguez', date: '30 ҚАЗ – 01 ҚАР • ДЕМО', round: 5),
    F1Race(id: 'brazil', name: 'Сан-Паулу Гран-приі', country: 'Бразилия', circuit: 'Interlagos', date: '06–08 ҚАР • ДЕМО', round: 6),
    F1Race(id: 'vegas', name: 'Лас-Вегас Гран-приі', country: 'АҚШ', circuit: 'Las Vegas Street Circuit', date: '19–21 ҚАР • ДЕМО', round: 7),
    F1Race(id: 'qatar', name: 'Катар Гран-приі', country: 'Катар', circuit: 'Lusail International Circuit', date: '27–29 ҚАР • ДЕМО', round: 8),
    F1Race(id: 'abudhabi', name: 'Абу-Даби Гран-приі', country: 'БАӘ', circuit: 'Yas Marina Circuit', date: 'ЖЕЛТОҚСАН • ДЕМО', round: 9),
  ];

  static const drivers = <F1Standing>[
    F1Standing(position: 1, name: 'Жүргізуші A', team: 'Команда 1', points: 286, color: Color(0xFFE10600)),
    F1Standing(position: 2, name: 'Жүргізуші B', team: 'Команда 2', points: 270, color: Color(0xFFFFCA70)),
    F1Standing(position: 3, name: 'Жүргізуші C', team: 'Команда 3', points: 237, color: Color(0xFF41D8A6)),
    F1Standing(position: 4, name: 'Жүргізуші D', team: 'Команда 4', points: 210, color: Color(0xFF778FDB)),
    F1Standing(position: 5, name: 'Жүргізуші E', team: 'Команда 5', points: 186, color: Color(0xFFC7A2E8)),
    F1Standing(position: 6, name: 'Жүргізуші F', team: 'Команда 6', points: 171, color: Color(0xFF94A1AE)),
  ];
  static const teams = <F1Standing>[
    F1Standing(position: 1, name: 'Команда 1', team: 'Конструкторлар', points: 520, color: Color(0xFFE10600)),
    F1Standing(position: 2, name: 'Команда 2', team: 'Конструкторлар', points: 480, color: Color(0xFFFFCA70)),
    F1Standing(position: 3, name: 'Команда 3', team: 'Конструкторлар', points: 435, color: Color(0xFF41D8A6)),
    F1Standing(position: 4, name: 'Команда 4', team: 'Конструкторлар', points: 391, color: Color(0xFF778FDB)),
    F1Standing(position: 5, name: 'Команда 5', team: 'Конструкторлар', points: 237, color: Color(0xFFC7A2E8)),
  ];

  static F1Race raceById(String id) => races.firstWhere(
    (r) => r.id == id,
    orElse: () => races.first,
  );
}
