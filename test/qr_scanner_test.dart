import 'package:flutter_test/flutter_test.dart';
import 'package:f1_tracker/data/models/f1_models.dart';
import 'package:f1_tracker/features/qr_scanner/presentation/qr_scanner_screen.dart';

void main() {
  final races = [
    const F1Race(
      id: 'usa',
      circuitId: 'cota',
      name: 'United States Grand Prix',
      country: 'United States',
      circuit: 'Circuit of the Americas',
      date: '23 October',
      round: 4,
    ),
  ];

  test('QR payload resolves a known race id case-insensitively', () {
    expect(parseF1RaceQrCode('F1RACE:USA', races), 'usa');
  });

  test('QR payload rejects malformed and unknown race ids', () {
    expect(parseF1RaceQrCode('F1RACE:unknown', races), isNull);
    expect(parseF1RaceQrCode('https://example.com/usa', races), isNull);
  });
}
