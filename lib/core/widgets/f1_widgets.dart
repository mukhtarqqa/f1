import 'package:flutter/material.dart';
import '../../data/models/f1_models.dart';
import '../theme/app_theme.dart';

class PageContent extends StatelessWidget {
  const PageContent({required this.children, super.key, this.topPadding = 14});
  final List<Widget> children;
  final double topPadding;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, topPadding, 24, 32),
              children: children,
            ),
          ),
        ),
      );
}

class F1Logo extends StatelessWidget {
  const F1Logo({super.key, this.large = false});
  final bool large;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: large ? 14 : 9, vertical: 5),
          decoration: BoxDecoration(color: F1Colors.red, borderRadius: BorderRadius.circular(6)),
          child: Text('F1', style: TextStyle(fontSize: large ? 32 : 17,
              fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Colors.white)),
        ),
        const SizedBox(width: 8),
        Text('TRACKER', style: TextStyle(fontSize: large ? 30 : 16,
            fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
            letterSpacing: 1.3)),
      ]);
}

class F1Header extends StatelessWidget {
  const F1Header({required this.title, this.subtitle, this.actions, super.key});
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const F1Logo(), const Spacer(), ...?actions]),
          const SizedBox(height: 30),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 5),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ]),
      );
}

class F1Button extends StatelessWidget {
  const F1Button({required this.label, required this.onPressed,
    this.icon, this.outlined = false, super.key});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 8)],
      Flexible(child: Text(label, textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700))),
    ]);
    return SizedBox(width: double.infinity, height: 54,
      child: outlined ? OutlinedButton(onPressed: onPressed, child: child)
          : FilledButton(onPressed: onPressed, child: child));
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {this.trailing, super.key});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(child: Text(title.toUpperCase(), style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1))),
          if (trailing != null) trailing!,
        ]),
      );
}

class F1Tag extends StatelessWidget {
  const F1Tag(this.label, {super.key, this.isActive = false});
  final String label;
  final bool isActive;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: isActive ? F1Colors.red : Theme.of(context).cardColor,
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
      );
}

class F1Panel extends StatelessWidget {
  const F1Panel({required this.child, this.padding = const EdgeInsets.all(16), super.key});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16)),
        child: child,
      );
}

class StatCard extends StatelessWidget {
  const StatCard({required this.value, required this.label, super.key});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => F1Panel(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.bodySmall),
        ],
      ));
}

class RaceCard extends StatelessWidget {
  const RaceCard({required this.race, this.onTap, this.trailing, super.key});
  final F1Race race;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(13), clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onTap,
            child: IntrinsicHeight(child: Row(children: [
              Container(width: 4, color: F1Colors.red),
              Expanded(child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(race.date, style: const TextStyle(fontSize: 11, color: F1Colors.red,
                      fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  Text(race.name.toUpperCase(), style: const TextStyle(fontSize: 17,
                      fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text('${race.country} · ${race.circuit}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ]),
              )),
              if (trailing != null) trailing!
              else const Padding(padding: EdgeInsets.only(right: 16),
                  child: Icon(Icons.chevron_right, size: 22)),
            ])),
          ),
        ),
      );
}

class F1ListTile extends StatelessWidget {
  const F1ListTile({required this.title, required this.subtitle,
    this.leading, this.trailing, this.onTap, super.key});
  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Material(color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12), child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: leading,
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
          ),
        ),
      );
}

class F1Input extends StatelessWidget {
  const F1Input({required this.label, this.hint, this.controller, this.validator,
    this.obscureText = false, this.keyboardType, this.prefixIcon, super.key});
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: label, hintText: hint,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
          ),
        ),
      );
}

class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.subtitle,
    required this.icon, this.action, super.key});
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 45),
        child: Column(children: [
          Icon(icon, size: 56, color: F1Colors.red),
          const SizedBox(height: 18),
          Text(title, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall),
          if (action != null) ...[const SizedBox(height: 24), action!],
        ]),
      );
}

class CircuitPainter extends CustomPainter {
  const CircuitPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(size.width * 0.05, size.height * 0.40);
    path.lineTo(size.width * 0.33, size.height * 0.40);
    path.lineTo(size.width * 0.33, size.height * 0.73);
    path.lineTo(size.width * 0.80, size.height * 0.73);
    path.lineTo(size.width * 0.80, size.height * 0.12);
    path.lineTo(size.width * 0.55, size.height * 0.12);
    path.lineTo(size.width * 0.55, size.height * 0.30);
    final glow = Paint()
      ..color = F1Colors.red.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, glow);
    final stroke = Paint()
      ..color = F1Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, stroke);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
