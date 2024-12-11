import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for Timestamp

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TimeOfDay? time; // Optional time field
  final String? reminder; // Optional reminder field
  final String priority;
  final String color;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.time,
    this.reminder,
    this.priority = 'Medium',
    this.color = 'None',
    this.completed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'reminder': reminder,
      'priority': priority,
      'color': color,
      'completed': completed,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    DateTime? dueDate;
    if (map['dueDate'] is Timestamp) {
      dueDate = (map['dueDate'] as Timestamp).toDate(); // Convert Timestamp to DateTime
    } else if (map['dueDate'] is String) {
      dueDate = DateTime.tryParse(map['dueDate']); // Parse String to DateTime
    }

    final timeString = map['time'] as String?;
    final time = timeString != null
        ? TimeOfDay(
      hour: int.parse(timeString.split(':')[0]),
      minute: int.parse(timeString.split(':')[1]),
    )
        : null;

    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled Task',
      description: map['description'] ?? '',
      dueDate: dueDate,
      time: time,
      reminder: map['reminder'] as String?,
      priority: map['priority'] ?? 'Medium',
      color: map['color'] ?? 'None',
      completed: map['completed'] ?? false,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? time,
    String? reminder,
    String? priority,
    String? color,
    bool? completed,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      time: time ?? this.time,
      reminder: reminder ?? this.reminder,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      completed: completed ?? this.completed,
    );
  }
}

