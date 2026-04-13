import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_schedule_service.dart'; // ✅ Removed duplicate import

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AiScheduleService>(context);
    final analysis = aiService.currentAnalysis;

    if (analysis == null) {
      return const Scaffold(
        body: Center(child: Text('No analysis data available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Schedule Recommendation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(
              context,
              '⚠️ Detected Conflicts',
              analysis.conflicts,
              Colors.red.shade50,
              Icons.warning_amber_rounded,
              Colors.red.shade700,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '📋 Ranked Tasks',
              analysis.rankedTasks,
              Colors.blue.shade50,
              Icons.format_list_numbered,
              Colors.blue.shade700,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '🗓️ Recommended Schedule',
              analysis.recommendedSchedule,
              Colors.green.shade50,
              Icons.calendar_today,
              Colors.green.shade700,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              '💡 Explanation',
              analysis.explanation,
              Colors.orange.shade50,
              Icons.lightbulb_outline,
              Colors.orange.shade700,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context,
      String title,
      String content,
      Color bgColor,
      IconData icon,
      Color iconColor,
      ) {
    // ✅ Show a placeholder if this section came back empty
    final displayContent = content.isEmpty
        ? '_No data returned for this section._'
        : content;

    return Card(
      color: bgColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              displayContent,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}