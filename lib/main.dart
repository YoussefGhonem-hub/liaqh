import 'package:firebase_core/firebase_core.dart';
import 'package:fitnessapp/firebase_options.dart';
import 'package:fitnessapp/providers/auth_provider.dart';
import 'package:fitnessapp/providers/chat_provider.dart';
import 'package:fitnessapp/providers/dashboard_provider.dart';
import 'package:fitnessapp/providers/inbody_provider.dart';
import 'package:fitnessapp/providers/language_provider.dart';
import 'package:fitnessapp/providers/meal_provider.dart';
import 'package:fitnessapp/providers/membership_provider.dart';
import 'package:fitnessapp/providers/notification_provider.dart';
import 'package:fitnessapp/providers/payment_provider.dart';
import 'package:fitnessapp/providers/payment_methods_provider.dart';
import 'package:fitnessapp/providers/support_ticket_provider.dart';
import 'package:fitnessapp/providers/gym_admin_provider.dart';
import 'package:fitnessapp/providers/platform_provider.dart';
import 'package:fitnessapp/providers/progress_provider.dart';
import 'package:fitnessapp/providers/theme_provider.dart';
import 'package:fitnessapp/providers/trainee_provider.dart';
import 'package:fitnessapp/providers/workout_provider.dart';
import 'package:fitnessapp/providers/daily_workout_log_provider.dart';
import 'package:fitnessapp/providers/coaching_provider.dart';
import 'package:fitnessapp/providers/coach_profile_provider.dart';
import 'package:fitnessapp/data/repositories/auth_repository.dart';
import 'package:fitnessapp/data/repositories/dashboard_repository.dart';
import 'package:fitnessapp/data/repositories/inbody_repository.dart';
import 'package:fitnessapp/data/repositories/meal_repository.dart';
import 'package:fitnessapp/data/repositories/membership_repository.dart';
import 'package:fitnessapp/data/repositories/notification_repository.dart';
import 'package:fitnessapp/data/repositories/payment_repository.dart';
import 'package:fitnessapp/data/repositories/payment_methods_repository.dart';
import 'package:fitnessapp/data/repositories/support_ticket_repository.dart';
import 'package:fitnessapp/data/repositories/gym_admin_repository.dart';
import 'package:fitnessapp/data/repositories/platform_repository.dart';
import 'package:fitnessapp/data/repositories/progress_repository.dart';
import 'package:fitnessapp/data/repositories/trainee_repository.dart';
import 'package:fitnessapp/data/repositories/workout_repository.dart';
import 'package:fitnessapp/data/repositories/daily_workout_log_repository.dart';
import 'package:fitnessapp/data/repositories/coaching_repository.dart';
import 'package:fitnessapp/data/repositories/coach_profile_repository.dart';
import 'package:fitnessapp/data/services/api_service.dart';
import 'package:fitnessapp/data/services/notification_service.dart';
import 'package:fitnessapp/routes.dart';
import 'package:fitnessapp/utils/app_theme.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:fitnessapp/view/welcome/welcome_landing_screen.dart';
import 'package:fitnessapp/view/welcome/language_select_screen.dart';
import 'package:fitnessapp/view/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fitnessapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Never block the first frame on Firebase: on emulators with broken Play
  // Services, initializeApp can hang, leaving a black (native-splash) screen.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 8));
  } catch (e) {
    debugPrint('Firebase init failed or timed out: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    // When the server rejects our token (e.g. password changed → security stamp
    // mismatch), drop the session and send the user back to the login screen.
    ApiService.onUnauthorized = () {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        try {
          ctx.read<AuthProvider>().logout();
        } catch (_) {}
      }
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
          LoginScreen.routeName, (r) => false);
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<ApiService>(create: (_) => apiService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => TraineeProvider(TraineeRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => MembershipProvider(MembershipRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => InBodyProvider(InBodyRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(WorkoutRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DailyWorkoutLogProvider(DailyWorkoutLogRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => CoachingProvider(CoachingRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CoachProfileProvider(CoachProfileRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => MealProvider(MealRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(DashboardRepository(apiService)),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              NotificationProvider(NotificationRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => ProgressProvider(ProgressRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(PaymentRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => PlatformProvider(PlatformRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              PaymentMethodsProvider(PaymentMethodsRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SupportTicketProvider(SupportTicketRepository(apiService)),
        ),
        ChangeNotifierProvider(
          create: (_) => GymAdminProvider(GymAdminRepository(apiService)),
        ),
      ],
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, lang, theme, _) {
          return MaterialApp(
            title: 'Gym Management',
            debugShowCheckedModeBanner: false,
            locale: lang.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => Directionality(
              textDirection: lang.textDirection,
              child: child!,
            ),
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: theme.mode,
            navigatorKey: navigatorKey,
            routes: routes,
            home: const _AuthGate(),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) NotificationService.init(context, navKey: navigatorKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return SplashScreen(
      onCheck: () => auth.checkLoginStatus(),
      onDone: (loggedIn) {
        if (!context.mounted) return;

        // Capture providers BEFORE navigating away.
        final user = auth.currentUser;
        final chat = context.read<ChatProvider>();
        final notif = context.read<NotificationProvider>();
        final langChosen = context.read<LanguageProvider>().hasChosenLanguage;

        // Logged in → dashboard. Otherwise show the language picker on first
        // launch, then the Welcome landing (Login / register).
        final String dest = loggedIn
            ? DashboardScreen.routeName
            : (langChosen
                ? WelcomeLandingScreen.routeName
                : LanguageSelectScreen.routeName);
        Navigator.pushReplacementNamed(context, dest);

        // Background setup (fire-and-forget; failures must not affect the UI).
        if (loggedIn && user != null) {
          try {
            chat.listenConversations(user.userId, auth.isCoach);
          } catch (_) {}
          try {
            NotificationService.saveTokenForUser(user.userId);
          } catch (_) {}
          NotificationService.getToken().then((t) {
            if (t != null) notif.saveFcmToken(t).ignore();
          }).catchError((_) {});
          notif.loadFirst();
        }
      },
    );
  }
}
