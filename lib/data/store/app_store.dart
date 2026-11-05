import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/supabase_service.dart';
import '../database/race_realtime.dart';
import '../models/f1_models.dart';
import '../repositories/f1_repository.dart';

enum AuthActionResult { authenticated, emailConfirmationRequired, failed }

/// Supabase PostgreSQL repository мен UI арасындағы жаһандық күй.
class AppStore extends ChangeNotifier {
  AppStore({F1Repository? repository, RaceRealtime? realtime})
      : _repository = repository ?? F1Repository(),
        _realtime = realtime ?? SupabaseRaceRealtime();

  final RaceRealtime _realtime;
  LiveConnection _liveConnection = LiveConnection.stopped;
  LiveConnection get liveConnection => _liveConnection;
  bool _disposed = false;
  int _liveGeneration = 0;
  int _raceRequest = 0;

  void startRealtime() {
    if (_disposed ||
        !isAuthenticated ||
        _liveConnection != LiveConnection.stopped) {
      return;
    }
    final generation = ++_liveGeneration;
    _realtime.start(
      onChange: () {
        if (!_disposed && generation == _liveGeneration) {
          unawaited(refreshRaces());
        }
      },
      onConnection: (connection) {
        if (_disposed || generation != _liveGeneration) return;
        _liveConnection = connection;
        notifyListeners();
        // Fetch again on every join, including reconnects: events missed while
        // offline are not replayed by Postgres Changes.
        if (connection == LiveConnection.connected) {
          unawaited(refreshRaces());
        }
      },
    );
  }

  Future<void> stopRealtime() async {
    ++_liveGeneration;
    ++_raceRequest;
    _liveConnection = LiveConnection.stopped;
    await _realtime.stop();
    if (!_disposed) notifyListeners();
  }

  Future<void> reconnectRealtime() async {
    await stopRealtime();
    if (!_disposed) startRealtime();
  }

  final F1Repository _repository;
  F1Repository get repository => _repository;

  bool _initialized = false;
  bool _authReady = false;
  bool _authLoading = false;
  bool _isLoading = true;
  bool _isRaceLoading = false;
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
  String _email = '';
  String _displayName = '';
  String? _authError;
  User? _user;
  StreamSubscription<AuthState>? _authSubscription;

  // Getters
  bool get isInitialized => _initialized;
  bool get isAuthReady => _authReady;
  bool get isAuthenticated => _user != null && !_user!.isAnonymous;
  bool get canManageRaces => _user?.appMetadata['role'] == 'admin';
  bool get authLoading => _authLoading;
  String? get authError => _authError;
  bool get isLoading => _isLoading;
  bool get isRaceLoading => _isRaceLoading;
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
  String get displayName => _displayName;

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
      final auth = SupabaseService.client.auth;
      _updateUser(auth.currentUser);
      _authSubscription ??= auth.onAuthStateChange.listen((state) {
        final previousUserId = _user?.id;
        _updateUser(state.session?.user);
        if (_user == null) {
          unawaited(stopRealtime());
          _favorites = {};
          _reminders = [];
          notifyListeners();
        } else if (_user!.id != previousUserId) {
          startRealtime();
          unawaited(refreshAll());
        }
      });
      _authReady = true;
      if (isAuthenticated) {
        startRealtime();
        await refreshAll();
      }
      _initialized = true;
    } catch (e) {
      _errorMessage = 'Деректерді жүктеу сәтсіз аяқталды: $e';
    } finally {
      _authReady = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateUser(User? user) {
    _user = user;
    _email = user?.email ?? '';
    _displayName = user?.userMetadata?['full_name']?.toString() ?? '';
    notifyListeners();
  }

  Future<AuthActionResult> signIn(String email, String password) async {
    _authLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user == null) {
        _authError = 'Кіру сәтсіз аяқталды. Email мен құпиясөзді тексеріңіз.';
        return AuthActionResult.failed;
      }
      _updateUser(response.user);
      await refreshAll();
      return AuthActionResult.authenticated;
    } on AuthException catch (error) {
      _authError = _friendlyAuthError(error);
      return AuthActionResult.failed;
    } catch (_) {
      _authError =
          'Сервермен байланыс жоқ. Интернетті тексеріп, қайта көріңіз.';
      return AuthActionResult.failed;
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  Future<AuthActionResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _authLoading = true;
    _authError = null;
    notifyListeners();
    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': name.trim()},
      );
      if (response.user == null) {
        _authError = 'Тіркелу аяқталмады. Қайта көріңіз.';
        return AuthActionResult.failed;
      }
      if (response.session == null) {
        return AuthActionResult.emailConfirmationRequired;
      }
      _updateUser(response.user);
      await refreshAll();
      return AuthActionResult.authenticated;
    } on AuthException catch (error) {
      _authError = _friendlyAuthError(error);
      return AuthActionResult.failed;
    } catch (_) {
      _authError =
          'Сервермен байланыс жоқ. Интернетті тексеріп, қайта көріңіз.';
      return AuthActionResult.failed;
    } finally {
      _authLoading = false;
      notifyListeners();
    }
  }

  String _friendlyAuthError(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Email немесе құпиясөз қате. Қайта тексеріңіз.';
    }
    if (message.contains('user already registered')) {
      return 'Бұл email бұрын тіркелген. Жүйеге кіріп көріңіз.';
    }
    if (message.contains('password should be at least')) {
      return 'Құпиясөз кемінде 6 таңбадан тұруы керек.';
    }
    return 'Аутентификация қатесі: ${error.message}';
  }

  Future<void> signOut() async {
    _authError = null;
    try {
      await SupabaseService.client.auth.signOut();
      await stopRealtime();
      _updateUser(null);
      _favorites = {};
      _reminders = [];
    } on AuthException catch (error) {
      _authError = 'Жүйеден шығу қатесі: ${error.message}';
      rethrow;
    } finally {
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
      await refreshRaces();
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
    final request = ++_raceRequest;
    try {
      final races = await _repository.getRaces(
        query: _raceSearchQuery,
        filter: _raceFilter,
        sort: _raceSort,
      );
      if (_disposed || request != _raceRequest) return;
      _races = races;
      _errorMessage = null;
    } catch (e) {
      if (_disposed || request != _raceRequest) return;
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

  Future<bool> saveRace(F1Race race) => _mutateRace(
        () => _repository.insertRace(race),
        'Жарысты сақтау қатесі',
      );

  Future<bool> updateRace(F1Race race) => _mutateRace(
        () => _repository.updateRace(race),
        'Жарысты жаңарту қатесі',
      );

  Future<bool> deleteRace(String id) => _mutateRace(
        () => _repository.deleteRace(id),
        'Жарысты жою қатесі',
      );

  Future<bool> _mutateRace(
    Future<void> Function() mutation,
    String errorLabel,
  ) async {
    if (_isRaceLoading) return false;
    _isRaceLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await mutation();
      await refreshRaces();
      return true;
    } catch (e) {
      _errorMessage = '$errorLabel: $e';
      return false;
    } finally {
      _isRaceLoading = false;
      notifyListeners();
    }
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

  @override
  void dispose() {
    _disposed = true;
    unawaited(stopRealtime());
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }
}

/// Keeps the existing store API while exposing it through Provider.
class StoreScope extends StatelessWidget {
  const StoreScope({super.key, required this.store, required this.child});

  final AppStore store;
  final Widget child;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<AppStore>.value(
        value: store,
        child: child,
      );

  static AppStore of(BuildContext context, {bool listen = true}) =>
      Provider.of<AppStore>(context, listen: listen);
}
