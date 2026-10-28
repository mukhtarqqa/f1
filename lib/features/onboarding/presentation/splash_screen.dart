import 'package:flutter/material.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/f1_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) Navigator.pushReplacementNamed(context, Routes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(child: Center(child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 160, width: 280,
              child: CustomPaint(painter: CircuitPainter())),
            const SizedBox(height: 25),
            const F1Logo(large: true),
            const SizedBox(height: 18),
            Text('Формула-1. Барлығы бір жерде.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 40),
            const SizedBox(width: 110,
              child: LinearProgressIndicator(color: F1Colors.red, minHeight: 3)),
          ]),
        ))),
      );
}
