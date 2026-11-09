import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/models/f1_models.dart';
import '../../../data/repositories/f1_repository.dart';
import '../../../data/store/app_store.dart';
import '../../../data/database/race_realtime.dart';
import '../../../data/database/supabase_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TextEditingController searchController = TextEditingController();
  bool _refreshing = false;
  bool _syncing = false;

  Future<void> _syncF1() async {
    final store = StoreScope.of(context, listen: false);
    final token = SupabaseService.client.auth.currentSession?.accessToken;
    if (_syncing || !store.canManageRaces || token == null) return;
    setState(() => _syncing = true);
    var message = 'F1 деректерін жаңарту мүмкін болмады.';
    try {
      final response = await http.post(
        Uri.base.resolve('/api/sync-f1'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 130));
      if (response.statusCode == 200) {
        await store.refreshAll();
        message = 'F1 деректері жаңартылды.';
      } else if (response.statusCode == 409) {
        message = 'Жаңарту жүріп жатыр немесе F1 деректері толық емес.';
      }
    } catch (_) {
      // Keep the existing calendar visible when the server is unavailable.
    } finally {
      if (mounted) {
        setState(() => _syncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _showRaceDialog(BuildContext context, {F1Race? race}) async {
    final store = StoreScope.of(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    await showDialog<void>(
      context: context,
      builder: (_) => _RaceEditorDialog(
        race: race,
        store: store,
        onSaved: () {
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(race == null
                  ? 'Жарыс серверге сақталды'
                  : 'Жарыс серверде жаңартылды'),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteRace(BuildContext context, F1Race race) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Жарысты өшіру'),
        content: Text('"${race.name}" жарысын серверден өшіресіз бе?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Бас тарту'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Өшіру'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final succeeded =
        await StoreScope.of(context, listen: false).deleteRace(race.id);
    if (!context.mounted) return;
    if (succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Жарыс серверден өшірілді')),
      );
    }
  }

  Future<void> _refreshRaces(BuildContext context) async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await StoreScope.of(context, listen: false).refreshRaces();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final races = store.races;

    return PageContent(children: [
      F1Header(
        title: 'Күнтізбе',
        subtitle: '2026 маусымының жарыстар кестесі',
        actions: store.canManageRaces
            ? [
                IconButton(
                  tooltip: 'F1 деректерін жаңарту',
                  icon: const Icon(Icons.sync),
                  onPressed: _syncing ? null : _syncF1,
                ),
                IconButton(
                  tooltip: 'Жаңа жарыс қосу',
                  icon: const Icon(Icons.add_circle_outline,
                      color: F1Colors.red, size: 28),
                  onPressed: store.isRaceLoading
                      ? null
                      : () => _showRaceDialog(context),
                ),
              ]
            : const [],
      ),
      if (store.isLoading || store.isRaceLoading || _refreshing || _syncing)
        const LinearProgressIndicator(),
      Card(
        child: ListTile(
          leading: Icon(store.liveConnection == LiveConnection.connected
              ? Icons.cloud_done_outlined
              : Icons.cloud_off_outlined),
          title: Text(switch (store.liveConnection) {
            LiveConnection.connected => 'Live: өзгерістер автоматты жаңарады',
            LiveConnection.connecting => 'Live: қосылуда…',
            LiveConnection.reconnecting =>
              'Live: байланыс қалпына келтірілуде…',
            LiveConnection.stopped => 'Live: байланыс тоқтатылған',
          }),
          subtitle: store.liveConnection == LiveConnection.reconnecting
              ? const Text(
                  'Соңғы деректер сақталды. Қосылғанда қайта жаңарады.')
              : null,
          trailing: store.liveConnection == LiveConnection.connected
              ? null
              : IconButton(
                  tooltip: 'Live байланысын қайта қосу',
                  onPressed: store.reconnectRealtime,
                  icon: const Icon(Icons.sync),
                ),
        ),
      ),
      if (store.errorMessage != null)
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: ListTile(
            leading: const Icon(Icons.cloud_off_outlined),
            title: Text(store.errorMessage!),
            trailing: IconButton(
              tooltip: 'Қайта жүктеу',
              onPressed: _refreshing ? null : () => _refreshRaces(context),
              icon: const Icon(Icons.refresh),
            ),
          ),
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
          const Text('Сүзгі: ',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
          const Text('Сұрыптау: ',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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
            onTap: () =>
                Navigator.pushNamed(context, Routes.race, arguments: race.id),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: store.isFavorite(race.id)
                      ? 'Таңдаулыдан алып тастау'
                      : 'Таңдаулыға қосу',
                  icon: Icon(
                    store.isFavorite(race.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: store.isFavorite(race.id) ? F1Colors.red : null,
                  ),
                  onPressed: () => store.toggleFavorite(race.id),
                ),
                if (store.canManageRaces)
                  PopupMenuButton<String>(
                    enabled: !store.isRaceLoading,
                    tooltip: 'Жарысты басқару',
                    onSelected: (action) {
                      if (action == 'edit') {
                        _showRaceDialog(context, race: race);
                      } else {
                        _deleteRace(context, race);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Өңдеу'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Өшіру'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
    ]);
  }
}

class _RaceEditorDialog extends StatefulWidget {
  const _RaceEditorDialog({
    required this.race,
    required this.store,
    required this.onSaved,
  });

  final F1Race? race;
  final AppStore store;
  final VoidCallback onSaved;

  @override
  State<_RaceEditorDialog> createState() => _RaceEditorDialogState();
}

class _RaceEditorDialogState extends State<_RaceEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _circuitController;
  late final TextEditingController _dateController;
  late final TextEditingController _roundController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final race = widget.race;
    _nameController = TextEditingController(text: race?.name ?? '');
    _countryController = TextEditingController(text: race?.country ?? '');
    _circuitController = TextEditingController(text: race?.circuit ?? '');
    _dateController =
        TextEditingController(text: race?.date ?? '12–14 ҚАЗ • АЛДАҒЫ');
    _roundController = TextEditingController(text: '${race?.round ?? 10}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _circuitController.dispose();
    _dateController.dispose();
    _roundController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final race = widget.race;
    final updatedRace = F1Race(
      id: race?.id ?? 'race_${DateTime.now().microsecondsSinceEpoch}',
      circuitId: race?.circuitId ?? 'cota',
      name: _nameController.text.trim(),
      country: _countryController.text.trim(),
      circuit: _circuitController.text.trim(),
      date: _dateController.text.trim(),
      round: int.parse(_roundController.text.trim()),
      laps: race?.laps ?? 56,
      isCompleted: race?.isCompleted ?? false,
      winnerDriverId: race?.winnerDriverId,
    );
    final succeeded = race == null
        ? await widget.store.saveRace(updatedRace)
        : await widget.store.updateRace(updatedRace);

    if (!mounted) return;
    if (!succeeded) {
      setState(() => _saving = false);
      return;
    }

    Navigator.pop(context);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final race = widget.race;
    final errorMessage = widget.store.errorMessage;
    return AlertDialog(
      title: Text(race == null ? 'Жаңа Гран-при қосу' : 'Жарысты өңдеу'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Жарыс атауы'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Атауын жазыңыз' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Ел'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Елді жазыңыз' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _circuitController,
                decoration: const InputDecoration(labelText: 'Трасса атауы'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Трассаны жазыңыз' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Өтетін күні'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Күнін жазыңыз' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roundController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Раунд (кезең №)'),
                validator: (v) {
                  final round = int.tryParse(v ?? '');
                  return round == null || round < 1
                      ? '1 немесе одан үлкен сан енгізіңіз'
                      : null;
                },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Бас тарту'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(race == null ? 'Қосу' : 'Сақтау'),
        ),
      ],
    );
  }
}
