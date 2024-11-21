import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCreationScreen extends StatefulWidget {
  const TaskCreationScreen({super.key});

  @override
  _TaskCreationScreenState createState() => _TaskCreationScreenState();
}

class _TaskCreationScreenState extends State<TaskCreationScreen> {
  // State variables for toggles
  bool _isDueDateEnabled = false;
  bool _isTimeEnabled = false;
  bool _isReminderEnabled = false;
  bool _isComplete = false;

  // State variables for dropdowns
  String _priorityLevel = 'Medium';
  String _color = 'None';

  // State for due date and time
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;

  // State variables for reminder
  String _reminderType = "Days"; // "Hours" or "Days"
  int _reminderValue = 1; // Default to 1 day before

  @override
  void initState() {
    super.initState();
    // Set default due date to today
    _selectedDueDate = DateTime.now();

    // Set default time to 8:30 AM
    _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Header Area
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFECE4FF), // Slightly darker purple header
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.only(top: 16), // Reduced bottom padding
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Add "Cancel" button functionality
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Text(
                    'Journal Name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Arial',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Add "Done" button functionality
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content Area
          Expanded(
            child: Container(
              color: const Color(0xFFFEF7FF),
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: ListView(
                children: [
                  const Text(
                    'Task Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField('Title'),
                  const SizedBox(height: 16),
                  _buildTextField('Description', maxLines: 4),
                  const SizedBox(height: 16),
                  _buildDivider(),
                  _buildToggleListTileWithDateSelector(
                    icon: Icons.calendar_today,
                    iconColor: Colors.purple,
                    title: 'Due Date',
                    subtitle: _selectedDueDate != null
                        ? DateFormat('EEE, MMM dd, yyyy').format(_selectedDueDate!)
                        : 'Day of Week, Mon DD, YYYY',
                    toggleValue: _isDueDateEnabled,
                    onToggleChanged: (value) {
                      setState(() {
                        _isDueDateEnabled = value;
                      });
                    },
                    onDateSelected: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDueDate = pickedDate;
                          _isDueDateEnabled = true; // Automatically enable the toggle
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildToggleListTileWithTimeSelector(
                    icon: Icons.access_time,
                    iconColor: Colors.blue,
                    title: 'Time',
                    subtitle: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : '9:00 AM',
                    toggleValue: _isTimeEnabled,
                    onToggleChanged: (value) {
                      setState(() {
                        _isTimeEnabled = value;
                      });
                    },
                    onTimeSelected: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedTime = pickedTime;
                          _isTimeEnabled = true; // Automatically enable the toggle
                        });
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildToggleListTileWithReminderSelector(
                    icon: Icons.notifications,
                    iconColor: Colors.orange,
                    title: 'Reminder',
                    subtitle:
                        '$_reminderValue ${_reminderValue == 1 ? _reminderType.substring(0, _reminderType.length - 1) : _reminderType} before',
                    toggleValue: _isReminderEnabled,
                    onToggleChanged: (value) {
                      setState(() {
                        _isReminderEnabled = value;
                      });
                    },
                    onReminderSelected: () async {
                      await _showReminderDialog(context);
                    },
                  ),
                  _buildDivider(),
                  _buildDropdownListTile(
                    icon: Icons.priority_high,
                    iconColor: Colors.red,
                    title: 'Priority',
                    value: _priorityLevel,
                    items: ['Low', 'Medium', 'High'],
                    onChanged: (value) {
                      setState(() {
                        _priorityLevel = value!;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildDropdownListTile(
                    icon: Icons.color_lens,
                    iconColor: Colors.blue,
                    title: 'Color',
                    value: _color,
                    items: ['None', 'Red', 'Green', 'Blue'],
                    onChanged: (value) {
                      setState(() {
                        _color = value!;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildToggleListTile(
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    title: 'Complete',
                    toggleValue: _isComplete,
                    onToggleChanged: (value) {
                      setState(() {
                        _isComplete = value;
                      });
                    },
                  ),
                  _buildDivider(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showReminderDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Set Reminder'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reminder Type Dropdown (Hours or Days)
            DropdownButton<String>(
              value: _reminderType,
              items: ['Hours', 'Days']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _reminderType = value!;
                });
                Navigator.of(context).pop();
                _showReminderDialog(context); // Reopen dialog with updated dropdown
              },
            ),
            const SizedBox(height: 10),
            // Reminder Value Dropdown
            DropdownButton<int>(
              value: _reminderValue,
              items: List.generate(24, (index) => index + 1)
                  .map((val) => DropdownMenuItem(
                        value: val,
                        child: Text(val.toString()),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _reminderValue = value!;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}


  Widget _buildToggleListTileWithReminderSelector({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool toggleValue,
    required Function(bool) onToggleChanged,
    required VoidCallback onReminderSelected,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: GestureDetector(
        onTap: onReminderSelected,
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      trailing: Switch(
        activeColor: Colors.orange,
        value: toggleValue,
        onChanged: onToggleChanged,
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildToggleListTileWithDateSelector({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool toggleValue,
    required Function(bool) onToggleChanged,
    required VoidCallback onDateSelected,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: GestureDetector(
        onTap: onDateSelected,
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      trailing: Switch(
        activeColor: Colors.purple,
        value: toggleValue,
        onChanged: onToggleChanged,
      ),
    );
  }
  Widget _buildToggleListTile({
      required IconData icon,
      required Color iconColor,
      required String title,
      String? subtitle,
      required bool toggleValue,
      required Function(bool) onToggleChanged,
    }) {
      return ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              )
            : null,
        trailing: Switch(
          activeColor: Colors.purple,
          value: toggleValue,
          onChanged: onToggleChanged,
        ),
      );
    }
  Widget _buildToggleListTileWithTimeSelector({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool toggleValue,
    required Function(bool) onToggleChanged,
    required VoidCallback onTimeSelected,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: GestureDetector(
        onTap: onTimeSelected,
        child: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      trailing: Switch(
        activeColor: Colors.purple,
        value: toggleValue,
        onChanged: onToggleChanged,
      ),
    );
  }

  Widget _buildDropdownListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: Colors.grey,
      thickness: 0.5,
      height: 0,
      indent: 16,
      endIndent: 16,
    );
  }
}
