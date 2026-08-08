import 'package:flutter/material.dart';
import 'package:cerebrum_app/services/user_session.dart';
import 'package:cerebrum_app/ui/desktop_main.dart';
import 'package:cerebrum_app/ui/screens/onboarding/onboarding_screen.dart';
import 'package:cerebrum_app/ui/screens/onboarding/login_screen.dart';

enum _StartupRoute { onboarding, login, home }

/// Sits ABOVE DesktopUI in the tree. Resolves "where should the user land"
/// once at startup (and again whenever onboarding/login completes) by
/// reading local session state. This is what makes login "persist" --
/// we're not remembering a runtime flag, we're re-checking storage on
/// every cold start.
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  late Future<_StartupRoute> _future;

  @override
  void initState() {
    super.initState();
    _future = _resolveRoute();
  }

  Future<_StartupRoute> _resolveRoute() async {
    final seenOnboarding = await UserSession.hasSeenOnboarding();
    if (!seenOnboarding) return _StartupRoute.onboarding;

    final loggedIn = await UserSession.isLoggedIn();
    if (!loggedIn) return _StartupRoute.login;

    return _StartupRoute.home;
  }

  void _refresh() {
    setState(() {
      _future = _resolveRoute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartupRoute>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        switch (snapshot.data!) {
          case _StartupRoute.onboarding:
            return OnboardingScreen(
              onDone: () async {
                await UserSession.markOnboardingSeen();
                _refresh();
              },
            );
          case _StartupRoute.login:
            return LoginScreen(
              // Fires after login/signup succeeds. UserApi.login() has already
              // persisted the bearer token via UserSession.saveSession(), so by
              // the time this runs isLoggedIn() (token present) returns true.
              onLoggedIn: _refresh,
            );
          case _StartupRoute.home:
            return const DesktopUI();
        }
      },
    );
  }
}
