import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_task_data_source.dart';
import '../models/task_model.dart';

/// Implementation of TaskRepository using local Hive storage.
class TaskRepositoryImpl implements TaskRepository {
  final LocalTaskDataSource _dataSource;
  final Uuid _uuid;

  TaskRepositoryImpl({
    required LocalTaskDataSource dataSource,
    Uuid? uuid,
  })  : _dataSource = dataSource,
        _uuid = uuid ?? const Uuid();

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      final models = await _dataSource.getAllTasks();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to retrieve tasks: $e');
    }
  }

  @override
  Future<Task> getTaskById(String id) async {
    try {
      final model = await _dataSource.getTaskById(id);
      if (model == null) {
        throw TaskNotFoundException('Task with id $id not found');
      }
      return model.toEntity();
    } on TaskNotFoundException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to retrieve task: $e');
    }
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      final taskWithId = task.id.isEmpty
          ? task.copyWith(id: _uuid.v4())
          : task;

      final model = TaskModel.fromEntity(taskWithId);
      await _dataSource.saveTask(model);
      return taskWithId;
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  @override
  Future<Task> updateTask(Task task) async {
    try {
      // Verify task exists
      final existing = await _dataSource.getTaskById(task.id);
      if (existing == null) {
        throw TaskNotFoundException('Task with id ${task.id} not found');
      }

      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      final model = TaskModel.fromEntity(updatedTask);
      await _dataSource.saveTask(model);
      return updatedTask;
    } on TaskNotFoundException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<bool> deleteTask(String id) async {
    try {
      return await _dataSource.deleteTask(id);
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  @override
  Future<List<Task>> searchTasks(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAllTasks();
      }
      final models = await _dataSource.searchTasks(query);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }
}

