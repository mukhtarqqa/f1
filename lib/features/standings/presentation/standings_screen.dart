import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/repositories/f1_repository.dart';
import '../../../data/store/app_store.dart';

void _showDriver(BuildContext context, F1Driver driver, F1Team? team) {
  _showDetails(context, driver.name, [
    F1ListTile(
        title: 'Жарыс нөмірі', subtitle: '#${driver.number} · ${driver.code}'),
    F1ListTile(title: 'Ел', subtitle: driver.country),
    if (team != null) F1ListTile(title: 'Команда', subtitle: team.name),
    F1ListTile(title: 'Маусым ұпайы', subtitle: '${driver.points}'),
    F1ListTile(title: 'Подиумдар', subtitle: '${driver.podiums}'),
  ]);
}

void _showDetails(BuildContext context, String title, List<Widget> details) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (context) => Scaffold(
      appBar: AppBar(title: const F1Logo()),
      body: PageContent(children: [SectionHeading(title), ...details]),
    ),
  ));
}

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});
  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  bool constructors = false;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final drivers = store.drivers;
    final teams = store.teams;

    final maxPoints = constructors
        ? (teams.isNotEmpty ? teams.first.points.toDouble() : 1.0)
        : (drivers.isNotEmpty ? drivers.first.points.toDouble() : 1.0);

    return PageContent(children: [
      F1Header(
        title: constructors ? 'Конструкторлар' : 'Чемпионат',
        subtitle: 'Жүргізушілер мен командалар рейтингі',
      ),
      Row(children: [
        Expanded(
          child: F1Button(
            label: 'Жүргізушілер (${drivers.length})',
            outlined: constructors,
            onPressed: () => setState(() => constructors = false),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: F1Button(
            label: 'Командалар (${teams.length})',
            outlined: !constructors,
            onPressed: () => setState(() => constructors = true),
          ),
        ),
      ]),
      const SizedBox(height: 16),

      // 15. Жүргізушілерді сұрыптау басқаруы
      if (!constructors)
        Row(
          children: [
            const Text('Сұрыптау: ',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 8),
            DropdownButton<DriverSort>(
              value: store.driverSort,
              underline: const SizedBox(),
              onChanged: (val) {
                if (val != null) store.setDriverSort(val);
              },
              items: const [
                DropdownMenuItem(
                  value: DriverSort.pointsDesc,
                  child: Text('Ұпай (жоғары -> төмен)'),
                ),
                DropdownMenuItem(
                  value: DriverSort.pointsAsc,
                  child: Text('Ұпай (төмен -> жоғары)'),
                ),
                DropdownMenuItem(
                  value: DriverSort.nameAsc,
                  child: Text('Аты (А -> Я)'),
                ),
                DropdownMenuItem(
                  value: DriverSort.podiumsDesc,
                  child: Text('Подиумдар саны'),
                ),
              ],
            ),
          ],
        ),
      const SizedBox(height: 16),

      SectionHeading(
          constructors ? 'Командалар рейтингі' : 'Жүргізушілер рейтингі'),

      if (!constructors) ...[
        if (drivers.isEmpty)
          const EmptyState(
            title: 'Жүргізушілер табылмады',
            subtitle: 'Деректер қоры бос.',
            icon: Icons.person_off_outlined,
          )
        else
          ...drivers.asMap().entries.map((entry) {
            final d = entry.value;
            final fraction =
                (d.points / (maxPoints == 0 ? 1 : maxPoints)).clamp(0.0, 1.0);
            return _DriverRow(
              position: entry.key + 1,
              driver: d,
              fraction: fraction,
              onTap: () => _showDriver(context, d,
                  teams.where((team) => team.id == d.teamId).firstOrNull),
            );
          }),
      ] else ...[
        if (teams.isEmpty)
          const EmptyState(
            title: 'Командалар табылмады',
            subtitle: 'Деректер қоры бос.',
            icon: Icons.group_off_outlined,
          )
        else
          ...teams.asMap().entries.map((entry) {
            final t = entry.value;
            final fraction =
                (t.points / (maxPoints == 0 ? 1 : maxPoints)).clamp(0.0, 1.0);
            return _TeamRow(
              position: entry.key + 1,
              team: t,
              fraction: fraction,
              onTap: () => _showDetails(context, t.name, [
                F1ListTile(title: 'База', subtitle: t.baseCountry),
                F1ListTile(title: 'Қозғалтқыш', subtitle: t.powerUnit),
                F1ListTile(title: 'Маусым ұпайы', subtitle: '${t.points}'),
                F1ListTile(title: 'Титулдар', subtitle: '${t.championships}'),
                const SectionHeading('Жүргізушілер'),
                for (final driver in drivers.where((d) => d.teamId == t.id))
                  F1ListTile(
                    title: driver.name,
                    subtitle: '#${driver.number} · ${driver.points} PTS',
                    onTap: () => _showDriver(context, driver, t),
                  ),
              ]),
            );
          }),
      ],
      const SizedBox(height: 16),
      Text(
        'Ағымдағы маусымның жеке және конструкторлық есебі.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ]);
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({
    required this.position,
    required this.driver,
    required this.fraction,
    required this.onTap,
  });

  final int position;
  final F1Driver driver;
  final double fraction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: F1Panel(
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  '$position'.padLeft(2, '0'),
                  style: TextStyle(
                    color: position == 1 ? F1Colors.red : F1Colors.muted,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${driver.number} ${driver.name}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: F1Colors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(driver.code,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        Text('${driver.points} PTS',
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${driver.country} · Подиум: ${driver.podiums}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 5,
                        color: F1Colors.red,
                        backgroundColor: F1Colors.border,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.position,
    required this.team,
    required this.fraction,
    required this.onTap,
  });

  final int position;
  final F1Team team;
  final double fraction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: F1Panel(
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  '$position'.padLeft(2, '0'),
                  style: TextStyle(
                    color: position == 1 ? F1Colors.red : F1Colors.muted,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            team.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text('${team.points} PTS',
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${team.baseCountry} · Қозғалтқыш: ${team.powerUnit} · Титул: ${team.championships}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 5,
                        color: team.color,
                        backgroundColor: F1Colors.border,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
