import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage; // ✅ Fixed typo (was _errorMesssage)

  // ✅ PASTE YOUR GEMINI API KEY HERE — get one free at https://aistudio.google.com
  final String _apiKey = '';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; // ✅ Fixed typo

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY_HERE' || tasks.isEmpty) return;

    _isLoading = true;
    _errorMessage = null; // ✅ Fixed typo
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final taskJson = jsonEncode(tasks.map((t) => t.toJson()).toList());

      final prompt = '''
You are an expert student scheduling assistant. The user has provided the following tasks for their day in JSON format:
$taskJson

Your job is to analyze these tasks, identify any overlaps or conflicts in their start and end times, and suggest a better balanced schedule. Consider their urgency, importance, and required energy level.

Please provide exactly 4 sections of markdown text:

### Detected Conflicts
List any scheduling conflicts or overlapping tasks. State clearly if there are none.

### Ranked Tasks
Rank which tasks need attention first based on urgency, importance, and energy level. Provide a brief reason for each ranking.

### Recommended Schedule
Provide a revised daily timeline adjusting task times to resolve conflicts and balance the student's workload, study time, and rest.

### Explanation
Explain why this recommendation was made in simple language that a student would easily understand.

Ensure the markdown is well-formatted and easy to read. Do not include any extra text outside of these four headers.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      _currentAnalysis = _parseResponse(response.text ?? '');
    } catch (e) {
      _errorMessage = 'Failed: $e'; // ✅ Fixed typo and removed backslash
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ScheduleAnalysis _parseResponse(String fulltext) {
    String conflicts = '', rankedTasks = '', recommendedSchedule = '', explanation = '';

    final sections = fulltext.split('###');
    for (var section in sections) {
      final trimmed = section.trim(); // ✅ trim before startsWith so whitespace won't break matching
      if (trimmed.startsWith('Detected Conflicts')) {
        conflicts = trimmed.replaceFirst('Detected Conflicts', '').trim();
      } else if (trimmed.startsWith('Ranked Tasks')) {
        rankedTasks = trimmed.replaceFirst('Ranked Tasks', '').trim();
      } else if (trimmed.startsWith('Recommended Schedule')) {
        recommendedSchedule = trimmed.replaceFirst('Recommended Schedule', '').trim();
      } else if (trimmed.startsWith('Explanation')) {
        explanation = trimmed.replaceFirst('Explanation', '').trim();
      }
    }

    return ScheduleAnalysis(
      conflicts: conflicts,
      rankedTasks: rankedTasks,
      recommendedSchedule: recommendedSchedule,
      explanation: explanation,
    );
  }
}