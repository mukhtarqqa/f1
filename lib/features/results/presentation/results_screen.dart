import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/repositories/demo_repository.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.raceId});
  final String raceId;

  @override
  Widget build(BuildContext context) {
    final race = DemoRepository.raceById(raceId);
    final results = DemoRepository.drivers;
    return Scaffold(appBar: AppBar(title: const Text('Нәтижелер')), body: PageContent(children: [
      F1Header(title: 'Жарыс нәтижелері', subtitle: race.name),
      const F1Tag('DEMO DATA', isActive: true),
      const SizedBox(height: 24),
      const SectionHeading('Подиум'),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (final index in [1, 0, 2])
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              height: index == 0 ? 164 : 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: index == 0 ? Border.all(color: F1Colors.red) : null),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('P${index + 1}', style: TextStyle(fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: index == 0 ? F1Colors.red : null)),
                const SizedBox(height: 7),
                Text(results[index].name, textAlign: TextAlign.center,
                  maxLines: 2, style: const TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w700)),
                const SizedBox(height: 9),
                Text('${[25, 18, 15][index]} PTS', style: const TextStyle(
                    color: F1Colors.green, fontWeight: FontWeight.w800)),
              ]),
            ),
          )),
      ]),
      const SizedBox(height: 30),
      const SectionHeading('Мәре кестесі'),
      ...results.asMap().entries.map((entry) => F1ListTile(
        leading: Text('${entry.key + 1}'.padLeft(2, '0'), style: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w900, color: F1Colors.red)),
        title: entry.value.name,
        subtitle: entry.value.team,
        trailing: Text('${[25, 18, 15, 12, 10, 8][entry.key]} PTS',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      )),
      const SizedBox(height: 18),
      F1Button(label: 'Чемпионат кестесіне өту',
        onPressed: () => Navigator.pushNamed(context, Routes.shell, arguments: 2)),
      const SizedBox(height: 12),
      Text('Маңызды: бұл жарыс нәтижелері ресми деректер емес, оқу мақсатындағы үлгі.',
        style: Theme.of(context).textTheme.bodySmall),
    ]));
  }
}
