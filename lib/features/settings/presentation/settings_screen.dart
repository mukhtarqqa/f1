import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/store/app_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Баптаулар')),
      body: PageContent(children: [
        const F1Header(title: 'Баптаулар', subtitle: 'Қосымша және деректер қорын басқару'),
        const SectionHeading('Жалпы'),
        F1Panel(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.language),
                title: const Text('Қосымша тілі'),
                subtitle: Text(store.language),
                trailing: const Icon(Icons.expand_more),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (sheetContext) => SafeArea(
                    child: Wrap(
                      children: [
                        const ListTile(title: Text('Тілді таңдау')),
                        for (final name in ['Қазақша', 'Русский', 'English'])
                          ListTile(
                            title: Text(name),
                            trailing: store.language == name ? const Icon(Icons.check) : null,
                            onTap: () {
                              store.setLanguage(name);
                              Navigator.pop(sheetContext);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Хабарламалар'),
                subtitle: const Text('Еске салғыш хабарландырулары'),
                value: store.notifications,
                onChanged: store.setNotifications,
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Қараңғы режим (Dark mode)'),
                subtitle: const Text('F1 қараңғы/жарық стилін таңдау'),
                value: store.darkMode,
                onChanged: store.setDarkMode,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeading('Деректерді басқару'),
        F1Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.cloud_off_outlined, color: F1Colors.red),
                title: Text('Жұмыс режимі'),
                subtitle: Text('Офлайн режимде толық қолжетімді'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.storage_outlined, color: F1Colors.red),
                title: const Text('Сақталған ақпарат'),
                subtitle: Text(
                  '${store.races.length} жарыс, ${store.drivers.length} жүргізуші, '
                  '${store.teams.length} команда, ${store.circuits.length} трасса, '
                  '${store.reminders.length} еске салғыш, ${store.favorites.length} таңдаулы',
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restart_alt, color: F1Colors.amber),
                title: const Text('Деректерді қалпына келтіру'),
                subtitle: const Text('Бастапқы күнтізбе мен ұпайлар күйіне қайтару'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Деректерді қалпына келтіру'),
                      content: const Text('Барлық өзгерістер бастапқы күйіне қайтарылады. Жалғастырасыз ба?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Жоқ')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Иә')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await store.resetDatabase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Деректер сәтті қалпына келтірілді')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text(
          'F1 Tracker — жарыстар күнтізбесі, нәтижелері мен жеке еске салғыштарыңыз әрқашан құрылғыңызда сақталады.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ]),
    );
  }
}
