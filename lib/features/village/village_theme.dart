import 'package:flutter/material.dart';

/// Deterministic (icon, color, structure label) per level order, cycling so
/// it scales to any number of levels without hardcoding per-level-name
/// logic. Used both for the puzzle "themed image" (SRS 3.3) and for the
/// matching village structure added when that level's puzzle completes.
class LevelTheme {
  const LevelTheme({required this.puzzleIcon, required this.color, required this.structureIcon, required this.structureLabel});

  final IconData puzzleIcon;
  final Color color;
  final IconData structureIcon;
  final String structureLabel;
}

const _palette = [
  LevelTheme(
    puzzleIcon: Icons.waving_hand,
    color: Colors.green,
    structureIcon: Icons.cottage,
    structureLabel: 'Hut',
  ),
  LevelTheme(
    puzzleIcon: Icons.storefront,
    color: Colors.orange,
    structureIcon: Icons.park,
    structureLabel: 'Tree',
  ),
  LevelTheme(
    puzzleIcon: Icons.local_hospital,
    color: Colors.blue,
    structureIcon: Icons.water_drop,
    structureLabel: 'Well',
  ),
];

LevelTheme themeForLevelOrder(int order) => _palette[(order - 1) % _palette.length];
