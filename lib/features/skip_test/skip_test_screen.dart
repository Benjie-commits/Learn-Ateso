import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../models/aptitude_test.dart';
import '../../providers/auth_provider.dart';
import '../../routing/route_args.dart';
import '../quiz/widgets/quiz_option_tile.dart';

class SkipTestScreen extends StatefulWidget {
  const SkipTestScreen({super.key, required this.args});

  final SkipTestArgs args;

  @override
  State<SkipTestScreen> createState() => _SkipTestScreenState();
}

class _SkipTestScreenState extends State<SkipTestScreen> {
  AptitudeTest? _test;
  int _questionIndex = 0;
  final Map<int, int> _answers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    context.read<ContentRepository>().getAptitudeTest(widget.args.levelId).then((test) {
      if (mounted) setState(() => _test = test);
    });
  }

  Future<void> _finish() async {
    setState(() => _isSubmitting = true);
    final test = _test!;
    var correct = 0;
    for (var i = 0; i < test.questions.length; i++) {
      if (_answers[i] == test.questions[i].correctOptionIndex) correct++;
    }
    final passed = correct >= test.passThreshold;
    final userId = context.read<AuthProvider>().user!.id;
    await context.read<ProgressRepository>().recordAptitudeTestResult(
          userId: userId,
          levelId: widget.args.levelId,
          passed: passed,
        );
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
      Routes.skipTestResult,
      arguments: SkipTestResultArgs(
        levelId: widget.args.levelId,
        levelName: widget.args.levelName,
        passed: passed,
        correctCount: correct,
        totalCount: test.questions.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final test = _test;
    if (test == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final question = test.questions[_questionIndex];
    final selected = _answers[_questionIndex];
    final isLast = _questionIndex == test.questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('Skip test: ${widget.args.levelName}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${_questionIndex + 1}/${test.questions.length}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(question.prompt, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < question.options.length; i++)
                      QuizOptionTile(
                        label: question.options[i],
                        selected: selected == i,
                        onTap: () => setState(() => _answers[_questionIndex] = i),
                      ),
                  ],
                ),
              ),
              PrimaryButton(
                label: isLast ? 'Submit' : 'Next question',
                isLoading: _isSubmitting,
                onPressed: selected == null
                    ? null
                    : () {
                        if (isLast) {
                          _finish();
                        } else {
                          setState(() => _questionIndex++);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
