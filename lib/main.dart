import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase.ensurePlatformInitialized();
  runApp(const F1TrackerApp());
}
