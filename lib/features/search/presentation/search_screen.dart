import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/store/app_store.dart';

/// 13. Деректерді атауы немесе басқа белгісі бойынша іздеу
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  String query = '';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final search = query.trim().toLowerCase();

    final races = store.races.where((r) =>
        '${r.name} ${r.country} ${r.circuit}'.toLowerCase().contains(search)).toList();

    final drivers = store.drivers.where((d) =>
        '${d.name} ${d.code} ${d.country}'.toLowerCase().contains(search)).toList();

    final teams = store.teams.where((t) =>
        '${t.name} ${t.baseCountry} ${t.powerUnit}'.toLowerCase().contains(search)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Іздеу')),
      body: PageContent(children: [
        const F1Header(
          title: 'Іздеу',
          subtitle: 'Жарыс, жүргізуші немесе команда',
        ),
        TextField(
          controller: controller,
          autofocus: true,
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            hintText: 'Гран-при, пилот немесе автодром...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Тазалау',
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      controller.clear();
                      query = '';
                    }),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        if (query.isNotEmpty) ...[
          SectionHeading('Жарыстар (${races.length})'),
          ...races.map(
            (race) => RaceCard(
              race: race,
              onTap: () => Navigator.pushNamed(context, Routes.race, arguments: race.id),
            ),
          ),
          if (races.isEmpty && drivers.isEmpty && teams.isEmpty)
            const EmptyState(
              title: 'Ештеңе табылмады',
              subtitle: 'Басқа атаумен немесе қала/ел атымен іздеп көріңіз.',
              icon: Icons.search_off,
            ),
          const SizedBox(height: 18),
          SectionHeading('Жүргізушілер (${drivers.length})'),
          ...drivers.map(
            (d) => F1ListTile(
              title: '#${d.number} ${d.name} (${d.code})',
              subtitle: '${d.country} · Ұпай: ${d.points}',
              leading: const Icon(Icons.person_outline, color: F1Colors.red),
              onTap: () => Navigator.pushNamed(context, Routes.shell, arguments: 2),
            ),
          ),
          const SizedBox(height: 18),
          SectionHeading('Конструкторлар (${teams.length})'),
          ...teams.map(
            (t) => F1ListTile(
              title: t.name,
              subtitle: '${t.baseCountry} · ${t.powerUnit} · Ұпай: ${t.points}',
              leading: Icon(Icons.shield_outlined, color: t.color),
              onTap: () => Navigator.pushNamed(context, Routes.shell, arguments: 2),
            ),
          ),
        ] else ...[
          const F1Panel(
            child: Row(
              children: [
                Icon(Icons.info_outline, color: F1Colors.muted),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Іздеу сөзін жоғарыдағы өріске енгізіңіз.',
                  ),
                ),
              ],
            ),
          ),
        ],
      ]),
    );
  }
}
