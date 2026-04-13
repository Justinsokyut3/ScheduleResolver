import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int urgency;
  final int importance;
  final double estimatedEffortHours;
  final String energyLevel;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.urgency,
    required this.importance,
    required this.estimatedEffortHours,
    required this.energyLevel,
  });

  Map<String, dynamic> toJson() {
    // ✅ Fixed escaped \$ — these are normal Dart files, not triple-quoted prompts
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMin = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMin = endTime.minute.toString().padLeft(2, '0');

    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date.toIso8601String().split('T').first,
      'startTime': '$startHour:$startMin',   // ✅ e.g. "09:30" instead of "9 : 30"
      'endTime': '$endHour:$endMin',          // ✅ clean format for AI to parse
      'urgency': urgency,
      'importance': importance,
      'estimatedEffortHours': estimatedEffortHours,
      'energyLevel': energyLevel,
    };
  }
}