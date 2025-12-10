import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import 'task_item.dart';

/// Dismissible wrapper for task items with swipe-to-delete.
class DismissibleTaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final Future<bool> Function(Task) onDelete;

  const DismissibleTaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await onDelete(task);
      },
      onDismissed: (direction) {
        // Task is already deleted in confirmDismiss
      },
      child: TaskItem(
        task: task,
        onTap: onTap,
        onToggleComplete: onToggleComplete,
        onDelete: () => onDelete(task),
      ),
    );
  }
}

