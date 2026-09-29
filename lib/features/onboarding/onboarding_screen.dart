import 'package:flutter/material.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.translate, size: 96, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Learn Ateso',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'Learn conversational Ateso through short lessons, quizzes, '
                'and real dialogue practice.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                label: 'Get started',
                onPressed: () => Navigator.of(context).pushNamed(Routes.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
