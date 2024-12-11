// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task_creation_screen.dart';
import 'journal_manager.dart';
import 'task.dart';

class TaskModalScreen extends StatelessWidget {
  final Task task;
  final String journalId;

  const TaskModalScreen({
    super.key,
    required this.task,
    required this.journalId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F4FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              const Text(
                '',
                style: TextStyle(),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Task Details
          _buildTaskDetails(context),

          const Divider(
            color: Colors.black26,
            thickness: 1,
            height: 16,
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildActionButton(
                icon: Icons.copy,
                label: 'Duplicate',
                color: Colors.blue,
                onPressed: () => _duplicateTask(context),
              ),
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit Task',
                color: Colors.orange,
                onPressed: () => _editTask(context),
              ),
              _buildActionButton(
                icon: Icons.delete,
                label: 'Delete',
                color: Colors.red,
                onPressed: () => _confirmDeleteTask(context),
              ),
              _buildActionButton(
                icon: Icons.check_circle,
                label: 'Complete',
                color: Colors.green,
                onPressed: () => _completeTask(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (task.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(task.description),
          ),
        if (task.dueDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('Due Date: ${DateFormat('EEE, MMM d, yyyy').format(task.dueDate!)}'),
          ),
        if (task.time != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('Time: ${task.time!.format(context)}'),
          ),
        if (task.reminder != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text('Reminder: ${task.reminder}'),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text('Priority: ${task.priority}'),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text('Color: ${task.color}'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _duplicateTask(BuildContext context) async {
    final journalManager = JournalManager();
    final newTaskName = '${task.title} Copy';

    final duplicatedTask = Task(
      id: '',
      title: newTaskName,
      description: task.description,
      dueDate: task.dueDate,
      time: task.time,
      reminder: task.reminder,
      priority: task.priority,
      color: task.color,
      completed: false,
    );

    try {
      await journalManager.addTask(journalId, duplicatedTask);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error duplicating task: $e')),
      );
    }
  }

  void _editTask(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskCreationScreen(
          journalId: journalId,
          task: task, // Pass the task object
        ),
      ),
    );

    if (result == true) {
      Navigator.pop(context); // Ensure modal is closed after editing
    }
  }

  void _confirmDeleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final journalManager = JournalManager();
                try {
                  await journalManager.deleteTask(journalId, task.id);
                  Navigator.pop(context);
                  Navigator.pop(context); // Close modal
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting task: $e')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _completeTask(BuildContext context) async {
    final journalManager = JournalManager();
    try {
      await journalManager.updateTaskFields(journalId, task.id, {'completed': true});
      Navigator.pop(context); // Close modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing task: $e')),
      );
    }
  }
}
