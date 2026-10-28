import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/repositories/demo_repository.dart';
import '../../../data/store/app_store.dart';
import '../../shell/presentation/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return PageContent(children: [
      const F1Header(title: 'Профиль', subtitle: 'Менің F1 әлемім'),
      F1Panel(child: Row(children: [
        const CircleAvatar(radius: 36, backgroundColor: F1Colors.red,
          child: Text('F1', style: TextStyle(color: Colors.white,
            fontSize: 23, fontWeight: FontWeight.w900))),
        const SizedBox(width: 18),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('F1 жанкүйері', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 5),
            Text(store.email, style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis),
          ],
        )),
      ])),
      const SizedBox(height: 22),
      Row(children: [
        Expanded(child: StatCard(value: '${store.favorites.length}', label: 'Таңдаулы')),
        const SizedBox(width: 12),
        Expanded(child: StatCard(value: '${store.reminders.length}', label: 'Еске салғыш')),
      ]),
      const SizedBox(height: 25),
      const SectionHeading('Менің аккаунтым'),
      F1ListTile(title: 'Таңдаулылар', subtitle: 'Сақталған Гран-при',
        leading: const Icon(Icons.favorite_border, color: F1Colors.red),
        onTap: () => AppShell.select(context, 3)),
      F1ListTile(title: 'Баптаулар', subtitle: 'Тіл және хабарламалар',
        leading: const Icon(Icons.settings_outlined, color: F1Colors.red),
        onTap: () => Navigator.pushNamed(context, Routes.settings)),
      const SizedBox(height: 9),
      const SectionHeading('Еске салғыштар'),
      if (store.reminders.isEmpty)
        const F1Panel(child: Text('Қазір ешбір еске салғыш сақталмаған.')),
      ...store.reminders.map((F1Reminder reminder) => F1ListTile(
        title: reminder.title,
        subtitle: '${DemoRepository.raceById(reminder.raceId).name} · ${reminder.advanceMinutes} мин',
        leading: const Icon(Icons.notifications_outlined, color: F1Colors.red),
        trailing: PopupMenuButton<String>(
          tooltip: 'Еске салғыш әрекеттері',
          onSelected: (choice) {
            if (choice == 'edit') Navigator.pushNamed(context, Routes.reminder,
              arguments: ReminderArgs(existing: reminder));
            if (choice == 'delete') store.removeReminder(reminder.id);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Өзгерту')),
            PopupMenuItem(value: 'delete', child: Text('Жою')),
          ],
        ),
      )),
      const SizedBox(height: 18),
      F1Button(label: 'Жаңа еске салғыш', outlined: true, icon: Icons.add,
        onPressed: () => Navigator.pushNamed(context, Routes.reminder)),
      const SizedBox(height: 12),
      F1Button(label: 'Шығу', outlined: true, onPressed: () =>
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (_) => false)),
    ]);
  }
}
