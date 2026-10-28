import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/repositories/demo_repository.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});
  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  bool constructors = false;
  @override
  Widget build(BuildContext context) {
    final entries = constructors ? DemoRepository.teams : DemoRepository.drivers;
    final maxPoints = entries.first.points.toDouble();
    return PageContent(children: [
      F1Header(title: constructors ? 'Конструкторлар' : 'Чемпионат',
          subtitle: 'Жүргізушілер мен командалардың ұпайлары'),
      Row(children: [
        Expanded(child: F1Button(label: 'Жүргізушілер',
          outlined: constructors,
          onPressed: () => setState(() => constructors = false))),
        const SizedBox(width: 9),
        Expanded(child: F1Button(label: 'Командалар',
          outlined: !constructors,
          onPressed: () => setState(() => constructors = true))),
      ]),
      const SizedBox(height: 24),
      const SectionHeading('Чемпионат • демо'),
      ...entries.map((e) => _StandingRow(value: e,
        fraction: e.points / maxPoints)),
      const SizedBox(height: 16),
      Text('Осы рейтинг оқу жобасына арналған демонстрациялық мәндерден тұрады.',
        style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.value, required this.fraction});
  final F1Standing value;
  final double fraction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: F1Panel(child: Row(children: [
      SizedBox(width: 42, child: Text('${value.position}'.padLeft(2, '0'),
        style: TextStyle(color: value.position == 1 ? F1Colors.red : F1Colors.muted,
          fontSize: 23, fontWeight: FontWeight.w900))),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(value.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800))),
            Text('${value.points} PTS', style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 6),
          Text(value.team, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(value: fraction, minHeight: 5,
              color: value.color, backgroundColor: F1Colors.border)),
        ],
      )),
    ])),
  );
}
