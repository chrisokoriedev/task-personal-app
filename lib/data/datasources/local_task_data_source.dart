import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

/// Local data source for task persistence using Hive.
/// Handles all direct database operations.
class LocalTaskDataSource {
  static const String _boxName = 'tasks';

  /// Gets the Hive box for tasks.
  Future<Box<TaskModel>> get _box async {
    return await Hive.openBox<TaskModel>(_boxName);
  }

  /// Retrieves all tasks from local storage.
  Future<List<TaskModel>> getAllTasks() async {
    final box = await _box;
    return box.values.toList();
  }

  /// Retrieves a task by ID.
  /// Returns null if not found.
  Future<TaskModel?> getTaskById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  /// Saves a task to local storage.
  Future<void> saveTask(TaskModel task) async {
    final box = await _box;
    await box.put(task.id, task);
  }

  /// Deletes a task by ID.
  Future<bool> deleteTask(String id) async {
    final box = await _box;
    if (box.containsKey(id)) {
      await box.delete(id);
      return true;
    }
    return false;
  }

  /// Searches tasks by query string.
  /// Searches in both title and description fields (case-insensitive).
  Future<List<TaskModel>> searchTasks(String query) async {
    final box = await _box;
    final lowerQuery = query.toLowerCase();
    
    return box.values.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
          task.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Clears all tasks from storage.
  /// Used for testing or reset functionality.
  Future<void> clearAll() async {
    final box = await _box;
    await box.clear();
  }
}

