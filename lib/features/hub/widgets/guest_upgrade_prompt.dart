import 'package:flutter/material.dart';

import '../../../core/constants/routes.dart';
import '../../../core/widgets/primary_button.dart';

class GuestUpgradePrompt extends StatelessWidget {
  const GuestUpgradePrompt({super.key, required this.featureName});

  final String featureName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'Create an account to use $featureName',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your guest progress will carry over automatically.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create account',
              onPressed: () => Navigator.of(context).pushNamed(Routes.guestUpgrade),
            ),
          ],
        ),
      ),
    );
  }
}
