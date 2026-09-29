import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/routes.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/onboarding_screen.dart';

/// Root widget (served at Routes.onboarding, '/') deciding between onboarding
/// and the signed-in app shell. Firebase Auth restores a persisted session
/// asynchronously, so this waits for AuthProvider.isInitialized before
/// deciding — otherwise an already-signed-in guest/user would flash
/// onboarding on every launch.
///
/// When already signed in, this replaces itself with a proper Routes.home
/// push (rather than rendering HomeShell inline) so screens elsewhere that
/// do `Navigator.popUntil(ModalRoute.withName(Routes.home))` keep working
/// regardless of whether the user arrived via fresh login or auto-redirect.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _navigating = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isInitialized && auth.isSignedIn && !_navigating) {
      _navigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed(Routes.home);
      });
    }

    if (!auth.isInitialized || _navigating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const OnboardingScreen();
  }
}
