import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/lesson_session_provider.dart';
import '../../routing/route_args.dart';
import 'widgets/word_chip.dart';

class SentenceBuildingScreen extends StatefulWidget {
  const SentenceBuildingScreen({super.key, required this.args});

  final LessonFlowArgs args;

  @override
  State<SentenceBuildingScreen> createState() => _SentenceBuildingScreenState();
}

class _SentenceBuildingScreenState extends State<SentenceBuildingScreen> {
  final List<int> _selectedIndices = [];
  bool? _isCorrect;

  void _submit(List<String> scrambledWords, List<String> correctOrder) {
    final built = _selectedIndices.map((i) => scrambledWords[i]).toList();
    final correct = built.length == correctOrder.length &&
        List.generate(built.length, (i) => built[i] == correctOrder[i]).every((v) => v);
    setState(() => _isCorrect = correct);
    context.read<LessonSessionProvider>().markSentenceCorrect(correct);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = context.watch<LessonSessionProvider>().content?.sentenceExercise;
    if (exercise == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final scrambledWords = exercise.scrambledWords;
    final availableIndices = List.generate(scrambledWords.length, (i) => i)
        .where((i) => !_selectedIndices.contains(i))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sentence building')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(exercise.promptTranslation, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final i in _selectedIndices)
                      WordChip(
                        label: scrambledWords[i],
                        onTap: () => setState(() {
                          _selectedIndices.remove(i);
                          _isCorrect = null;
                        }),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final i in availableIndices)
                    WordChip(
                      label: scrambledWords[i],
                      onTap: () => setState(() {
                        _selectedIndices.add(i);
                        _isCorrect = null;
                      }),
                    ),
                ],
              ),
              const Spacer(),
              if (_isCorrect != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _isCorrect! ? 'Correct!' : 'Not quite — try again.',
                    style: TextStyle(
                      color: _isCorrect! ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (_isCorrect == true)
                PrimaryButton(
                  label: 'Next: Conversation practice',
                  onPressed: () => Navigator.of(context)
                      .pushNamed(Routes.conversationPractice, arguments: widget.args),
                )
              else
                PrimaryButton(
                  label: 'Check',
                  onPressed: availableIndices.isEmpty
                      ? () => _submit(scrambledWords, exercise.correctOrder)
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
