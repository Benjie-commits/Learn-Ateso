import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/dialogue_module.dart';
import '../../providers/lesson_session_provider.dart';
import '../../routing/route_args.dart';
import 'widgets/dialogue_bubble.dart';

class ConversationPracticeScreen extends StatefulWidget {
  const ConversationPracticeScreen({super.key, required this.args});

  final LessonFlowArgs args;

  @override
  State<ConversationPracticeScreen> createState() => _ConversationPracticeScreenState();
}

class _ConversationPracticeScreenState extends State<ConversationPracticeScreen> {
  // Number of turns fully resolved (npc turns shown, user turns answered
  // correctly). The turn at this index, if any, is the one currently
  // awaiting action.
  int _resolvedCount = 0;
  final Map<int, String> _chosenResponses = {};
  String? _feedback;
  bool _initialized = false;

  void _autoResolveNpcTurns(List<DialogueTurn> turns) {
    while (_resolvedCount < turns.length && turns[_resolvedCount].speaker != 'user') {
      _resolvedCount++;
    }
    if (_resolvedCount >= turns.length) {
      context.read<LessonSessionProvider>().markDialogueCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<LessonSessionProvider>();
    final dialogue = session.content?.dialogue;
    if (dialogue == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _autoResolveNpcTurns(dialogue.turns));
      });
    }

    final turns = dialogue.turns;
    final isDone = session.dialogueCompleted;
    final pendingTurn = _resolvedCount < turns.length ? turns[_resolvedCount] : null;
    final isUserTurnPending = pendingTurn != null && pendingTurn.speaker == 'user';

    return Scaffold(
      appBar: AppBar(title: Text('Conversation: ${dialogue.scenario}')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (var i = 0; i < _resolvedCount; i++)
                    DialogueBubble(
                      text: turns[i].speaker == 'user'
                          ? (_chosenResponses[i] ?? turns[i].line)
                          : turns[i].line,
                      isUser: turns[i].speaker == 'user',
                    ),
                ],
              ),
            ),
            if (isUserTurnPending && !isDone)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < pendingTurn.responseOptions.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                          onPressed: () {
                            final correct = i == pendingTurn.correctResponseIndex;
                            setState(() {
                              if (correct) {
                                _feedback = null;
                                _chosenResponses[_resolvedCount] =
                                    pendingTurn.responseOptions[i];
                                _resolvedCount++;
                                _autoResolveNpcTurns(turns);
                              } else {
                                _feedback = 'Try a different response.';
                              }
                            });
                          },
                          child: Text(pendingTurn.responseOptions[i]),
                        ),
                      ),
                    if (_feedback != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(_feedback!, style: const TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                label: 'Complete lesson',
                onPressed: isDone
                    ? () => Navigator.of(context)
                        .pushNamed(Routes.lessonComplete, arguments: widget.args)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
