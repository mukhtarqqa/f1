import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/repositories/demo_repository.dart';

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
    final search = query.trim().toLowerCase();
    final races = DemoRepository.races.where((r) =>
        '${r.name} ${r.country} ${r.circuit}'.toLowerCase().contains(search)).toList();
    final drivers = DemoRepository.drivers.where((d) =>
        '${d.name} ${d.team}'.toLowerCase().contains(search)).toList();
    return Scaffold(appBar: AppBar(title: const Text('Іздеу')), body: PageContent(children: [
      const F1Header(title: 'Іздеу', subtitle: 'Жарыс, жүргізуші немесе команда'),
      TextField(
        controller: controller,
        autofocus: true,
        onChanged: (value) => setState(() => query = value),
        decoration: InputDecoration(
          hintText: 'Гран-при, жүргізуші немесе трасса...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isEmpty ? null : IconButton(
            tooltip: 'Тазалау', icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              controller.clear();
              query = '';
            })),
        ),
      ),
      const SizedBox(height: 24),
      SectionHeading('Жарыстар (${races.length})'),
      ...races.map((race) => RaceCard(race: race,
        onTap: () => Navigator.pushNamed(context, Routes.race, arguments: race.id))),
      if (races.isEmpty && drivers.isEmpty) const EmptyState(
        title: 'Ештеңе табылмады', subtitle: 'Басқа сөзбен іздеп көріңіз',
        icon: Icons.search_off),
      const SizedBox(height: 18),
      SectionHeading('Жүргізушілер (${drivers.length})'),
      ...drivers.map((d) => F1ListTile(title: d.name, subtitle: d.team,
        leading: const Icon(Icons.person_outline, color: F1Colors.red),
        onTap: () => Navigator.pushNamed(context, Routes.shell, arguments: 2))),
    ]));
  }
}
