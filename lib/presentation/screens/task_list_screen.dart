import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../widgets/task_item.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/task_search_bar.dart';
import 'add_edit_task_screen.dart';
import '../../domain/entities/task.dart';

/// Main screen displaying the list of tasks.
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(taskSearchProvider.notifier).search(query);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(taskSearchProvider.notifier).clearSearch();
      }
    });
  }

  Future<void> _handleDeleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(taskListProvider.notifier)
          .deleteTask(task.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete task')),
        );
      }
    }
  }

  void _navigateToAddTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditTaskScreen(),
      ),
    );
  }

  void _navigateToEditTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskListAsync = ref.watch(taskListProvider);
    final searchAsync = ref.watch(taskSearchProvider);

    // Use search results if searching, otherwise use full list
    final tasksAsync = _isSearching ? searchAsync : taskListAsync;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TaskSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
              )
            : const Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search tasks',
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return EmptyStateWidget(
              onAddTask: _navigateToAddTask,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(taskListProvider.notifier).refresh();
            },
            child: ListView.builder(
              itemCount: tasks.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskItem(
                  task: task,
                  onTap: () => _navigateToEditTask(task),
                  onToggleComplete: () {
                    ref
                        .read(taskListProvider.notifier)
                        .toggleTaskCompletion(task);
                  },
                  onDelete: () => _handleDeleteTask(task),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading tasks',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(taskListProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

