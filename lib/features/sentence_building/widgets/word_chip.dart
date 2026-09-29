import 'package:flutter/material.dart';

class WordChip extends StatelessWidget {
  const WordChip({super.key, required this.label, required this.onTap, this.disabled = false});

  final String label;
  final VoidCallback onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: disabled ? null : onTap,
    );
  }
}
