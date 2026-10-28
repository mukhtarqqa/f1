import 'package:flutter/material.dart';
import '../../data/models/f1_models.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/races/presentation/race_detail_screen.dart';
import '../../features/reminders/presentation/reminder_editor_screen.dart';
import '../../features/results/presentation/results_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';

abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const shell = '/app';
  static const race = '/race';
  static const results = '/results';
  static const search = '/search';
  static const reminder = '/reminder';
  static const settings = '/settings';
}

class ReminderArgs {
  const ReminderArgs({this.raceId, this.existing});
  final String? raceId;
  final F1Reminder? existing;
}

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    Widget view;
    switch (settings.name) {
      case Routes.splash:
        view = const SplashScreen();
        break;
      case Routes.onboarding:
        view = const OnboardingScreen();
        break;
      case Routes.login:
        view = const AuthScreen(mode: AuthMode.login);
        break;
      case Routes.register:
        view = const AuthScreen(mode: AuthMode.register);
        break;
      case Routes.shell:
        view = AppShell(initialIndex: settings.arguments is int ? settings.arguments as int : 0);
        break;
      case Routes.race:
        view = RaceDetailScreen(raceId: settings.arguments is String ? settings.arguments as String : 'usa');
        break;
      case Routes.results:
        view = ResultsScreen(raceId: settings.arguments is String ? settings.arguments as String : 'usa');
        break;
      case Routes.search:
        view = const SearchScreen();
        break;
      case Routes.reminder:
        final arg = settings.arguments;
        view = ReminderEditorScreen(args: arg is ReminderArgs ? arg : const ReminderArgs());
        break;
      case Routes.settings:
        view = const SettingsScreen();
        break;
      default:
        view = const SplashScreen();
        break;
    }
    return MaterialPageRoute<void>(builder: (_) => view, settings: settings);
  }
}
