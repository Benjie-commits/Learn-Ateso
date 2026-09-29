import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/lesson_session_provider.dart';
import '../../routing/route_args.dart';

class GrammarNotesScreen extends StatelessWidget {
  const GrammarNotesScreen({super.key, required this.args});

  final LessonFlowArgs args;

  @override
  Widget build(BuildContext context) {
    final content = context.watch<LessonSessionProvider>().content;
    return Scaffold(
      appBar: AppBar(title: const Text('Grammar notes')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  content?.grammarNote ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                label: 'Next: Quiz',
                onPressed: () => Navigator.of(context).pushNamed(Routes.quiz, arguments: args),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
