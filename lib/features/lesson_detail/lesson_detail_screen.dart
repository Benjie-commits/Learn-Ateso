import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/lesson_session_provider.dart';
import '../../routing/route_args.dart';
import 'widgets/audio_play_button.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key, required this.args});

  final LessonFlowArgs args;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LessonSessionProvider>().loadLesson(
            lessonId: widget.args.lessonId,
            levelId: widget.args.levelId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<LessonSessionProvider>();
    final content = session.content;

    return Scaffold(
      appBar: AppBar(title: Text(widget.args.lessonTitle)),
      body: session.isLoading || content == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final item in content.vocabulary)
                          Card(
                            child: ListTile(
                              title: Text(item.word, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item.translation),
                              trailing: AudioPlayButton(audioRef: item.audioRef),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: PrimaryButton(
                      label: 'Next: Grammar notes',
                      onPressed: () => Navigator.of(context).pushNamed(
                        Routes.grammarNotes,
                        arguments: widget.args,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
