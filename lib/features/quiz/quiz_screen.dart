import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/lesson_session_provider.dart';
import '../../routing/route_args.dart';
import 'widgets/quiz_option_tile.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.args});

  final LessonFlowArgs args;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<LessonSessionProvider>();
    final quiz = session.content?.quiz ?? const [];
    if (quiz.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = quiz[_questionIndex];
    final selected = session.answerFor(_questionIndex);
    final isLastQuestion = _questionIndex == quiz.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text('Quiz (${_questionIndex + 1}/${quiz.length})')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(question.prompt, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < question.options.length; i++)
                      QuizOptionTile(
                        label: question.options[i],
                        selected: selected == i,
                        onTap: () => context
                            .read<LessonSessionProvider>()
                            .answerQuizQuestion(_questionIndex, i),
                      ),
                  ],
                ),
              ),
              PrimaryButton(
                label: isLastQuestion ? 'Next: Sentence building' : 'Next question',
                onPressed: selected == null
                    ? null
                    : () {
                        if (isLastQuestion) {
                          Navigator.of(context)
                              .pushNamed(Routes.sentenceBuilding, arguments: widget.args);
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
