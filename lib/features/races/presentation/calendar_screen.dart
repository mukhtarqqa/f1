import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/repositories/demo_repository.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int filter = 0;
  @override
  Widget build(BuildContext context) {
    final races = DemoRepository.races.where((race) => filter == 0 ||
        (filter == 1 && !race.isCompleted) || (filter == 2 && race.isCompleted)).toList();
    return PageContent(children: [
      F1Header(title: 'Күнтізбе', subtitle: '2026 • Үлгі Гран-при тізімі', actions: [
        IconButton(tooltip: 'Іздеу', icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, Routes.search)),
      ]),
      Wrap(spacing: 8, runSpacing: 8,
        children: ['Барлығы', 'Алдағы', 'Аяқталған'].asMap().entries.map((entry) =>
          ChoiceChip(label: Text(entry.value), selected: filter == entry.key,
            onSelected: (_) => setState(() => filter = entry.key))).toList()),
      const SizedBox(height: 24),
      SectionHeading('Жарыстар • ${races.length}'),
      ...races.map((race) => RaceCard(race: race,
        onTap: () => Navigator.pushNamed(context, Routes.race, arguments: race.id))),
    ]);
  }
}
