import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/repositories/demo_repository.dart';
import '../../../data/store/app_store.dart';
import '../../shell/presentation/app_shell.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final races = DemoRepository.races.where((r) => store.isFavorite(r.id)).toList();
    return PageContent(children: [
      const F1Header(title: 'Таңдаулылар', subtitle: 'Сақталған жарыстар'),
      if (races.isEmpty) EmptyState(
        title: 'Таңдаулылар бос', subtitle: 'Күнтізбеден жарыстарды сақтаңыз.',
        icon: Icons.favorite_border,
        action: F1Button(label: 'Күнтізбеге өту',
          onPressed: () => AppShell.select(context, 1))),
      if (races.isNotEmpty) ...[
        SectionHeading('Жарыстар • ${races.length}'),
        ...races.map((race) => RaceCard(race: race,
          onTap: () => Navigator.pushNamed(context, Routes.race, arguments: race.id),
          trailing: IconButton(
            tooltip: 'Таңдаулылардан өшіру',
            icon: const Icon(Icons.favorite, color: F1Colors.red),
            onPressed: () => store.toggleFavorite(race.id),
          ),
        )),
      ],
    ]);
  }
}
