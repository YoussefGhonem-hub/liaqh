// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gym Management';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get heyThere => 'Hey there,';

  @override
  String get createAccount => 'Create an Account';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get noAccount => 'Don\'t have an account yet? ';

  @override
  String get alreadyAccount => 'Already have an account? ';

  @override
  String get termsText =>
      'By continuing you accept our Privacy Policy and Term of Use';

  @override
  String get gymId => 'Gym ID (provided by gym owner)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get seeMore => 'See More';

  @override
  String get optional => 'Optional';

  @override
  String get required => 'Required';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get done => 'Done';

  @override
  String get share => 'Share';

  @override
  String get or => 'Or';

  @override
  String get signIn => 'Sign In';

  @override
  String get getStarted => 'Get Started';

  @override
  String get myTrainees => 'My Trainees';

  @override
  String get addTrainee => 'Add Trainee';

  @override
  String get noTraineesYet => 'No trainees yet';

  @override
  String get noTraineesHint => 'Tap + to add your first trainee';

  @override
  String get goal => 'Goal';

  @override
  String get cut => 'Cut';

  @override
  String get bulk => 'Bulk';

  @override
  String get maintain => 'Maintain';

  @override
  String get recomp => 'Recomp';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get weightKg => 'Current Weight (kg)';

  @override
  String get tempPassword => 'Temporary Password';

  @override
  String get score => 'Score';

  @override
  String get trainees => 'Trainees';

  @override
  String get traineeAdded => 'Trainee added successfully';

  @override
  String get profile => 'Profile';

  @override
  String get home => 'Home';

  @override
  String get activity => 'Activity';

  @override
  String get membership => 'Membership';

  @override
  String get inBody => 'InBody';

  @override
  String get workout => 'Workout';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get onTrack => 'On Track';

  @override
  String get atRisk => 'At Risk';

  @override
  String get offTrack => 'Off Track';

  @override
  String get errorInvalidCredentials => 'Invalid credentials or data.';

  @override
  String get errorConnection => 'Cannot connect to server. Check your network.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorAcceptTerms => 'Please accept the terms to continue.';

  @override
  String get errorRequired => 'This field is required.';

  @override
  String get errorInvalidEmail => 'Enter a valid email.';

  @override
  String get errorMinPassword => 'Password must be at least 6 characters.';

  @override
  String get errorInvalidWeight => 'Enter a valid weight.';

  @override
  String get errorInvalidMuscle => 'Enter a valid muscle mass.';

  @override
  String get errorBodyFatRange => 'Body fat % must be 0–100.';

  @override
  String get inBodyHistory => 'InBody History';

  @override
  String get addInBody => 'Add InBody Measurement';

  @override
  String get addMeasurement => 'Add Measurement';

  @override
  String get bodyScore => 'Body Score';

  @override
  String get weight => 'Weight';

  @override
  String get muscleMass => 'Muscle Mass';

  @override
  String get bodyFat => 'Body Fat %';

  @override
  String get bodyWater => 'Body Water %';

  @override
  String get visceralFat => 'Visceral Fat Level';

  @override
  String get bmr => 'BMR (kcal)';

  @override
  String get coachNotes => 'Coach Notes (optional)';

  @override
  String get latestMeasurement => 'Latest Measurement';

  @override
  String get allMeasurements => 'All Measurements';

  @override
  String get noMeasurementsYet => 'No measurements yet';

  @override
  String get noMeasurementsHint => 'Add the first InBody measurement';

  @override
  String get progress => 'Progress';

  @override
  String get scans => 'Attachments';

  @override
  String get addScans => 'Add Attachments';

  @override
  String get noScansAdded => 'No attachments added yet';

  @override
  String get scansHint =>
      'Attach images, PDF or documents of the InBody result';

  @override
  String get saveMeasurement => 'Save Measurement';

  @override
  String get fillForm => 'Fill Form';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get pending => 'Pending';

  @override
  String get uploading => 'Uploading...';

  @override
  String get manage => 'Manage';

  @override
  String scanCount(int count) {
    return '$count attachment(s)';
  }

  @override
  String get workoutPrograms => 'Workout Programs';

  @override
  String get createProgram => 'Create Program';

  @override
  String newProgram(String name) {
    return 'New Program — $name';
  }

  @override
  String get programName => 'Program Name';

  @override
  String get programNameHint => 'e.g. \"Cut Phase Week 1\"';

  @override
  String get programNameRequired => 'Program name is required.';

  @override
  String get duration => 'Duration';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get quarter => 'Quarter';

  @override
  String get startDate => 'Start Date';

  @override
  String get notes => 'Notes';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get createAndAddDays => 'Create & Add Days →';

  @override
  String dayNumber(int number) {
    return 'Day $number';
  }

  @override
  String get dayName => 'Day Name';

  @override
  String get dayNameHint => 'e.g. Push Day, Chest & Triceps';

  @override
  String get dayNameRequired => 'Day name is required.';

  @override
  String get muscleFocus => 'Muscle Focus';

  @override
  String get exercises => 'Exercises';

  @override
  String get noExercisesYet =>
      'No exercises yet. Tap \"Add\" to pick from library.';

  @override
  String get saveDayAddAnother => 'Save Day & Add Another';

  @override
  String finishDays(int count) {
    return 'Finish — $count day(s) saved';
  }

  @override
  String get saveAtLeastOneDay => 'Save at least one day before finishing.';

  @override
  String get addAtLeastOneExercise => 'Add at least one exercise.';

  @override
  String programCreated(String name, int count) {
    return 'Program \"$name\" created with $count day(s)!';
  }

  @override
  String get sets => 'Sets';

  @override
  String get reps => 'Reps';

  @override
  String get restSeconds => 'Rest (s)';

  @override
  String get weightKgOpt => 'Weight kg (opt)';

  @override
  String daysSaved(int count, String days) {
    return '$count day(s) saved: $days';
  }

  @override
  String get exerciseLibrary => 'Exercise Library';

  @override
  String get selectExercise => 'Select Exercise';

  @override
  String get searchExercises => 'Search exercises…';

  @override
  String get noExercisesFound => 'No exercises found';

  @override
  String get addCustom => 'Add Custom';

  @override
  String get custom => 'Custom';

  @override
  String get addCustomExercise => 'Add Custom Exercise';

  @override
  String get exerciseNameEn => 'Exercise Name (English) *';

  @override
  String get exerciseNameAr => 'اسم التمرين (عربي)';

  @override
  String get exerciseNameRequired => 'Exercise name (English) is required.';

  @override
  String get equipment => 'Equipment';

  @override
  String get equipmentHint => 'e.g. Barbell, Dumbbell';

  @override
  String get descriptionOptional => 'Description / instructions (optional)';

  @override
  String get videoUrl => 'Video URL (optional)';

  @override
  String get exerciseAdded => 'Exercise added';

  @override
  String get saveExercise => 'Save Exercise';

  @override
  String get addExercisePhoto => 'Add exercise photo (optional)';

  @override
  String get workoutHistory => 'Workout History';

  @override
  String get noWorkoutsLogged => 'No workouts logged yet';

  @override
  String effort(int effort) {
    return 'Effort $effort/10';
  }

  @override
  String get prescribedWeights => 'Prescribed weights';

  @override
  String get modifiedWeights => 'Modified weights';

  @override
  String get noSetDetails => 'No set details recorded.';

  @override
  String get usedPrescribedWeights => 'Used prescribed weights?';

  @override
  String get overallEffort => 'Overall Effort';

  @override
  String get sessionNotes => 'Session notes (optional)';

  @override
  String get logAtLeastOneSet => 'Log at least one set before saving.';

  @override
  String get confirmWorkoutCompleted => 'Confirm Workout Completed';

  @override
  String rest(int seconds) {
    return 'Rest: ${seconds}s';
  }

  @override
  String get skip => 'Skip';

  @override
  String get mealPlans => 'Meal Plans';

  @override
  String get createMealPlan => 'Create Meal Plan';

  @override
  String newMealPlan(String name) {
    return 'New Meal Plan — $name';
  }

  @override
  String get planName => 'Plan Name';

  @override
  String get planNameHint => 'e.g. \"Cut Phase Week 1\"';

  @override
  String get planNameRequired => 'Plan name is required.';

  @override
  String get weekStartDate => 'Week Start Date';

  @override
  String get dailyMacroTargets => 'Daily Macro Targets';

  @override
  String get calories => 'Calories';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get protein => 'Protein';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get carbs => 'Carbs';

  @override
  String get carbsG => 'Carbs (g)';

  @override
  String get fat => 'Fat';

  @override
  String get fatG => 'Fat (g)';

  @override
  String get suggestedTargets => 'Suggested Targets (Reference)';

  @override
  String get createPlanAndBuild => 'Create Plan & Build →';

  @override
  String get viewPlan => 'View Plan';

  @override
  String get shoppingList => 'Shopping List';

  @override
  String get noMealPlanLoaded => 'No plan loaded';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get mealRemoved => 'Meal removed';

  @override
  String addMealTitle(String name) {
    return 'Add Meal — $name';
  }

  @override
  String get mealType => 'Meal Type';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get midMorning => 'Mid Morning';

  @override
  String get lunch => 'Lunch';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get dinner => 'Dinner';

  @override
  String get preWorkout => 'Pre Workout';

  @override
  String get postWorkout => 'Post Workout';

  @override
  String get time => 'Time';

  @override
  String get foodItems => 'Food Items';

  @override
  String get addFood => 'Add Food';

  @override
  String get noFoodsAdded => 'No foods added yet. Tap \"Add Food\" to begin.';

  @override
  String get addAtLeastOneFood => 'Add at least one food item.';

  @override
  String get saveMeal => 'Save Meal';

  @override
  String get foodLibrary => 'Food Library';

  @override
  String get selectFood => 'Select Food';

  @override
  String get searchFoods => 'Search foods…';

  @override
  String get noFoodsFound => 'No foods found';

  @override
  String get howManyGrams => 'How many grams?';

  @override
  String get grams => 'Grams';

  @override
  String get noMealsToday => 'No meals for this day';

  @override
  String get log => 'Log';

  @override
  String logMeal(String meal) {
    return 'Log: $meal';
  }

  @override
  String get completed => 'Completed ✅';

  @override
  String get completedHint => 'I ate this meal fully';

  @override
  String get skipped => 'Skipped ❌';

  @override
  String get skippedHint => 'I did not eat this meal';

  @override
  String get partial => 'Partial 🔄';

  @override
  String get partialHint => 'I ate part of this meal';

  @override
  String mealLoggedAs(String status) {
    return 'Meal logged as $status';
  }

  @override
  String get failedToLog => 'Failed to log meal';

  @override
  String get noShoppingItems => 'No items';

  @override
  String get shoppingListHint =>
      'Build your meal plan to generate a shopping list.';

  @override
  String get totalEstimatedPrice => 'Total Estimated Price';

  @override
  String get shareComingSoon => 'Share coming soon';

  @override
  String get subscribeToPlan => 'Subscribe to Plan';

  @override
  String get selectPlan => 'Select Plan';

  @override
  String get noPlansAvailable => 'No plans available for this gym.';

  @override
  String get autoRenew => 'Auto-renew';

  @override
  String get selectPlanFirst => 'Please select a plan.';

  @override
  String get confirmSubscription => 'Confirm Subscription';

  @override
  String planDuration(int days, String cycle) {
    return '$days days · $cycle';
  }

  @override
  String get accountType => 'Account Type';

  @override
  String get chooseAccountType => 'Choose your account type to continue.';

  @override
  String get individualCoach => 'Individual Coach';

  @override
  String get individualCoachDesc =>
      'Manage your own trainees directly.\nNo gym setup needed.';

  @override
  String get gym => 'Gym';

  @override
  String get gymDesc =>
      'Create a gym, add multiple coaches,\neach with their own trainees.';

  @override
  String get gymDetails => 'Gym Details';

  @override
  String get adminAccount => 'Admin Account';

  @override
  String get gymNameHint => 'Gym name e.g. FitZone Cairo';

  @override
  String get gymNameRequired => 'Gym name is required.';

  @override
  String get adminAccountDesc => 'This will be your login to manage the gym.';

  @override
  String get createGym => 'Create Gym';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get personalGymNote => 'A personal gym will be set up automatically.';

  @override
  String get gymLogo => 'Gym Logo';

  @override
  String get gymLogoDesc => 'Optional — shown on trainee dashboard';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get points => 'Points';

  @override
  String get streak => 'Streak';

  @override
  String get onBoardingTitle1 => 'Track Your Goal';

  @override
  String get onBoardingDesc1 =>
      'Don\'t worry if you have trouble determining your goals, We can help you determine your goals and track your goals';

  @override
  String get onBoardingTitle2 => 'Get Burn';

  @override
  String get onBoardingDesc2 =>
      'Let\'s keep burning, to achieve your goals, it hurts only temporarily, if you give up now you will be in pain forever';

  @override
  String get onBoardingTitle3 => 'Eat Well';

  @override
  String get onBoardingDesc3 =>
      'Let\'s start a healthy lifestyle with us, we can determine your diet every day. healthy eating is fun';

  @override
  String get onBoardingTitle4 => 'Improve Sleep Quality';

  @override
  String get onBoardingDesc4 =>
      'Improve the quality of your sleep with us, good quality sleep can bring a good mood in the morning';

  @override
  String get welcomeCoach => 'Welcome Back, Coach';

  @override
  String get bmi => 'BMI (Body Mass Index)';

  @override
  String get normalWeight => 'You have a normal weight';

  @override
  String get todayTarget => 'Today Target';

  @override
  String get activityStatus => 'Activity Status';

  @override
  String get workoutProgress => 'Workout Progress';

  @override
  String get latestWorkout => 'Latest Workout';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get heartRate => 'Heart Rate';

  @override
  String get waterIntake => 'Water Intake';

  @override
  String get sleep => 'Sleep';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get account => 'Account';

  @override
  String get personalData => 'Personal Data';

  @override
  String get achievement => 'Achievement';

  @override
  String get activityHistory => 'Activity History';

  @override
  String get workoutProgressTitle => 'Workout Progress';

  @override
  String get notification => 'Notification';

  @override
  String get popupNotification => 'Pop-up Notification';

  @override
  String get other => 'Other';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get setting => 'Setting';

  @override
  String get height => 'Height';

  @override
  String get age => 'Age';

  @override
  String get dietaryRestrictions => 'Dietary Restrictions';

  @override
  String get medicalNotes => 'Medical Notes';

  @override
  String get personalDataTitle => 'Personal Data';

  @override
  String get fullName => 'Full Name';

  @override
  String get role => 'Role';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get gymIdLabel => 'Gym ID';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get noAchievementsYet => 'No achievements yet';

  @override
  String get noAchievementsHint => 'Keep training to earn badges!';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get days => 'days';

  @override
  String get badges => 'Badges';

  @override
  String get activityHistoryTitle => 'Activity History';

  @override
  String get noActivityYet => 'No activity recorded yet';

  @override
  String get noActivityHint => 'Your workout and meal logs will appear here.';

  @override
  String get workoutsCompleted => 'Workouts Completed';

  @override
  String get mealsLogged => 'Meals Logged';

  @override
  String get inBodyScans => 'InBody Scans';

  @override
  String get workoutProgressTitle2 => 'Workout Progress';

  @override
  String get noProgressYet => 'No workout data yet';

  @override
  String get noProgressHint => 'Complete workouts to see your progress charts.';

  @override
  String get totalWorkouts => 'Total Workouts';

  @override
  String get avgEffort => 'Avg. Effort';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get contactUsTitle => 'Contact Us';

  @override
  String get contactEmail => 'Email Support';

  @override
  String get contactPhone => 'Phone Support';

  @override
  String get contactWhatsApp => 'WhatsApp';

  @override
  String get contactHours => 'Working Hours';

  @override
  String get contactHoursValue => 'Sun–Thu, 9 AM – 6 PM';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appLanguage => 'App Language';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get appVersion => 'App Version';

  @override
  String get version => 'Version 1.0.0';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get noMembershipsYet => 'No memberships yet.';

  @override
  String get perPlan => '/ plan';

  @override
  String get expiringWarning => '⚠ Expiring within 7 days';

  @override
  String get renew => 'Renew';

  @override
  String get freeze => 'Freeze';

  @override
  String get unfreeze => 'Unfreeze';

  @override
  String get noInBodyYet => 'No InBody measurements yet';

  @override
  String get latestBodyScore => 'Latest Body Score';

  @override
  String get viewAll => 'View All';

  @override
  String get recentMeasurements => 'Recent Measurements';

  @override
  String get historyLabel => 'History';

  @override
  String get noActiveProgram => 'No active program';

  @override
  String get createWorkoutHint => 'Create a workout program for this trainee';

  @override
  String get daysLabel => 'Days';

  @override
  String get logLabel => 'Log';

  @override
  String get more => 'more';

  @override
  String get newProgramLabel => 'New Program';

  @override
  String get createPlan => 'Create Plan';

  @override
  String get newPlan => 'New Plan';

  @override
  String get shop => 'Shop';

  @override
  String get noActiveMealPlan => 'No active meal plan';

  @override
  String get createNutritionHint => 'Create a nutrition plan for this trainee';

  @override
  String get thisWeek => 'This Week';

  @override
  String get traineeView => 'Trainee View';

  @override
  String get noMeals => 'No meals';

  @override
  String get chatMessages => 'Messages';

  @override
  String get chatNoConversations => 'No conversations yet';

  @override
  String get chatNoConversationsHint =>
      'Messages with your coach or trainees will appear here.';

  @override
  String get chatNoMessages => 'No messages yet';

  @override
  String get chatSayHi => 'Say hi! 👋';

  @override
  String get chatTypeMessage => 'Type a message…';

  @override
  String get chatTrainee => 'Trainee';

  @override
  String get chatCoach => 'Coach';

  @override
  String get chatToday => 'Today';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get chatAttachReference => 'Attach a reference';

  @override
  String get chatReferenceInBody => 'InBody Result';

  @override
  String get chatReferenceWorkout => 'Workout Plan';

  @override
  String get chatReferenceMeal => 'Meal Plan';

  @override
  String get chatReferencing => 'Referencing';

  @override
  String get chatRemoveReference => 'Remove reference';

  @override
  String get progressBody => 'Progress Body';

  @override
  String get progressTimeline => 'Progress Timeline';

  @override
  String get noProgressEntries => 'No progress entries yet';

  @override
  String get noProgressEntriesHint =>
      'Add photos and notes to track your body changes over time.';

  @override
  String get addProgressEntry => 'Add Progress Entry';

  @override
  String get progressPhotos => 'Progress Photos';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get progressNotes => 'Notes';

  @override
  String get progressNotesHint =>
      'How are you feeling? Any changes you noticed?';

  @override
  String get saveProgress => 'Save Entry';

  @override
  String get progressSaved => 'Progress entry saved';

  @override
  String get addPhotoOrNote => 'Add at least one photo or a note.';

  @override
  String get deleteEntry => 'Delete entry';

  @override
  String get deleteEntryConfirm => 'Delete this progress entry?';

  @override
  String photosCount(int count) {
    return '$count photo(s)';
  }

  @override
  String get coachComments => 'Coach Comments';

  @override
  String get addComment => 'Add Comment';

  @override
  String get commentHint => 'Add a note or tip for this exercise…';

  @override
  String get noComments => 'No comments yet';

  @override
  String get commentAdded => 'Comment added';

  @override
  String get deleteComment => 'Delete comment';

  @override
  String get totalTraineesLabel => 'Total';

  @override
  String get traineesNeedAttention => 'Trainees Need Attention';

  @override
  String get expiringMemberships => 'Expiring Memberships';

  @override
  String get allTraineesOnTrack => 'All Trainees On Track 🎉';

  @override
  String get allTraineesOnTrackHint =>
      'Everyone is following their plan. Great work!';

  @override
  String get keepItUp => 'Keep It Up! 💪';

  @override
  String get keepItUpHint =>
      'Check your plan and stay consistent with your workouts and meals.';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get myWorkout => 'My Workout';

  @override
  String get myMeals => 'My Meals';

  @override
  String get drawerNavigation => 'Navigation';

  @override
  String get drawerCoachActions => 'Coach Actions';

  @override
  String get drawerAdmin => 'Admin';

  @override
  String get drawerGeneral => 'General';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get navMessages => 'Messages';

  @override
  String get navMyTrainees => 'My Trainees';

  @override
  String get navAddNewTrainee => 'Add New Trainee';

  @override
  String get navReports => 'Reports & Analytics';

  @override
  String get navManageStaff => 'Manage Staff';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get languageToggle => 'العربية / English';

  @override
  String get navSettings => 'Settings';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutTitle => 'Log Out?';

  @override
  String get logOutMessage => 'Are you sure you want to log out?';

  @override
  String get dashGymDashboard => 'Gym Dashboard';

  @override
  String dashWelcomeUser(String name) {
    return 'Welcome, $name 👋';
  }

  @override
  String get dashCoaches => 'Coaches';

  @override
  String get dashTrainees => 'Trainees';

  @override
  String get dashActiveMembers => 'Active members';

  @override
  String get dashMonthlyRevenue => 'Monthly revenue';

  @override
  String get dashExpiringThisWeek => 'Expiring this week';

  @override
  String get dashNewThisMonth => 'New this month';

  @override
  String dashUnpaidTraineesAlert(int count) {
    return '$count trainee(s) have not paid the current period.';
  }

  @override
  String get dashPlatform => 'Platform';

  @override
  String get dashPlatformSubtitle => 'Overview of all gyms & activity';

  @override
  String get dashPayments => 'Payments';

  @override
  String get dashPaymentRequests => 'Payment Requests';

  @override
  String get dashPaymentRequestsSubtitle => 'Review & approve manual payments';

  @override
  String get dashPaymentMethods => 'Payment Methods';

  @override
  String get dashPaymentMethodsSubtitle =>
      'Activate / deactivate & edit methods';

  @override
  String get dashRevenueLastMonths => 'Revenue (last months)';

  @override
  String get dashGrowth => 'Growth';

  @override
  String get dashTotalGyms => 'Total Gyms';

  @override
  String dashGymsActiveInactive(int active, int inactive) {
    return '$active active · $inactive inactive';
  }

  @override
  String get dashTotalRevenue => 'Total Revenue';

  @override
  String dashThisMonthAmount(String amount) {
    return 'This month $amount';
  }

  @override
  String dashPlusThisMonth(int count) {
    return '+$count this month';
  }

  @override
  String dashAdminsCount(int count) {
    return '$count admins';
  }

  @override
  String get dashInBodyRecords => 'InBody Records';

  @override
  String get dashWorkoutSessions => 'Workout Sessions';

  @override
  String get dashMealPlans => 'Meal Plans';

  @override
  String get dashNewGyms => 'New Gyms';

  @override
  String get dashThisMonth => 'this month';

  @override
  String get dashNoRevenueData => 'No revenue data yet';

  @override
  String get dashNoGrowthData => 'No growth data yet';

  @override
  String get dashWorkouts => 'Workouts';

  @override
  String get dashRevenue => 'Revenue';

  @override
  String get tabMore => 'More';

  @override
  String get tabAlerts => 'Alerts';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabRequests => 'Requests';

  @override
  String get tabSupport => 'Support';

  @override
  String get membershipPaymentDue => 'Membership payment due';

  @override
  String get payCoachUnlockMessage =>
      'Please pay your coach to unlock your workouts, meal plans, InBody and progress tracking. Message your coach to arrange payment.';

  @override
  String get messageCoach => 'Message Coach';

  @override
  String get maybeLater => 'Maybe later';

  @override
  String get drawerMySubscription => 'My Subscription';

  @override
  String get drawerOverview => 'Overview';

  @override
  String get drawerManageGyms => 'Manage Gyms';

  @override
  String get drawerAllUsers => 'All Users';

  @override
  String get drawerAllCoaches => 'All Coaches';

  @override
  String get drawerSendAnnouncement => 'Send Announcement';

  @override
  String get addCoach => 'Add coach';

  @override
  String get searchCoaches => 'Search coaches…';

  @override
  String get noCoachesYet => 'No coaches yet.';

  @override
  String get traineesLower => 'trainees';

  @override
  String get noOtherCoachToReassign => 'No other coach to reassign to.';

  @override
  String reassignTraineeTo(String name) {
    return 'Reassign $name to…';
  }

  @override
  String reassignedToName(String name) {
    return 'Reassigned to $name.';
  }

  @override
  String get failedGeneric => 'Failed.';

  @override
  String get noTraineesUnderCoach => 'No trainees under this coach yet.';

  @override
  String get openDetails => 'Open details';

  @override
  String get reassignCoach => 'Reassign coach';

  @override
  String get coachCreated => 'Coach created.';

  @override
  String get failedToCreateCoach => 'Failed to create coach.';

  @override
  String get newCoach => 'New Coach';

  @override
  String get createCoach => 'Create Coach';

  @override
  String get firstNameField => 'First name';

  @override
  String get lastNameField => 'Last name';

  @override
  String get tempPasswordField => 'Temporary password';

  @override
  String get phoneOptionalField => 'Phone (optional)';

  @override
  String get bioOptionalField => 'Bio (optional)';

  @override
  String get heightCmField => 'Height (cm)';

  @override
  String get weightKgField => 'Weight (kg)';

  @override
  String get invalid => 'Invalid';

  @override
  String get traineeCreatedAndAssigned => 'Trainee created and assigned.';

  @override
  String get failedToCreateTrainee => 'Failed to create trainee.';

  @override
  String get newTrainee => 'New Trainee';

  @override
  String assignedToCoach(String name) {
    return 'Assigned to coach: $name';
  }

  @override
  String get createTrainee => 'Create Trainee';

  @override
  String get unpaidTrainees => 'Unpaid Trainees';

  @override
  String get everyonePaid => 'Everyone has paid 🎉';

  @override
  String get unpaid => 'Unpaid';

  @override
  String coachWithName(String name) {
    return 'Coach: $name';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get notificationEmptyHint =>
      'Chat messages and updates will appear here';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get changePassword => 'Change Password';

  @override
  String get updateAccountPassword => 'Update your account password';

  @override
  String get appearance => 'Appearance';

  @override
  String get settingOn => 'On';

  @override
  String get settingOff => 'Off';

  @override
  String get receiveWorkoutReminders => 'Receive workout reminders';

  @override
  String get submitSupportTicket => 'Submit a support ticket';

  @override
  String get workoutTemplates => 'Workout Templates';

  @override
  String get workoutTemplatesHint =>
      'Build a workout once — from the exercise library or by uploading a file — then assign it to any trainee in one tap. No more rebuilding the same plan for everyone.';

  @override
  String get newTemplate => 'New template';

  @override
  String get assignFromTemplate => 'Assign from a template';
}
