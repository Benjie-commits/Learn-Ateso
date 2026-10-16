import 'package:flutter/material.dart';

class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    super.key,
    required this.label,
    required this.selected,
    required this.isCorrectAnswer,
    required this.revealResult,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isCorrectAnswer;
  final bool revealResult;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color? color;
    Widget? trailing;
    if (revealResult && isCorrectAnswer) {
      color = Colors.green.withValues(alpha: 0.2);
      trailing = const Icon(Icons.check_circle, color: Colors.green);
    } else if (revealResult && selected) {
      color = Colors.red.withValues(alpha: 0.2);
      trailing = const Icon(Icons.cancel, color: Colors.red);
    } else if (selected) {
      color = colorScheme.primaryContainer;
    }

    return Card(
      color: color,
      child: ListTile(
        title: Text(label),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
