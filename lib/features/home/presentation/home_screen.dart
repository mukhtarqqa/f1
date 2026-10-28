import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/repositories/demo_repository.dart';
import '../../shell/presentation/app_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final next = DemoRepository.races.firstWhere((r) => !r.isCompleted);
    return PageContent(children: [
      F1Header(title: 'Басты бет', subtitle: 'Формула-1 әлемінің шолуы', actions: [
        IconButton(tooltip: 'Іздеу', icon: const Icon(Icons.search),
          onPressed: () => Navigator.pushNamed(context, Routes.search)),
      ]),
      Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 5, width: double.infinity,
              child: ColoredBox(color: F1Colors.red)),
          Padding(padding: const EdgeInsets.all(20), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('FEATURED RACE • ДЕМО', style: TextStyle(
                color: F1Colors.red, fontSize: 11, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Text('UNITED STATES', style: Theme.of(context).textTheme.headlineLarge),
              Text('GRAND PRIX', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 10),
              Text(next.circuit, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 17),
              Row(children: [F1Tag(next.date), const Spacer(),
                OutlinedButton(onPressed: () => Navigator.pushNamed(
                    context, Routes.race, arguments: next.id),
                  child: const Text('Мәлімет'))]),
            ],
          )),
        ]),
      ),
      const SizedBox(height: 26),
      const SectionHeading('Маусым шолуы'),
      const Row(children: [
        Expanded(child: StatCard(value: '09', label: 'Демо жарыстар')),
        SizedBox(width: 12),
        Expanded(child: StatCard(value: '05', label: 'Демо командалар')),
      ]),
      const SizedBox(height: 26),
      const SectionHeading('Жылдам қолжетімділік'),
      F1ListTile(title: 'Жарыстар күнтізбесі', subtitle: 'Барлық Гран-при',
        leading: const Icon(Icons.calendar_month_outlined, color: F1Colors.red),
        onTap: () => AppShell.select(context, 1)),
      F1ListTile(title: 'Жарыс нәтижелері', subtitle: 'Мәре реті мен ұпайлар',
        leading: const Icon(Icons.flag_outlined, color: F1Colors.red),
        onTap: () => Navigator.pushNamed(context, Routes.results, arguments: 'usa')),
      F1ListTile(title: 'Чемпионат ұпайлары', subtitle: 'Жүргізушілер және командалар',
        leading: const Icon(Icons.emoji_events_outlined, color: F1Colors.red),
        onTap: () => AppShell.select(context, 2)),
      Text('Көрсетілген мәліметтер — Figma прототипін тексеруге арналған үлгілер.',
        style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}
