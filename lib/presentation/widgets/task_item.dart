import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

/// Widget representing a single task item in the list.
class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggleComplete(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted
                ? Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                : null,
          ),
        ),
        subtitle: Text(
          task.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: task.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: task.isCompleted
                ? Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)
                : null,
          ),
        ),
        isThreeLine: true,
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: onDelete,
          tooltip: 'Delete task',
        ),
      ),
    );
  }
}

