import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/store/app_store.dart';

class F1TrackerApp extends StatefulWidget {
  const F1TrackerApp({super.key, this.store});
  final AppStore? store;

  @override
  State<F1TrackerApp> createState() => _F1TrackerAppState();
}

class _F1TrackerAppState extends State<F1TrackerApp> {
  late final AppStore store;

  @override
  void initState() {
    super.initState();
    store = widget.store ?? AppStore();
    if (!store.isInitialized) {
      store.init();
    }
  }

  @override
  void dispose() {
    if (widget.store == null) {
      store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) => StoreScope(
          store: store,
          child: MaterialApp(
            title: 'F1 Tracker',
            theme: F1Theme.light(),
            darkTheme: F1Theme.dark(),
            themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: Routes.splash,
          ),
        ),
      );
}
