import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/weekly_quest.dart';
import '../../providers/quests_provider.dart';
import 'quest_templates.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quests = context.watch<QuestsProvider>().quests;

    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Quests')),
      body: quests.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final quest in quests)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuestCard(quest: quest),
                  ),
              ],
            ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  const _QuestCard({required this.quest});

  final WeeklyQuest quest;

  @override
  Widget build(BuildContext context) {
    final progress = (quest.progressValue / quest.targetValue).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  quest.completed ? Icons.check_circle : Icons.flag_outlined,
                  color: quest.completed ? Colors.green : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(quest.description)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: quest.completed ? Colors.green : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              quest.completed
                  ? 'Completed! +$questCompletionBonus bonus points'
                  : '${quest.progressValue}/${quest.targetValue}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
