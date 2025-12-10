import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/task.dart';
import 'task_providers.dart';

part 'add_edit_task_notifier.g.dart';

/// Notifier for managing add/edit task screen state and operations.
@riverpod
class AddEditTaskNotifier extends _$AddEditTaskNotifier {
  @override
  AddEditTaskState build() {
    return const AddEditTaskState();
  }

  /// Initializes the notifier with existing task data (for editing).
  void initializeWithTask(Task? task) {
    state = state.copyWith(
      title: task?.title ?? '',
      description: task?.description ?? '',
      dueDate: task?.dueDate,
      isEditing: task != null,
      originalTask: task,
    );
  }

  /// Updates the title field.
  void updateTitle(String title) {
    state = state.copyWith(title: title);
  }

  /// Updates the description field.
  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  /// Updates the selected due date.
  void updateDueDate(DateTime? date) {
    state = state.copyWith(dueDate: date);
  }

  /// Clears the selected due date.
  void clearDueDate() {
    state = state.copyWith(dueDate: null);
  }

  /// Validates the form.
  bool validate() {
    final errors = <String>[];
    
    if (state.title.trim().isEmpty) {
      errors.add('Title is required');
    }
    
    if (state.description.trim().isEmpty) {
      errors.add('Description is required');
    }

    state = state.copyWith(
      errors: errors,
      isValid: errors.isEmpty,
    );

    return errors.isEmpty;
  }

  /// Saves the task (create or update).
  Future<bool> saveTask() async {
    // Validate first
    if (!validate()) {
      return false;
    }

    state = state.copyWith(isLoading: true, errors: []);

    try {
      final title = state.title.trim();
      final description = state.description.trim();

      if (state.isEditing && state.originalTask != null) {
        // Update existing task
        final updatedTask = state.originalTask!.updateContent(
          title: title,
          description: description,
        ).copyWith(dueDate: state.dueDate);
        
        await ref.read(taskListProvider.notifier).updateTask(updatedTask);
      } else {
        // Create new task
        final newTask = Task.create(
          title: title,
          description: description,
          dueDate: state.dueDate,
        );
        await ref.read(taskListProvider.notifier).createTask(newTask);
      }

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errors: [e.toString()],
        isSuccess: false,
      );
      return false;
    }
  }

  /// Resets the state.
  void reset() {
    state = const AddEditTaskState();
  }
}

/// State for the add/edit task screen.
class AddEditTaskState {
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool isEditing;
  final Task? originalTask;
  final bool isLoading;
  final bool isValid;
  final bool isSuccess;
  final List<String> errors;

  const AddEditTaskState({
    this.title = '',
    this.description = '',
    this.dueDate,
    this.isEditing = false,
    this.originalTask,
    this.isLoading = false,
    this.isValid = true,
    this.isSuccess = false,
    this.errors = const [],
  });

  AddEditTaskState copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isEditing,
    Task? originalTask,
    bool? isLoading,
    bool? isValid,
    bool? isSuccess,
    List<String>? errors,
  }) {
    return AddEditTaskState(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isEditing: isEditing ?? this.isEditing,
      originalTask: originalTask ?? this.originalTask,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      isSuccess: isSuccess ?? this.isSuccess,
      errors: errors ?? this.errors,
    );
  }
}

