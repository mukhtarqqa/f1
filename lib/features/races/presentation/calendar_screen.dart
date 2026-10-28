import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/repositories/f1_repository.dart';
import '../../../data/store/app_store.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showAddRaceDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final countryController = TextEditingController();
    final circuitController = TextEditingController();
    final dateController = TextEditingController(text: '12–14 ҚАЗ • АЛДАҒЫ');
    final roundController = TextEditingController(text: '10');

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Жаңа Гран-при қосу (Create)'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Жарыс атауы'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Атауын жазыңыз' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Ел'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Елді жазыңыз' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: circuitController,
                  decoration: const InputDecoration(labelText: 'Трасса атауы'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Трассаны жазыңыз' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Өтетін күні'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: roundController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Раунд (кезең №)'),
                  validator: (v) => int.tryParse(v ?? '') == null ? 'Сан енгізіңіз' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Бас тарту'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final store = StoreScope.of(context);
              final id = 'race_${DateTime.now().millisecondsSinceEpoch}';
              final newRace = F1Race(
                id: id,
                circuitId: 'cota',
                name: nameController.text.trim(),
                country: countryController.text.trim(),
                circuit: circuitController.text.trim(),
                date: dateController.text.trim(),
                round: int.parse(roundController.text.trim()),
                isCompleted: false,
              );
              store.saveRace(newRace);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Жаңа жарыс SQLite базасына қосылды!')),
              );
            },
            child: const Text('Қосу'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final races = store.races;

    return PageContent(children: [
      F1Header(
        title: 'Күнтізбе',
        subtitle: '2026 • Офлайн SQLite жарыстар тізімі',
        actions: [
          IconButton(
            tooltip: 'Жаңа жарыс қосу (Create)',
            icon: const Icon(Icons.add_circle_outline, color: F1Colors.red, size: 28),
            onPressed: () => _showAddRaceDialog(context),
          ),
        ],
      ),

      // 13. Іздеу өрісі
      TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Жарыс, ел немесе трасса бойынша іздеу...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: store.raceSearchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    store.setRaceSearchQuery('');
                  },
                )
              : null,
        ),
        onChanged: store.setRaceSearchQuery,
      ),
      const SizedBox(height: 16),

      // 14. Сүзгілеу (Filtering)
      Row(
        children: [
          const Text('Сүзгі: ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Барлығы'),
                  selected: store.raceFilter == RaceFilter.all,
                  onSelected: (_) => store.setRaceFilter(RaceFilter.all),
                ),
                ChoiceChip(
                  label: const Text('Алдағы'),
                  selected: store.raceFilter == RaceFilter.upcoming,
                  onSelected: (_) => store.setRaceFilter(RaceFilter.upcoming),
                ),
                ChoiceChip(
                  label: const Text('Аяқталған'),
                  selected: store.raceFilter == RaceFilter.completed,
                  onSelected: (_) => store.setRaceFilter(RaceFilter.completed),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),

      // 15. Сұрыптау (Sorting by at least two parameters)
      Row(
        children: [
          const Text('Сұрыптау: ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(width: 8),
          DropdownButton<RaceSort>(
            value: store.raceSort,
            underline: const SizedBox(),
            onChanged: (val) {
              if (val != null) store.setRaceSort(val);
            },
            items: const [
              DropdownMenuItem(
                value: RaceSort.roundAsc,
                child: Text('Кезең № (1 -> 9)'),
              ),
              DropdownMenuItem(
                value: RaceSort.roundDesc,
                child: Text('Кезең № (9 -> 1)'),
              ),
              DropdownMenuItem(
                value: RaceSort.nameAsc,
                child: Text('Атауы (А -> Я)'),
              ),
              DropdownMenuItem(
                value: RaceSort.nameDesc,
                child: Text('Атауы (Я -> А)'),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 20),

      SectionHeading('Жарыстар • ${races.length}'),

      // 17. Бос жағдайды өңдеу (Empty state)
      if (races.isEmpty)
        EmptyState(
          title: 'Жарыстар табылмады',
          subtitle: store.raceSearchQuery.isNotEmpty
              ? '"${store.raceSearchQuery}" сұранысы бойынша нәтиже жоқ.'
              : 'Таңдалған сүзгі бойынша жарыс жоқ.',
          icon: Icons.search_off,
          action: OutlinedButton(
            onPressed: () {
              searchController.clear();
              store.setRaceSearchQuery('');
              store.setRaceFilter(RaceFilter.all);
            },
            child: const Text('Сүзгіні тазалау'),
          ),
        )
      else
        ...races.map(
          (race) => RaceCard(
            race: race,
            onTap: () => Navigator.pushNamed(context, Routes.race, arguments: race.id),
            trailing: IconButton(
              tooltip: store.isFavorite(race.id)
                  ? 'Таңдаулыдан алып тастау'
                  : 'Таңдаулыға қосу',
              icon: Icon(
                store.isFavorite(race.id) ? Icons.favorite : Icons.favorite_border,
                color: store.isFavorite(race.id) ? F1Colors.red : null,
              ),
              onPressed: () => store.toggleFavorite(race.id),
            ),
          ),
        ),
    ]);
  }
}
