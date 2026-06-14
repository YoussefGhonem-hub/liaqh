import 'package:fitnessapp/data/models/chat_models.dart';
import 'package:fitnessapp/view/activity_tracker/activity_tracker_screen.dart';
import 'package:fitnessapp/view/chat/chat_list_screen.dart';
import 'package:fitnessapp/view/chat/chat_room_screen.dart';
import 'package:fitnessapp/view/dashboard/dashboard_screen.dart';
import 'package:fitnessapp/view/finish_workout/finish_workout_screen.dart';
import 'package:fitnessapp/view/login/login_screen.dart';
import 'package:fitnessapp/view/notification/notification_screen.dart';
import 'package:fitnessapp/view/on_boarding/on_boarding_screen.dart';
import 'package:fitnessapp/view/on_boarding/start_screen.dart';
import 'package:fitnessapp/view/profile/achievements_screen.dart';
import 'package:fitnessapp/view/profile/activity_history_screen.dart';
import 'package:fitnessapp/view/profile/complete_profile_screen.dart';
import 'package:fitnessapp/view/profile/contact_us_screen.dart';
import 'package:fitnessapp/view/profile/personal_data_screen.dart';
import 'package:fitnessapp/view/profile/privacy_policy_screen.dart';
import 'package:fitnessapp/view/profile/settings_screen.dart';
import 'package:fitnessapp/view/profile/change_password_screen.dart';
import 'package:fitnessapp/view/payment/subscription_screen.dart';
import 'package:fitnessapp/view/payment/my_subscription_screen.dart';
import 'package:fitnessapp/view/profile/workout_progress_screen.dart';
import 'package:fitnessapp/view/signup/account_type_screen.dart';
import 'package:fitnessapp/view/signup/gym_signup_screen.dart';
import 'package:fitnessapp/view/signup/individual_coach_signup_screen.dart';
import 'package:fitnessapp/view/signup/signup_screen.dart';
import 'package:fitnessapp/view/platform/platform_overview_screen.dart';
import 'package:fitnessapp/view/platform/gyms_list_screen.dart';
import 'package:fitnessapp/view/platform/platform_revenue_screen.dart';
import 'package:fitnessapp/view/platform/platform_users_screen.dart';
import 'package:fitnessapp/view/platform/platform_coaches_screen.dart';
import 'package:fitnessapp/view/platform/send_announcement_screen.dart';
import 'package:fitnessapp/view/trainees/trainees_screen.dart';
import 'package:fitnessapp/view/trainees/add_trainee_screen.dart';
import 'package:fitnessapp/view/welcome/welcome_screen.dart';
import 'package:fitnessapp/view/welcome/welcome_landing_screen.dart';
import 'package:fitnessapp/view/welcome/language_select_screen.dart';
import 'package:fitnessapp/view/workout_schedule_view/workout_schedule_view.dart';
import 'package:fitnessapp/view/your_goal/your_goal_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  OnBoardingScreen.routeName: (_) => const OnBoardingScreen(),
  LoginScreen.routeName: (_) => const LoginScreen(),
  StartScreen.routeName: (_) => const StartScreen(),
  SignupScreen.routeName: (_) => const SignupScreen(),
  AccountTypeScreen.routeName: (_) => const AccountTypeScreen(),
  IndividualCoachSignupScreen.routeName: (_) => const IndividualCoachSignupScreen(),
  GymSignupScreen.routeName: (_) => const GymSignupScreen(),
  CompleteProfileScreen.routeName: (_) => const CompleteProfileScreen(),
  YourGoalScreen.routeName: (_) => const YourGoalScreen(),
  WelcomeScreen.routeName: (_) => const WelcomeScreen(),
  WelcomeLandingScreen.routeName: (_) => const WelcomeLandingScreen(),
  LanguageSelectScreen.routeName: (_) => const LanguageSelectScreen(),
  DashboardScreen.routeName: (_) => const DashboardScreen(),
  FinishWorkoutScreen.routeName: (_) => const FinishWorkoutScreen(),
  NotificationScreen.routeName: (_) => const NotificationScreen(),
  ActivityTrackerScreen.routeName: (_) => const ActivityTrackerScreen(),
  WorkoutScheduleView.routeName: (_) => const WorkoutScheduleView(),
  TraineesScreen.routeName: (_) => const TraineesScreen(),
  AddTraineeScreen.routeName: (_) => const AddTraineeScreen(),
  ChatListScreen.routeName: (_) => const ChatListScreen(),
  ChatRoomScreen.routeName: (context) {
    final conv =
        ModalRoute.of(context)!.settings.arguments as ChatConversation;
    return ChatRoomScreen(conversation: conv);
  },

  // Platform Owner screens
  PlatformOverviewScreen.routeName: (_) => const PlatformOverviewScreen(),
  GymsListScreen.routeName: (_) => const GymsListScreen(),
  PlatformRevenueScreen.routeName: (_) => const PlatformRevenueScreen(),
  PlatformUsersScreen.routeName: (_) => const PlatformUsersScreen(),
  PlatformCoachesScreen.routeName: (_) => const PlatformCoachesScreen(),
  SendAnnouncementScreen.routeName: (_) => const SendAnnouncementScreen(),

  // Profile sub-screens
  PersonalDataScreen.routeName: (_) => const PersonalDataScreen(),
  AchievementsScreen.routeName: (_) => const AchievementsScreen(),
  ActivityHistoryScreen.routeName: (_) => const ActivityHistoryScreen(),
  WorkoutProgressScreen.routeName: (_) => const WorkoutProgressScreen(),
  ContactUsScreen.routeName: (_) => const ContactUsScreen(),
  PrivacyPolicyScreen.routeName: (_) => const PrivacyPolicyScreen(),
  SettingsScreen.routeName: (_) => const SettingsScreen(),
  ChangePasswordScreen.routeName: (_) => const ChangePasswordScreen(),
  SubscriptionScreen.routeName: (_) => const SubscriptionScreen(),
  MySubscriptionScreen.routeName: (_) => const MySubscriptionScreen(),
};
