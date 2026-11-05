import 'package:flutter/material.dart';
import '../../data/models/f1_models.dart';
import '../../data/store/app_store.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/qr_scanner/presentation/qr_scanner_screen.dart';
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
  static const scanner = '/scanner';
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
        view = AppShell(
            initialIndex:
                settings.arguments is int ? settings.arguments as int : 0);
        break;
      case Routes.race:
        view = RaceDetailScreen(
            raceId: settings.arguments is String
                ? settings.arguments as String
                : 'usa');
        break;
      case Routes.results:
        view = ResultsScreen(
            raceId: settings.arguments is String
                ? settings.arguments as String
                : 'usa');
        break;
      case Routes.search:
        view = const SearchScreen();
        break;
      case Routes.reminder:
        final arg = settings.arguments;
        view = ReminderEditorScreen(
            args: arg is ReminderArgs ? arg : const ReminderArgs());
        break;
      case Routes.settings:
        view = const SettingsScreen();
        break;
      case Routes.scanner:
        view = const QrScannerScreen();
        break;
      default:
        view = const SplashScreen();
        break;
    }
    final requiresAuth = {
      Routes.shell,
      Routes.race,
      Routes.results,
      Routes.search,
      Routes.reminder,
      Routes.settings,
      Routes.scanner,
    }.contains(settings.name);
    return MaterialPageRoute<void>(
      builder: (_) => requiresAuth ? _AuthGuard(child: view) : view,
      settings: settings,
    );
  }
}

class _AuthGuard extends StatefulWidget {
  const _AuthGuard({required this.child});
  final Widget child;

  @override
  State<_AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<_AuthGuard> {
  bool _redirecting = false;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    if (!store.isAuthReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (store.isAuthenticated) return widget.child;
    if (!_redirecting) {
      _redirecting = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.login,
            (_) => false,
          );
        }
      });
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
