import 'package:flutter/material.dart';

import '../../../core/constants/routes.dart';
import '../../../models/lesson.dart';
import '../../../routing/route_args.dart';

/// One round node on the winding lesson path. [index] decides how far left or
/// right of centre the node sits, which gives the path its zigzag shape.
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.index,
    required this.locked,
    required this.completed,
    required this.color,
  });

  final Lesson lesson;
  final int index;
  final bool locked;
  final bool completed;
  final Color color;

  static const _wave = [0.0, 0.5, 0.8, 0.5, 0.0, -0.5, -0.8, -0.5];
  static const double _size = 76;

  @override
  Widget build(BuildContext context) {
    final face = locked ? Colors.grey.shade400 : color;
    final edge = HSLColor.fromColor(face).withLightness(
      (HSLColor.fromColor(face).lightness - 0.15).clamp(0.0, 1.0),
    ).toColor();
    final icon = locked
        ? Icons.lock
        : completed
            ? Icons.check
            : Icons.star;

    return Align(
      alignment: Alignment(_wave[index % _wave.length], 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
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
              child: Container(
                width: _size,
                height: _size - 6,
                decoration: BoxDecoration(
                  color: face,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: edge, offset: const Offset(0, 6))],
                ),
                child: Icon(icon, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 130,
              child: Text(
                lesson.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: locked ? Colors.grey.shade600 : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
