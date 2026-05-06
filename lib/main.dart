import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'components/app_card.dart';
import 'components/buttons.dart';
import 'components/metric_card.dart';
import 'screens/diary_screen.dart';
import 'screens/edit_training_screen.dart';
import 'screens/home_screen.dart';
import 'screens/new_training_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/timers_screen.dart';
import 'screens/workout_detail_screen.dart';

void main() {
  runApp(const ProviderScope(child: ClimbingDiaryApp()));
}

class ClimbingDiaryApp extends StatelessWidget {
  const ClimbingDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Climbing Diary',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: _router,
    );
  }
}

ThemeData _buildTheme() {
  const background = Color(0xFF1A1D20);
  const surface = Color(0xFF252A2F);
  const onSurface = Color(0xFFF6F1E8);
  const accent = Color(0xFFD4AF37);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
  ).copyWith(
    surface: surface,
    onSurface: onSurface,
    primary: accent,
    secondary: accent,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    textTheme: Typography.whiteMountainView.apply(
      bodyColor: onSurface,
      displayColor: onSurface,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: accent,
      unselectedItemColor: onSurface.withValues(alpha: 0.65),
      backgroundColor: const Color(0xFF20252A),
      type: BottomNavigationBarType.fixed,
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/new-training', pageBuilder: (context, state) => const NoTransitionPage(child: NewTrainingScreen())),
    GoRoute(
      path: '/workout/:id',
      pageBuilder: (context, state) => NoTransitionPage(
        child: WorkoutDetailScreen(sessionId: state.pathParameters['id'] ?? ''),
      ),
    ),
    GoRoute(
      path: '/workout/:id/edit',
      pageBuilder: (context, state) => NoTransitionPage(
        child: EditTrainingScreen(sessionId: state.pathParameters['id'] ?? ''),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen())),
        GoRoute(path: '/diary', pageBuilder: (context, state) => const NoTransitionPage(child: DiaryScreen())),
        GoRoute(path: '/timers', pageBuilder: (context, state) => const NoTransitionPage(child: TimersScreen())),
        GoRoute(path: '/progress', pageBuilder: (context, state) => const NoTransitionPage(child: ProgressScreen())),
        GoRoute(path: '/profile', pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen())),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = ['/home', '/diary', '/timers', '/progress', '/profile'];

  int _indexFromLocation(String location) {
    return _tabs.indexWhere((tab) => location.startsWith(tab)).clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 18,
        toolbarHeight: 58,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: const Color(0xE61A1D20),
        title: const Text('Дневник скалолаза'),
        titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF6F1E8),
          letterSpacing: 0.15,
        ),
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index != currentIndex) {
            unawaited(HapticFeedback.selectionClick());
          }
          context.go(_tabs[index]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Дневник'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_rounded), label: 'Таймеры'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart_rounded), label: 'Прогресс'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Профиль'),
        ],
      ),
    );
  }
}

class PlaceholderContent extends StatelessWidget {
  const PlaceholderContent({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(description),
              const SizedBox(height: 16),
              const MetricCard(label: 'Сессий за месяц', value: '12'),
              const SizedBox(height: 16),
              const PrimaryButton(label: 'Добавить запись'),
              const SizedBox(height: 8),
              const SecondaryButton(label: 'Открыть детали'),
            ],
          ),
        ),
      ],
    );
  }
}
