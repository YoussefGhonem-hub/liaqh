import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'Gym Management'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @heyThere.
  ///
  /// In en, this message translates to:
  /// **'Hey there,'**
  String get heyThere;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone'**
  String get emailOrPhone;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @phoneRequiredField.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneRequiredField;

  /// No description provided for @phoneRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequiredError;

  /// No description provided for @phoneInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneInvalidError;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet? '**
  String get noAccount;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccount;

  /// No description provided for @termsText.
  ///
  /// In en, this message translates to:
  /// **'By continuing you accept our Privacy Policy and Term of Use'**
  String get termsText;

  /// No description provided for @gymId.
  ///
  /// In en, this message translates to:
  /// **'Gym ID (provided by gym owner)'**
  String get gymId;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @deleteProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete program?'**
  String get deleteProgramTitle;

  /// No description provided for @deleteProgramConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes \"{name}\" and all its days and exercises.'**
  String deleteProgramConfirm(String name);

  /// No description provided for @programDeleted.
  ///
  /// In en, this message translates to:
  /// **'Program deleted.'**
  String get programDeleted;

  /// No description provided for @dailyLog.
  ///
  /// In en, this message translates to:
  /// **'Daily Log'**
  String get dailyLog;

  /// No description provided for @thisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeekLabel;

  /// No description provided for @didYouWorkoutToday.
  ///
  /// In en, this message translates to:
  /// **'Did you work out today?'**
  String get didYouWorkoutToday;

  /// No description provided for @workedOut.
  ///
  /// In en, this message translates to:
  /// **'Worked out'**
  String get workedOut;

  /// No description provided for @restDay.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get restDay;

  /// No description provided for @loggedWorkedOut.
  ///
  /// In en, this message translates to:
  /// **'Done ✅'**
  String get loggedWorkedOut;

  /// No description provided for @loggedRest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get loggedRest;

  /// No description provided for @notLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'Not logged'**
  String get notLoggedYet;

  /// No description provided for @logHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get logHistory;

  /// No description provided for @noLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No check-ins yet.'**
  String get noLogsYet;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @activeTraineesLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeTraineesLabel;

  /// No description provided for @retentionLabel.
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get retentionLabel;

  /// No description provided for @newThisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'New this month'**
  String get newThisMonthLabel;

  /// No description provided for @revenueThisMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Revenue (month)'**
  String get revenueThisMonthLabel;

  /// No description provided for @workoutsThisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Workouts (week)'**
  String get workoutsThisWeekLabel;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get needsAttention;

  /// No description provided for @needsAttentionSub.
  ///
  /// In en, this message translates to:
  /// **'Trainees who may need a nudge'**
  String get needsAttentionSub;

  /// No description provided for @everyoneOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Everyone\'s on track 🎉'**
  String get everyoneOnTrack;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @byStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get byStreak;

  /// No description provided for @byMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get byMonth;

  /// No description provided for @broadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get broadcast;

  /// No description provided for @broadcastSub.
  ///
  /// In en, this message translates to:
  /// **'Message all your trainees at once'**
  String get broadcastSub;

  /// No description provided for @broadcastTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get broadcastTitleHint;

  /// No description provided for @broadcastBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message…'**
  String get broadcastBodyHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @broadcastSent.
  ///
  /// In en, this message translates to:
  /// **'Sent to {count} trainee(s).'**
  String broadcastSent(int count);

  /// No description provided for @flagNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No plan yet'**
  String get flagNoPlan;

  /// No description provided for @flagInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get flagInactive;

  /// No description provided for @flagInactiveDays.
  ///
  /// In en, this message translates to:
  /// **'Inactive {days}d'**
  String flagInactiveDays(int days);

  /// No description provided for @flagRejectedMeal.
  ///
  /// In en, this message translates to:
  /// **'Rejected a meal'**
  String get flagRejectedMeal;

  /// No description provided for @flagExpiring.
  ///
  /// In en, this message translates to:
  /// **'Subscription expiring'**
  String get flagExpiring;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get dayStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @totalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total Workouts'**
  String get totalWorkouts;

  /// No description provided for @weeklyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal'**
  String get weeklyGoalLabel;

  /// No description provided for @setWeeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Set weekly goal'**
  String get setWeeklyGoal;

  /// No description provided for @daysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{n} days / week'**
  String daysPerWeek(int n);

  /// No description provided for @streakMilestone.
  ///
  /// In en, this message translates to:
  /// **'🔥 {days}-day streak!'**
  String streakMilestone(int days);

  /// No description provided for @weeklyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal reached! 🎉'**
  String get weeklyGoalReached;

  /// No description provided for @badge7.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get badge7;

  /// No description provided for @badge30.
  ///
  /// In en, this message translates to:
  /// **'30-day streak'**
  String get badge30;

  /// No description provided for @badge100.
  ///
  /// In en, this message translates to:
  /// **'100-day streak'**
  String get badge100;

  /// No description provided for @badgeTotal10.
  ///
  /// In en, this message translates to:
  /// **'10 workouts'**
  String get badgeTotal10;

  /// No description provided for @badgeTotal50.
  ///
  /// In en, this message translates to:
  /// **'50 workouts'**
  String get badgeTotal50;

  /// No description provided for @badgeTotal100.
  ///
  /// In en, this message translates to:
  /// **'100 workouts'**
  String get badgeTotal100;

  /// No description provided for @workoutReminder.
  ///
  /// In en, this message translates to:
  /// **'Workout reminder'**
  String get workoutReminder;

  /// No description provided for @workoutReminderHint.
  ///
  /// In en, this message translates to:
  /// **'Get a daily notification to head to the gym'**
  String get workoutReminderHint;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// No description provided for @setTime.
  ///
  /// In en, this message translates to:
  /// **'Set time'**
  String get setTime;

  /// No description provided for @reminderSetFor.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be reminded daily at {time}'**
  String reminderSetFor(String time);

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing…'**
  String get typing;

  /// No description provided for @restTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest timer'**
  String get restTimer;

  /// No description provided for @customSeconds.
  ///
  /// In en, this message translates to:
  /// **'Custom seconds'**
  String get customSeconds;

  /// No description provided for @customLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customLabel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @chatYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatYou;

  /// No description provided for @editMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editMessage;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get deleteMessage;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'This message will be removed for everyone.'**
  String get deleteMessageConfirm;

  /// No description provided for @edited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get edited;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @myTrainees.
  ///
  /// In en, this message translates to:
  /// **'My Trainees'**
  String get myTrainees;

  /// No description provided for @addTrainee.
  ///
  /// In en, this message translates to:
  /// **'Add Trainee'**
  String get addTrainee;

  /// No description provided for @noTraineesYet.
  ///
  /// In en, this message translates to:
  /// **'No trainees yet'**
  String get noTraineesYet;

  /// No description provided for @noTraineesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first trainee'**
  String get noTraineesHint;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @bulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get bulk;

  /// No description provided for @maintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get maintain;

  /// No description provided for @recomp.
  ///
  /// In en, this message translates to:
  /// **'Recomp'**
  String get recomp;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Current Weight (kg)'**
  String get weightKg;

  /// No description provided for @tempPassword.
  ///
  /// In en, this message translates to:
  /// **'Temporary Password'**
  String get tempPassword;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @trainees.
  ///
  /// In en, this message translates to:
  /// **'Trainees'**
  String get trainees;

  /// No description provided for @traineeAdded.
  ///
  /// In en, this message translates to:
  /// **'Trainee added successfully'**
  String get traineeAdded;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @inBody.
  ///
  /// In en, this message translates to:
  /// **'InBody'**
  String get inBody;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @onTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get onTrack;

  /// No description provided for @atRisk.
  ///
  /// In en, this message translates to:
  /// **'At Risk'**
  String get atRisk;

  /// No description provided for @offTrack.
  ///
  /// In en, this message translates to:
  /// **'Off Track'**
  String get offTrack;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials or data.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server. Check your network.'**
  String get errorConnection;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue.'**
  String get errorAcceptTerms;

  /// No description provided for @errorRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get errorRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get errorInvalidEmail;

  /// No description provided for @errorMinPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errorMinPassword;

  /// No description provided for @errorInvalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight.'**
  String get errorInvalidWeight;

  /// No description provided for @errorInvalidMuscle.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid muscle mass.'**
  String get errorInvalidMuscle;

  /// No description provided for @errorBodyFatRange.
  ///
  /// In en, this message translates to:
  /// **'Body fat % must be 0–100.'**
  String get errorBodyFatRange;

  /// No description provided for @inBodyHistory.
  ///
  /// In en, this message translates to:
  /// **'InBody History'**
  String get inBodyHistory;

  /// No description provided for @addInBody.
  ///
  /// In en, this message translates to:
  /// **'Add InBody Measurement'**
  String get addInBody;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurement;

  /// No description provided for @bodyScore.
  ///
  /// In en, this message translates to:
  /// **'Body Score'**
  String get bodyScore;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @muscleMass.
  ///
  /// In en, this message translates to:
  /// **'Muscle Mass'**
  String get muscleMass;

  /// No description provided for @bodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body Fat %'**
  String get bodyFat;

  /// No description provided for @bodyWater.
  ///
  /// In en, this message translates to:
  /// **'Body Water %'**
  String get bodyWater;

  /// No description provided for @visceralFat.
  ///
  /// In en, this message translates to:
  /// **'Visceral Fat Level'**
  String get visceralFat;

  /// No description provided for @bmr.
  ///
  /// In en, this message translates to:
  /// **'BMR (kcal)'**
  String get bmr;

  /// No description provided for @coachNotes.
  ///
  /// In en, this message translates to:
  /// **'Coach Notes (optional)'**
  String get coachNotes;

  /// No description provided for @latestMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Latest Measurement'**
  String get latestMeasurement;

  /// No description provided for @allMeasurements.
  ///
  /// In en, this message translates to:
  /// **'All Measurements'**
  String get allMeasurements;

  /// No description provided for @noMeasurementsYet.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurementsYet;

  /// No description provided for @noMeasurementsHint.
  ///
  /// In en, this message translates to:
  /// **'Add the first InBody measurement'**
  String get noMeasurementsHint;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @scans.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get scans;

  /// No description provided for @addScans.
  ///
  /// In en, this message translates to:
  /// **'Add Attachments'**
  String get addScans;

  /// No description provided for @noScansAdded.
  ///
  /// In en, this message translates to:
  /// **'No attachments added yet'**
  String get noScansAdded;

  /// No description provided for @scansHint.
  ///
  /// In en, this message translates to:
  /// **'Attach images, PDF or documents of the InBody result'**
  String get scansHint;

  /// No description provided for @saveMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save Measurement'**
  String get saveMeasurement;

  /// No description provided for @fillForm.
  ///
  /// In en, this message translates to:
  /// **'Fill Form'**
  String get fillForm;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @scanCount.
  ///
  /// In en, this message translates to:
  /// **'{count} attachment(s)'**
  String scanCount(int count);

  /// No description provided for @workoutPrograms.
  ///
  /// In en, this message translates to:
  /// **'Workout Programs'**
  String get workoutPrograms;

  /// No description provided for @createProgram.
  ///
  /// In en, this message translates to:
  /// **'Create Program'**
  String get createProgram;

  /// No description provided for @newProgram.
  ///
  /// In en, this message translates to:
  /// **'New Program — {name}'**
  String newProgram(String name);

  /// No description provided for @programName.
  ///
  /// In en, this message translates to:
  /// **'Program Name'**
  String get programName;

  /// No description provided for @programNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Cut Phase Week 1\"'**
  String get programNameHint;

  /// No description provided for @programNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Program name is required.'**
  String get programNameRequired;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @quarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get quarter;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @createAndAddDays.
  ///
  /// In en, this message translates to:
  /// **'Create & Add Days →'**
  String get createAndAddDays;

  /// No description provided for @dayNumber.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayNumber(int number);

  /// No description provided for @dayName.
  ///
  /// In en, this message translates to:
  /// **'Day Name'**
  String get dayName;

  /// No description provided for @dayNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Push Day, Chest & Triceps'**
  String get dayNameHint;

  /// No description provided for @dayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Day name is required.'**
  String get dayNameRequired;

  /// No description provided for @muscleFocus.
  ///
  /// In en, this message translates to:
  /// **'Muscle Focus'**
  String get muscleFocus;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @noExercisesYet.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet. Tap \"Add\" to pick from library.'**
  String get noExercisesYet;

  /// No description provided for @saveDayAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Save Day & Add Another'**
  String get saveDayAddAnother;

  /// No description provided for @finishDays.
  ///
  /// In en, this message translates to:
  /// **'Finish — {count} day(s) saved'**
  String finishDays(int count);

  /// No description provided for @saveAtLeastOneDay.
  ///
  /// In en, this message translates to:
  /// **'Save at least one day before finishing.'**
  String get saveAtLeastOneDay;

  /// No description provided for @addAtLeastOneExercise.
  ///
  /// In en, this message translates to:
  /// **'Add at least one exercise.'**
  String get addAtLeastOneExercise;

  /// No description provided for @programCreated.
  ///
  /// In en, this message translates to:
  /// **'Program \"{name}\" created with {count} day(s)!'**
  String programCreated(String name, int count);

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @restSeconds.
  ///
  /// In en, this message translates to:
  /// **'Rest (s)'**
  String get restSeconds;

  /// No description provided for @weightKgOpt.
  ///
  /// In en, this message translates to:
  /// **'Weight kg (opt)'**
  String get weightKgOpt;

  /// No description provided for @daysSaved.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s) saved: {days}'**
  String daysSaved(int count, String days);

  /// No description provided for @exerciseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Exercise Library'**
  String get exerciseLibrary;

  /// No description provided for @selectExercise.
  ///
  /// In en, this message translates to:
  /// **'Select Exercise'**
  String get selectExercise;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises…'**
  String get searchExercises;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesFound;

  /// No description provided for @addCustom.
  ///
  /// In en, this message translates to:
  /// **'Add Custom'**
  String get addCustom;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @addCustomExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Exercise'**
  String get addCustomExercise;

  /// No description provided for @exerciseNameEn.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name (English) *'**
  String get exerciseNameEn;

  /// No description provided for @exerciseNameAr.
  ///
  /// In en, this message translates to:
  /// **'اسم التمرين (عربي)'**
  String get exerciseNameAr;

  /// No description provided for @exerciseNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Exercise name (English) is required.'**
  String get exerciseNameRequired;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @equipmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Barbell, Dumbbell'**
  String get equipmentHint;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description / instructions (optional)'**
  String get descriptionOptional;

  /// No description provided for @videoUrl.
  ///
  /// In en, this message translates to:
  /// **'Video URL (optional)'**
  String get videoUrl;

  /// No description provided for @exerciseAdded.
  ///
  /// In en, this message translates to:
  /// **'Exercise added'**
  String get exerciseAdded;

  /// No description provided for @saveExercise.
  ///
  /// In en, this message translates to:
  /// **'Save Exercise'**
  String get saveExercise;

  /// No description provided for @addExercisePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add exercise photo (optional)'**
  String get addExercisePhoto;

  /// No description provided for @workoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Workout History'**
  String get workoutHistory;

  /// No description provided for @noWorkoutsLogged.
  ///
  /// In en, this message translates to:
  /// **'No workouts logged yet'**
  String get noWorkoutsLogged;

  /// No description provided for @effort.
  ///
  /// In en, this message translates to:
  /// **'Effort {effort}/10'**
  String effort(int effort);

  /// No description provided for @prescribedWeights.
  ///
  /// In en, this message translates to:
  /// **'Prescribed weights'**
  String get prescribedWeights;

  /// No description provided for @modifiedWeights.
  ///
  /// In en, this message translates to:
  /// **'Modified weights'**
  String get modifiedWeights;

  /// No description provided for @noSetDetails.
  ///
  /// In en, this message translates to:
  /// **'No set details recorded.'**
  String get noSetDetails;

  /// No description provided for @usedPrescribedWeights.
  ///
  /// In en, this message translates to:
  /// **'Used prescribed weights?'**
  String get usedPrescribedWeights;

  /// No description provided for @overallEffort.
  ///
  /// In en, this message translates to:
  /// **'Overall Effort'**
  String get overallEffort;

  /// No description provided for @sessionNotes.
  ///
  /// In en, this message translates to:
  /// **'Session notes (optional)'**
  String get sessionNotes;

  /// No description provided for @logAtLeastOneSet.
  ///
  /// In en, this message translates to:
  /// **'Log at least one set before saving.'**
  String get logAtLeastOneSet;

  /// No description provided for @confirmWorkoutCompleted.
  ///
  /// In en, this message translates to:
  /// **'Confirm Workout Completed'**
  String get confirmWorkoutCompleted;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest: {seconds}s'**
  String rest(int seconds);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @mealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal Plans'**
  String get mealPlans;

  /// No description provided for @createMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Meal Plan'**
  String get createMealPlan;

  /// No description provided for @newMealPlan.
  ///
  /// In en, this message translates to:
  /// **'New Meal Plan — {name}'**
  String newMealPlan(String name);

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planName;

  /// No description provided for @planNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. \"Cut Phase Week 1\"'**
  String get planNameHint;

  /// No description provided for @planNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Plan name is required.'**
  String get planNameRequired;

  /// No description provided for @weekStartDate.
  ///
  /// In en, this message translates to:
  /// **'Week Start Date'**
  String get weekStartDate;

  /// No description provided for @dailyMacroTargets.
  ///
  /// In en, this message translates to:
  /// **'Daily Macro Targets'**
  String get dailyMacroTargets;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @carbsG.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsG;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @fatG.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatG;

  /// No description provided for @suggestedTargets.
  ///
  /// In en, this message translates to:
  /// **'Suggested Targets (Reference)'**
  String get suggestedTargets;

  /// No description provided for @createPlanAndBuild.
  ///
  /// In en, this message translates to:
  /// **'Create Plan & Build →'**
  String get createPlanAndBuild;

  /// No description provided for @viewPlan.
  ///
  /// In en, this message translates to:
  /// **'View Plan'**
  String get viewPlan;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @noMealPlanLoaded.
  ///
  /// In en, this message translates to:
  /// **'No plan loaded'**
  String get noMealPlanLoaded;

  /// No description provided for @addMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// No description provided for @mealRemoved.
  ///
  /// In en, this message translates to:
  /// **'Meal removed'**
  String get mealRemoved;

  /// No description provided for @addMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Meal — {name}'**
  String addMealTitle(String name);

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @midMorning.
  ///
  /// In en, this message translates to:
  /// **'Mid Morning'**
  String get midMorning;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @preWorkout.
  ///
  /// In en, this message translates to:
  /// **'Pre Workout'**
  String get preWorkout;

  /// No description provided for @postWorkout.
  ///
  /// In en, this message translates to:
  /// **'Post Workout'**
  String get postWorkout;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @foodItems.
  ///
  /// In en, this message translates to:
  /// **'Food Items'**
  String get foodItems;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// No description provided for @noFoodsAdded.
  ///
  /// In en, this message translates to:
  /// **'No foods added yet. Tap \"Add Food\" to begin.'**
  String get noFoodsAdded;

  /// No description provided for @addAtLeastOneFood.
  ///
  /// In en, this message translates to:
  /// **'Add at least one food item.'**
  String get addAtLeastOneFood;

  /// No description provided for @saveMeal.
  ///
  /// In en, this message translates to:
  /// **'Save Meal'**
  String get saveMeal;

  /// No description provided for @foodLibrary.
  ///
  /// In en, this message translates to:
  /// **'Food Library'**
  String get foodLibrary;

  /// No description provided for @selectFood.
  ///
  /// In en, this message translates to:
  /// **'Select Food'**
  String get selectFood;

  /// No description provided for @searchFoods.
  ///
  /// In en, this message translates to:
  /// **'Search foods…'**
  String get searchFoods;

  /// No description provided for @noFoodsFound.
  ///
  /// In en, this message translates to:
  /// **'No foods found'**
  String get noFoodsFound;

  /// No description provided for @howManyGrams.
  ///
  /// In en, this message translates to:
  /// **'How many grams?'**
  String get howManyGrams;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get grams;

  /// No description provided for @noMealsToday.
  ///
  /// In en, this message translates to:
  /// **'No meals for this day'**
  String get noMealsToday;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @logMeal.
  ///
  /// In en, this message translates to:
  /// **'Log: {meal}'**
  String logMeal(String meal);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed ✅'**
  String get completed;

  /// No description provided for @completedHint.
  ///
  /// In en, this message translates to:
  /// **'I ate this meal fully'**
  String get completedHint;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped ❌'**
  String get skipped;

  /// No description provided for @skippedHint.
  ///
  /// In en, this message translates to:
  /// **'I did not eat this meal'**
  String get skippedHint;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partial 🔄'**
  String get partial;

  /// No description provided for @partialHint.
  ///
  /// In en, this message translates to:
  /// **'I ate part of this meal'**
  String get partialHint;

  /// No description provided for @mealLoggedAs.
  ///
  /// In en, this message translates to:
  /// **'Meal logged as {status}'**
  String mealLoggedAs(String status);

  /// No description provided for @failedToLog.
  ///
  /// In en, this message translates to:
  /// **'Failed to log meal'**
  String get failedToLog;

  /// No description provided for @noShoppingItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noShoppingItems;

  /// No description provided for @shoppingListHint.
  ///
  /// In en, this message translates to:
  /// **'Build your meal plan to generate a shopping list.'**
  String get shoppingListHint;

  /// No description provided for @totalEstimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Estimated Price'**
  String get totalEstimatedPrice;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share coming soon'**
  String get shareComingSoon;

  /// No description provided for @subscribeToPlan.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to Plan'**
  String get subscribeToPlan;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get selectPlan;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available for this gym.'**
  String get noPlansAvailable;

  /// No description provided for @autoRenew.
  ///
  /// In en, this message translates to:
  /// **'Auto-renew'**
  String get autoRenew;

  /// No description provided for @selectPlanFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a plan.'**
  String get selectPlanFirst;

  /// No description provided for @confirmSubscription.
  ///
  /// In en, this message translates to:
  /// **'Confirm Subscription'**
  String get confirmSubscription;

  /// No description provided for @planDuration.
  ///
  /// In en, this message translates to:
  /// **'{days} days · {cycle}'**
  String planDuration(int days, String cycle);

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @chooseAccountType.
  ///
  /// In en, this message translates to:
  /// **'Choose your account type to continue.'**
  String get chooseAccountType;

  /// No description provided for @individualCoach.
  ///
  /// In en, this message translates to:
  /// **'Individual Coach'**
  String get individualCoach;

  /// No description provided for @individualCoachDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your own trainees directly.\nNo gym setup needed.'**
  String get individualCoachDesc;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @gymDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a gym, add multiple coaches,\neach with their own trainees.'**
  String get gymDesc;

  /// No description provided for @gymDetails.
  ///
  /// In en, this message translates to:
  /// **'Gym Details'**
  String get gymDetails;

  /// No description provided for @adminAccount.
  ///
  /// In en, this message translates to:
  /// **'Admin Account'**
  String get adminAccount;

  /// No description provided for @gymNameHint.
  ///
  /// In en, this message translates to:
  /// **'Gym name e.g. FitZone Cairo'**
  String get gymNameHint;

  /// No description provided for @gymNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Gym name is required.'**
  String get gymNameRequired;

  /// No description provided for @adminAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'This will be your login to manage the gym.'**
  String get adminAccountDesc;

  /// No description provided for @createGym.
  ///
  /// In en, this message translates to:
  /// **'Create Gym'**
  String get createGym;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @personalGymNote.
  ///
  /// In en, this message translates to:
  /// **'A personal gym will be set up automatically.'**
  String get personalGymNote;

  /// No description provided for @gymLogo.
  ///
  /// In en, this message translates to:
  /// **'Gym Logo'**
  String get gymLogo;

  /// No description provided for @gymLogoDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional — shown on trainee dashboard'**
  String get gymLogoDesc;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @onBoardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track Your Goal'**
  String get onBoardingTitle1;

  /// No description provided for @onBoardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry if you have trouble determining your goals, We can help you determine your goals and track your goals'**
  String get onBoardingDesc1;

  /// No description provided for @onBoardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Get Burn'**
  String get onBoardingTitle2;

  /// No description provided for @onBoardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Let\'s keep burning, to achieve your goals, it hurts only temporarily, if you give up now you will be in pain forever'**
  String get onBoardingDesc2;

  /// No description provided for @onBoardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Eat Well'**
  String get onBoardingTitle3;

  /// No description provided for @onBoardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start a healthy lifestyle with us, we can determine your diet every day. healthy eating is fun'**
  String get onBoardingDesc3;

  /// No description provided for @onBoardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Improve Sleep Quality'**
  String get onBoardingTitle4;

  /// No description provided for @onBoardingDesc4.
  ///
  /// In en, this message translates to:
  /// **'Improve the quality of your sleep with us, good quality sleep can bring a good mood in the morning'**
  String get onBoardingDesc4;

  /// No description provided for @welcomeCoach.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back, Coach'**
  String get welcomeCoach;

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI (Body Mass Index)'**
  String get bmi;

  /// No description provided for @normalWeight.
  ///
  /// In en, this message translates to:
  /// **'You have a normal weight'**
  String get normalWeight;

  /// No description provided for @todayTarget.
  ///
  /// In en, this message translates to:
  /// **'Today Target'**
  String get todayTarget;

  /// No description provided for @activityStatus.
  ///
  /// In en, this message translates to:
  /// **'Activity Status'**
  String get activityStatus;

  /// No description provided for @workoutProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout Progress'**
  String get workoutProgress;

  /// No description provided for @latestWorkout.
  ///
  /// In en, this message translates to:
  /// **'Latest Workout'**
  String get latestWorkout;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @personalData.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalData;

  /// No description provided for @achievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievement;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @workoutProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Progress'**
  String get workoutProgressTitle;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @popupNotification.
  ///
  /// In en, this message translates to:
  /// **'Pop-up Notification'**
  String get popupNotification;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @dietaryRestrictions.
  ///
  /// In en, this message translates to:
  /// **'Dietary Restrictions'**
  String get dietaryRestrictions;

  /// No description provided for @medicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Medical Notes'**
  String get medicalNotes;

  /// No description provided for @personalDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get personalDataTitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @gymIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Gym ID'**
  String get gymIdLabel;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievementsTitle;

  /// No description provided for @noAchievementsYet.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get noAchievementsYet;

  /// No description provided for @noAchievementsHint.
  ///
  /// In en, this message translates to:
  /// **'Keep training to earn badges!'**
  String get noAchievementsHint;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @activityHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistoryTitle;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet'**
  String get noActivityYet;

  /// No description provided for @noActivityHint.
  ///
  /// In en, this message translates to:
  /// **'Your workout and meal logs will appear here.'**
  String get noActivityHint;

  /// No description provided for @workoutsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workouts Completed'**
  String get workoutsCompleted;

  /// No description provided for @mealsLogged.
  ///
  /// In en, this message translates to:
  /// **'Meals Logged'**
  String get mealsLogged;

  /// No description provided for @inBodyScans.
  ///
  /// In en, this message translates to:
  /// **'InBody Scans'**
  String get inBodyScans;

  /// No description provided for @workoutProgressTitle2.
  ///
  /// In en, this message translates to:
  /// **'Workout Progress'**
  String get workoutProgressTitle2;

  /// No description provided for @noProgressYet.
  ///
  /// In en, this message translates to:
  /// **'No workout data yet'**
  String get noProgressYet;

  /// No description provided for @noProgressHint.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to see your progress charts.'**
  String get noProgressHint;

  /// No description provided for @avgEffort.
  ///
  /// In en, this message translates to:
  /// **'Avg. Effort'**
  String get avgEffort;

  /// No description provided for @contactUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUsTitle;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get contactPhone;

  /// No description provided for @contactWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get contactWhatsApp;

  /// No description provided for @contactHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get contactHours;

  /// No description provided for @contactHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Sun–Thu, 9 AM – 6 PM'**
  String get contactHoursValue;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @noMembershipsYet.
  ///
  /// In en, this message translates to:
  /// **'No memberships yet.'**
  String get noMembershipsYet;

  /// No description provided for @perPlan.
  ///
  /// In en, this message translates to:
  /// **'/ plan'**
  String get perPlan;

  /// No description provided for @expiringWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠ Expiring within 7 days'**
  String get expiringWarning;

  /// No description provided for @renew.
  ///
  /// In en, this message translates to:
  /// **'Renew'**
  String get renew;

  /// No description provided for @freeze.
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get freeze;

  /// No description provided for @unfreeze.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze'**
  String get unfreeze;

  /// No description provided for @noInBodyYet.
  ///
  /// In en, this message translates to:
  /// **'No InBody measurements yet'**
  String get noInBodyYet;

  /// No description provided for @latestBodyScore.
  ///
  /// In en, this message translates to:
  /// **'Latest Body Score'**
  String get latestBodyScore;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @recentMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Recent Measurements'**
  String get recentMeasurements;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @noActiveProgram.
  ///
  /// In en, this message translates to:
  /// **'No active program'**
  String get noActiveProgram;

  /// No description provided for @createWorkoutHint.
  ///
  /// In en, this message translates to:
  /// **'Create a workout program for this trainee'**
  String get createWorkoutHint;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysLabel;

  /// No description provided for @logLabel.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get logLabel;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @newProgramLabel.
  ///
  /// In en, this message translates to:
  /// **'New Program'**
  String get newProgramLabel;

  /// No description provided for @createPlan.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlan;

  /// No description provided for @newPlan.
  ///
  /// In en, this message translates to:
  /// **'New Plan'**
  String get newPlan;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @noActiveMealPlan.
  ///
  /// In en, this message translates to:
  /// **'No active meal plan'**
  String get noActiveMealPlan;

  /// No description provided for @createNutritionHint.
  ///
  /// In en, this message translates to:
  /// **'Create a nutrition plan for this trainee'**
  String get createNutritionHint;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @traineeView.
  ///
  /// In en, this message translates to:
  /// **'Trainee View'**
  String get traineeView;

  /// No description provided for @noMeals.
  ///
  /// In en, this message translates to:
  /// **'No meals'**
  String get noMeals;

  /// No description provided for @chatMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatMessages;

  /// No description provided for @chatNoConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatNoConversations;

  /// No description provided for @chatNoConversationsHint.
  ///
  /// In en, this message translates to:
  /// **'Messages with your coach or trainees will appear here.'**
  String get chatNoConversationsHint;

  /// No description provided for @chatNoMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chatNoMessages;

  /// No description provided for @chatSayHi.
  ///
  /// In en, this message translates to:
  /// **'Say hi! 👋'**
  String get chatSayHi;

  /// No description provided for @chatTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatTypeMessage;

  /// No description provided for @chatTrainee.
  ///
  /// In en, this message translates to:
  /// **'Trainee'**
  String get chatTrainee;

  /// No description provided for @chatCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get chatCoach;

  /// No description provided for @chatToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatToday;

  /// No description provided for @chatYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatYesterday;

  /// No description provided for @chatAttachReference.
  ///
  /// In en, this message translates to:
  /// **'Attach a reference'**
  String get chatAttachReference;

  /// No description provided for @chatReferenceInBody.
  ///
  /// In en, this message translates to:
  /// **'InBody Result'**
  String get chatReferenceInBody;

  /// No description provided for @chatReferenceWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout Plan'**
  String get chatReferenceWorkout;

  /// No description provided for @chatReferenceMeal.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get chatReferenceMeal;

  /// No description provided for @chatReferencing.
  ///
  /// In en, this message translates to:
  /// **'Referencing'**
  String get chatReferencing;

  /// No description provided for @chatRemoveReference.
  ///
  /// In en, this message translates to:
  /// **'Remove reference'**
  String get chatRemoveReference;

  /// No description provided for @progressBody.
  ///
  /// In en, this message translates to:
  /// **'Progress Body'**
  String get progressBody;

  /// No description provided for @progressTimeline.
  ///
  /// In en, this message translates to:
  /// **'Progress Timeline'**
  String get progressTimeline;

  /// No description provided for @noProgressEntries.
  ///
  /// In en, this message translates to:
  /// **'No progress entries yet'**
  String get noProgressEntries;

  /// No description provided for @noProgressEntriesHint.
  ///
  /// In en, this message translates to:
  /// **'Add photos and notes to track your body changes over time.'**
  String get noProgressEntriesHint;

  /// No description provided for @addProgressEntry.
  ///
  /// In en, this message translates to:
  /// **'Add Progress Entry'**
  String get addProgressEntry;

  /// No description provided for @progressPhotos.
  ///
  /// In en, this message translates to:
  /// **'Progress Photos'**
  String get progressPhotos;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @progressNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get progressNotes;

  /// No description provided for @progressNotesHint.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling? Any changes you noticed?'**
  String get progressNotesHint;

  /// No description provided for @saveProgress.
  ///
  /// In en, this message translates to:
  /// **'Save Entry'**
  String get saveProgress;

  /// No description provided for @progressSaved.
  ///
  /// In en, this message translates to:
  /// **'Progress entry saved'**
  String get progressSaved;

  /// No description provided for @addPhotoOrNote.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo or a note.'**
  String get addPhotoOrNote;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete entry'**
  String get deleteEntry;

  /// No description provided for @deleteEntryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this progress entry?'**
  String get deleteEntryConfirm;

  /// No description provided for @photosCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s)'**
  String photosCount(int count);

  /// No description provided for @coachComments.
  ///
  /// In en, this message translates to:
  /// **'Coach Comments'**
  String get coachComments;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addComment;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note or tip for this exercise…'**
  String get commentHint;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noComments;

  /// No description provided for @commentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added'**
  String get commentAdded;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get deleteComment;

  /// No description provided for @totalTraineesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalTraineesLabel;

  /// No description provided for @traineesNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'Trainees Need Attention'**
  String get traineesNeedAttention;

  /// No description provided for @expiringMemberships.
  ///
  /// In en, this message translates to:
  /// **'Expiring Memberships'**
  String get expiringMemberships;

  /// No description provided for @allTraineesOnTrack.
  ///
  /// In en, this message translates to:
  /// **'All Trainees On Track 🎉'**
  String get allTraineesOnTrack;

  /// No description provided for @allTraineesOnTrackHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone is following their plan. Great work!'**
  String get allTraineesOnTrackHint;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep It Up! 💪'**
  String get keepItUp;

  /// No description provided for @keepItUpHint.
  ///
  /// In en, this message translates to:
  /// **'Check your plan and stay consistent with your workouts and meals.'**
  String get keepItUpHint;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @myWorkout.
  ///
  /// In en, this message translates to:
  /// **'My Workout'**
  String get myWorkout;

  /// No description provided for @myMeals.
  ///
  /// In en, this message translates to:
  /// **'My Meals'**
  String get myMeals;

  /// No description provided for @drawerNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get drawerNavigation;

  /// No description provided for @drawerCoachActions.
  ///
  /// In en, this message translates to:
  /// **'Coach Actions'**
  String get drawerCoachActions;

  /// No description provided for @drawerAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get drawerAdmin;

  /// No description provided for @drawerGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get drawerGeneral;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navMyTrainees.
  ///
  /// In en, this message translates to:
  /// **'My Trainees'**
  String get navMyTrainees;

  /// No description provided for @navAddNewTrainee.
  ///
  /// In en, this message translates to:
  /// **'Add New Trainee'**
  String get navAddNewTrainee;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get navReports;

  /// No description provided for @navManageStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage Staff'**
  String get navManageStaff;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @languageToggle.
  ///
  /// In en, this message translates to:
  /// **'العربية / English'**
  String get languageToggle;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out?'**
  String get logOutTitle;

  /// No description provided for @logOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutMessage;

  /// No description provided for @dashGymDashboard.
  ///
  /// In en, this message translates to:
  /// **'Gym Dashboard'**
  String get dashGymDashboard;

  /// No description provided for @dashWelcomeUser.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name} 👋'**
  String dashWelcomeUser(String name);

  /// No description provided for @dashCoaches.
  ///
  /// In en, this message translates to:
  /// **'Coaches'**
  String get dashCoaches;

  /// No description provided for @dashTrainees.
  ///
  /// In en, this message translates to:
  /// **'Trainees'**
  String get dashTrainees;

  /// No description provided for @dashActiveMembers.
  ///
  /// In en, this message translates to:
  /// **'Active members'**
  String get dashActiveMembers;

  /// No description provided for @dashMonthlyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Monthly revenue'**
  String get dashMonthlyRevenue;

  /// No description provided for @dashExpiringThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Expiring this week'**
  String get dashExpiringThisWeek;

  /// No description provided for @dashNewThisMonth.
  ///
  /// In en, this message translates to:
  /// **'New this month'**
  String get dashNewThisMonth;

  /// No description provided for @dashUnpaidTraineesAlert.
  ///
  /// In en, this message translates to:
  /// **'{count} trainee(s) have not paid the current period.'**
  String dashUnpaidTraineesAlert(int count);

  /// No description provided for @dashPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get dashPlatform;

  /// No description provided for @dashPlatformSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview of all gyms & activity'**
  String get dashPlatformSubtitle;

  /// No description provided for @dashPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get dashPayments;

  /// No description provided for @dashPaymentRequests.
  ///
  /// In en, this message translates to:
  /// **'Payment Requests'**
  String get dashPaymentRequests;

  /// No description provided for @dashPaymentRequestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review & approve manual payments'**
  String get dashPaymentRequestsSubtitle;

  /// No description provided for @dashPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get dashPaymentMethods;

  /// No description provided for @dashPaymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Activate / deactivate & edit methods'**
  String get dashPaymentMethodsSubtitle;

  /// No description provided for @dashRevenueLastMonths.
  ///
  /// In en, this message translates to:
  /// **'Revenue (last months)'**
  String get dashRevenueLastMonths;

  /// No description provided for @dashGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get dashGrowth;

  /// No description provided for @dashTotalGyms.
  ///
  /// In en, this message translates to:
  /// **'Total Gyms'**
  String get dashTotalGyms;

  /// No description provided for @dashGymsActiveInactive.
  ///
  /// In en, this message translates to:
  /// **'{active} active · {inactive} inactive'**
  String dashGymsActiveInactive(int active, int inactive);

  /// No description provided for @dashTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get dashTotalRevenue;

  /// No description provided for @dashThisMonthAmount.
  ///
  /// In en, this message translates to:
  /// **'This month {amount}'**
  String dashThisMonthAmount(String amount);

  /// No description provided for @dashPlusThisMonth.
  ///
  /// In en, this message translates to:
  /// **'+{count} this month'**
  String dashPlusThisMonth(int count);

  /// No description provided for @dashAdminsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} admins'**
  String dashAdminsCount(int count);

  /// No description provided for @dashInBodyRecords.
  ///
  /// In en, this message translates to:
  /// **'InBody Records'**
  String get dashInBodyRecords;

  /// No description provided for @dashWorkoutSessions.
  ///
  /// In en, this message translates to:
  /// **'Workout Sessions'**
  String get dashWorkoutSessions;

  /// No description provided for @dashMealPlans.
  ///
  /// In en, this message translates to:
  /// **'Meal Plans'**
  String get dashMealPlans;

  /// No description provided for @dashNewGyms.
  ///
  /// In en, this message translates to:
  /// **'New Gyms'**
  String get dashNewGyms;

  /// No description provided for @dashThisMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get dashThisMonth;

  /// No description provided for @dashNoRevenueData.
  ///
  /// In en, this message translates to:
  /// **'No revenue data yet'**
  String get dashNoRevenueData;

  /// No description provided for @dashNoGrowthData.
  ///
  /// In en, this message translates to:
  /// **'No growth data yet'**
  String get dashNoGrowthData;

  /// No description provided for @dashWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get dashWorkouts;

  /// No description provided for @dashRevenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get dashRevenue;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @tabAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get tabAlerts;

  /// No description provided for @tabChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tabChat;

  /// No description provided for @tabRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get tabRequests;

  /// No description provided for @tabSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get tabSupport;

  /// No description provided for @membershipPaymentDue.
  ///
  /// In en, this message translates to:
  /// **'Membership payment due'**
  String get membershipPaymentDue;

  /// No description provided for @payCoachUnlockMessage.
  ///
  /// In en, this message translates to:
  /// **'Please pay your coach to unlock your workouts, meal plans, InBody and progress tracking. Message your coach to arrange payment.'**
  String get payCoachUnlockMessage;

  /// No description provided for @messageCoach.
  ///
  /// In en, this message translates to:
  /// **'Message Coach'**
  String get messageCoach;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get maybeLater;

  /// No description provided for @drawerMySubscription.
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get drawerMySubscription;

  /// No description provided for @drawerOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get drawerOverview;

  /// No description provided for @drawerManageGyms.
  ///
  /// In en, this message translates to:
  /// **'Manage Gyms'**
  String get drawerManageGyms;

  /// No description provided for @drawerAllUsers.
  ///
  /// In en, this message translates to:
  /// **'All Users'**
  String get drawerAllUsers;

  /// No description provided for @drawerAllCoaches.
  ///
  /// In en, this message translates to:
  /// **'All Coaches'**
  String get drawerAllCoaches;

  /// No description provided for @drawerSendAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Send Announcement'**
  String get drawerSendAnnouncement;

  /// No description provided for @addCoach.
  ///
  /// In en, this message translates to:
  /// **'Add coach'**
  String get addCoach;

  /// No description provided for @searchCoaches.
  ///
  /// In en, this message translates to:
  /// **'Search coaches…'**
  String get searchCoaches;

  /// No description provided for @noCoachesYet.
  ///
  /// In en, this message translates to:
  /// **'No coaches yet.'**
  String get noCoachesYet;

  /// No description provided for @traineesLower.
  ///
  /// In en, this message translates to:
  /// **'trainees'**
  String get traineesLower;

  /// No description provided for @noOtherCoachToReassign.
  ///
  /// In en, this message translates to:
  /// **'No other coach to reassign to.'**
  String get noOtherCoachToReassign;

  /// No description provided for @reassignTraineeTo.
  ///
  /// In en, this message translates to:
  /// **'Reassign {name} to…'**
  String reassignTraineeTo(String name);

  /// No description provided for @reassignedToName.
  ///
  /// In en, this message translates to:
  /// **'Reassigned to {name}.'**
  String reassignedToName(String name);

  /// No description provided for @failedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Failed.'**
  String get failedGeneric;

  /// No description provided for @noTraineesUnderCoach.
  ///
  /// In en, this message translates to:
  /// **'No trainees under this coach yet.'**
  String get noTraineesUnderCoach;

  /// No description provided for @openDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get openDetails;

  /// No description provided for @reassignCoach.
  ///
  /// In en, this message translates to:
  /// **'Reassign coach'**
  String get reassignCoach;

  /// No description provided for @coachCreated.
  ///
  /// In en, this message translates to:
  /// **'Coach created.'**
  String get coachCreated;

  /// No description provided for @failedToCreateCoach.
  ///
  /// In en, this message translates to:
  /// **'Failed to create coach.'**
  String get failedToCreateCoach;

  /// No description provided for @newCoach.
  ///
  /// In en, this message translates to:
  /// **'New Coach'**
  String get newCoach;

  /// No description provided for @createCoach.
  ///
  /// In en, this message translates to:
  /// **'Create Coach'**
  String get createCoach;

  /// No description provided for @firstNameField.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameField;

  /// No description provided for @lastNameField.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameField;

  /// No description provided for @tempPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Temporary password'**
  String get tempPasswordField;

  /// No description provided for @phoneOptionalField.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptionalField;

  /// No description provided for @bioOptionalField.
  ///
  /// In en, this message translates to:
  /// **'Bio (optional)'**
  String get bioOptionalField;

  /// No description provided for @heightCmField.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCmField;

  /// No description provided for @weightKgField.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgField;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @traineeCreatedAndAssigned.
  ///
  /// In en, this message translates to:
  /// **'Trainee created and assigned.'**
  String get traineeCreatedAndAssigned;

  /// No description provided for @failedToCreateTrainee.
  ///
  /// In en, this message translates to:
  /// **'Failed to create trainee.'**
  String get failedToCreateTrainee;

  /// No description provided for @newTrainee.
  ///
  /// In en, this message translates to:
  /// **'New Trainee'**
  String get newTrainee;

  /// No description provided for @assignedToCoach.
  ///
  /// In en, this message translates to:
  /// **'Assigned to coach: {name}'**
  String assignedToCoach(String name);

  /// No description provided for @createTrainee.
  ///
  /// In en, this message translates to:
  /// **'Create Trainee'**
  String get createTrainee;

  /// No description provided for @unpaidTrainees.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Trainees'**
  String get unpaidTrainees;

  /// No description provided for @everyonePaid.
  ///
  /// In en, this message translates to:
  /// **'Everyone has paid 🎉'**
  String get everyonePaid;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @coachWithName.
  ///
  /// In en, this message translates to:
  /// **'Coach: {name}'**
  String coachWithName(String name);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @notificationEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Chat messages and updates will appear here'**
  String get notificationEmptyHint;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateAccountPassword;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @settingOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get settingOn;

  /// No description provided for @settingOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get settingOff;

  /// No description provided for @receiveWorkoutReminders.
  ///
  /// In en, this message translates to:
  /// **'Receive workout reminders'**
  String get receiveWorkoutReminders;

  /// No description provided for @submitSupportTicket.
  ///
  /// In en, this message translates to:
  /// **'Submit a support ticket'**
  String get submitSupportTicket;

  /// No description provided for @workoutTemplates.
  ///
  /// In en, this message translates to:
  /// **'Workout Templates'**
  String get workoutTemplates;

  /// No description provided for @workoutTemplatesHint.
  ///
  /// In en, this message translates to:
  /// **'Build a workout once — from the exercise library or by uploading a file — then assign it to any trainee in one tap. No more rebuilding the same plan for everyone.'**
  String get workoutTemplatesHint;

  /// No description provided for @newTemplate.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get newTemplate;

  /// No description provided for @assignFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Assign from a template'**
  String get assignFromTemplate;

  /// No description provided for @planBuildInApp.
  ///
  /// In en, this message translates to:
  /// **'Build in app'**
  String get planBuildInApp;

  /// No description provided for @planUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload file'**
  String get planUploadFile;

  /// No description provided for @chooseFileToUpload.
  ///
  /// In en, this message translates to:
  /// **'Please choose a file to upload.'**
  String get chooseFileToUpload;

  /// No description provided for @fileUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'File upload failed. Please try again.'**
  String get fileUploadFailed;

  /// No description provided for @planUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Nutrition plan uploaded successfully.'**
  String get planUploadedSuccess;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @uploadAndAssignPlan.
  ///
  /// In en, this message translates to:
  /// **'Upload & Assign Plan'**
  String get uploadAndAssignPlan;

  /// No description provided for @traineeMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Trainee measurements'**
  String get traineeMeasurements;

  /// No description provided for @heightCmLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCmLabel;

  /// No description provided for @weightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @planFilePdfImage.
  ///
  /// In en, this message translates to:
  /// **'Plan file (PDF / image)'**
  String get planFilePdfImage;

  /// No description provided for @enterMeasurementsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter height, weight and age to auto-calculate daily targets.'**
  String get enterMeasurementsHint;

  /// No description provided for @recommendedDailyTargets.
  ///
  /// In en, this message translates to:
  /// **'Recommended daily targets'**
  String get recommendedDailyTargets;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @bmrLabel.
  ///
  /// In en, this message translates to:
  /// **'BMR'**
  String get bmrLabel;

  /// No description provided for @tdeeLabel.
  ///
  /// In en, this message translates to:
  /// **'TDEE'**
  String get tdeeLabel;

  /// No description provided for @proteinPerMeal.
  ///
  /// In en, this message translates to:
  /// **'Protein/meal'**
  String get proteinPerMeal;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'Per week'**
  String get perWeek;

  /// No description provided for @useTheseTargets.
  ///
  /// In en, this message translates to:
  /// **'Use these as plan targets'**
  String get useTheseTargets;

  /// No description provided for @tapToChooseFile.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose a PDF or image'**
  String get tapToChooseFile;

  /// No description provided for @fileTypesHint.
  ///
  /// In en, this message translates to:
  /// **'PDF, JPG, PNG · up to 50 MB'**
  String get fileTypesHint;

  /// No description provided for @monthSingular.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get monthSingular;

  /// No description provided for @monthPlural.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get monthPlural;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @rejectedByTrainee.
  ///
  /// In en, this message translates to:
  /// **'Rejected by trainee'**
  String get rejectedByTrainee;

  /// No description provided for @replaceMeal.
  ///
  /// In en, this message translates to:
  /// **'Replace meal'**
  String get replaceMeal;

  /// No description provided for @mealReplacedNotified.
  ///
  /// In en, this message translates to:
  /// **'Meal replaced. The trainee has been notified.'**
  String get mealReplacedNotified;

  /// No description provided for @copyDayTo.
  ///
  /// In en, this message translates to:
  /// **'Copy {day} to…'**
  String copyDayTo(String day);

  /// No description provided for @mealsWillBeCopied.
  ///
  /// In en, this message translates to:
  /// **'{count} meal(s) will be copied to the selected days.'**
  String mealsWillBeCopied(int count);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @currentlyHasMeals.
  ///
  /// In en, this message translates to:
  /// **'Currently has {count} meal(s)'**
  String currentlyHasMeals(int count);

  /// No description provided for @replaceExistingMeals.
  ///
  /// In en, this message translates to:
  /// **'Replace existing meals'**
  String get replaceExistingMeals;

  /// No description provided for @replaceExistingOn.
  ///
  /// In en, this message translates to:
  /// **'Target days are cleared before copying'**
  String get replaceExistingOn;

  /// No description provided for @replaceExistingOff.
  ///
  /// In en, this message translates to:
  /// **'Copied meals are added alongside existing ones'**
  String get replaceExistingOff;

  /// No description provided for @copyToDays.
  ///
  /// In en, this message translates to:
  /// **'Copy to {count} day(s)'**
  String copyToDays(int count);

  /// No description provided for @copiedMealsToDays.
  ///
  /// In en, this message translates to:
  /// **'Copied {meals} meal(s) to {days} day(s).'**
  String copiedMealsToDays(int meals, int days);

  /// No description provided for @couldNotDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Could not duplicate the day.'**
  String get couldNotDuplicate;

  /// No description provided for @copyThisDayToOthers.
  ///
  /// In en, this message translates to:
  /// **'Copy this day to other days'**
  String get copyThisDayToOthers;

  /// No description provided for @coachProvidedFilePlan.
  ///
  /// In en, this message translates to:
  /// **'Your coach provided this nutrition plan as a file. Duration: {months} month(s).'**
  String coachProvidedFilePlan(int months);

  /// No description provided for @rejectThisMeal.
  ///
  /// In en, this message translates to:
  /// **'Reject this meal?'**
  String get rejectThisMeal;

  /// No description provided for @rejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Let your coach know why this meal doesn\'t work for you so they can replace it.'**
  String get rejectReasonHint;

  /// No description provided for @rejectReasonPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. I\'m allergic, I dislike this food…'**
  String get rejectReasonPlaceholder;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @mealRejectedNotified.
  ///
  /// In en, this message translates to:
  /// **'Meal rejected. Your coach has been notified.'**
  String get mealRejectedNotified;

  /// No description provided for @couldNotReject.
  ///
  /// In en, this message translates to:
  /// **'Could not reject the meal.'**
  String get couldNotReject;

  /// No description provided for @rejectedWaitingCoach.
  ///
  /// In en, this message translates to:
  /// **'Rejected — waiting for coach'**
  String get rejectedWaitingCoach;

  /// No description provided for @planFile.
  ///
  /// In en, this message translates to:
  /// **'Plan file'**
  String get planFile;

  /// No description provided for @catAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catAll;

  /// No description provided for @catVegetable.
  ///
  /// In en, this message translates to:
  /// **'Vegetable'**
  String get catVegetable;

  /// No description provided for @catFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get catFruit;

  /// No description provided for @catDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get catDairy;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @howManyUnit.
  ///
  /// In en, this message translates to:
  /// **'How many {unit}?'**
  String howManyUnit(String unit);

  /// No description provided for @pieceUnit.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get pieceUnit;

  /// No description provided for @approxGrams.
  ///
  /// In en, this message translates to:
  /// **'≈ {grams} g'**
  String approxGrams(String grams);

  /// No description provided for @countLabel.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get countLabel;

  /// No description provided for @measureByCount.
  ///
  /// In en, this message translates to:
  /// **'Measure by count (e.g. eggs)'**
  String get measureByCount;

  /// No description provided for @gramsPerUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Grams per unit'**
  String get gramsPerUnitLabel;

  /// No description provided for @unitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit name (e.g. egg)'**
  String get unitNameLabel;

  /// No description provided for @addCustomFood.
  ///
  /// In en, this message translates to:
  /// **'Add custom food'**
  String get addCustomFood;

  /// No description provided for @newCustomFood.
  ///
  /// In en, this message translates to:
  /// **'New custom food'**
  String get newCustomFood;

  /// No description provided for @foodNameEnLabel.
  ///
  /// In en, this message translates to:
  /// **'Food name (English)'**
  String get foodNameEnLabel;

  /// No description provided for @foodNameArLabel.
  ///
  /// In en, this message translates to:
  /// **'Food name (Arabic)'**
  String get foodNameArLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @per100gNote.
  ///
  /// In en, this message translates to:
  /// **'Values per 100 g'**
  String get per100gNote;

  /// No description provided for @caloriesPer100.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesPer100;

  /// No description provided for @proteinPer100.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinPer100;

  /// No description provided for @carbsPer100.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsPer100;

  /// No description provided for @fatPer100.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatPer100;

  /// No description provided for @foodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Food name is required.'**
  String get foodNameRequired;

  /// No description provided for @foodAdded.
  ///
  /// In en, this message translates to:
  /// **'Food added to your library.'**
  String get foodAdded;

  /// No description provided for @saveFood.
  ///
  /// In en, this message translates to:
  /// **'Save food'**
  String get saveFood;

  /// No description provided for @noFoodAddYours.
  ///
  /// In en, this message translates to:
  /// **'No foods found. Add your own custom food.'**
  String get noFoodAddYours;

  /// No description provided for @coachGuide.
  ///
  /// In en, this message translates to:
  /// **'Coach Guide'**
  String get coachGuide;

  /// No description provided for @guideHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to run your coaching — step by step.'**
  String get guideHeaderSubtitle;

  /// No description provided for @guideProcessTitle.
  ///
  /// In en, this message translates to:
  /// **'The full journey'**
  String get guideProcessTitle;

  /// No description provided for @guideProcessStep1.
  ///
  /// In en, this message translates to:
  /// **'Add a trainee and assign them to yourself.'**
  String get guideProcessStep1;

  /// No description provided for @guideProcessStep2.
  ///
  /// In en, this message translates to:
  /// **'Record their measurements (InBody) and set a goal.'**
  String get guideProcessStep2;

  /// No description provided for @guideProcessStep3.
  ///
  /// In en, this message translates to:
  /// **'Create a workout program and a nutrition plan.'**
  String get guideProcessStep3;

  /// No description provided for @guideProcessStep4.
  ///
  /// In en, this message translates to:
  /// **'Set their subscription so their content unlocks.'**
  String get guideProcessStep4;

  /// No description provided for @guideProcessStep5.
  ///
  /// In en, this message translates to:
  /// **'They follow, log, and chat — you track progress.'**
  String get guideProcessStep5;

  /// No description provided for @guideNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a nutrition plan'**
  String get guideNutritionTitle;

  /// No description provided for @guideNutritionStep1.
  ///
  /// In en, this message translates to:
  /// **'Open a trainee → Nutrition tab → tap New plan.'**
  String get guideNutritionStep1;

  /// No description provided for @guideNutritionStep2.
  ///
  /// In en, this message translates to:
  /// **'Enter height, weight & age, then pick sex, goal and activity — targets are calculated for you.'**
  String get guideNutritionStep2;

  /// No description provided for @guideNutritionStep3.
  ///
  /// In en, this message translates to:
  /// **'Choose to build in-app or upload a ready file (PDF/image), and set the duration in months.'**
  String get guideNutritionStep3;

  /// No description provided for @guideNutritionStep4.
  ///
  /// In en, this message translates to:
  /// **'Add meals, pick foods (or add your own custom food) and enter grams — macros are auto-calculated.'**
  String get guideNutritionStep4;

  /// No description provided for @guideNutritionStep5.
  ///
  /// In en, this message translates to:
  /// **'Use Copy day to duplicate one day across the week in seconds.'**
  String get guideNutritionStep5;

  /// No description provided for @guideNutritionStep6.
  ///
  /// In en, this message translates to:
  /// **'If a trainee rejects a meal, you\'re notified — just replace it and they\'re notified back.'**
  String get guideNutritionStep6;

  /// No description provided for @guideWorkoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a workout'**
  String get guideWorkoutsTitle;

  /// No description provided for @guideWorkoutsStep1.
  ///
  /// In en, this message translates to:
  /// **'Open a trainee → Workout tab → create a program.'**
  String get guideWorkoutsStep1;

  /// No description provided for @guideWorkoutsStep2.
  ///
  /// In en, this message translates to:
  /// **'Build a template once and assign it to any trainee in one tap.'**
  String get guideWorkoutsStep2;

  /// No description provided for @guideWorkoutsStep3.
  ///
  /// In en, this message translates to:
  /// **'Edit day-by-day and add exercises from the library.'**
  String get guideWorkoutsStep3;

  /// No description provided for @guideWorkoutsStep4.
  ///
  /// In en, this message translates to:
  /// **'Trainees log their workouts and comment on exercises.'**
  String get guideWorkoutsStep4;

  /// No description provided for @guideSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage subscriptions'**
  String get guideSubscriptionsTitle;

  /// No description provided for @guideSubscriptionsStep1.
  ///
  /// In en, this message translates to:
  /// **'Open a trainee and set up their membership/subscription.'**
  String get guideSubscriptionsStep1;

  /// No description provided for @guideSubscriptionsStep2.
  ///
  /// In en, this message translates to:
  /// **'Track who has paid and who is unpaid at a glance.'**
  String get guideSubscriptionsStep2;

  /// No description provided for @guideSubscriptionsStep3.
  ///
  /// In en, this message translates to:
  /// **'When the subscription is active, the trainee\'s content unlocks automatically.'**
  String get guideSubscriptionsStep3;

  /// No description provided for @guideTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro tips'**
  String get guideTipsTitle;

  /// No description provided for @guideTip1.
  ///
  /// In en, this message translates to:
  /// **'Reuse workout templates and copy nutrition days to save time.'**
  String get guideTip1;

  /// No description provided for @guideTip2.
  ///
  /// In en, this message translates to:
  /// **'Add your own custom foods so your plans match your style.'**
  String get guideTip2;

  /// No description provided for @guideTip3.
  ///
  /// In en, this message translates to:
  /// **'Keep an eye on notifications for meal rejections and messages.'**
  String get guideTip3;

  /// No description provided for @tourSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get tourSkip;

  /// No description provided for @tourNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get tourNext;

  /// No description provided for @tourDone.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get tourDone;

  /// No description provided for @tourReopenHint.
  ///
  /// In en, this message translates to:
  /// **'You can reopen this guide anytime from the menu.'**
  String get tourReopenHint;

  /// No description provided for @tourWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Liaqh 👋'**
  String get tourWelcomeTitle;

  /// No description provided for @tourWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your all-in-one app to coach trainees: workouts, nutrition, progress and payments — in Arabic & English.'**
  String get tourWelcomeBody;

  /// No description provided for @tourNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart nutrition 🍽️'**
  String get tourNutritionTitle;

  /// No description provided for @tourNutritionBody.
  ///
  /// In en, this message translates to:
  /// **'Create plans with auto-calculated targets, build in-app or upload a file, add custom foods, and copy days in one tap.'**
  String get tourNutritionBody;

  /// No description provided for @tourWorkoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts made easy 🏋️'**
  String get tourWorkoutsTitle;

  /// No description provided for @tourWorkoutsBody.
  ///
  /// In en, this message translates to:
  /// **'Build reusable templates and assign full programs to any trainee in seconds.'**
  String get tourWorkoutsBody;

  /// No description provided for @tourTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track & get paid 📊'**
  String get tourTrackTitle;

  /// No description provided for @tourTrackBody.
  ///
  /// In en, this message translates to:
  /// **'Follow InBody and progress over time, chat with trainees, and unlock their content with subscriptions.'**
  String get tourTrackBody;

  /// No description provided for @tourGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Need a refresher? 📖'**
  String get tourGuideTitle;

  /// No description provided for @tourGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Open the Coach Guide anytime from the side menu for step-by-step instructions.'**
  String get tourGuideBody;

  /// No description provided for @goalCut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get goalCut;

  /// No description provided for @goalBulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk'**
  String get goalBulk;

  /// No description provided for @goalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain'**
  String get goalMaintain;

  /// No description provided for @goalRecomp.
  ///
  /// In en, this message translates to:
  /// **'Recomp'**
  String get goalRecomp;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get activityLight;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get activityModerate;

  /// No description provided for @activityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activityActive;

  /// No description provided for @activityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get activityVeryActive;

  /// No description provided for @activitySedentaryHint.
  ///
  /// In en, this message translates to:
  /// **'Little or no exercise'**
  String get activitySedentaryHint;

  /// No description provided for @activityLightHint.
  ///
  /// In en, this message translates to:
  /// **'1–3 days / week'**
  String get activityLightHint;

  /// No description provided for @activityModerateHint.
  ///
  /// In en, this message translates to:
  /// **'3–5 days / week'**
  String get activityModerateHint;

  /// No description provided for @activityActiveHint.
  ///
  /// In en, this message translates to:
  /// **'6–7 days / week'**
  String get activityActiveHint;

  /// No description provided for @activityVeryActiveHint.
  ///
  /// In en, this message translates to:
  /// **'Hard daily / physical job'**
  String get activityVeryActiveHint;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChangedSuccess;

  /// No description provided for @couldNotChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not change password.'**
  String get couldNotChangePassword;

  /// No description provided for @passwordTip.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters. Choose a strong password you don\'t use elsewhere.'**
  String get passwordTip;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get enterNewPassword;

  /// No description provided for @passwordMin8.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 8 characters'**
  String get passwordMin8;

  /// No description provided for @newPasswordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'New password must differ from the current one'**
  String get newPasswordMustDiffer;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @reenterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the new password'**
  String get reenterNewPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s complete your profile'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It will help us to know more about you!'**
  String get completeProfileSubtitle;

  /// No description provided for @chooseGender.
  ///
  /// In en, this message translates to:
  /// **'Choose Gender'**
  String get chooseGender;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @yourWeight.
  ///
  /// In en, this message translates to:
  /// **'Your Weight'**
  String get yourWeight;

  /// No description provided for @yourHeight.
  ///
  /// In en, this message translates to:
  /// **'Your Height'**
  String get yourHeight;

  /// No description provided for @couldNotLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile'**
  String get couldNotLoadProfile;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image…'**
  String get uploadingImage;

  /// No description provided for @profileImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated'**
  String get profileImageUpdated;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacySection1Title;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Information'**
  String get privacySection2Title;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Storage'**
  String get privacySection3Title;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Sharing Information'**
  String get privacySection4Title;

  /// No description provided for @privacySection5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacySection5Title;

  /// No description provided for @privacySection6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Changes to this Policy'**
  String get privacySection6Title;

  /// No description provided for @privacySection7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Contact'**
  String get privacySection7Title;

  /// No description provided for @newWorkoutTemplate.
  ///
  /// In en, this message translates to:
  /// **'New workout template'**
  String get newWorkoutTemplate;

  /// No description provided for @uploadWorkoutFile.
  ///
  /// In en, this message translates to:
  /// **'Upload workout file'**
  String get uploadWorkoutFile;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateName;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @buildFromSystem.
  ///
  /// In en, this message translates to:
  /// **'Build from system'**
  String get buildFromSystem;

  /// No description provided for @addDaysExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'Add days & exercises from the library'**
  String get addDaysExercisesHint;

  /// No description provided for @uploadAFile.
  ///
  /// In en, this message translates to:
  /// **'Upload a file'**
  String get uploadAFile;

  /// No description provided for @uploadFileHint.
  ///
  /// In en, this message translates to:
  /// **'PDF, document or image with the workout'**
  String get uploadFileHint;

  /// No description provided for @templateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleted;

  /// No description provided for @noTemplatesYet.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get noTemplatesYet;

  /// No description provided for @templatesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Create a workout once and assign it to any trainee — no need to rebuild it each time.'**
  String get templatesEmptyHint;

  /// No description provided for @editDays.
  ///
  /// In en, this message translates to:
  /// **'Edit days'**
  String get editDays;

  /// No description provided for @fileWorkout.
  ///
  /// In en, this message translates to:
  /// **'File workout'**
  String get fileWorkout;

  /// No description provided for @daysCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} day(s)'**
  String daysCountLabel(int count);

  /// No description provided for @exercisesCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} exercise(s)'**
  String exercisesCountLabel(int count);

  /// No description provided for @dayUpdated.
  ///
  /// In en, this message translates to:
  /// **'Day updated'**
  String get dayUpdated;

  /// No description provided for @daySaved.
  ///
  /// In en, this message translates to:
  /// **'Day saved'**
  String get daySaved;

  /// No description provided for @savedDays.
  ///
  /// In en, this message translates to:
  /// **'Saved days'**
  String get savedDays;

  /// No description provided for @editDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editDayTitle(String name);

  /// No description provided for @dayWord.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get dayWord;

  /// No description provided for @updateDay.
  ///
  /// In en, this message translates to:
  /// **'Update Day'**
  String get updateDay;

  /// No description provided for @cancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel edit'**
  String get cancelEdit;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @subStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get subStatusActive;

  /// No description provided for @subStatusFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get subStatusFrozen;

  /// No description provided for @subStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get subStatusExpired;

  /// No description provided for @subStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get subStatusCancelled;

  /// No description provided for @subStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get subStatusPending;

  /// No description provided for @subStatusNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get subStatusNone;

  /// No description provided for @payStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payStatusPaid;

  /// No description provided for @payStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get payStatusUnpaid;

  /// No description provided for @payStatusFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get payStatusFree;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @egpPerMonth.
  ///
  /// In en, this message translates to:
  /// **'EGP / month'**
  String get egpPerMonth;

  /// No description provided for @subscriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription details'**
  String get subscriptionDetails;

  /// No description provided for @cancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get cancelSubscription;

  /// No description provided for @cancelSubscriptionQ.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription?'**
  String get cancelSubscriptionQ;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get paymentHistory;

  /// No description provided for @standardPlan.
  ///
  /// In en, this message translates to:
  /// **'Standard Plan'**
  String get standardPlan;

  /// No description provided for @planStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get planStandard;

  /// No description provided for @couldNotLoadSubscription.
  ///
  /// In en, this message translates to:
  /// **'Could not load subscription.'**
  String get couldNotLoadSubscription;

  /// No description provided for @daysRemainingCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days remaining'**
  String daysRemainingCount(int days);

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @renewsOn.
  ///
  /// In en, this message translates to:
  /// **'Renews on'**
  String get renewsOn;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires on'**
  String get expiresOn;

  /// No description provided for @nextBilling.
  ///
  /// In en, this message translates to:
  /// **'Next billing'**
  String get nextBilling;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @subscribeToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to unlock everything'**
  String get subscribeToUnlock;

  /// No description provided for @subscribeToUnlockBody.
  ///
  /// In en, this message translates to:
  /// **'Get full access to workouts, meal plans, InBody tracking, progress and coach chat.'**
  String get subscribeToUnlockBody;

  /// No description provided for @subscribeAndPay.
  ///
  /// In en, this message translates to:
  /// **'Subscribe & Pay'**
  String get subscribeAndPay;

  /// No description provided for @noCoachAssigned.
  ///
  /// In en, this message translates to:
  /// **'No coach is assigned to your account yet.'**
  String get noCoachAssigned;

  /// No description provided for @couldNotOpenChat.
  ///
  /// In en, this message translates to:
  /// **'Could not open chat'**
  String get couldNotOpenChat;

  /// No description provided for @lockOneStepPayCoach.
  ///
  /// In en, this message translates to:
  /// **'One step left — pay your coach'**
  String get lockOneStepPayCoach;

  /// No description provided for @lockOneStepSubscribe.
  ///
  /// In en, this message translates to:
  /// **'One step left — subscribe to the platform'**
  String get lockOneStepSubscribe;

  /// No description provided for @lockPendingMsg.
  ///
  /// In en, this message translates to:
  /// **'Your platform payment is pending approval by the admin (up to 24 hours). Complete your coach payment below in the meantime.'**
  String get lockPendingMsg;

  /// No description provided for @lockPaidPlatformMsg.
  ///
  /// In en, this message translates to:
  /// **'Your platform subscription is active. Now pay your coach to unlock everything.'**
  String get lockPaidPlatformMsg;

  /// No description provided for @lockPaidCoachMsg.
  ///
  /// In en, this message translates to:
  /// **'Your coach payment is confirmed. Now subscribe to the platform to unlock everything.'**
  String get lockPaidCoachMsg;

  /// No description provided for @lockBothMsg.
  ///
  /// In en, this message translates to:
  /// **'To unlock your workouts, meals, InBody and progress you must complete BOTH payments below.'**
  String get lockBothMsg;

  /// No description provided for @closeLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeLabel;

  /// No description provided for @subscribeToPlatform.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to the platform'**
  String get subscribeToPlatform;

  /// No description provided for @payByCardInstaPayWallet.
  ///
  /// In en, this message translates to:
  /// **'Pay by card, InstaPay or Wallet'**
  String get payByCardInstaPayWallet;

  /// No description provided for @pendingAdminApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending admin approval (up to 24h)'**
  String get pendingAdminApproval;

  /// No description provided for @payPlatform.
  ///
  /// In en, this message translates to:
  /// **'Pay platform'**
  String get payPlatform;

  /// No description provided for @payYourCoach.
  ///
  /// In en, this message translates to:
  /// **'Pay your coach'**
  String get payYourCoach;

  /// No description provided for @cashToCoachHint.
  ///
  /// In en, this message translates to:
  /// **'Cash to your coach — they confirm it'**
  String get cashToCoachHint;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get pendingApproval;

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @paymentSubmitted24h.
  ///
  /// In en, this message translates to:
  /// **'Payment submitted. We\'ll confirm within 24 hours.'**
  String get paymentSubmitted24h;

  /// No description provided for @payWithMethod.
  ///
  /// In en, this message translates to:
  /// **'Pay with {method}'**
  String payWithMethod(String method);

  /// No description provided for @sendPaymentToNumber.
  ///
  /// In en, this message translates to:
  /// **'Send the payment to this {method} number'**
  String sendPaymentToNumber(String method);

  /// No description provided for @numberCopied.
  ///
  /// In en, this message translates to:
  /// **'Number copied'**
  String get numberCopied;

  /// No description provided for @acceptance24h.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of payment may take up to 24 hours.'**
  String get acceptance24h;

  /// No description provided for @afterSendingFillDetails.
  ///
  /// In en, this message translates to:
  /// **'After sending the money, fill in your details below:'**
  String get afterSendingFillDetails;

  /// No description provided for @fullAccountName.
  ///
  /// In en, this message translates to:
  /// **'Full account name'**
  String get fullAccountName;

  /// No description provided for @nameOnAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Name on your account'**
  String get nameOnAccountHint;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get referenceNumber;

  /// No description provided for @referenceNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Reference number (if found)'**
  String get referenceNumberOptional;

  /// No description provided for @transactionReferenceHint.
  ///
  /// In en, this message translates to:
  /// **'Transaction reference'**
  String get transactionReferenceHint;

  /// No description provided for @submitPayment.
  ///
  /// In en, this message translates to:
  /// **'Submit Payment'**
  String get submitPayment;

  /// No description provided for @choosePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose payment method'**
  String get choosePaymentMethod;

  /// No description provided for @noPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods available.'**
  String get noPaymentMethods;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessful;

  /// No description provided for @membershipNowActive.
  ///
  /// In en, this message translates to:
  /// **'Your membership is now active. Enjoy full access to all features.'**
  String get membershipNowActive;

  /// No description provided for @continueToApp.
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get continueToApp;

  /// No description provided for @couldNotOpenBrowser.
  ///
  /// In en, this message translates to:
  /// **'Could not open the browser for checkout.'**
  String get couldNotOpenBrowser;

  /// No description provided for @completePayment.
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get completePayment;

  /// No description provided for @paymentComplete.
  ///
  /// In en, this message translates to:
  /// **'Payment Complete!'**
  String get paymentComplete;

  /// No description provided for @waitingForPayment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment...'**
  String get waitingForPayment;

  /// No description provided for @openingCheckout.
  ///
  /// In en, this message translates to:
  /// **'Opening checkout...'**
  String get openingCheckout;

  /// No description provided for @membershipActivated.
  ///
  /// In en, this message translates to:
  /// **'Your membership has been activated.'**
  String get membershipActivated;

  /// No description provided for @completePaymentInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment in the browser.\nThis screen will update automatically.'**
  String get completePaymentInBrowser;

  /// No description provided for @openCheckoutAgain.
  ///
  /// In en, this message translates to:
  /// **'Open Checkout Again'**
  String get openCheckoutAgain;

  /// No description provided for @yourCoach.
  ///
  /// In en, this message translates to:
  /// **'Your Coach'**
  String get yourCoach;

  /// No description provided for @couldNotUpdatePaymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not update payment status.'**
  String get couldNotUpdatePaymentStatus;

  /// No description provided for @coachNoWorkoutYet.
  ///
  /// In en, this message translates to:
  /// **'Your coach hasn\'t added a workout program yet.'**
  String get coachNoWorkoutYet;

  /// No description provided for @coachNoMealPlanYet.
  ///
  /// In en, this message translates to:
  /// **'Your coach hasn\'t added a meal plan yet.'**
  String get coachNoMealPlanYet;

  /// No description provided for @currencyEgp.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currencyEgp;

  /// No description provided for @currentPeriodSuffix.
  ///
  /// In en, this message translates to:
  /// **'current'**
  String get currentPeriodSuffix;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and personal data. This action cannot be undone.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account. Please try again.'**
  String get deleteAccountFailed;

  /// No description provided for @pickFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Pick from contacts'**
  String get pickFromContacts;

  /// No description provided for @noPhoneInContact.
  ///
  /// In en, this message translates to:
  /// **'This contact has no phone number.'**
  String get noPhoneInContact;

  /// No description provided for @chooseNumber.
  ///
  /// In en, this message translates to:
  /// **'Choose a number'**
  String get chooseNumber;

  /// No description provided for @couldNotOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp.'**
  String get couldNotOpenWhatsapp;

  /// No description provided for @sendOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Send on WhatsApp'**
  String get sendOnWhatsapp;

  /// No description provided for @whatsappWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Trainee added 🎉'**
  String get whatsappWelcomeTitle;

  /// No description provided for @whatsappWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Send {name} their login details and the app link on WhatsApp?'**
  String whatsappWelcomeBody(String name);

  /// No description provided for @whatsappWelcomeTemplate.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Liaqh, {name}! 🏋️\n\nYour coach created an account for you. Here are your login details:\n\n👤 Username: {username}\n🔑 Password: {password}\n\n📲 Download the app: {link}\n\nLog in and let\'s get started! 💪'**
  String whatsappWelcomeTemplate(
      String name, String username, String password, String link);

  /// No description provided for @rolePlatformOwner.
  ///
  /// In en, this message translates to:
  /// **'Platform Owner'**
  String get rolePlatformOwner;

  /// No description provided for @roleGymAdmin.
  ///
  /// In en, this message translates to:
  /// **'Gym Admin'**
  String get roleGymAdmin;

  /// No description provided for @roleCoach.
  ///
  /// In en, this message translates to:
  /// **'Coach'**
  String get roleCoach;

  /// No description provided for @roleTrainee.
  ///
  /// In en, this message translates to:
  /// **'Trainee'**
  String get roleTrainee;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @paymentApprovedActivated.
  ///
  /// In en, this message translates to:
  /// **'Payment approved — subscription activated.'**
  String get paymentApprovedActivated;

  /// No description provided for @rejectPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject payment?'**
  String get rejectPaymentTitle;

  /// No description provided for @reasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reasonOptional;

  /// No description provided for @noRequestsForStatus.
  ///
  /// In en, this message translates to:
  /// **'No {status} requests.'**
  String noRequestsForStatus(String status);

  /// No description provided for @methodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get methodLabel;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountNameLabel;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get referenceLabel;

  /// No description provided for @submittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submittedLabel;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @editNamed.
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String editNamed(String name);

  /// No description provided for @receiverNumber.
  ///
  /// In en, this message translates to:
  /// **'Receiver number'**
  String get receiverNumber;

  /// No description provided for @instructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Instructions / hint'**
  String get instructionsHint;

  /// No description provided for @couldNotUpdateSetting.
  ///
  /// In en, this message translates to:
  /// **'Could not update setting'**
  String get couldNotUpdateSetting;

  /// No description provided for @requireSystemSubscription.
  ///
  /// In en, this message translates to:
  /// **'Require system subscription'**
  String get requireSystemSubscription;

  /// No description provided for @requireSystemOnDesc.
  ///
  /// In en, this message translates to:
  /// **'Trainees must pay the system subscription AND their coach.'**
  String get requireSystemOnDesc;

  /// No description provided for @requireSystemOffDesc.
  ///
  /// In en, this message translates to:
  /// **'System payment is OFF — trainees only need to pay their coach.'**
  String get requireSystemOffDesc;

  /// No description provided for @manualNeedsApproval.
  ///
  /// In en, this message translates to:
  /// **'Manual · needs approval'**
  String get manualNeedsApproval;

  /// No description provided for @onlinePaddle.
  ///
  /// In en, this message translates to:
  /// **'Online (Paddle)'**
  String get onlinePaddle;

  /// No description provided for @receiverWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Receiver: {number}'**
  String receiverWithNumber(String number);

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTitle;

  /// No description provided for @allUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All users across the platform'**
  String get allUsersSubtitle;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @deleteAccountQ.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountQ;

  /// No description provided for @deleteUserConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes {name}\'s account. They will be logged out and unable to sign in. Historical records are kept. This cannot be undone.'**
  String deleteUserConfirmBody(String name);

  /// No description provided for @userAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get userAccountDeleted;

  /// No description provided for @couldNotDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account'**
  String get couldNotDeleteAccount;

  /// No description provided for @failedToUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status: {error}'**
  String failedToUpdateStatus(String error);

  /// No description provided for @coachProfile.
  ///
  /// In en, this message translates to:
  /// **'Coach Profile'**
  String get coachProfile;

  /// No description provided for @editCoachProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editCoachProfile;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @coachProfileEmpty.
  ///
  /// In en, this message translates to:
  /// **'This coach hasn\'t added profile details yet.'**
  String get coachProfileEmpty;

  /// No description provided for @headlineLabel.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get headlineLabel;

  /// No description provided for @headlineHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Certified Strength & Nutrition Coach'**
  String get headlineHint;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @yearsExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get yearsExperienceLabel;

  /// No description provided for @specialtiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialties'**
  String get specialtiesLabel;

  /// No description provided for @specialtiesHint.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated (e.g. Weight loss, Bodybuilding)'**
  String get specialtiesHint;

  /// No description provided for @instagramLabel.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagramLabel;

  /// No description provided for @whatsappLabel.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get whatsappLabel;

  /// No description provided for @messageOnWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Message on WhatsApp'**
  String get messageOnWhatsapp;

  /// No description provided for @certifications.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certifications;

  /// No description provided for @addCertification.
  ///
  /// In en, this message translates to:
  /// **'Add certification'**
  String get addCertification;

  /// No description provided for @certTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Certification title'**
  String get certTitleLabel;

  /// No description provided for @issuerLabel.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuerLabel;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @transformationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transformations'**
  String get transformationsTitle;

  /// No description provided for @addTransformation.
  ///
  /// In en, this message translates to:
  /// **'Add transformation'**
  String get addTransformation;

  /// No description provided for @beforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get beforeLabel;

  /// No description provided for @afterLabel.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get afterLabel;

  /// No description provided for @captionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get captionLabel;

  /// No description provided for @durationResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration / result'**
  String get durationResultLabel;

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsTitle;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload PDF / document'**
  String get uploadDocument;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @rateYourCoach.
  ///
  /// In en, this message translates to:
  /// **'Rate your coach'**
  String get rateYourCoach;

  /// No description provided for @writeReviewOptional.
  ///
  /// In en, this message translates to:
  /// **'Write a review (optional)'**
  String get writeReviewOptional;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your review'**
  String get yourReview;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSubmitted;

  /// No description provided for @statTrainees.
  ///
  /// In en, this message translates to:
  /// **'Trainees'**
  String get statTrainees;

  /// No description provided for @statTransformations.
  ///
  /// In en, this message translates to:
  /// **'Transformations'**
  String get statTransformations;

  /// No description provided for @statYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get statYears;

  /// No description provided for @statRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get statRating;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @registeredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered {date}'**
  String registeredOn(String date);

  /// No description provided for @nutritionTodayQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did you follow your nutrition today?'**
  String get nutritionTodayQuestion;

  /// No description provided for @followedNutrition.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get followedNutrition;

  /// No description provided for @missedNutrition.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missedNutrition;

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch video'**
  String get watchVideo;

  /// No description provided for @exerciseVideo.
  ///
  /// In en, this message translates to:
  /// **'Exercise video'**
  String get exerciseVideo;

  /// No description provided for @videoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Video URL (YouTube)'**
  String get videoUrlLabel;

  /// No description provided for @uploadVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload video'**
  String get uploadVideo;

  /// No description provided for @videoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Video is too large (max {mb} MB).'**
  String videoTooLarge(int mb);

  /// No description provided for @halfYear.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get halfYear;

  /// No description provided for @restDayHint.
  ///
  /// In en, this message translates to:
  /// **'Break day — no workout'**
  String get restDayHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
