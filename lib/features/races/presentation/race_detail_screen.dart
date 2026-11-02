import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';
import '../../../data/store/app_store.dart';

class RaceDetailScreen extends StatelessWidget {
  const RaceDetailScreen({super.key, required this.raceId});
  final String raceId;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final race = store.raceById(raceId);
    final favorite = store.isFavorite(race.id);

    return Scaffold(
      appBar: AppBar(
        title: const F1Logo(),
        actions: [
          IconButton(
            tooltip: favorite ? 'Таңдаулылардан алып тастау' : 'Таңдаулыларға қосу',
            icon: Icon(
              favorite ? Icons.favorite : Icons.favorite_border,
              color: favorite ? F1Colors.red : null,
            ),
            onPressed: () => store.toggleFavorite(race.id),
          ),
        ],
      ),
      body: PageContent(children: [
        Container(
          height: 235,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: 0,
                top: 16,
                width: 220,
                height: 170,
                child: CustomPaint(painter: CircuitPainter()),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    F1Tag(
                      race.isCompleted ? 'АЯҚТАЛДЫ' : 'АЛДАҒЫ ЖАРЫС',
                      isActive: !race.isCompleted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      race.name.toUpperCase(),
                      style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      race.circuit,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const SectionHeading('Жарыс мәліметі'),
        F1ListTile(
          title: 'Өтетін елі',
          subtitle: race.country,
          leading: const Icon(Icons.location_on_outlined, color: F1Colors.red),
        ),
        F1ListTile(
          title: 'Күні мен мәртебесі',
          subtitle: race.date,
          leading: const Icon(Icons.calendar_today_outlined, color: F1Colors.red),
        ),
        F1ListTile(
          title: 'Айналымдар саны (Laps)',
          subtitle: '${race.laps} айналым · Раунд ${race.round}',
          leading: const Icon(Icons.repeat_outlined, color: F1Colors.red),
        ),
        const SizedBox(height: 12),
        const SectionHeading('Әрекеттер'),
        F1Button(
          label: race.isCompleted
              ? 'Алдағы жарыстарға қайтару'
              : 'Аяқталды деп белгілеу',
          outlined: true,
          icon: race.isCompleted ? Icons.replay : Icons.check_circle_outline,
          onPressed: () {
            final updated = race.copyWith(
              isCompleted: !race.isCompleted,
              date: race.isCompleted ? 'АЛДАҒЫ' : 'АЯҚТАЛДЫ',
            );
            store.updateRace(updated);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Жарыс күйі жаңартылды: ${updated.isCompleted ? "Аяқталды" : "Алдағы"}')),
            );
          },
        ),
        const SizedBox(height: 12),
        F1Button(
          label: 'Еске салғыш орнату',
          icon: Icons.notifications_active_outlined,
          onPressed: () => Navigator.pushNamed(
            context,
            Routes.reminder,
            arguments: ReminderArgs(raceId: race.id),
          ),
        ),
        const SizedBox(height: 12),
        F1Button(
          label: 'Нәтижелерді қарау',
          outlined: true,
          onPressed: () => Navigator.pushNamed(
            context,
            Routes.results,
            arguments: race.id,
          ),
        ),
      ]),
    );
  }
}
