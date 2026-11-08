import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';

class RaceWeekendSection extends StatelessWidget {
  const RaceWeekendSection({super.key, required this.raceId});

  final String raceId;

  static final _weekends = rootBundle
      .loadString('assets/f1_weekends_2026.json')
      .then((data) => jsonDecode(data) as Map<String, dynamic>);

  static const _labels = {
    'Practice 1': 'Бірінші жаттығу',
    'Practice 2': 'Екінші жаттығу',
    'Practice 3': 'Үшінші жаттығу',
    'Sprint Qualifying': 'Спринт іріктеуі',
    'Sprint': 'Спринт',
    'Qualifying': 'Іріктеу',
    'Race': 'Гран-при',
  };

  Future<void> _open(BuildContext context, String path) async {
    if (await launchUrl(Uri.https('www.formula1.com', path),
            mode: LaunchMode.externalApplication) ||
        !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formula1.com сайтын ашу мүмкін болмады.')),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
        future: _weekends,
        builder: (context, snapshot) {
          final weekend = snapshot.data?[raceId] as Map<String, dynamic>?;
          if (weekend == null) return const SizedBox.shrink();
          final strings = MaterialLocalizations.of(context);
          final sessions =
              (weekend['sessions'] as List).cast<Map<String, dynamic>>();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const SectionHeading('Гран-при кестесі'),
              Text('2026 · Құрылғының жергілікті уақыты',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              for (final session in sessions)
                _sessionTile(context, strings, session),
              F1Button(
                label: 'Formula1.com сайтындағы Гран-при',
                outlined: true,
                icon: Icons.open_in_new,
                onPressed: () =>
                    _open(context, '/en/racing/2026/${weekend['slug']}'),
              ),
            ],
          );
        },
      );

  Widget _sessionTile(BuildContext context, MaterialLocalizations strings,
      Map<String, dynamic> session) {
    final start = DateTime.parse(session['start'] as String).toLocal();
    final name = session['name'] as String;
    final result = session['result'] as String?;
    final time = strings.formatTimeOfDay(TimeOfDay.fromDateTime(start),
        alwaysUse24HourFormat: true);
    return F1ListTile(
      title: _labels[name] ?? name,
      subtitle: '${strings.formatShortDate(start)} · $time'
          '${result == null ? '' : ' · Formula1.com нәтижесі'}',
      leading: const Icon(Icons.schedule, color: F1Colors.red),
      trailing: result == null
          ? const SizedBox.shrink()
          : const Icon(Icons.open_in_new, size: 18),
      onTap: result == null ? null : () => _open(context, result),
    );
  }
}
