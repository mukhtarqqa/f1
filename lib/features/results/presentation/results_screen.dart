import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/store/app_store.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.raceId});
  final String raceId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Future<List<F1RaceResult>>? _results;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _results ??= _loadResults();
  }

  @override
  void didUpdateWidget(ResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.raceId != oldWidget.raceId) _results = _loadResults();
  }

  Future<List<F1RaceResult>> _loadResults() =>
      StoreScope.of(context, listen: false)
          .repository
          .getRaceResults(widget.raceId);

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final race = store.raceById(widget.raceId);
    final drivers = {for (final driver in store.drivers) driver.id: driver};

    return Scaffold(
      appBar: AppBar(title: const Text('Нәтижелер')),
      body: FutureBuilder<List<F1RaceResult>>(
        future: _results,
        builder: (context, snapshot) {
          final results = snapshot.data ?? const <F1RaceResult>[];
          final top = results
              .where((r) => r.position != null && r.position! <= 3)
              .toList()
            ..sort((a, b) => a.position!.compareTo(b.position!));
          final podium = top.length == 3 ? [top[1], top[0], top[2]] : top;
          return PageContent(children: [
            F1Header(title: 'Жарыс нәтижелері', subtitle: race.name),
            if (snapshot.connectionState != ConnectionState.done)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.hasError)
              EmptyState(
                title: 'Нәтижелерді жүктеу мүмкін болмады',
                subtitle: 'Байланысты тексеріп, қайта көріңіз.',
                icon: Icons.cloud_off_outlined,
                action: OutlinedButton(
                  onPressed: () => setState(() => _results = _loadResults()),
                  child: const Text('Қайта жүктеу'),
                ),
              ),
            if (results.isNotEmpty)
              const F1Tag('ФИНИШ ХАТТАМАСЫ', isActive: true),
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
                          height: podium[i].position == 1 ? 164 : 140,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: podium[i].position == 1
                                ? Border.all(color: F1Colors.red)
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'P${podium[i].position}',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: podium[i].position == 1
                                      ? F1Colors.red
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                drivers[podium[i].driverId]?.name ??
                                    podium[i].driverId.toUpperCase(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                '${podium[i].pointsLabel} PTS',
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
            if (results.isNotEmpty) const SectionHeading('Мәре кестесі'),
            if (results.isEmpty &&
                !snapshot.hasError &&
                snapshot.connectionState == ConnectionState.done)
              const EmptyState(
                title: 'Нәтижелер әлі жарияланбаған',
                subtitle: 'Бұл Гран-при үшін финиш хаттамасы жоқ.',
                icon: Icons.flag_outlined,
              )
            else
              ...results.map(
                (result) => F1ListTile(
                  leading: Text(
                    result.position?.toString().padLeft(2, '0') ??
                        result.status,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: F1Colors.red,
                    ),
                  ),
                  title: drivers[result.driverId]?.name ??
                      result.driverId.toUpperCase(),
                  subtitle: '${result.time} · ${result.laps} айналым',
                  trailing: Text(
                    '${result.pointsLabel} PTS',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            const SizedBox(height: 18),
            F1Button(
              label: 'Чемпионат кестесіне өту',
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.shell, arguments: 2),
            ),
          ]);
        },
      ),
    );
  }
}
