import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/store/app_store.dart';
import '../../shell/presentation/app_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final races = store.races;
    final nextRace = races.where((r) => !r.isCompleted).firstOrNull ??
        (races.isNotEmpty
            ? races.first
            : const F1Race(
                id: 'usa',
                circuitId: 'cota',
                name: 'АҚШ Гран-приі',
                country: 'АҚШ',
                circuit: 'Circuit of the Americas',
                date: '23–25 ҚАЗ',
                round: 4,
              ));

    return PageContent(children: [
      if (store.errorMessage != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.red.shade900.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: F1Colors.red),
              title: Text(store.errorMessage!, style: const TextStyle(fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: store.clearError,
              ),
            ),
          ),
        ),
      F1Header(
        title: 'Басты бет',
        subtitle: 'Формула-1: офлайн деректер қоры (SQLite)',
        actions: [
          IconButton(
            tooltip: 'Іздеу',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, Routes.search),
          ),
        ],
      ),
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
              width: double.infinity,
              child: ColoredBox(color: F1Colors.red),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'КЕЛЕСІ ЖАРЫС • ОФЛАЙН SQLITE',
                    style: TextStyle(
                      color: F1Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    nextRace.name.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${nextRace.country} · ${nextRace.circuit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      F1Tag(nextRace.date),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Routes.race,
                          arguments: nextRace.id,
                        ),
                        child: const Text('Мәлімет'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      const SectionHeading('Маусым статистикасы (SQLite)'),
      Row(
        children: [
          Expanded(
            child: StatCard(
              value: '${races.length}'.padLeft(2, '0'),
              label: 'Барлық жарыс',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              value: '${store.teams.length}'.padLeft(2, '0'),
              label: 'Командалар',
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: StatCard(
              value: '${store.drivers.length}'.padLeft(2, '0'),
              label: 'Жүргізушілер',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              value: '${store.favorites.length}'.padLeft(2, '0'),
              label: 'Таңдаулылар',
            ),
          ),
        ],
      ),
      const SizedBox(height: 26),
      const SectionHeading('Жылдам қолжетімділік'),
      F1ListTile(
        title: 'Жарыстар күнтізбесі',
        subtitle: 'Сүзгілеу және сұрыптау бар',
        leading: const Icon(Icons.calendar_month_outlined, color: F1Colors.red),
        onTap: () => AppShell.select(context, 1),
      ),
      F1ListTile(
        title: 'Жарыс нәтижелері',
        subtitle: 'Мәре реті мен ұпайлар',
        leading: const Icon(Icons.flag_outlined, color: F1Colors.red),
        onTap: () => Navigator.pushNamed(context, Routes.results, arguments: nextRace.id),
      ),
      F1ListTile(
        title: 'Чемпионат ұпайлары',
        subtitle: 'Жүргізушілер мен конструкторлар',
        leading: const Icon(Icons.emoji_events_outlined, color: F1Colors.red),
        onTap: () => AppShell.select(context, 2),
      ),
    ]);
  }
}
