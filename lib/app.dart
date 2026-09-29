import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/routes.dart';
import 'core/theme/app_theme.dart';
import 'data/fake/fake_auth_repository.dart';
import 'data/fake/fake_content_repository.dart';
import 'data/fake/fake_progress_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/content_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/lesson_session_provider.dart';
import 'providers/level_list_provider.dart';
import 'providers/progress_provider.dart';
import 'routing/app_router.dart';

/// The single swap point for Firebase: once credentials are wired (Phase 5
/// of the implementation plan), replace these three Fake* instances with
/// Firebase*Repository instances. No other file needs to change, since
/// everything downstream depends only on the abstract repository interfaces.
class LearnAtesoApp extends StatelessWidget {
  const LearnAtesoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => FakeAuthRepository()),
        Provider<ContentRepository>(create: (_) => FakeContentRepository()),
        Provider<ProgressRepository>(create: (_) => FakeProgressRepository()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => LevelListProvider(
            context.read<ContentRepository>(),
            context.read<ProgressRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LessonSessionProvider(context.read<ContentRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ProgressProvider(context.read<ProgressRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Learn Ateso',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: Routes.onboarding,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
