import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier{
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMesssage;

  final String _apiKey = '';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMesssage;


  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apiKey.isEmpty || tasks.isEmpty) return;
    _isLoading = true;
    _errorMesssage = null;
    notifyListeners();

    try {

      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final taskJson = jsonEncode(tasks.map((t) => t.toJson()).toList());

      final prompt = '''

       You are an expert student scheduling assistant. The user has provided the following tasks for their day in JSON format:
       $taskJson

       Your job is to analyze these task, identify any overlaps or conflicts in their srtart and end time, and suggest a better balanced schedule,
       consider their urgency, importance, and required energy level.

      Please Provide exactly 4 sections of markdown text:
      1. ### Detected Conflicts
      List any Scheduling conflicts or state that there are none.
      2. ### Ranked tasks
      Rank Whick tasks need attention first based on urgency, importance, and energy, provide a brief reason for each.
      3. ### Recommended Schedule
      Provide a revised daily timeline view adjusting the task times to resolve conflicts and balance the students workload, study time and rest.
      4. ### Explanation
      Explain why this recommencdation was made in simple language that a student would easily understand.

      Ensure the markdown is well-formatted and easy to read. Do not include extra text outside of there headers.
    ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      _currentAnalysis = _parseResponse(response.text ?? '');
    } catch (e) {
      _errorMesssage = 'Failed: \$e';
    }finally {
      _isLoading = false;
      notifyListeners();

    }

  }

  ScheduleAnalysis _parseResponse (String fulltext) {
    String conflicts = '', rankedTasks = "", recommendedSchedule = "", explanation = "";

    final sections = fulltext.split('###');
    for (var section in sections) {
      if (section.startsWith('Detected Conflicts')) conflicts = section.replaceFirst('Detected Conflicts','').trim();
      else if (section.startsWith('Ranked Tasks')) rankedTasks = section.replaceFirst('RankedTasks', '').trim();
      else if (section.startsWith('Recommended Schedule')) recommendedSchedule = section.replaceFirst('Recommended Schedule', '').trim();
      else if (section.startsWith('Explanation')) explanation = section.replaceFirst('Explanation', '').trim();
    }

    return ScheduleAnalysis(
        coflicts: conflicts,
        rankedTasks: rankedTasks,
        recommendedSchedule: recommendedSchedule,
        explanation: explanation
    );
  }

}