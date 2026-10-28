import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../races/presentation/calendar_screen.dart';
import '../../standings/presentation/standings_screen.dart';

/// Five primary destinations. NavigationRail is used for tablets/large windows.
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  static void select(BuildContext context, int index) {
    final shell = context.findAncestorStateOfType<AppShellState>();
    if (shell != null) shell.select(index);
  }

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  late int index;
  @override
  void initState() {
    super.initState();
    index = widget.initialIndex.clamp(0, 4).toInt();
  }

  void select(int value) => setState(() => index = value);

  static const pages = [
    HomeScreen(),
    CalendarScreen(),
    StandingsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  static const destinations = <NavigationDestination>[
    NavigationDestination(icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home), label: 'Басты'),
    NavigationDestination(icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month), label: 'Күнтізбе'),
    NavigationDestination(icon: Icon(Icons.emoji_events_outlined),
        selectedIcon: Icon(Icons.emoji_events), label: 'Ұпай'),
    NavigationDestination(icon: Icon(Icons.favorite_border),
        selectedIcon: Icon(Icons.favorite), label: 'Таңдаулы'),
    NavigationDestination(icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person), label: 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
        final isWide = box.maxWidth >= 720;
        final content = IndexedStack(index: index, children: pages);
        return Scaffold(
          body: isWide
              ? Row(children: [
                  NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: select,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: Theme.of(context).cardColor,
                    selectedIconTheme: const IconThemeData(color: F1Colors.red),
                    destinations: destinations
                        .map((d) => NavigationRailDestination(
                            icon: d.icon, selectedIcon: d.selectedIcon, label: Text(d.label)))
                        .toList(),
                  ),
                  Expanded(child: content),
                ])
              : content,
          bottomNavigationBar: isWide ? null : NavigationBar(
            selectedIndex: index,
            onDestinationSelected: select,
            destinations: destinations,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        );
      });
}
