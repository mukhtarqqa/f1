import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/repositories/demo_repository.dart';
import '../../../data/store/app_store.dart';

/// Create/Edit user reminder. Saves only inside AppStore (no OS notifications).
class ReminderEditorScreen extends StatefulWidget {
  const ReminderEditorScreen({super.key, required this.args});
  final ReminderArgs args;
  @override
  State<ReminderEditorScreen> createState() => _ReminderEditorScreenState();
}

class _ReminderEditorScreenState extends State<ReminderEditorScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title;
  late String raceId;
  late int minutes;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.existing;
    raceId = existing?.raceId ?? widget.args.raceId ?? 'usa';
    minutes = existing?.advanceMinutes ?? 60;
    title = TextEditingController(text: existing?.title ?? 'Жарыс еске салғышы');
  }

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    final store = StoreScope.of(context);
    store.saveReminder(F1Reminder(
      id: widget.args.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      raceId: raceId,
      advanceMinutes: minutes,
      title: title.text.trim(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Еске салғыш сақталды')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.args.existing != null;
    return Scaffold(appBar: AppBar(title: Text(editing ? 'Еске салғышты өзгерту' : 'Еске салғыш құру')),
      body: PageContent(children: [
        F1Header(title: editing ? 'Өңдеу' : 'Еске салғыш',
          subtitle: 'Жарысқа хабарландыру параметрлері'),
        Form(key: formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            F1Input(label: 'Атауы', controller: title, prefixIcon: Icons.edit_outlined,
              validator: (v) => v == null || v.trim().isEmpty
                ? 'Атауын енгізіңіз' : null),
            const SizedBox(height: 4),
            const Text('Жарыс', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey(raceId),
              initialValue: raceId,
              isExpanded: true,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.flag_outlined)),
              items: DemoRepository.races.map((race) => DropdownMenuItem(
                value: race.id, child: Text(race.name,
                  overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (id) {if (id != null) setState(() => raceId = id);},
              validator: (v) => v == null ? 'Жарысты таңдаңыз' : null,
            ),
            const SizedBox(height: 24),
            const Text('Еске салу уақыты', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue: minutes,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 минут қалғанда')),
                DropdownMenuItem(value: 30, child: Text('30 минут қалғанда')),
                DropdownMenuItem(value: 60, child: Text('1 сағат қалғанда')),
                DropdownMenuItem(value: 120, child: Text('2 сағат қалғанда')),
              ],
              onChanged: (v) {if (v != null) setState(() => minutes = v);},
            ),
            const SizedBox(height: 24),
            const F1Panel(child: Row(children: [
              Icon(Icons.info_outline, color: F1Colors.red),
              SizedBox(width: 12),
              Expanded(child: Text('Демо режим: еске салғыш қосымша ішінде сақталады. Телефон хабарламасы жіберілмейді.')),
            ])),
            const SizedBox(height: 32),
            F1Button(label: 'Сақтау', onPressed: save),
            const SizedBox(height: 12),
            F1Button(label: 'Болдырмау', outlined: true,
              onPressed: () => Navigator.pop(context)),
          ],
        )),
      ]));
  }
}
