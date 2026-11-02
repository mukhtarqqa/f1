import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/store/app_store.dart';

/// 8. Create, 10. Update reminder with SQLite persistence
class ReminderEditorScreen extends StatefulWidget {
  const ReminderEditorScreen({super.key, required this.args});
  final ReminderArgs args;

  @override
  State<ReminderEditorScreen> createState() => _ReminderEditorScreenState();
}

class _ReminderEditorScreenState extends State<ReminderEditorScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController notesController;
  late String raceId;
  late int minutes;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.existing;
    raceId = existing?.raceId ?? widget.args.raceId ?? 'usa';
    minutes = existing?.advanceMinutes ?? 60;
    titleController = TextEditingController(text: existing?.title ?? 'Жарыс еске салғышы');
    notesController = TextEditingController(text: existing?.notes ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;
    final store = StoreScope.of(context);
    final isNew = widget.args.existing == null;

    final reminder = F1Reminder(
      id: widget.args.existing?.id ?? 'rem_${DateTime.now().millisecondsSinceEpoch}',
      raceId: raceId,
      advanceMinutes: minutes,
      title: titleController.text.trim(),
      notes: notesController.text.trim(),
      createdAt: widget.args.existing?.createdAt ?? DateTime.now().toIso8601String(),
    );

    store.saveReminder(reminder);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNew
              ? 'Жаңа еске салғыш сақталды'
              : 'Еске салғыш жаңартылды',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.args.existing != null;
    final store = StoreScope.of(context);
    final races = store.races;

    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Өңдеу' : 'Жаңа еске салғыш'),
      ),
      body: PageContent(children: [
        F1Header(
          title: editing ? 'Еске салғышты өзгерту' : 'Жаңа еске салғыш',
          subtitle: 'Жарыс басталар алдында уақытылы хабарландыру',
        ),
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              F1Input(
                label: 'Атауы',
                hint: 'Мысалы: Басты жарысты жіберіп алма',
                controller: titleController,
                prefixIcon: Icons.edit_outlined,
                validator: (v) => v == null || v.trim().isEmpty ? 'Атауын енгізіңіз' : null,
              ),
              const SizedBox(height: 6),
              const Text('Гран-приді таңдаңыз', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: ValueKey(raceId),
                initialValue: races.any((r) => r.id == raceId) ? raceId : (races.isNotEmpty ? races.first.id : null),
                isExpanded: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.flag_outlined)),
                items: races
                    .map(
                      (race) => DropdownMenuItem(
                        value: race.id,
                        child: Text('${race.round}-раунд: ${race.name}', overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (id) {
                  if (id != null) setState(() => raceId = id);
                },
                validator: (v) => v == null ? 'Жарысты таңдаңыз' : null,
              ),
              const SizedBox(height: 20),
              const Text('Еске салу уақыты', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: minutes,
                isExpanded: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.timer_outlined)),
                items: const [
                  DropdownMenuItem(value: 15, child: Text('15 минут қалғанда')),
                  DropdownMenuItem(value: 30, child: Text('30 минут қалғанда')),
                  DropdownMenuItem(value: 60, child: Text('1 сағат қалғанда')),
                  DropdownMenuItem(value: 120, child: Text('2 сағат қалғанда')),
                  DropdownMenuItem(value: 1440, child: Text('1 күн бұрын')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => minutes = v);
                },
              ),
              const SizedBox(height: 20),
              F1Input(
                label: 'Қосымша жазба (Notes)',
                hint: 'Еске салғышқа арналған ескертпе',
                controller: notesController,
                prefixIcon: Icons.notes_outlined,
              ),
              const SizedBox(height: 20),
              const F1Panel(
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: F1Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Еске салғыш белгіленген уақытта жарысты өткізіп алмауға көмектеседі.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              F1Button(
                label: editing ? 'Өзгерісті сақтау' : 'Еске салғыш қосу',
                onPressed: save,
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
