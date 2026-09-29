import 'package:flutter/material.dart';

import '../../../core/constants/routes.dart';
import '../../../models/lesson.dart';
import '../../../routing/route_args.dart';

class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.locked,
    required this.completed,
  });

  final Lesson lesson;
  final bool locked;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        locked
            ? Icons.lock_outline
            : completed
                ? Icons.check_circle
                : Icons.play_circle_outline,
        color: completed ? Colors.green : null,
      ),
      title: Text(lesson.title),
      enabled: !locked,
      onTap: locked
          ? null
          : () => Navigator.of(context).pushNamed(
                Routes.lessonDetail,
                arguments: LessonFlowArgs(
                  lessonId: lesson.id,
                  levelId: lesson.levelId,
                  lessonTitle: lesson.title,
                ),
              ),
    );
  }
}
