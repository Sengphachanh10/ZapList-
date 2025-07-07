// screens/todo/edit_todo_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/todo_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/todo.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class EditTodoScreen extends StatefulWidget {
  final Todo todo;

  const EditTodoScreen({Key? key, required this.todo}) : super(key: key);

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedPriority;
  late bool _isCompleted;
  late DateTime _createdAt;
  late DateTime _updatedAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController =
        TextEditingController(text: widget.todo.description);
    _selectedPriority = widget.todo.priority;
    _isCompleted = widget.todo.completed;
    _createdAt = widget.todo.createdAt ?? DateTime.now();
    _updatedAt = widget.todo.updatedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({required bool isCreated}) async {
    final initialDate = isCreated ? _createdAt : _updatedAt;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isCreated) {
            _createdAt = newDateTime;
          } else {
            _updatedAt = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _updateTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _updatedAt = DateTime.now(); // Auto-update Updated At
    });

    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final request = UpdateTodoRequest(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _selectedPriority,
      completed: _isCompleted,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
    );

    final success = await todoProvider.updateTodo(widget.todo.id!, request);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todo updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(todoProvider.error ?? 'Failed to update todo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.blue.shade50, // Blue background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue, // Blue AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Todo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      label: 'Title',
                      controller: _titleController,
                      prefixIcon: Icon(Icons.title, color: Colors.blue),
                      validator: (value) =>
                          Validators.validateRequired(value, 'Title'),
                    ),
                    const SizedBox(height: 22),
                    CustomTextField(
                      label: 'Description',
                      controller: _descriptionController,
                      maxLines: 4,
                      prefixIcon: Icon(Icons.description, color: Colors.blue),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Priority',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 12,
                        ),
                      ),
                      items: Constants.priorities.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                priority.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 22),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.event, color: Colors.blue),
                      title: Text('Created At'),
                      subtitle: Text(
                        '${_createdAt.year}-${_createdAt.month.toString().padLeft(2, '0')}-${_createdAt.day.toString().padLeft(2, '0')} '
                        '${_createdAt.hour.toString().padLeft(2, '0')}:${_createdAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      // Read-only: no trailing icon, no onTap
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.update, color: Colors.blue),
                      title: Text('Updated At'),
                      subtitle: Text(
                        '${_updatedAt.year}-${_updatedAt.month.toString().padLeft(2, '0')}-${_updatedAt.day.toString().padLeft(2, '0')} '
                        '${_updatedAt.hour.toString().padLeft(2, '0')}:${_updatedAt.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.black87),
                      ),
                      // Read-only: no trailing icon, no onTap
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Mark as Completed'),
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value;
                        });
                      },
                      activeColor: Colors.blue,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 32),
                    Consumer<TodoProvider>(
                      builder: (context, todoProvider, child) {
                        return CustomButton(
                          text: 'Update Todo',
                          onPressed: _updateTodo,
                          isLoading: todoProvider.isLoading,
                          backgroundColor: Colors.blue, // Blue button
                          borderRadius: 12,
                          elevation: 4,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Todo'),
          content: const Text(
              'Are you sure you want to permanently delete this todo?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                final success = await todoProvider.deleteTodo(widget.todo.id!);
                if (success && mounted) {
                  context.pop(); // Go back to the list screen
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(todoProvider.error ?? 'Failed to delete todo'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
