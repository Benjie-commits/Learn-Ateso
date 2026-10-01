import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../models/leaderboard_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/level_list_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/quests_provider.dart';
import 'village_theme.dart';

/// Decay is derived live from UserProgress.lastActive rather than stored as
/// its own Firestore field (a deliberate simplification vs. the domain
/// model's VILLAGE.decayState) — it needs no extra write path, and
/// "restoring as the user resumes activity" (SRS 3.3) falls out for free
/// the moment lastActive updates on their next lesson completion.
class _Decay {
  const _Decay(this.opacity, this.message, this.color, {this.overgrown = false});

  final double opacity;
  final String message;
  final Color color;
  final bool overgrown;
}

_Decay _decayFor(int daysSinceActive) {
  if (daysSinceActive >= 7) {
    return const _Decay(
      0.35,
      'Your village has become overgrown from inactivity. Complete a lesson to restore it!',
      Colors.brown,
      overgrown: true,
    );
  }
  if (daysSinceActive >= 3) {
    return const _Decay(
      0.65,
      'Your village is starting to fade — come back and keep learning!',
      Colors.amber,
    );
  }
  return const _Decay(1.0, 'Your village is thriving!', Colors.green);
}

class VillageView extends StatelessWidget {
  const VillageView({super.key});

  @override
  Widget build(BuildContext context) {
    final levelProvider = context.watch<LevelListProvider>();
    final progress = context.watch<ProgressProvider>().progress;
    final leaderboard = context.watch<LeaderboardProvider>().entries;
    final currentUserId = context.watch<AuthProvider>().user?.id;
    final quests = context.watch<QuestsProvider>().quests;
    final completedQuests = quests.where((q) => q.completed).length;

    final completedLevels = levelProvider.levelViewModels.where((vm) => vm.isComplete).toList()
      ..sort((a, b) => a.level.order.compareTo(b.level.order));

    final daysSinceActive = DateTime.now().difference(progress.lastActive).inDays;
    final decay = _decayFor(daysSinceActive);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Village', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              if (decay.overgrown) const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.eco, size: 18, color: Colors.brown),
              ),
              Expanded(
                child: Text(decay.message, style: TextStyle(color: decay.color)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (completedLevels.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Complete a level to add your first structure!',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (final vm in completedLevels)
                  _StructureTile(levelOrder: vm.level.order, levelName: vm.level.name, opacity: decay.opacity),
              ],
            ),
          const SizedBox(height: 32),
          Card(
            child: ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Weekly Quests'),
              subtitle: Text(
                quests.isEmpty
                    ? 'Loading this week\'s challenges…'
                    : '$completedQuests/${quests.length} complete this week',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(Routes.quests),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.leaderboard_outlined, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: 12),
                      Text('Leaderboard', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (leaderboard.isEmpty)
                    const Text('Complete a lesson to join the leaderboard!')
                  else
                    for (var i = 0; i < leaderboard.length; i++)
                      _LeaderboardRow(
                        rank: i + 1,
                        entry: leaderboard[i],
                        isCurrentUser: leaderboard[i].userId == currentUserId,
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
  });

  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
      color: isCurrentUser ? Theme.of(context).colorScheme.primary : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$rank', style: style)),
          Expanded(
            child: Text(
              isCurrentUser ? '${entry.name} (You)' : entry.name,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${entry.points} pts', style: style),
        ],
      ),
    );
  }
}

class _StructureTile extends StatelessWidget {
  const _StructureTile({required this.levelOrder, required this.levelName, required this.opacity});

  final int levelOrder;
  final String levelName;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final theme = themeForLevelOrder(levelOrder);
    return SizedBox(
      width: 90,
      child: Opacity(
        opacity: opacity,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(theme.structureIcon, size: 36, color: theme.color),
            ),
            const SizedBox(height: 6),
            Text(
              theme.structureLabel,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              levelName,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
