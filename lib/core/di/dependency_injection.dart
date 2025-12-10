import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task_model.dart';

/// Initializes all dependencies and services.
/// Must be called before running the app.
Future<void> initializeDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(taskModelTypeId)) {
    Hive.registerAdapter(TaskModelAdapter());
  }
}

