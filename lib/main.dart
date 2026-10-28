import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppDatabase.ensurePlatformInitialized();
  runApp(const F1TrackerApp());
}
