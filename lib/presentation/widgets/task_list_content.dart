import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persona/presentation/widgets/error_state_widget.dart';
import '../providers/task_providers.dart';
import 'dismissible_task_item.dart';
import 'empty_state_widget.dart';
import '../../domain/entities/task.dart';

/// Widget displaying the list of tasks with filtering.
class TaskListContent extends ConsumerWidget {
  final DateTime selectedDate;
  final Function(Task) onTaskTap;
  final Function(Task) onToggleComplete;
  final Future<bool> Function(Task) onDelete;
  final VoidCallback onAddTask;

  const TaskListContent({
    super.key,
    required this.selectedDate,
    required this.onTaskTap,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListAsync = ref.watch(taskListProvider);

    return taskListAsync.when(
      data: (tasks) {
        // Filter tasks by selected date
        final filteredTasks = _filterTasksByDate(tasks, selectedDate);

        if (filteredTasks.isEmpty) {
          return EmptyStateWidget(onAddTask: onAddTask);
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(taskListProvider.notifier).refresh();
          },
          child: ListView.builder(
            itemCount: filteredTasks.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return DismissibleTaskItem(
                task: task,
                onTap: () => onTaskTap(task),
                onToggleComplete: () => onToggleComplete(task),
                onDelete: onDelete,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorStateWidget(errorMessage: error.toString()),
    );
  }

  List<Task> _filterTasksByDate(List<Task> tasks, DateTime selectedDate) {
    return tasks.where((task) {
      // Show tasks without due date on today
      if (task.dueDate == null) {
        final today = DateTime.now();
        final isToday = selectedDate.year == today.year &&
            selectedDate.month == today.month &&
            selectedDate.day == today.day;
        return isToday;
      }

      // Show tasks with due date matching selected date
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      final selected = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      return taskDate.isAtSameMomentAs(selected);
    }).toList();
  }
}

