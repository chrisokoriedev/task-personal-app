import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Hive type adapter ID for Task model.
const int taskModelTypeId = 0;

/// Data model representing a task for persistence.
/// Extends the domain entity with Hive annotations for serialization.
@freezed
@HiveType(typeId: taskModelTypeId)
class TaskModel with _$TaskModel {
  const factory TaskModel({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required String description,
    @HiveField(3) required bool isCompleted,
    @HiveField(4) required DateTime createdAt,
    @HiveField(5) required DateTime updatedAt,
  }) = _TaskModel;

  const TaskModel._();

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  /// Converts domain entity to data model.
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  /// Converts data model to domain entity.
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

