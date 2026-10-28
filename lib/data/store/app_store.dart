import 'package:flutter/material.dart';
import '../models/f1_models.dart';
import '../repositories/f1_repository.dart';

/// Локалды SQLite деректер қорымен синхрондалатын жаһандық күй (State Management)
class AppStore extends ChangeNotifier {
  AppStore({F1Repository? repository}) : _repository = repository ?? F1Repository();

  final F1Repository _repository;
  F1Repository get repository => _repository;

  bool _initialized = false;
  bool _isLoading = true;
  String? _errorMessage;

  List<F1Race> _races = [];
  List<F1Driver> _drivers = [];
  List<F1Team> _teams = [];
  List<F1Circuit> _circuits = [];
  List<F1Reminder> _reminders = [];
  Set<String> _favorites = {};

  // Сүзгілеу және сұрыптау күйі
  RaceFilter _raceFilter = RaceFilter.all;
  RaceSort _raceSort = RaceSort.roundAsc;
  DriverSort _driverSort = DriverSort.pointsDesc;
  String _raceSearchQuery = '';

  // Баптаулар
  bool _notifications = true;
  bool _darkMode = true;
  String _language = 'Қазақша';
  String _email = 'f1fan@example.com';

  // Getters
  bool get isInitialized => _initialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<F1Race> get races => List.unmodifiable(_races);
  List<F1Driver> get drivers => List.unmodifiable(_drivers);
  List<F1Team> get teams => List.unmodifiable(_teams);
  List<F1Circuit> get circuits => List.unmodifiable(_circuits);
  List<F1Reminder> get reminders => List.unmodifiable(_reminders);
  Set<String> get favorites => Set.unmodifiable(_favorites);

  RaceFilter get raceFilter => _raceFilter;
  RaceSort get raceSort => _raceSort;
  DriverSort get driverSort => _driverSort;
  String get raceSearchQuery => _raceSearchQuery;

  bool get notifications => _notifications;
  bool get darkMode => _darkMode;
  String get language => _language;
  String get email => _email;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 7. Деректер қорын инициализациялау және алғашқы деректерді оқу
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await refreshAll();
      _initialized = true;
    } catch (e) {
      _errorMessage = 'Деректерді жүктеу сәтсіз аяқталды: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 9. Read: Барлық кестелерден деректерді қайта оқу
  Future<void> refreshAll() async {
    try {
      _favorites = await _repository.getFavoriteRaceIds();
      _reminders = await _repository.getReminders();
      _circuits = await _repository.getCircuits();
      _teams = await _repository.getTeams();
      _drivers = await _repository.getDrivers(sort: _driverSort);
      _races = await _repository.getRaces(
        query: _raceSearchQuery,
        filter: _raceFilter,
        sort: _raceSort,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ==========================================
  // Сүзгілеу, сұрыптау, іздеу әдістері (13, 14, 15)
  // ==========================================

  void setRaceFilter(RaceFilter filter) {
    if (_raceFilter == filter) return;
    _raceFilter = filter;
    refreshRaces();
  }

  void setRaceSort(RaceSort sort) {
    if (_raceSort == sort) return;
    _raceSort = sort;
    refreshRaces();
  }

  void setRaceSearchQuery(String query) {
    _raceSearchQuery = query;
    refreshRaces();
  }

  void setDriverSort(DriverSort sort) {
    if (_driverSort == sort) return;
    _driverSort = sort;
    refreshDrivers();
  }

  Future<void> refreshRaces() async {
    try {
      _races = await _repository.getRaces(
        query: _raceSearchQuery,
        filter: _raceFilter,
        sort: _raceSort,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> refreshDrivers() async {
    try {
      _drivers = await _repository.getDrivers(sort: _driverSort);
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  // ==========================================
  // Таңдаулылар (16. Favorites)
  // ==========================================

  bool isFavorite(String raceId) => _favorites.contains(raceId);

  Future<void> toggleFavorite(String raceId) async {
    try {
      await _repository.toggleFavorite(raceId);
      _favorites = await _repository.getFavoriteRaceIds();
    } catch (e) {
      _errorMessage = 'Таңдаулыны өзгерту қатесі: $e';
    }
    notifyListeners();
  }

  // ==========================================
  // Еске салғыштар CRUD (8, 9, 10, 11)
  // ==========================================

  Future<void> saveReminder(F1Reminder reminder) async {
    try {
      final exists = _reminders.any((r) => r.id == reminder.id);
      if (exists) {
        await _repository.updateReminder(reminder);
      } else {
        await _repository.insertReminder(reminder);
      }
      _reminders = await _repository.getReminders();
    } catch (e) {
      _errorMessage = 'Еске салғышты сақтау қатесі: $e';
    }
    notifyListeners();
  }

  Future<void> removeReminder(String id) async {
    try {
      await _repository.deleteReminder(id);
      _reminders = await _repository.getReminders();
    } catch (e) {
      _errorMessage = 'Еске салғышты жою қатесі: $e';
    }
    notifyListeners();
  }

  // ==========================================
  // Жарыстар (CRUD - 8, 10, 11)
  // ==========================================

  Future<void> saveRace(F1Race race) async {
    try {
      await _repository.insertRace(race);
      await refreshRaces();
    } catch (e) {
      _errorMessage = 'Жарысты сақтау қатесі: $e';
    }
    notifyListeners();
  }

  Future<void> updateRace(F1Race race) async {
    try {
      await _repository.updateRace(race);
      await refreshRaces();
    } catch (e) {
      _errorMessage = 'Жарысты жаңарту қатесі: $e';
    }
    notifyListeners();
  }

  Future<void> deleteRace(String id) async {
    try {
      await _repository.deleteRace(id);
      await refreshRaces();
    } catch (e) {
      _errorMessage = 'Жарысты жою қатесі: $e';
    }
    notifyListeners();
  }

  // ==========================================
  // Базаны тазарту / Бастапқы күйге келтіру
  // ==========================================

  Future<void> resetDatabase() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.resetDatabase();
      await refreshAll();
    } catch (e) {
      _errorMessage = 'Қорды тазарту қатесі: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Баптаулар
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

  F1Race raceById(String id) {
    return _races.firstWhere(
      (r) => r.id == id,
      orElse: () => _races.isNotEmpty
          ? _races.first
          : F1Race(
              id: id,
              circuitId: 'cota',
              name: 'АҚШ Гран-приі',
              country: 'АҚШ',
              circuit: 'Circuit of the Americas',
              date: '23–25 ҚАЗ',
              round: 4,
            ),
    );
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
