import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Renders a level's "themed image" (SRS 3.3) as a grid of cover tiles over
/// a base icon/color, removing tiles as puzzle pieces are revealed —
/// instead of the pieces just being abstract squares, completing lessons
/// visibly uncovers one coherent picture.
class PuzzleImageReveal extends StatelessWidget {
  const PuzzleImageReveal({
    super.key,
    required this.totalPieces,
    required this.revealedPositions,
    required this.icon,
    required this.color,
    this.size = 120,
  });

  final int totalPieces;
  final Set<int> revealedPositions;
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final columns = math.sqrt(totalPieces).ceil().clamp(1, totalPieces);
    final rows = (totalPieces / columns).ceil();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: color.withValues(alpha: 0.15),
              child: Center(child: Icon(icon, size: size * 0.55, color: color)),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns),
              itemCount: rows * columns,
              itemBuilder: (context, index) {
                // Cells beyond totalPieces exist only to fill a non-square
                // grid; treat them as always revealed rather than stuck grey.
                final revealed = index >= totalPieces || revealedPositions.contains(index);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: revealed ? Colors.transparent : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
