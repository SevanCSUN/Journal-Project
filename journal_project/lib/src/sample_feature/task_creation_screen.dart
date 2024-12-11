import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'journal_manager.dart';
import 'task.dart';

class TaskCreationScreen extends StatefulWidget {
  final String journalId;
  final Task? task;

  const TaskCreationScreen({
    super.key,
    required this.journalId,
    this.task,
  });

  @override
  TaskCreationScreenState createState() => TaskCreationScreenState();
}

class TaskCreationScreenState extends State<TaskCreationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isDueDateEnabled = false;
  bool _isTimeEnabled = false;
  bool _isReminderEnabled = false;
  String _priorityLevel = 'Medium';
  String _color = 'None';
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;
  String _reminder = 'None';
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.task != null) {
      final task = widget.task!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _isDueDateEnabled = task.dueDate != null;
      _selectedDueDate = task.dueDate;
      _isTimeEnabled = task.time != null;
      _selectedTime = task.time;
      _isReminderEnabled = task.reminder != null;
      _reminder = task.reminder ?? 'None';
      _priorityLevel = task.priority;
      _color = task.color;
      _isCompleted = task.completed;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Done',
                style: TextStyle(color: Colors.deepPurpleAccent)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTextField('Title', controller: _titleController),
          const SizedBox(height: 16),
          _buildTextField('Description', controller: _descriptionController, maxLines: 4),
          const SizedBox(height: 16),
          _buildToggleListTileWithDateSelector(),
          _buildToggleListTileWithTimeSelector(),
          _buildToggleListTileWithReminderSelector(),
          _buildDropdownListTile(
            title: 'Priority',
            value: _priorityLevel,
            items: ['Low', 'Medium', 'High'],
            onChanged: (value) => setState(() {
              _priorityLevel = value!;
            }),
          ),
          _buildDropdownListTile(
            title: 'Color',
            value: _color,
            items: ['None', 'Red', 'Green', 'Blue'],
            onChanged: (value) => setState(() {
              _color = value!;
            }),
          ),
          _buildCompletionToggle(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _buildToggleListTileWithDateSelector() {
    return ListTile(
      title: const Text('Due Date'),
      subtitle: Text(
        _isDueDateEnabled && _selectedDueDate != null
            ? DateFormat('EEE, MMM d, yyyy').format(_selectedDueDate!)
            : 'No date selected',
      ),
      trailing: Switch(
        value: _isDueDateEnabled,
        onChanged: (value) => setState(() {
          _isDueDateEnabled = value;
        }),
      ),
      onTap: _selectDueDate,
    );
  }

  Widget _buildToggleListTileWithTimeSelector() {
    return ListTile(
      title: const Text('Time'),
      subtitle: Text(
        _isTimeEnabled && _selectedTime != null
            ? _selectedTime!.format(context)
            : 'No time selected',
      ),
      trailing: Switch(
        value: _isTimeEnabled,
        onChanged: (value) => setState(() {
          _isTimeEnabled = value;
        }),
      ),
      onTap: _selectTime,
    );
  }

  Widget _buildToggleListTileWithReminderSelector() {
    return ListTile(
      title: const Text('Reminder'),
      subtitle: Text(_isReminderEnabled ? _reminder : 'No reminder set'),
      trailing: Switch(
        value: _isReminderEnabled,
        onChanged: (value) => setState(() {
          _isReminderEnabled = value;
        }),
      ),
      onTap: _selectReminder,
    );
  }

  Widget _buildDropdownListTile({
    required String title,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCompletionToggle() {
    return SwitchListTile(
      title: const Text('Complete'),
      value: _isCompleted,
      onChanged: (value) => setState(() {
        _isCompleted = value;
      }),
    );
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
        _isDueDateEnabled = true;
      });
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        _isTimeEnabled = true;
      });
    }
  }

  Future<void> _selectReminder() async {
    final reminders = ['None', '1 Day before', '1 Hour before', '30 Minutes before'];
    final pickedReminder = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Reminder'),
        children: reminders.map((reminder) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, reminder),
            child: Text(reminder),
          );
        }).toList(),
      ),
    );
    if (pickedReminder != null) {
      setState(() {
        _reminder = pickedReminder;
        _isReminderEnabled = true;
      });
    }
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final taskToSave = Task(
      id: widget.task?.id ?? '', // Use existing ID for edits, or empty for new tasks
      title: title,
      description: _descriptionController.text.trim(),
      dueDate: _isDueDateEnabled ? _selectedDueDate : null,
      time: _isTimeEnabled ? _selectedTime : null,
      reminder: _isReminderEnabled ? _reminder : null,
      priority: _priorityLevel,
      color: _color,
      completed: _isCompleted,
    );

    try {
      if (widget.task == null) {
        await JournalManager().addTask(widget.journalId, taskToSave);
      } else {
        await JournalManager().updateTask(widget.journalId, taskToSave);
      }
      Navigator.pop(context, true); // Pass `true` to indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
