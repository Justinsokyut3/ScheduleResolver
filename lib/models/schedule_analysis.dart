class ScheduleAnalysis {

  final String coflicts;
  final String rankedTasks;
  final String recommendedSchedule;
  final String explanation;


  ScheduleAnalysis ({
    required this.coflicts, required this.rankedTasks,
    required this.recommendedSchedule, required this.explanation,
});
}
