import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/routes.dart';
import 'core/theme/app_theme.dart';
import 'data/cached_content_repository.dart';
import 'data/fake/fake_auth_repository.dart';
import 'data/fake/fake_content_repository.dart';
import 'data/fake/fake_progress_repository.dart';
import 'data/firebase/firebase_auth_repository.dart';
import 'data/firebase/firestore_content_repository.dart';
import 'data/firebase/firestore_progress_repository.dart';
import 'data/local/local_download_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/content_repository.dart';
import 'data/repositories/download_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/downloads_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/lesson_session_provider.dart';
import 'providers/level_list_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/quests_provider.dart';
import 'routing/app_router.dart';

/// The single swap point for backends. Firebase is used by default now that
/// the learn-ateso project is wired up (Phase 5); pass
/// --dart-define=USE_FIREBASE=false to fall back to the in-memory fakes for
/// offline development. No other file needs to change either way, since
/// everything downstream depends only on the abstract repository interfaces.
const useFirebase = bool.fromEnvironment('USE_FIREBASE', defaultValue: true);

class LearnAtesoApp extends StatelessWidget {
  const LearnAtesoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DownloadRepository>(
          create: (_) => LocalDownloadRepository(),
        ),
        Provider<ContentRepository>(
          create: (context) => CachedContentRepository(
            useFirebase ? FirestoreContentRepository() : FakeContentRepository(),
            context.read<DownloadRepository>(),
          ),
        ),
        Provider<AuthRepository>(
          create: (_) => useFirebase ? FirebaseAuthRepository() : FakeAuthRepository(),
        ),
        Provider<ProgressRepository>(
          create: (context) => useFirebase
              ? FirestoreProgressRepository(context.read<ContentRepository>())
              : FakeProgressRepository(),
        ),
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
        ChangeNotifierProvider(
          create: (context) => LeaderboardProvider(context.read<ProgressRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => QuestsProvider(context.read<ProgressRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => DownloadsProvider(
            context.read<ContentRepository>(),
            context.read<DownloadRepository>(),
          ),
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
