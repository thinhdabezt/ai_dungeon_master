import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/sessions/providers/session_provider.dart';
import 'features/sessions/services/session_service.dart';
import 'features/sessions/screens/sessions_list_screen.dart';
import 'features/sessions/screens/new_session_screen.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/chat/screens/chat_screen.dart';
import 'core/storage/cache_service.dart';
import 'features/learning/services/learning_service.dart';
import 'features/learning/providers/learning_provider.dart';
import 'features/learning/screens/grimoire_screen.dart';
import 'features/learning/screens/review_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency Injection
    final storageService = SecureStorageService();
    final cacheService = CacheService();
    final apiClient = ApiClient(storageService);
    final authService = AuthService(apiClient);
    final sessionService = SessionService(apiClient, cacheService);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(sessionService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(sessionService),
        ),
        ChangeNotifierProvider(
          create: (_) => LearningProvider(LearningService(apiClient)),
        ),
      ],
      child: const AppRouter(),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const SessionsListScreen(),
        ),
        GoRoute(
          path: '/sessions/new',
          builder: (context, state) => const NewSessionScreen(),
        ),
        GoRoute(
          path: '/sessions/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final title = state.extra as String?;
            return ChatScreen(sessionId: id, title: title);
          },
        ),
        GoRoute(
          path: '/grimoire',
          builder: (context, state) => const GrimoireScreen(),
        ),
        GoRoute(
          path: '/review',
          builder: (context, state) => const ReviewScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'AI Dungeon Master',
      theme: AppTheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}


