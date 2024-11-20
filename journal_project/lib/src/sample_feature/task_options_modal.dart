import 'package:flutter/material.dart';

class TaskModalScreen extends StatelessWidget {
  final String taskName;
  final String dateTime;

  TaskModalScreen({
    required this.taskName,
    required this.dateTime,
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
              const SizedBox(), // Empty space for alignment
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
          // Task Name and Date/Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                taskName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateTime,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
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
                onPressed: () {
                  // Duplicate functionality here
                },
              ),
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit Task',
                color: Colors.orange,
                onPressed: () {
                  // Edit functionality here
                },
              ),
              _buildActionButton(
                icon: Icons.delete,
                label: 'Delete',
                color: Colors.red,
                onPressed: () {
                  // Delete functionality here
                },
              ),
              _buildActionButton(
                icon: Icons.check_circle,
                label: 'Complete',
                color: Colors.green,
                onPressed: () {
                  // Complete functionality here
                },
              ),
            ],
          ),
        ],
      ),
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
}
