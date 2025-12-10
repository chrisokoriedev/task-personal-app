import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../widgets/task_search_bar.dart';
import '../widgets/date_selector_widget.dart';
import '../widgets/task_list_content.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/dismissible_task_item.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
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
  DateTime _selectedDate = DateTime.now();

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

  Future<bool> _handleDeleteTask(Task task) async {
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
        return true;
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete task')),
        );
        return false;
      }
    }
    return false;
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

  Widget _buildSearchResults() {
    final searchAsync = ref.watch(taskSearchProvider);
    
    return searchAsync.when(
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return DismissibleTaskItem(
                task: task,
                onTap: () => _navigateToEditTask(task),
                onToggleComplete: () {
                  ref
                      .read(taskListProvider.notifier)
                      .toggleTaskCompletion(task);
                },
                onDelete: _handleDeleteTask,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorStateWidget(errorMessage: error.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: _isSearching
            ? TaskSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
              )
            : Text(
                'Tasks',
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.grey.shade700,
            ),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search tasks',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          DateSelectorWidget(
            selectedDate: _selectedDate,
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
          // Task list
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : TaskListContent(
                    selectedDate: _selectedDate,
                    onTaskTap: _navigateToEditTask,
                    onToggleComplete: (task) {
                      ref
                          .read(taskListProvider.notifier)
                          .toggleTaskCompletion(task);
                    },
                    onDelete: _handleDeleteTask,
                    onAddTask: _navigateToAddTask,
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActionBar(
        onCreateTask: _navigateToAddTask,
      ),
    );
  }
}

