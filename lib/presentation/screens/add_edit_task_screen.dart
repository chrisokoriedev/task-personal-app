import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/add_edit_task_notifier.dart';
import '../../domain/entities/task.dart';

/// Screen for adding new tasks or editing existing ones.
class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    // Initialize notifier with task data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(addEditTaskNotifierProvider.notifier)
          .initializeWithTask(widget.task);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    ref.read(addEditTaskNotifierProvider.notifier).reset();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(addEditTaskNotifierProvider.notifier);
    final success = await notifier.saveTask();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.task == null
                ? 'Task created successfully'
                : 'Task updated successfully',
          ),
        ),
      );
    } else {
      final state = ref.read(addEditTaskNotifierProvider);
      if (state.errors.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.errors.first}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addEditTaskNotifierProvider);
    final notifier = ref.read(addEditTaskNotifierProvider.notifier);
    final theme = Theme.of(context);

    // Sync controllers with state
    if (_titleController.text != state.title) {
      _titleController.text = state.title;
    }
    if (_descriptionController.text != state.description) {
      _descriptionController.text = state.description;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          state.isEditing ? 'Edit Task' : 'New Task',
          style: TextStyle(
            color: Colors.grey.shade900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Task Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
                labelStyle: TextStyle(color: Colors.grey.shade700),
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLength: 100,
              enabled: !state.isLoading,
              style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
              onChanged: (value) => notifier.updateTitle(value),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                labelStyle: TextStyle(color: Colors.grey.shade700),
                hintStyle: TextStyle(color: Colors.grey.shade400),
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 5,
              maxLength: 500,
              enabled: !state.isLoading,
              style: TextStyle(color: Colors.grey.shade900, fontSize: 16),
              onChanged: (value) => notifier.updateDescription(value),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Date picker
            InkWell(
              onTap: state.isLoading ? null : () => _selectDate(notifier),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.dueDate == null
                            ? 'Select due date (optional)'
                            : 'Due: ${DateFormat('MMM d, yyyy').format(state.dueDate!)}',
                        style: TextStyle(
                          color: state.dueDate == null
                              ? Colors.grey.shade400
                              : Colors.grey.shade900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (state.dueDate != null)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () => notifier.clearDueDate(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: state.isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      state.isEditing ? 'Update Task' : 'Create Task',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(AddEditTaskNotifier notifier) async {
    final state = ref.read(addEditTaskNotifierProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey.shade900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      notifier.updateDueDate(picked);
    }
  }
}
