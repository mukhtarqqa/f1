import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/store/app_store.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.raceId});
  final String raceId;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final race = store.raceById(raceId);
    final drivers = store.drivers;

    final podium = drivers.length >= 3 ? [drivers[1], drivers[0], drivers[2]] : drivers;

    return Scaffold(
      appBar: AppBar(title: const Text('Нәтижелер')),
      body: PageContent(children: [
        F1Header(title: 'Жарыс нәтижелері', subtitle: race.name),
        const F1Tag('SQLITE НӘТИЖЕЛЕРІ', isActive: true),
        const SizedBox(height: 24),
        if (podium.isNotEmpty) ...[
          const SectionHeading('Подиум'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < podium.length && i < 3; i++) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      height: i == 1 ? 164 : 140, // Winner in center
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: i == 1 ? Border.all(color: F1Colors.red) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            i == 1 ? 'P1' : (i == 0 ? 'P2' : 'P3'),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: i == 1 ? F1Colors.red : null,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            podium[i].name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            '${i == 1 ? 25 : (i == 0 ? 18 : 15)} PTS',
                            style: const TextStyle(
                              color: F1Colors.green,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 30),
        ],
        const SectionHeading('Мәре кестесі (SQLite)'),
        if (drivers.isEmpty)
          const EmptyState(
            title: 'Нәтижелер жоқ',
            subtitle: 'Деректер қорында жүргізушілер жазбасы табылмады.',
            icon: Icons.flag_outlined,
          )
        else
          ...drivers.asMap().entries.map(
            (entry) => F1ListTile(
              leading: Text(
                '${entry.key + 1}'.padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: F1Colors.red,
                ),
              ),
              title: entry.value.name,
              subtitle: '${entry.value.country} · №${entry.value.number}',
              trailing: Text(
                '${[25, 18, 15, 12, 10, 8, 6, 4, 2, 1].elementAtOrNull(entry.key) ?? 0} PTS',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        const SizedBox(height: 18),
        F1Button(
          label: 'Чемпионат кестесіне өту',
          onPressed: () => Navigator.pushNamed(context, Routes.shell, arguments: 2),
        ),
      ]),
    );
  }
}
