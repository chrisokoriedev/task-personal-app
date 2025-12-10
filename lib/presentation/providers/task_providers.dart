import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/datasources/local_task_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

part 'task_providers.g.dart';

/// Provider for LocalTaskDataSource.
@riverpod
LocalTaskDataSource localTaskDataSource(LocalTaskDataSourceRef ref) {
  return LocalTaskDataSource();
}

/// Provider for TaskRepository.
@riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  final dataSource = ref.watch(localTaskDataSourceProvider);
  return TaskRepositoryImpl(dataSource: dataSource);
}

/// Provider for all tasks.
/// Automatically refreshes when tasks are modified.
@riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<Task>> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getAllTasks();
  }

  /// Refreshes the task list.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      return repository.getAllTasks();
    });
  }

  /// Creates a new task.
  Future<void> createTask(Task task) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.createTask(task);
    await refresh();
  }

  /// Updates an existing task.
  Future<void> updateTask(Task task) async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.updateTask(task);
    await refresh();
  }

  /// Deletes a task.
  Future<bool> deleteTask(String id) async {
    final repository = ref.read(taskRepositoryProvider);
    final success = await repository.deleteTask(id);
    if (success) {
      await refresh();
    }
    return success;
  }

  /// Toggles task completion status.
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.toggleCompletion();
    await updateTask(updatedTask);
  }
}

/// Provider for searching tasks.
@riverpod
class TaskSearch extends _$TaskSearch {
  @override
  Future<List<Task>> build() async {
    // Initial state: return all tasks
    final repository = ref.watch(taskRepositoryProvider);
    return repository.getAllTasks();
  }

  /// Performs a search query.
  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(taskRepositoryProvider);
      if (query.trim().isEmpty) {
        return repository.getAllTasks();
      }
      return repository.searchTasks(query);
    });
  }

  /// Clears the search and shows all tasks.
  Future<void> clearSearch() async {
    await search('');
  }
}

