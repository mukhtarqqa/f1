import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int current = 0;
  static const labels = <(String, String, String)>[
    ('RACE CALENDAR', 'Жарысты өткізіп алма',
        'Гран-при күндерін және жарыс демалысының бағдарламасын қараңыз.'),
    ('LIVE RESULTS', 'Әр секунд маңызды',
        'Нәтижелерді, орындарды және ұпайларды бір экраннан көріңіз.'),
    ('WORLD STANDINGS', 'Титул үшін күрес',
        'Жүргізушілер мен конструкторлар рейтингін салыстырыңыз.'),
  ];

  void advance() {
    if (current == labels.length - 1) {
      Navigator.pushReplacementNamed(context, Routes.login);
    } else {
      setState(() => current++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (headline, title, description) = labels[current];
    return Scaffold(body: SafeArea(child: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        Row(children: [const F1Logo(), const Spacer(),
          TextButton(onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
            child: const Text('Өткізу'))]),
        const SizedBox(height: 30),
        Expanded(child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24)),
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: const CircuitPainter())),
            Positioned(left: 20, right: 20, bottom: 26,
              child: Text(headline, style: const TextStyle(
                fontSize: 35, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
              )),
          ]),
        )),
        const SizedBox(height: 32),
        Align(alignment: Alignment.centerLeft,
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
        const SizedBox(height: 10),
        Align(alignment: Alignment.centerLeft,
          child: Text(description, style: Theme.of(context).textTheme.bodySmall)),
        const SizedBox(height: 22),
        Row(children: List.generate(labels.length, (i) => Container(
          width: i == current ? 38 : 8, height: 5,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: i == current ? F1Colors.red : F1Colors.border,
            borderRadius: BorderRadius.circular(4)),
        ))),
        const SizedBox(height: 24),
        F1Button(label: current == 2 ? 'Кіру' : 'Келесі', onPressed: advance),
      ])),
    ))));
  }
}
