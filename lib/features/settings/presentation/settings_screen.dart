import 'package:flutter/material.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/store/app_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(appBar: AppBar(title: const Text('Баптаулар')), body: PageContent(children: [
      const F1Header(title: 'Баптаулар', subtitle: 'Қосымшаны реттеу'),
      const SectionHeading('Жалпы'),
      F1Panel(child: Column(children: [
        ListTile(contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.language), title: const Text('Қосымша тілі'),
          subtitle: Text(store.language),
          trailing: const Icon(Icons.expand_more),
          onTap: () => showModalBottomSheet<void>(context: context,
            builder: (sheetContext) => SafeArea(child: Wrap(children: [
              const ListTile(title: Text('Тілді таңдау (демо)')),
              for (final name in ['Қазақша', 'Русский', 'English'])
                ListTile(title: Text(name),
                  trailing: store.language == name ? const Icon(Icons.check) : null,
                  onTap: () {
                    store.setLanguage(name);
                    Navigator.pop(sheetContext);
                  }),
            ]))),
        ),
        const Divider(),
        SwitchListTile(contentPadding: EdgeInsets.zero,
          title: const Text('Хабарламалар'),
          subtitle: const Text('Демо параметр'),
          value: store.notifications,
          onChanged: store.setNotifications),
        const Divider(),
        SwitchListTile(contentPadding: EdgeInsets.zero,
          title: const Text('Қараңғы режим'),
          subtitle: const Text('Тақырыпты ауыстыру'),
          value: store.darkMode,
          onChanged: store.setDarkMode),
        const Divider(),
        const ListTile(contentPadding: EdgeInsets.zero,
          title: Text('Маусым'), subtitle: Text('2026 • демонстрациялық деректер'),
          trailing: Icon(Icons.flag_outlined)),
      ])),
      const SizedBox(height: 25),
      Text('F1 Tracker — Практикалық жұмыс №3. Тіл таңдауы үлгі ретінде берілген: интерфейс мәтіндері қазақша қалуы мүмкін.',
        style: Theme.of(context).textTheme.bodySmall),
    ]));
  }
}
