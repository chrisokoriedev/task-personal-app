import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_providers.dart';
import '../widgets/task_item.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/task_search_bar.dart';
import 'add_edit_task_screen.dart';
import 'completed_tasks_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final taskListAsync = ref.watch(taskListProvider);
    final searchAsync = ref.watch(taskSearchProvider);

    // Use search results if searching, otherwise use full list
    final tasksAsync = _isSearching ? searchAsync : taskListAsync;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
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
                    return await _handleDeleteTask(task);
                  },
                  onDismissed: (direction) {
                    // Task is already deleted in confirmDismiss
                  },
                  child: TaskItem(
                    task: task,
                    onTap: () => _navigateToEditTask(task),
                    onToggleComplete: () {
                      ref
                          .read(taskListProvider.notifier)
                          .toggleTaskCompletion(task);
                    },
                    onDelete: () => _handleDeleteTask(task),
                  ),
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
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Smaller Create button
                  ElevatedButton.icon(
                    onPressed: _navigateToAddTask,
                    icon: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: Colors.black87,
                      ),
                    ),
                    label: const Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.grey.shade900,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Done tasks icon with badge
                  Consumer(
                    builder: (context, ref, child) {
                      final completedCountAsync = ref.watch(completedTasksCountProvider);
                      return completedCountAsync.when(
                        data: (count) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Navigate to completed tasks screen
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const CompletedTasksScreen(),
                                  ),
                                );
                              },
                              icon: SizedBox(
                                width: 24,
                                height: 24,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Bottom card
                                    Positioned(
                                      left: 4,
                                      top: 6,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Middle card
                                    Positioned(
                                      left: 2,
                                      top: 3,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Top card with checkmark
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(3),
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 10,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              tooltip: 'Completed Tasks',
                            ),
                            // Badge showing count
                            if (count > 0)
                              Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade600,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Center(
                                    child: Text(
                                      count > 99 ? '99+' : count.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        loading: () => IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CompletedTasksScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.assignment,
                            color: Colors.grey.shade600,
                          ),
                          tooltip: 'Completed Tasks',
                        ),
                        error: (_, __) => IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CompletedTasksScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.assignment,
                            color: Colors.grey.shade600,
                          ),
                          tooltip: 'Completed Tasks',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

