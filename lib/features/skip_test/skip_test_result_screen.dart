import 'package:flutter/material.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../routing/route_args.dart';

class SkipTestResultScreen extends StatelessWidget {
  const SkipTestResultScreen({super.key, required this.args});

  final SkipTestResultArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skip test result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                args.passed ? Icons.lock_open : Icons.lock_outline,
                size: 72,
                color: args.passed ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                args.passed
                    ? '${args.levelName} unlocked!'
                    : 'Not quite — ${args.levelName} stays locked',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Score: ${args.correctCount}/${args.totalCount}'),
              const SizedBox(height: 8),
              if (!args.passed)
                const Text(
                  "You'll start from the first lesson of this level instead.",
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Back to lessons',
                onPressed: () =>
                    Navigator.of(context).popUntil(ModalRoute.withName(Routes.home)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
