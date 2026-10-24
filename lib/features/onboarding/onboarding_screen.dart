import 'package:flutter/material.dart';

import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.welcomeBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandBrown.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 260,
                    height: 260,
                    fit: BoxFit.cover,
                    semanticLabel: 'Learn Ateso',
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Learn conversational Ateso through short lessons, quizzes, '
                'and real dialogue practice.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: AppTheme.brandBrown),
              ),
              const SizedBox(height: 48),
              Theme(
                data: theme.copyWith(
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppTheme.brandBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                child: PrimaryButton(
                  label: 'Get started',
                  onPressed: () => Navigator.of(context).pushNamed(Routes.login),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
