import '../entities/task.dart';

/// Repository interface for task operations.
/// This defines the contract for task data operations without implementation details.
abstract class TaskRepository {
  /// Retrieves all tasks from storage.
  /// Returns a list of all tasks, empty list if none exist.
  Future<List<Task>> getAllTasks();

  /// Retrieves a task by its ID.
  /// Throws [TaskNotFoundException] if task doesn't exist.
  Future<Task> getTaskById(String id);

  /// Saves a new task to storage.
  /// Returns the saved task with generated ID.
  Future<Task> createTask(Task task);

  /// Updates an existing task.
  /// Throws [TaskNotFoundException] if task doesn't exist.
  Future<Task> updateTask(Task task);

  /// Deletes a task by its ID.
  /// Returns true if deletion was successful, false otherwise.
  Future<bool> deleteTask(String id);

  /// Searches tasks by query string.
  /// Searches in both title and description fields.
  Future<List<Task>> searchTasks(String query);
}

/// Exception thrown when a task is not found.
class TaskNotFoundException implements Exception {
  final String message;
  const TaskNotFoundException(this.message);

  @override
  String toString() => 'TaskNotFoundException: $message';
}

