import 'package:flutter/material.dart';
import '../models/f1_models.dart';

/// Local, in-memory demo state. Values reset when the app restarts.
class AppStore extends ChangeNotifier {
  final Set<String> _favorites = {'usa', 'monaco'};
  final List<F1Reminder> _reminders = [];
  bool _notifications = true;
  bool _darkMode = true;
  String _language = 'Қазақша';
  String _email = 'f1fan@example.com';

  Set<String> get favorites => Set.unmodifiable(_favorites);
  List<F1Reminder> get reminders => List.unmodifiable(_reminders);
  bool get notifications => _notifications;
  bool get darkMode => _darkMode;
  String get language => _language;
  String get email => _email;

  bool isFavorite(String raceId) => _favorites.contains(raceId);
  void toggleFavorite(String raceId) {
    if (!_favorites.remove(raceId)) _favorites.add(raceId);
    notifyListeners();
  }

  void saveReminder(F1Reminder reminder) {
    final index = _reminders.indexWhere((e) => e.id == reminder.id);
    if (index == -1) {
      _reminders.add(reminder);
    } else {
      _reminders[index] = reminder;
    }
    notifyListeners();
  }

  void removeReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void setNotifications(bool value) {
    _notifications = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }
}

/// Access shared application state without extra dependencies.
class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({super.key, required AppStore store, required super.child})
      : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'Missing StoreScope above the widget tree');
    return scope!.notifier!;
  }
}
