import 'package:flutter/material.dart';

import '../core/constants/routes.dart';
import '../features/auth/auth_gate.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/conversation_practice/conversation_practice_screen.dart';
import '../features/grammar_notes/grammar_notes_screen.dart';
import '../features/guest_upgrade/guest_upgrade_screen.dart';
import '../features/home/home_shell.dart';
import '../features/lesson_complete/lesson_complete_screen.dart';
import '../features/lesson_detail/lesson_detail_screen.dart';
import '../features/quests/quests_screen.dart';
import '../features/quiz/quiz_screen.dart';
import '../features/sentence_building/sentence_building_screen.dart';
import '../features/skip_test/skip_test_result_screen.dart';
import '../features/skip_test/skip_test_screen.dart';
import '../features/village/village_screen.dart';
import 'route_args.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboarding:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
      case Routes.guestUpgrade:
        return MaterialPageRoute(builder: (_) => const GuestUpgradeScreen());
      case Routes.lessonDetail:
        final args = settings.arguments as LessonFlowArgs;
        return MaterialPageRoute(builder: (_) => LessonDetailScreen(args: args));
      case Routes.grammarNotes:
        final args = settings.arguments as LessonFlowArgs;
        return MaterialPageRoute(builder: (_) => GrammarNotesScreen(args: args));
      case Routes.quiz:
        final args = settings.arguments as LessonFlowArgs;
        return MaterialPageRoute(builder: (_) => QuizScreen(args: args));
      case Routes.sentenceBuilding:
        final args = settings.arguments as LessonFlowArgs;
        return MaterialPageRoute(builder: (_) => SentenceBuildingScreen(args: args));
      case Routes.conversationPractice:
        final args = settings.arguments as LessonFlowArgs;
        return MaterialPageRoute(builder: (_) => ConversationPracticeScreen(args: args));
      case Routes.lessonComplete:
        final args = settings.arguments as LessonFlowArgs;
        return MaterialPageRoute(builder: (_) => LessonCompleteScreen(args: args));
      case Routes.skipTest:
        final args = settings.arguments as SkipTestArgs;
        return MaterialPageRoute(builder: (_) => SkipTestScreen(args: args));
      case Routes.skipTestResult:
        final args = settings.arguments as SkipTestResultArgs;
        return MaterialPageRoute(builder: (_) => SkipTestResultScreen(args: args));
      case Routes.village:
        return MaterialPageRoute(builder: (_) => const VillageScreen());
      case Routes.quests:
        return MaterialPageRoute(builder: (_) => const QuestsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
