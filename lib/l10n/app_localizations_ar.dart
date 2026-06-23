// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إدارة الجيم';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get heyThere => 'أهلاً،';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'تسجيل';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو الهاتف';

  @override
  String get invalidCredentials => 'اسم المستخدم أو كلمة المرور غير صحيحة';

  @override
  String get phoneRequiredField => 'رقم الهاتف';

  @override
  String get phoneRequiredError => 'رقم الهاتف مطلوب';

  @override
  String get phoneInvalidError => 'أدخل رقم هاتف صحيح';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get alreadyAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get termsText =>
      'بالمتابعة أنت توافق على سياسة الخصوصية وشروط الاستخدام';

  @override
  String get gymId => 'معرّف الجيم (يوفره مالك الجيم)';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get add => 'إضافة';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get message => 'مراسلة';

  @override
  String get deleteProgramTitle => 'حذف البرنامج؟';

  @override
  String deleteProgramConfirm(String name) {
    return 'سيؤدي هذا إلى حذف \"$name\" وكل أيامه وتمارينه نهائيًا.';
  }

  @override
  String get programDeleted => 'تم حذف البرنامج.';

  @override
  String get dailyLog => 'السجل اليومي';

  @override
  String get thisWeekLabel => 'هذا الأسبوع';

  @override
  String get didYouWorkoutToday => 'هل تمرّنت اليوم؟';

  @override
  String get workedOut => 'تمرّنت';

  @override
  String get restDay => 'يوم راحة';

  @override
  String get loggedWorkedOut => 'تم ✅';

  @override
  String get loggedRest => 'راحة';

  @override
  String get notLoggedYet => 'لم يُسجّل';

  @override
  String get logHistory => 'السجل';

  @override
  String get noLogsYet => 'لا توجد تسجيلات بعد.';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get analyticsTitle => 'التحليلات';

  @override
  String get activeTraineesLabel => 'نشِط';

  @override
  String get retentionLabel => 'الاحتفاظ';

  @override
  String get newThisMonthLabel => 'جديد هذا الشهر';

  @override
  String get revenueThisMonthLabel => 'الإيراد (الشهر)';

  @override
  String get workoutsThisWeekLabel => 'تمارين (الأسبوع)';

  @override
  String get needsAttention => 'يحتاج متابعة';

  @override
  String get needsAttentionSub => 'متدربون قد يحتاجون تحفيزًا';

  @override
  String get everyoneOnTrack => 'الجميع على المسار 🎉';

  @override
  String get leaderboard => 'لوحة المتصدّرين';

  @override
  String get byStreak => 'التتابع';

  @override
  String get byMonth => 'هذا الشهر';

  @override
  String get broadcast => 'إرسال جماعي';

  @override
  String get broadcastSub => 'راسل كل متدربيك دفعة واحدة';

  @override
  String get broadcastTitleHint => 'العنوان (اختياري)';

  @override
  String get broadcastBodyHint => 'اكتب رسالتك…';

  @override
  String get send => 'إرسال';

  @override
  String broadcastSent(int count) {
    return 'تم الإرسال إلى $count متدرب.';
  }

  @override
  String get flagNoPlan => 'لا توجد خطة';

  @override
  String get flagInactive => 'غير نشط';

  @override
  String flagInactiveDays(int days) {
    return 'غير نشط $days يوم';
  }

  @override
  String get flagRejectedMeal => 'رفض وجبة';

  @override
  String get flagExpiring => 'الاشتراك ينتهي قريبًا';

  @override
  String get dayStreak => 'أيام متتابعة';

  @override
  String get bestStreak => 'أفضل سلسلة';

  @override
  String get totalWorkouts => 'إجمالي التمارين';

  @override
  String get weeklyGoalLabel => 'الهدف الأسبوعي';

  @override
  String get setWeeklyGoal => 'تحديد الهدف الأسبوعي';

  @override
  String daysPerWeek(int n) {
    return '$n أيام / أسبوع';
  }

  @override
  String streakMilestone(int days) {
    return '🔥 $days أيام متتابعة!';
  }

  @override
  String get weeklyGoalReached => 'تحقق الهدف الأسبوعي! 🎉';

  @override
  String get badge7 => 'تتابع ٧ أيام';

  @override
  String get badge30 => 'تتابع ٣٠ يومًا';

  @override
  String get badge100 => 'تتابع ١٠٠ يوم';

  @override
  String get badgeTotal10 => '١٠ تمارين';

  @override
  String get badgeTotal50 => '٥٠ تمرينًا';

  @override
  String get badgeTotal100 => '١٠٠ تمرين';

  @override
  String get workoutReminder => 'تذكير التمرين';

  @override
  String get workoutReminderHint => 'احصل على إشعار يومي للذهاب إلى النادي';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get setTime => 'تحديد الوقت';

  @override
  String reminderSetFor(String time) {
    return 'سيتم تذكيرك يوميًا الساعة $time';
  }

  @override
  String get reply => 'رد';

  @override
  String get typing => 'يكتب…';

  @override
  String get restTimer => 'مؤقّت الراحة';

  @override
  String get customSeconds => 'ثوانٍ مخصصة';

  @override
  String get customLabel => 'مخصص';

  @override
  String get reset => 'إعادة';

  @override
  String get pause => 'إيقاف';

  @override
  String get start => 'بدء';

  @override
  String get chatYou => 'أنت';

  @override
  String get editMessage => 'تعديل الرسالة';

  @override
  String get deleteMessage => 'حذف الرسالة';

  @override
  String get deleteMessageConfirm => 'سيتم حذف هذه الرسالة للجميع.';

  @override
  String get edited => 'تم التعديل';

  @override
  String get ok => 'موافق';

  @override
  String get next => 'التالي';

  @override
  String get back => 'رجوع';

  @override
  String get seeMore => 'عرض المزيد';

  @override
  String get optional => 'اختياري';

  @override
  String get required => 'مطلوب';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get search => 'بحث';

  @override
  String get done => 'تم';

  @override
  String get share => 'مشاركة';

  @override
  String get or => 'أو';

  @override
  String get signIn => 'دخول';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get myTrainees => 'متدرّبوني';

  @override
  String get addTrainee => 'إضافة متدرّب';

  @override
  String get noTraineesYet => 'لا يوجد متدرّبون بعد';

  @override
  String get noTraineesHint => 'اضغط + لإضافة أول متدرّب';

  @override
  String get goal => 'الهدف';

  @override
  String get cut => 'تخفيف';

  @override
  String get bulk => 'تضخيم';

  @override
  String get maintain => 'حافظ';

  @override
  String get recomp => 'إعادة تكوين';

  @override
  String get heightCm => 'الطول (سم)';

  @override
  String get weightKg => 'الوزن الحالي (كجم)';

  @override
  String get tempPassword => 'كلمة مرور مؤقتة';

  @override
  String get score => 'النقاط';

  @override
  String get trainees => 'المتدرّبون';

  @override
  String get traineeAdded => 'تمت إضافة المتدرّب بنجاح';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get home => 'الرئيسية';

  @override
  String get activity => 'النشاط';

  @override
  String get membership => 'الاشتراك';

  @override
  String get inBody => 'قياس الجسم';

  @override
  String get workout => 'التمرين';

  @override
  String get nutrition => 'التغذية';

  @override
  String get onTrack => 'على المسار';

  @override
  String get atRisk => 'في خطر';

  @override
  String get offTrack => 'خارج المسار';

  @override
  String get errorInvalidCredentials => 'بيانات الدخول غير صحيحة.';

  @override
  String get errorConnection => 'تعذّر الاتصال بالخادم. تحقق من الشبكة.';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorAcceptTerms => 'يرجى الموافقة على الشروط للمتابعة.';

  @override
  String get errorRequired => 'هذا الحقل مطلوب.';

  @override
  String get errorInvalidEmail => 'أدخل بريداً إلكترونياً صحيحاً.';

  @override
  String get errorMinPassword => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل.';

  @override
  String get errorInvalidWeight => 'أدخل وزناً صحيحاً.';

  @override
  String get errorInvalidMuscle => 'أدخل كتلة عضلية صحيحة.';

  @override
  String get errorBodyFatRange => 'نسبة الدهون يجب أن تكون بين 0 و100.';

  @override
  String get inBodyHistory => 'سجل قياس الجسم';

  @override
  String get addInBody => 'إضافة قياس جسم';

  @override
  String get addMeasurement => 'إضافة قياس';

  @override
  String get bodyScore => 'نقاط الجسم';

  @override
  String get weight => 'الوزن';

  @override
  String get muscleMass => 'كتلة العضلات';

  @override
  String get bodyFat => 'نسبة الدهون %';

  @override
  String get bodyWater => 'نسبة الماء %';

  @override
  String get visceralFat => 'مستوى الدهون الحشوية';

  @override
  String get bmr => 'معدل الأيض الأساسي (سعرة)';

  @override
  String get coachNotes => 'ملاحظات المدرّب (اختياري)';

  @override
  String get latestMeasurement => 'آخر قياس';

  @override
  String get allMeasurements => 'جميع القياسات';

  @override
  String get noMeasurementsYet => 'لا توجد قياسات بعد';

  @override
  String get noMeasurementsHint => 'أضف أول قياس InBody';

  @override
  String get progress => 'التقدّم';

  @override
  String get scans => 'المرفقات';

  @override
  String get addScans => 'إضافة مرفقات';

  @override
  String get noScansAdded => 'لا توجد مرفقات بعد';

  @override
  String get scansHint => 'أرفق صوراً أو PDF أو مستندات لنتيجة InBody';

  @override
  String get saveMeasurement => 'حفظ القياس';

  @override
  String get fillForm => 'ملء النموذج';

  @override
  String get uploaded => 'تم الرفع';

  @override
  String get pending => 'في الانتظار';

  @override
  String get uploading => 'جارٍ الرفع...';

  @override
  String get manage => 'إدارة';

  @override
  String scanCount(int count) {
    return '$count مرفق';
  }

  @override
  String get workoutPrograms => 'برامج التمرين';

  @override
  String get createProgram => 'إنشاء برنامج';

  @override
  String newProgram(String name) {
    return 'برنامج جديد — $name';
  }

  @override
  String get programName => 'اسم البرنامج';

  @override
  String get programNameHint => 'مثال: \"مرحلة التخفيف - الأسبوع الأول\"';

  @override
  String get programNameRequired => 'اسم البرنامج مطلوب.';

  @override
  String get duration => 'المدة';

  @override
  String get week => 'أسبوع';

  @override
  String get month => 'شهر';

  @override
  String get quarter => 'ربع سنة';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get notes => 'ملاحظات';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get createAndAddDays => 'إنشاء وإضافة الأيام ←';

  @override
  String dayNumber(int number) {
    return 'اليوم $number';
  }

  @override
  String get dayName => 'اسم اليوم';

  @override
  String get dayNameHint => 'مثال: يوم الدفع، الصدر والترايسبس';

  @override
  String get dayNameRequired => 'اسم اليوم مطلوب.';

  @override
  String get muscleFocus => 'العضلات المستهدفة';

  @override
  String get exercises => 'التمارين';

  @override
  String get noExercisesYet => 'لا توجد تمارين. اضغط \"إضافة\" للاختيار.';

  @override
  String get saveDayAddAnother => 'حفظ اليوم وإضافة يوم آخر';

  @override
  String finishDays(int count) {
    return 'إنهاء — $count يوم/أيام محفوظة';
  }

  @override
  String get saveAtLeastOneDay => 'احفظ يوماً واحداً على الأقل قبل الإنهاء.';

  @override
  String get addAtLeastOneExercise => 'أضف تمريناً واحداً على الأقل.';

  @override
  String programCreated(String name, int count) {
    return 'تم إنشاء برنامج \"$name\" بـ $count يوم/أيام!';
  }

  @override
  String get sets => 'المجموعات';

  @override
  String get reps => 'التكرارات';

  @override
  String get restSeconds => 'الراحة (ث)';

  @override
  String get weightKgOpt => 'الوزن كجم (اختياري)';

  @override
  String daysSaved(int count, String days) {
    return '$count يوم/أيام محفوظة: $days';
  }

  @override
  String get exerciseLibrary => 'مكتبة التمارين';

  @override
  String get selectExercise => 'اختر تمريناً';

  @override
  String get searchExercises => 'ابحث عن تمرين…';

  @override
  String get noExercisesFound => 'لا توجد تمارين';

  @override
  String get addCustom => 'إضافة مخصّص';

  @override
  String get custom => 'مخصّص';

  @override
  String get addCustomExercise => 'إضافة تمرين مخصّص';

  @override
  String get exerciseNameEn => 'اسم التمرين (إنجليزي) *';

  @override
  String get exerciseNameAr => 'اسم التمرين (عربي)';

  @override
  String get exerciseNameRequired => 'اسم التمرين بالإنجليزية مطلوب.';

  @override
  String get equipment => 'المعدات';

  @override
  String get equipmentHint => 'مثال: بار، دمبل';

  @override
  String get descriptionOptional => 'الوصف / التعليمات (اختياري)';

  @override
  String get videoUrl => 'رابط الفيديو (اختياري)';

  @override
  String get exerciseAdded => 'تمت إضافة التمرين';

  @override
  String get saveExercise => 'حفظ التمرين';

  @override
  String get addExercisePhoto => 'إضافة صورة التمرين (اختياري)';

  @override
  String get workoutHistory => 'سجل التمارين';

  @override
  String get noWorkoutsLogged => 'لم يُسجَّل أي تمرين بعد';

  @override
  String effort(int effort) {
    return 'المجهود $effort/10';
  }

  @override
  String get prescribedWeights => 'الأوزان المحددة';

  @override
  String get modifiedWeights => 'أوزان معدّلة';

  @override
  String get noSetDetails => 'لا توجد تفاصيل مجموعات مسجّلة.';

  @override
  String get usedPrescribedWeights => 'هل استخدمت الأوزان المحددة؟';

  @override
  String get overallEffort => 'المجهود الكلي';

  @override
  String get sessionNotes => 'ملاحظات الجلسة (اختياري)';

  @override
  String get logAtLeastOneSet => 'سجّل مجموعة واحدة على الأقل قبل الحفظ.';

  @override
  String get confirmWorkoutCompleted => 'تأكيد إتمام التمرين';

  @override
  String rest(int seconds) {
    return 'راحة: $seconds ث';
  }

  @override
  String get skip => 'تخطّي';

  @override
  String get mealPlans => 'خطط التغذية';

  @override
  String get createMealPlan => 'إنشاء خطة تغذية';

  @override
  String newMealPlan(String name) {
    return 'خطة تغذية جديدة — $name';
  }

  @override
  String get planName => 'اسم الخطة';

  @override
  String get planNameHint => 'مثال: \"مرحلة التخفيف - الأسبوع الأول\"';

  @override
  String get planNameRequired => 'اسم الخطة مطلوب.';

  @override
  String get weekStartDate => 'تاريخ بداية الأسبوع';

  @override
  String get dailyMacroTargets => 'أهداف الماكرو اليومية';

  @override
  String get calories => 'السعرات الحرارية';

  @override
  String get caloriesKcal => 'السعرات الحرارية (سعرة)';

  @override
  String get protein => 'البروتين';

  @override
  String get proteinG => 'البروتين (جم)';

  @override
  String get carbs => 'الكربوهيدرات';

  @override
  String get carbsG => 'الكربوهيدرات (جم)';

  @override
  String get fat => 'الدهون';

  @override
  String get fatG => 'الدهون (جم)';

  @override
  String get suggestedTargets => 'أهداف مقترحة (مرجع)';

  @override
  String get createPlanAndBuild => 'إنشاء الخطة وبناؤها ←';

  @override
  String get viewPlan => 'عرض الخطة';

  @override
  String get shoppingList => 'قائمة التسوق';

  @override
  String get noMealPlanLoaded => 'لم تُحمَّل خطة بعد';

  @override
  String get addMeal => 'إضافة وجبة';

  @override
  String get mealRemoved => 'تم حذف الوجبة';

  @override
  String addMealTitle(String name) {
    return 'إضافة وجبة — $name';
  }

  @override
  String get mealType => 'نوع الوجبة';

  @override
  String get breakfast => 'فطور';

  @override
  String get midMorning => 'وجبة منتصف الصباح';

  @override
  String get lunch => 'غداء';

  @override
  String get afternoon => 'وجبة العصر';

  @override
  String get dinner => 'عشاء';

  @override
  String get preWorkout => 'قبل التمرين';

  @override
  String get postWorkout => 'بعد التمرين';

  @override
  String get time => 'الوقت';

  @override
  String get foodItems => 'عناصر الطعام';

  @override
  String get addFood => 'إضافة طعام';

  @override
  String get noFoodsAdded => 'لم تُضف أطعمة بعد. اضغط \"إضافة طعام\" للبدء.';

  @override
  String get addAtLeastOneFood => 'أضف عنصر طعام واحداً على الأقل.';

  @override
  String get saveMeal => 'حفظ الوجبة';

  @override
  String get foodLibrary => 'مكتبة الأطعمة';

  @override
  String get selectFood => 'اختر طعاماً';

  @override
  String get searchFoods => 'ابحث عن طعام…';

  @override
  String get noFoodsFound => 'لا توجد أطعمة';

  @override
  String get howManyGrams => 'كم غراماً؟';

  @override
  String get grams => 'غرامات';

  @override
  String get noMealsToday => 'لا توجد وجبات لهذا اليوم';

  @override
  String get log => 'تسجيل';

  @override
  String logMeal(String meal) {
    return 'تسجيل: $meal';
  }

  @override
  String get completed => 'مكتمل ✅';

  @override
  String get completedHint => 'أكلت هذه الوجبة كاملاً';

  @override
  String get skipped => 'متخطّي ❌';

  @override
  String get skippedHint => 'لم آكل هذه الوجبة';

  @override
  String get partial => 'جزئي 🔄';

  @override
  String get partialHint => 'أكلت جزءاً من هذه الوجبة';

  @override
  String mealLoggedAs(String status) {
    return 'تم تسجيل الوجبة كـ $status';
  }

  @override
  String get failedToLog => 'فشل تسجيل الوجبة';

  @override
  String get noShoppingItems => 'لا توجد عناصر';

  @override
  String get shoppingListHint => 'أنشئ خطة الوجبات لتوليد قائمة التسوق.';

  @override
  String get totalEstimatedPrice => 'السعر الإجمالي التقريبي';

  @override
  String get shareComingSoon => 'المشاركة قادمة قريباً';

  @override
  String get subscribeToPlan => 'اشترك في خطة';

  @override
  String get selectPlan => 'اختر خطة';

  @override
  String get noPlansAvailable => 'لا توجد خطط متاحة لهذا الجيم.';

  @override
  String get autoRenew => 'تجديد تلقائي';

  @override
  String get selectPlanFirst => 'يرجى اختيار خطة.';

  @override
  String get confirmSubscription => 'تأكيد الاشتراك';

  @override
  String planDuration(int days, String cycle) {
    return '$days يوم · $cycle';
  }

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get chooseAccountType => 'اختر نوع حسابك للمتابعة.';

  @override
  String get individualCoach => 'مدرّب مستقل';

  @override
  String get individualCoachDesc =>
      'أدِر متدرّبيك مباشرةً.\nلا تحتاج إلى إعداد جيم.';

  @override
  String get gym => 'جيم';

  @override
  String get gymDesc =>
      'أنشئ جيماً وأضف مدرّبين متعددين،\nلكل مدرّب متدرّبوه الخاصون.';

  @override
  String get gymDetails => 'بيانات الجيم';

  @override
  String get adminAccount => 'حساب المشرف';

  @override
  String get gymNameHint => 'اسم الجيم مثال: FitZone القاهرة';

  @override
  String get gymNameRequired => 'اسم الجيم مطلوب.';

  @override
  String get adminAccountDesc => 'هذا سيكون تسجيل دخولك لإدارة الجيم.';

  @override
  String get createGym => 'إنشاء الجيم';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get personalGymNote => 'سيُنشأ جيم شخصي تلقائياً.';

  @override
  String get gymLogo => 'شعار الجيم';

  @override
  String get gymLogoDesc => 'اختياري — يُعرض على لوحة المتدرّب';

  @override
  String get points => 'النقاط';

  @override
  String get streak => 'السلسلة';

  @override
  String get onBoardingTitle1 => 'تتبّع هدفك';

  @override
  String get onBoardingDesc1 =>
      'لا تقلق إذا واجهت صعوبة في تحديد أهدافك، يمكننا مساعدتك في تحديد أهدافك وتتبّعها';

  @override
  String get onBoardingTitle2 => 'احرق الدهون';

  @override
  String get onBoardingDesc2 =>
      'لنستمر في الحرق لتحقيق أهدافك، الألم مؤقت فقط، إذا استسلمت الآن ستعاني إلى الأبد';

  @override
  String get onBoardingTitle3 => 'تناول طعاماً صحياً';

  @override
  String get onBoardingDesc3 =>
      'لنبدأ نمط حياة صحياً معاً، يمكننا تحديد نظامك الغذائي كل يوم. الأكل الصحي ممتع';

  @override
  String get onBoardingTitle4 => 'حسّن جودة نومك';

  @override
  String get onBoardingDesc4 =>
      'حسّن جودة نومك معنا، النوم الجيد يجلب مزاجاً رائعاً في الصباح';

  @override
  String get welcomeCoach => 'مرحباً بعودتك، مدرّب';

  @override
  String get bmi => 'مؤشر كتلة الجسم (BMI)';

  @override
  String get normalWeight => 'وزنك طبيعي';

  @override
  String get todayTarget => 'هدف اليوم';

  @override
  String get activityStatus => 'حالة النشاط';

  @override
  String get workoutProgress => 'تقدّم التمرين';

  @override
  String get latestWorkout => 'آخر تمرين';

  @override
  String get weekly => 'أسبوعي';

  @override
  String get monthly => 'شهري';

  @override
  String get heartRate => 'معدل ضربات القلب';

  @override
  String get waterIntake => 'كمية الماء';

  @override
  String get sleep => 'النوم';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get account => 'الحساب';

  @override
  String get personalData => 'البيانات الشخصية';

  @override
  String get achievement => 'الإنجازات';

  @override
  String get activityHistory => 'سجل النشاط';

  @override
  String get workoutProgressTitle => 'تقدّم التمرين';

  @override
  String get notification => 'الإشعارات';

  @override
  String get popupNotification => 'إشعارات منبثقة';

  @override
  String get other => 'أخرى';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get setting => 'الإعدادات';

  @override
  String get height => 'الطول';

  @override
  String get age => 'العمر';

  @override
  String get dietaryRestrictions => 'القيود الغذائية';

  @override
  String get medicalNotes => 'ملاحظات طبية';

  @override
  String get personalDataTitle => 'البيانات الشخصية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get role => 'الدور';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get phoneLabel => 'الهاتف';

  @override
  String get gymIdLabel => 'معرّف الجيم';

  @override
  String get achievementsTitle => 'الإنجازات';

  @override
  String get noAchievementsYet => 'لا توجد إنجازات بعد';

  @override
  String get noAchievementsHint => 'استمر في التدريب لكسب الشارات!';

  @override
  String get totalPoints => 'مجموع النقاط';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get days => 'يوم';

  @override
  String get badges => 'الشارات';

  @override
  String get activityHistoryTitle => 'سجل النشاط';

  @override
  String get noActivityYet => 'لم يُسجَّل أي نشاط بعد';

  @override
  String get noActivityHint => 'ستظهر هنا سجلات التمارين والوجبات.';

  @override
  String get workoutsCompleted => 'التمارين المكتملة';

  @override
  String get mealsLogged => 'الوجبات المسجّلة';

  @override
  String get inBodyScans => 'قياسات InBody';

  @override
  String get workoutProgressTitle2 => 'تقدّم التمرين';

  @override
  String get noProgressYet => 'لا توجد بيانات تمرين بعد';

  @override
  String get noProgressHint => 'أكمل التمارين لرؤية مخططات تقدّمك.';

  @override
  String get avgEffort => 'متوسط المجهود';

  @override
  String get contactUsTitle => 'اتصل بنا';

  @override
  String get contactEmail => 'دعم البريد الإلكتروني';

  @override
  String get contactPhone => 'دعم الهاتف';

  @override
  String get contactWhatsApp => 'واتساب';

  @override
  String get contactHours => 'ساعات العمل';

  @override
  String get contactHoursValue => 'الأحد–الخميس، 9 ص – 6 م';

  @override
  String get privacyPolicyTitle => 'سياسة الخصوصية';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get pushNotifications => 'إشعارات الدفع';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get version => 'الإصدار 1.0.0';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get noMembershipsYet => 'لا توجد اشتراكات بعد.';

  @override
  String get perPlan => '/ خطة';

  @override
  String get expiringWarning => '⚠ ينتهي خلال 7 أيام';

  @override
  String get renew => 'تجديد';

  @override
  String get freeze => 'تجميد';

  @override
  String get unfreeze => 'إلغاء التجميد';

  @override
  String get noInBodyYet => 'لا توجد قياسات InBody بعد';

  @override
  String get latestBodyScore => 'أحدث نقاط الجسم';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get recentMeasurements => 'القياسات الأخيرة';

  @override
  String get historyLabel => 'السجل';

  @override
  String get noActiveProgram => 'لا يوجد برنامج نشط';

  @override
  String get createWorkoutHint => 'أنشئ برنامج تمارين لهذا المتدرب';

  @override
  String get daysLabel => 'الأيام';

  @override
  String get logLabel => 'تسجيل';

  @override
  String get more => 'المزيد';

  @override
  String get newProgramLabel => 'برنامج جديد';

  @override
  String get createPlan => 'إنشاء خطة';

  @override
  String get newPlan => 'خطة جديدة';

  @override
  String get shop => 'التسوق';

  @override
  String get noActiveMealPlan => 'لا توجد خطة غذائية نشطة';

  @override
  String get createNutritionHint => 'أنشئ خطة تغذية لهذا المتدرب';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get traineeView => 'عرض المتدرب';

  @override
  String get noMeals => 'لا توجد وجبات';

  @override
  String get chatMessages => 'الرسائل';

  @override
  String get chatNoConversations => 'لا توجد محادثات بعد';

  @override
  String get chatNoConversationsHint =>
      'ستظهر هنا الرسائل المتبادلة مع مدربك أو متدربيك.';

  @override
  String get chatNoMessages => 'لا توجد رسائل بعد';

  @override
  String get chatSayHi => 'ابدأ المحادثة! 👋';

  @override
  String get chatTypeMessage => 'اكتب رسالة…';

  @override
  String get chatTrainee => 'متدرب';

  @override
  String get chatCoach => 'مدرب';

  @override
  String get chatToday => 'اليوم';

  @override
  String get chatYesterday => 'أمس';

  @override
  String get chatAttachReference => 'إرفاق مرجع';

  @override
  String get chatReferenceInBody => 'نتيجة InBody';

  @override
  String get chatReferenceWorkout => 'خطة التمرين';

  @override
  String get chatReferenceMeal => 'خطة الوجبات';

  @override
  String get chatReferencing => 'بخصوص';

  @override
  String get chatRemoveReference => 'إزالة المرجع';

  @override
  String get progressBody => 'تتبع الجسم';

  @override
  String get progressTimeline => 'مسار التقدم';

  @override
  String get noProgressEntries => 'لا توجد سجلات تقدم بعد';

  @override
  String get noProgressEntriesHint =>
      'أضف صورًا وملاحظات لتتبع تغيرات جسمك بمرور الوقت.';

  @override
  String get addProgressEntry => 'إضافة سجل تقدم';

  @override
  String get progressPhotos => 'صور التقدم';

  @override
  String get addPhotos => 'إضافة صور';

  @override
  String get progressNotes => 'ملاحظات';

  @override
  String get progressNotesHint => 'كيف تشعر؟ هل لاحظت أي تغييرات؟';

  @override
  String get saveProgress => 'حفظ السجل';

  @override
  String get progressSaved => 'تم حفظ سجل التقدم';

  @override
  String get addPhotoOrNote => 'أضف صورة واحدة على الأقل أو ملاحظة.';

  @override
  String get deleteEntry => 'حذف السجل';

  @override
  String get deleteEntryConfirm => 'هل تريد حذف سجل التقدم هذا؟';

  @override
  String photosCount(int count) {
    return '$count صورة';
  }

  @override
  String get coachComments => 'تعليقات المدرب';

  @override
  String get addComment => 'إضافة تعليق';

  @override
  String get commentHint => 'أضف ملاحظة أو نصيحة لهذا التمرين…';

  @override
  String get noComments => 'لا توجد تعليقات بعد';

  @override
  String get commentAdded => 'تمت إضافة التعليق';

  @override
  String get deleteComment => 'حذف التعليق';

  @override
  String get totalTraineesLabel => 'الإجمالي';

  @override
  String get traineesNeedAttention => 'متدربون يحتاجون انتباهاً';

  @override
  String get expiringMemberships => 'اشتراكات منتهية قريباً';

  @override
  String get allTraineesOnTrack => 'جميع المتدربين في المسار الصحيح 🎉';

  @override
  String get allTraineesOnTrackHint => 'الجميع يتبع خطته. عمل رائع!';

  @override
  String get keepItUp => 'استمر! 💪';

  @override
  String get keepItUpHint => 'راجع خطتك وكن منتظماً في تمارينك ووجباتك.';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get myWorkout => 'تمريني';

  @override
  String get myMeals => 'وجباتي';

  @override
  String get drawerNavigation => 'التنقل';

  @override
  String get drawerCoachActions => 'إجراءات المدرب';

  @override
  String get drawerAdmin => 'الإدارة';

  @override
  String get drawerGeneral => 'عام';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get navMessages => 'الرسائل';

  @override
  String get navMyTrainees => 'متدربيّ';

  @override
  String get navAddNewTrainee => 'إضافة متدرب';

  @override
  String get navReports => 'التقارير والتحليلات';

  @override
  String get navManageStaff => 'إدارة الموظفين';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get languageToggle => 'العربية / English';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logOutTitle => 'تسجيل الخروج؟';

  @override
  String get logOutMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get dashGymDashboard => 'لوحة النادي';

  @override
  String dashWelcomeUser(String name) {
    return 'مرحباً، $name 👋';
  }

  @override
  String get dashCoaches => 'المدربون';

  @override
  String get dashTrainees => 'المتدربون';

  @override
  String get dashActiveMembers => 'الأعضاء النشطون';

  @override
  String get dashMonthlyRevenue => 'الإيراد الشهري';

  @override
  String get dashExpiringThisWeek => 'تنتهي هذا الأسبوع';

  @override
  String get dashNewThisMonth => 'جديد هذا الشهر';

  @override
  String dashUnpaidTraineesAlert(int count) {
    return '$count متدرب لم يدفعوا الفترة الحالية.';
  }

  @override
  String get dashPlatform => 'المنصة';

  @override
  String get dashPlatformSubtitle => 'نظرة عامة على جميع الأندية والنشاط';

  @override
  String get dashPayments => 'المدفوعات';

  @override
  String get dashPaymentRequests => 'طلبات الدفع';

  @override
  String get dashPaymentRequestsSubtitle => 'مراجعة واعتماد المدفوعات اليدوية';

  @override
  String get dashPaymentMethods => 'طرق الدفع';

  @override
  String get dashPaymentMethodsSubtitle => 'تفعيل / تعطيل وتعديل الطرق';

  @override
  String get dashRevenueLastMonths => 'الإيرادات (آخر الأشهر)';

  @override
  String get dashGrowth => 'النمو';

  @override
  String get dashTotalGyms => 'إجمالي الأندية';

  @override
  String dashGymsActiveInactive(int active, int inactive) {
    return '$active نشط · $inactive غير نشط';
  }

  @override
  String get dashTotalRevenue => 'إجمالي الإيرادات';

  @override
  String dashThisMonthAmount(String amount) {
    return 'هذا الشهر $amount';
  }

  @override
  String dashPlusThisMonth(int count) {
    return '+$count هذا الشهر';
  }

  @override
  String dashAdminsCount(int count) {
    return '$count مشرف';
  }

  @override
  String get dashInBodyRecords => 'سجلات InBody';

  @override
  String get dashWorkoutSessions => 'جلسات التمرين';

  @override
  String get dashMealPlans => 'خطط الوجبات';

  @override
  String get dashNewGyms => 'أندية جديدة';

  @override
  String get dashThisMonth => 'هذا الشهر';

  @override
  String get dashNoRevenueData => 'لا توجد بيانات إيرادات بعد';

  @override
  String get dashNoGrowthData => 'لا توجد بيانات نمو بعد';

  @override
  String get dashWorkouts => 'التمارين';

  @override
  String get dashRevenue => 'الإيرادات';

  @override
  String get tabMore => 'المزيد';

  @override
  String get tabAlerts => 'التنبيهات';

  @override
  String get tabChat => 'المحادثة';

  @override
  String get tabRequests => 'الطلبات';

  @override
  String get tabSupport => 'الدعم';

  @override
  String get membershipPaymentDue => 'استحقاق دفع الاشتراك';

  @override
  String get payCoachUnlockMessage =>
      'يرجى الدفع لمدربك لفتح تمارينك وخطط وجباتك وقياسات InBody وتتبع التقدم. راسل مدربك لترتيب الدفع.';

  @override
  String get messageCoach => 'مراسلة المدرب';

  @override
  String get maybeLater => 'ربما لاحقاً';

  @override
  String get drawerMySubscription => 'اشتراكي';

  @override
  String get drawerOverview => 'نظرة عامة';

  @override
  String get drawerManageGyms => 'إدارة الأندية';

  @override
  String get drawerAllUsers => 'جميع المستخدمين';

  @override
  String get drawerAllCoaches => 'جميع المدربين';

  @override
  String get drawerSendAnnouncement => 'إرسال إعلان';

  @override
  String get addCoach => 'إضافة مدرب';

  @override
  String get searchCoaches => 'بحث عن المدربين…';

  @override
  String get noCoachesYet => 'لا يوجد مدربون بعد.';

  @override
  String get traineesLower => 'متدرب';

  @override
  String get noOtherCoachToReassign => 'لا يوجد مدرب آخر لإعادة التعيين إليه.';

  @override
  String reassignTraineeTo(String name) {
    return 'إعادة تعيين $name إلى…';
  }

  @override
  String reassignedToName(String name) {
    return 'تمت إعادة التعيين إلى $name.';
  }

  @override
  String get failedGeneric => 'فشل.';

  @override
  String get noTraineesUnderCoach => 'لا يوجد متدربون لدى هذا المدرب بعد.';

  @override
  String get openDetails => 'عرض التفاصيل';

  @override
  String get reassignCoach => 'إعادة تعيين المدرب';

  @override
  String get coachCreated => 'تم إنشاء المدرب.';

  @override
  String get failedToCreateCoach => 'فشل إنشاء المدرب.';

  @override
  String get newCoach => 'مدرب جديد';

  @override
  String get createCoach => 'إنشاء مدرب';

  @override
  String get firstNameField => 'الاسم الأول';

  @override
  String get lastNameField => 'اسم العائلة';

  @override
  String get tempPasswordField => 'كلمة مرور مؤقتة';

  @override
  String get phoneOptionalField => 'الهاتف (اختياري)';

  @override
  String get bioOptionalField => 'نبذة (اختياري)';

  @override
  String get heightCmField => 'الطول (سم)';

  @override
  String get weightKgField => 'الوزن (كجم)';

  @override
  String get invalid => 'غير صالح';

  @override
  String get traineeCreatedAndAssigned => 'تم إنشاء المتدرب وتعيينه.';

  @override
  String get failedToCreateTrainee => 'فشل إنشاء المتدرب.';

  @override
  String get newTrainee => 'متدرب جديد';

  @override
  String assignedToCoach(String name) {
    return 'معيّن للمدرب: $name';
  }

  @override
  String get createTrainee => 'إنشاء متدرب';

  @override
  String get unpaidTrainees => 'متدربون لم يدفعوا';

  @override
  String get everyonePaid => 'الجميع دفع 🎉';

  @override
  String get unpaid => 'لم يدفع';

  @override
  String coachWithName(String name) {
    return 'المدرب: $name';
  }

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات بعد';

  @override
  String get notificationEmptyHint => 'ستظهر هنا رسائل المحادثة والتحديثات';

  @override
  String get justNow => 'الآن';

  @override
  String minutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String hoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String daysAgo(int count) {
    return 'منذ $count ي';
  }

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get updateAccountPassword => 'تحديث كلمة مرور حسابك';

  @override
  String get appearance => 'المظهر';

  @override
  String get settingOn => 'مفعّل';

  @override
  String get settingOff => 'معطّل';

  @override
  String get receiveWorkoutReminders => 'تلقّي تذكيرات التمارين';

  @override
  String get submitSupportTicket => 'إرسال تذكرة دعم';

  @override
  String get workoutTemplates => 'قوالب التمارين';

  @override
  String get workoutTemplatesHint =>
      'أنشئ التمرين مرة واحدة — من مكتبة التمارين أو برفع ملف — ثم عيّنه لأي متدرب بضغطة واحدة. لا حاجة لإعادة بناء نفس الخطة للجميع.';

  @override
  String get newTemplate => 'قالب جديد';

  @override
  String get assignFromTemplate => 'تعيين من قالب';

  @override
  String get planBuildInApp => 'إنشاء داخل التطبيق';

  @override
  String get planUploadFile => 'رفع ملف';

  @override
  String get chooseFileToUpload => 'الرجاء اختيار ملف للرفع.';

  @override
  String get fileUploadFailed => 'فشل رفع الملف. حاول مرة أخرى.';

  @override
  String get planUploadedSuccess => 'تم رفع الخطة الغذائية بنجاح.';

  @override
  String get somethingWentWrong => 'حدث خطأ ما.';

  @override
  String get uploadAndAssignPlan => 'رفع وتعيين الخطة';

  @override
  String get traineeMeasurements => 'قياسات المتدرب';

  @override
  String get heightCmLabel => 'الطول (سم)';

  @override
  String get weightKgLabel => 'الوزن (كجم)';

  @override
  String get ageLabel => 'العمر';

  @override
  String get planFilePdfImage => 'ملف الخطة (PDF / صورة)';

  @override
  String get enterMeasurementsHint =>
      'أدخل الطول والوزن والعمر لحساب الأهداف اليومية تلقائيًا.';

  @override
  String get recommendedDailyTargets => 'الأهداف اليومية الموصى بها';

  @override
  String get water => 'الماء';

  @override
  String get bmrLabel => 'الأيض الأساسي';

  @override
  String get tdeeLabel => 'إجمالي الحرق اليومي';

  @override
  String get proteinPerMeal => 'بروتين/وجبة';

  @override
  String get fiber => 'الألياف';

  @override
  String get perWeek => 'أسبوعيًا';

  @override
  String get useTheseTargets => 'استخدم هذه كأهداف للخطة';

  @override
  String get tapToChooseFile => 'اضغط لاختيار ملف PDF أو صورة';

  @override
  String get fileTypesHint => 'PDF، JPG، PNG · حتى 50 ميجابايت';

  @override
  String get monthSingular => 'شهر';

  @override
  String get monthPlural => 'أشهر';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get rejectedByTrainee => 'مرفوضة من المتدرب';

  @override
  String get replaceMeal => 'استبدال الوجبة';

  @override
  String get mealReplacedNotified => 'تم استبدال الوجبة. تم إشعار المتدرب.';

  @override
  String copyDayTo(String day) {
    return 'نسخ $day إلى…';
  }

  @override
  String mealsWillBeCopied(int count) {
    return 'سيتم نسخ $count وجبة إلى الأيام المحددة.';
  }

  @override
  String get clearAll => 'إلغاء تحديد الكل';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String currentlyHasMeals(int count) {
    return 'يحتوي حاليًا على $count وجبة';
  }

  @override
  String get replaceExistingMeals => 'استبدال الوجبات الحالية';

  @override
  String get replaceExistingOn => 'يتم مسح الأيام المستهدفة قبل النسخ';

  @override
  String get replaceExistingOff => 'تُضاف الوجبات المنسوخة بجانب الموجودة';

  @override
  String copyToDays(int count) {
    return 'نسخ إلى $count يوم';
  }

  @override
  String copiedMealsToDays(int meals, int days) {
    return 'تم نسخ $meals وجبة إلى $days يوم.';
  }

  @override
  String get couldNotDuplicate => 'تعذّر نسخ اليوم.';

  @override
  String get copyThisDayToOthers => 'انسخ هذا اليوم إلى أيام أخرى';

  @override
  String coachProvidedFilePlan(int months) {
    return 'قدّم مدربك هذه الخطة الغذائية كملف. المدة: $months شهر.';
  }

  @override
  String get rejectThisMeal => 'رفض هذه الوجبة؟';

  @override
  String get rejectReasonHint =>
      'أخبر مدربك لماذا لا تناسبك هذه الوجبة حتى يتمكن من استبدالها.';

  @override
  String get rejectReasonPlaceholder => 'مثال: لدي حساسية، لا أحب هذا الطعام…';

  @override
  String get reject => 'رفض';

  @override
  String get mealRejectedNotified => 'تم رفض الوجبة. تم إشعار مدربك.';

  @override
  String get couldNotReject => 'تعذّر رفض الوجبة.';

  @override
  String get rejectedWaitingCoach => 'مرفوضة — بانتظار المدرب';

  @override
  String get planFile => 'ملف الخطة';

  @override
  String get catAll => 'الكل';

  @override
  String get catVegetable => 'خضروات';

  @override
  String get catFruit => 'فواكه';

  @override
  String get catDairy => 'ألبان';

  @override
  String get catOther => 'أخرى';

  @override
  String howManyUnit(String unit) {
    return 'كم عدد ($unit)؟';
  }

  @override
  String get pieceUnit => 'حبة';

  @override
  String approxGrams(String grams) {
    return '≈ $grams جم';
  }

  @override
  String get countLabel => 'العدد';

  @override
  String get measureByCount => 'القياس بالعدد (مثل البيض)';

  @override
  String get gramsPerUnitLabel => 'جرامات لكل وحدة';

  @override
  String get unitNameLabel => 'اسم الوحدة (مثل بيضة)';

  @override
  String get addCustomFood => 'إضافة طعام مخصص';

  @override
  String get newCustomFood => 'طعام مخصص جديد';

  @override
  String get foodNameEnLabel => 'اسم الطعام (إنجليزي)';

  @override
  String get foodNameArLabel => 'اسم الطعام (عربي)';

  @override
  String get categoryLabel => 'التصنيف';

  @override
  String get per100gNote => 'القيم لكل 100 جرام';

  @override
  String get caloriesPer100 => 'السعرات (سعرة)';

  @override
  String get proteinPer100 => 'البروتين (جم)';

  @override
  String get carbsPer100 => 'الكربوهيدرات (جم)';

  @override
  String get fatPer100 => 'الدهون (جم)';

  @override
  String get foodNameRequired => 'اسم الطعام مطلوب.';

  @override
  String get foodAdded => 'تمت إضافة الطعام إلى مكتبتك.';

  @override
  String get saveFood => 'حفظ الطعام';

  @override
  String get noFoodAddYours => 'لا توجد أطعمة. أضف طعامك المخصص.';

  @override
  String get coachGuide => 'دليل المدرب';

  @override
  String get guideHeaderSubtitle => 'كل ما تحتاجه لإدارة تدريبك — خطوة بخطوة.';

  @override
  String get guideProcessTitle => 'الرحلة كاملة';

  @override
  String get guideProcessStep1 => 'أضف متدربًا وعيّنه لك.';

  @override
  String get guideProcessStep2 => 'سجّل قياساته (InBody) وحدّد هدفه.';

  @override
  String get guideProcessStep3 => 'أنشئ برنامج تمارين وخطة غذائية.';

  @override
  String get guideProcessStep4 => 'فعّل اشتراكه ليُفتح له المحتوى.';

  @override
  String get guideProcessStep5 =>
      'يتابع ويسجّل ويتحدث معك — وأنت تتابع تقدّمه.';

  @override
  String get guideNutritionTitle => 'إنشاء خطة غذائية';

  @override
  String get guideNutritionStep1 =>
      'افتح متدربًا ← تبويب التغذية ← اضغط خطة جديدة.';

  @override
  String get guideNutritionStep2 =>
      'أدخل الطول والوزن والعمر، ثم اختر الجنس والهدف والنشاط — وتُحسب الأهداف تلقائيًا.';

  @override
  String get guideNutritionStep3 =>
      'اختر الإنشاء داخل التطبيق أو رفع ملف جاهز (PDF/صورة)، وحدّد المدة بالأشهر.';

  @override
  String get guideNutritionStep4 =>
      'أضف الوجبات، اختر الأطعمة (أو أضف طعامك المخصص) وأدخل الجرامات — وتُحسب القيم تلقائيًا.';

  @override
  String get guideNutritionStep5 =>
      'استخدم نسخ اليوم لتكرار يوم على باقي الأيام خلال ثوانٍ.';

  @override
  String get guideNutritionStep6 =>
      'إذا رفض المتدرب وجبة، يصلك إشعار — استبدلها فيصله إشعار بذلك.';

  @override
  String get guideWorkoutsTitle => 'إنشاء تمرين';

  @override
  String get guideWorkoutsStep1 =>
      'افتح متدربًا ← تبويب التمارين ← أنشئ برنامجًا.';

  @override
  String get guideWorkoutsStep2 =>
      'أنشئ قالبًا مرة واحدة وعيّنه لأي متدرب بضغطة.';

  @override
  String get guideWorkoutsStep3 => 'عدّل يومًا بيوم وأضف تمارين من المكتبة.';

  @override
  String get guideWorkoutsStep4 =>
      'يسجّل المتدربون تمارينهم ويعلّقون على التمارين.';

  @override
  String get guideSubscriptionsTitle => 'إدارة الاشتراكات';

  @override
  String get guideSubscriptionsStep1 => 'افتح متدربًا وفعّل عضويته/اشتراكه.';

  @override
  String get guideSubscriptionsStep2 => 'تابع من دفع ومن لم يدفع بنظرة واحدة.';

  @override
  String get guideSubscriptionsStep3 =>
      'عند تفعيل الاشتراك يُفتح محتوى المتدرب تلقائيًا.';

  @override
  String get guideTipsTitle => 'نصائح احترافية';

  @override
  String get guideTip1 =>
      'أعد استخدام قوالب التمارين وانسخ أيام التغذية لتوفير الوقت.';

  @override
  String get guideTip2 => 'أضف أطعمتك المخصصة لتناسب خططك أسلوبك.';

  @override
  String get guideTip3 => 'تابع الإشعارات لرفض الوجبات والرسائل.';

  @override
  String get tourSkip => 'تخطٍّ';

  @override
  String get tourNext => 'التالي';

  @override
  String get tourDone => 'ابدأ';

  @override
  String get tourReopenHint => 'يمكنك فتح هذا الدليل في أي وقت من القائمة.';

  @override
  String get tourWelcomeTitle => 'مرحبًا بك في لياقة 👋';

  @override
  String get tourWelcomeBody =>
      'تطبيقك الشامل لتدريب المتدربين: تمارين، تغذية، تقدّم ومدفوعات — بالعربية والإنجليزية.';

  @override
  String get tourNutritionTitle => 'تغذية ذكية 🍽️';

  @override
  String get tourNutritionBody =>
      'أنشئ خططًا بأهداف محسوبة تلقائيًا، ابنِ داخل التطبيق أو ارفع ملفًا، أضف أطعمة مخصصة، وانسخ الأيام بضغطة.';

  @override
  String get tourWorkoutsTitle => 'تمارين بسهولة 🏋️';

  @override
  String get tourWorkoutsBody =>
      'أنشئ قوالب قابلة لإعادة الاستخدام وعيّن برامج كاملة لأي متدرب خلال ثوانٍ.';

  @override
  String get tourTrackTitle => 'تابِع واحصل على مدفوعاتك 📊';

  @override
  String get tourTrackBody =>
      'تابع قياسات الجسم والتقدّم، تحدّث مع المتدربين، وافتح محتواهم عبر الاشتراكات.';

  @override
  String get tourGuideTitle => 'تحتاج تذكيرًا؟ 📖';

  @override
  String get tourGuideBody =>
      'افتح دليل المدرب في أي وقت من القائمة الجانبية للحصول على خطوات تفصيلية.';

  @override
  String get goalCut => 'تنشيف';

  @override
  String get goalBulk => 'تضخيم';

  @override
  String get goalMaintain => 'محافظة';

  @override
  String get goalRecomp => 'إعادة تكوين';

  @override
  String get activitySedentary => 'خامل';

  @override
  String get activityLight => 'نشاط خفيف';

  @override
  String get activityModerate => 'نشاط متوسط';

  @override
  String get activityActive => 'نشيط';

  @override
  String get activityVeryActive => 'نشيط جدًا';

  @override
  String get activitySedentaryHint => 'تمارين قليلة أو معدومة';

  @override
  String get activityLightHint => '١–٣ أيام / أسبوع';

  @override
  String get activityModerateHint => '٣–٥ أيام / أسبوع';

  @override
  String get activityActiveHint => '٦–٧ أيام / أسبوع';

  @override
  String get activityVeryActiveHint => 'تمارين شاقة يوميًا / عمل بدني';

  @override
  String get passwordChangedSuccess => 'تم تغيير كلمة المرور بنجاح.';

  @override
  String get couldNotChangePassword => 'تعذّر تغيير كلمة المرور.';

  @override
  String get passwordTip =>
      'استخدم 8 أحرف على الأقل. اختر كلمة مرور قوية لا تستخدمها في مكان آخر.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get enterCurrentPassword => 'أدخل كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get enterNewPassword => 'أدخل كلمة مرور جديدة';

  @override
  String get passwordMin8 => 'يجب ألا تقل عن 8 أحرف';

  @override
  String get newPasswordMustDiffer =>
      'يجب أن تختلف كلمة المرور الجديدة عن الحالية';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get reenterNewPassword => 'أعد إدخال كلمة المرور الجديدة';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get updatePassword => 'تحديث كلمة المرور';

  @override
  String get completeProfileTitle => 'لنُكمل ملفك الشخصي';

  @override
  String get completeProfileSubtitle => 'سيساعدنا ذلك في معرفة المزيد عنك!';

  @override
  String get chooseGender => 'اختر النوع';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get yourWeight => 'وزنك';

  @override
  String get yourHeight => 'طولك';

  @override
  String get couldNotLoadProfile => 'تعذّر تحميل ملفك الشخصي';

  @override
  String get uploadingImage => 'جارٍ رفع الصورة…';

  @override
  String get profileImageUpdated => 'تم تحديث صورة الملف الشخصي';

  @override
  String get uploadFailed => 'فشل الرفع';

  @override
  String get privacySection1Title => '١. المعلومات التي نجمعها';

  @override
  String get privacySection2Title => '٢. كيف نستخدم المعلومات';

  @override
  String get privacySection3Title => '٣. تخزين البيانات';

  @override
  String get privacySection4Title => '٤. مشاركة المعلومات';

  @override
  String get privacySection5Title => '٥. حقوقك';

  @override
  String get privacySection6Title => '٦. التغييرات على هذه السياسة';

  @override
  String get privacySection7Title => '٧. التواصل';

  @override
  String get newWorkoutTemplate => 'قالب تمرين جديد';

  @override
  String get uploadWorkoutFile => 'رفع ملف تمرين';

  @override
  String get templateName => 'اسم القالب';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get buildFromSystem => 'إنشاء من النظام';

  @override
  String get addDaysExercisesHint => 'أضف الأيام والتمارين من المكتبة';

  @override
  String get uploadAFile => 'رفع ملف';

  @override
  String get uploadFileHint => 'ملف PDF أو مستند أو صورة تحتوي على التمرين';

  @override
  String get templateDeleted => 'تم حذف القالب';

  @override
  String get noTemplatesYet => 'لا توجد قوالب بعد';

  @override
  String get templatesEmptyHint =>
      'أنشئ التمرين مرة واحدة وعيّنه لأي متدرب — دون الحاجة لإعادة بنائه في كل مرة.';

  @override
  String get editDays => 'تعديل الأيام';

  @override
  String get fileWorkout => 'تمرين بملف';

  @override
  String daysCountLabel(int count) {
    return '$count يوم';
  }

  @override
  String exercisesCountLabel(int count) {
    return '$count تمرين';
  }

  @override
  String get dayUpdated => 'تم تحديث اليوم';

  @override
  String get daySaved => 'تم حفظ اليوم';

  @override
  String get savedDays => 'الأيام المحفوظة';

  @override
  String editDayTitle(String name) {
    return 'تعديل $name';
  }

  @override
  String get dayWord => 'يوم';

  @override
  String get updateDay => 'تحديث اليوم';

  @override
  String get cancelEdit => 'إلغاء التعديل';

  @override
  String get failedToDelete => 'فشل الحذف';

  @override
  String get subStatusActive => 'نشط';

  @override
  String get subStatusFrozen => 'مجمّد';

  @override
  String get subStatusExpired => 'منتهٍ';

  @override
  String get subStatusCancelled => 'ملغى';

  @override
  String get subStatusPending => 'قيد الانتظار';

  @override
  String get subStatusNone => 'لا يوجد';

  @override
  String get payStatusPaid => 'مدفوع';

  @override
  String get payStatusUnpaid => 'غير مدفوع';

  @override
  String get payStatusFree => 'مجاني';

  @override
  String get subscribeNow => 'اشترك الآن';

  @override
  String get egpPerMonth => 'ج.م / شهريًا';

  @override
  String get subscriptionDetails => 'تفاصيل الاشتراك';

  @override
  String get cancelSubscription => 'إلغاء الاشتراك';

  @override
  String get cancelSubscriptionQ => 'إلغاء الاشتراك؟';

  @override
  String get keepIt => 'الاحتفاظ به';

  @override
  String get paymentHistory => 'سجل المدفوعات';

  @override
  String get standardPlan => 'الخطة القياسية';

  @override
  String get planStandard => 'قياسي';

  @override
  String get couldNotLoadSubscription => 'تعذّر تحميل الاشتراك.';

  @override
  String daysRemainingCount(int days) {
    return '$days يوم متبقٍ';
  }

  @override
  String get started => 'بدأ في';

  @override
  String get renewsOn => 'يتجدد في';

  @override
  String get expiresOn => 'ينتهي في';

  @override
  String get nextBilling => 'الفاتورة القادمة';

  @override
  String get amount => 'المبلغ';

  @override
  String get subscribeToUnlock => 'اشترك لفتح كل المزايا';

  @override
  String get subscribeToUnlockBody =>
      'احصل على وصول كامل للتمارين وخطط الوجبات وتتبّع InBody والتقدّم ومحادثة المدرب.';

  @override
  String get subscribeAndPay => 'اشترك وادفع';

  @override
  String get noCoachAssigned => 'لم يتم تعيين مدرب لحسابك بعد.';

  @override
  String get couldNotOpenChat => 'تعذّر فتح المحادثة';

  @override
  String get lockOneStepPayCoach => 'خطوة واحدة متبقية — ادفع لمدربك';

  @override
  String get lockOneStepSubscribe => 'خطوة واحدة متبقية — اشترك في المنصة';

  @override
  String get lockPendingMsg =>
      'دفعتك للمنصة قيد موافقة المسؤول (حتى 24 ساعة). أكمل دفع مدربك بالأسفل في هذه الأثناء.';

  @override
  String get lockPaidPlatformMsg =>
      'اشتراكك في المنصة فعّال. ادفع الآن لمدربك لفتح كل المزايا.';

  @override
  String get lockPaidCoachMsg =>
      'تم تأكيد دفعتك للمدرب. اشترك الآن في المنصة لفتح كل المزايا.';

  @override
  String get lockBothMsg =>
      'لفتح التمارين والوجبات وInBody والتقدّم يجب إكمال كلتا الدفعتين بالأسفل.';

  @override
  String get closeLabel => 'إغلاق';

  @override
  String get subscribeToPlatform => 'اشترك في المنصة';

  @override
  String get payByCardInstaPayWallet => 'ادفع بالبطاقة أو إنستاباي أو المحفظة';

  @override
  String get pendingAdminApproval => 'بانتظار موافقة المسؤول (حتى 24 ساعة)';

  @override
  String get payPlatform => 'ادفع للمنصة';

  @override
  String get payYourCoach => 'ادفع لمدربك';

  @override
  String get cashToCoachHint => 'نقدًا لمدربك — هو من يؤكدها';

  @override
  String get pendingApproval => 'قيد الموافقة';

  @override
  String get paidLabel => 'مدفوع';

  @override
  String get paymentSubmitted24h => 'تم إرسال الدفعة. سنؤكدها خلال 24 ساعة.';

  @override
  String payWithMethod(String method) {
    return 'ادفع عبر $method';
  }

  @override
  String sendPaymentToNumber(String method) {
    return 'أرسل الدفعة إلى رقم $method هذا';
  }

  @override
  String get numberCopied => 'تم نسخ الرقم';

  @override
  String get acceptance24h => 'قد يستغرق قبول الدفع حتى 24 ساعة.';

  @override
  String get afterSendingFillDetails =>
      'بعد إرسال المبلغ، أدخل بياناتك بالأسفل:';

  @override
  String get fullAccountName => 'اسم الحساب كاملًا';

  @override
  String get nameOnAccountHint => 'الاسم على حسابك';

  @override
  String get referenceNumber => 'الرقم المرجعي';

  @override
  String get referenceNumberOptional => 'الرقم المرجعي (إن وُجد)';

  @override
  String get transactionReferenceHint => 'مرجع المعاملة';

  @override
  String get submitPayment => 'إرسال الدفعة';

  @override
  String get choosePaymentMethod => 'اختر طريقة الدفع';

  @override
  String get noPaymentMethods => 'لا توجد طرق دفع متاحة.';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح';

  @override
  String get membershipNowActive =>
      'اشتراكك الآن فعّال. استمتع بالوصول الكامل لكل المزايا.';

  @override
  String get continueToApp => 'المتابعة إلى التطبيق';

  @override
  String get couldNotOpenBrowser => 'تعذّر فتح المتصفح لإتمام الدفع.';

  @override
  String get completePayment => 'إتمام الدفع';

  @override
  String get paymentComplete => 'اكتمل الدفع!';

  @override
  String get waitingForPayment => 'بانتظار الدفع...';

  @override
  String get openingCheckout => 'جارٍ فتح صفحة الدفع...';

  @override
  String get membershipActivated => 'تم تفعيل اشتراكك.';

  @override
  String get completePaymentInBrowser =>
      'أكمل الدفع في المتصفح.\nستُحدّث هذه الشاشة تلقائيًا.';

  @override
  String get openCheckoutAgain => 'افتح صفحة الدفع مجددًا';

  @override
  String get yourCoach => 'مدربك';

  @override
  String get couldNotUpdatePaymentStatus => 'تعذّر تحديث حالة الدفع.';

  @override
  String get coachNoWorkoutYet => 'لم يضِف مدربك برنامج تمرين بعد.';

  @override
  String get coachNoMealPlanYet => 'لم يضِف مدربك خطة وجبات بعد.';

  @override
  String get currencyEgp => 'ج.م';

  @override
  String get currentPeriodSuffix => 'الحالية';

  @override
  String get dangerZone => 'منطقة الخطر';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountSubtitle => 'احذف حسابك وبياناتك نهائيًا';

  @override
  String get deleteAccountConfirmTitle => 'هل أنت متأكد؟';

  @override
  String get deleteAccountConfirmBody =>
      'سيؤدي هذا إلى حذف حسابك وبياناتك الشخصية نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get accountDeleted => 'تم حذف حسابك.';

  @override
  String get deleteAccountFailed => 'تعذّر حذف الحساب. حاول مرة أخرى.';

  @override
  String get pickFromContacts => 'اختر من جهات الاتصال';

  @override
  String get noPhoneInContact => 'جهة الاتصال هذه لا تحتوي على رقم هاتف.';

  @override
  String get chooseNumber => 'اختر رقمًا';

  @override
  String get couldNotOpenWhatsapp => 'تعذّر فتح واتساب.';

  @override
  String get sendOnWhatsapp => 'إرسال عبر واتساب';

  @override
  String get whatsappWelcomeTitle => 'تمت إضافة المتدرب 🎉';

  @override
  String whatsappWelcomeBody(String name) {
    return 'هل تريد إرسال بيانات الدخول ورابط التطبيق إلى $name عبر واتساب؟';
  }

  @override
  String whatsappWelcomeTemplate(
      String name, String username, String password, String link) {
    return 'أهلاً بك في لياقة يا $name! 🏋️\n\nأنشأ لك مدربك حسابًا. إليك بيانات تسجيل الدخول:\n\n👤 اسم المستخدم: $username\n🔑 كلمة المرور: $password\n\n📲 حمّل التطبيق: $link\n\nسجّل الدخول ولنبدأ! 💪';
  }

  @override
  String get rolePlatformOwner => 'مالك المنصة';

  @override
  String get roleGymAdmin => 'مدير الصالة';

  @override
  String get roleCoach => 'مدرب';

  @override
  String get roleTrainee => 'متدرب';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get paymentApprovedActivated =>
      'تمت الموافقة على الدفع — تم تفعيل الاشتراك.';

  @override
  String get rejectPaymentTitle => 'رفض الدفع؟';

  @override
  String get reasonOptional => 'السبب (اختياري)';

  @override
  String noRequestsForStatus(String status) {
    return 'لا توجد طلبات $status.';
  }

  @override
  String get methodLabel => 'الطريقة';

  @override
  String get accountNameLabel => 'اسم الحساب';

  @override
  String get accountLabel => 'الحساب';

  @override
  String get referenceLabel => 'المرجع';

  @override
  String get submittedLabel => 'تاريخ الإرسال';

  @override
  String get noteLabel => 'ملاحظة';

  @override
  String get accept => 'قبول';

  @override
  String editNamed(String name) {
    return 'تعديل $name';
  }

  @override
  String get receiverNumber => 'رقم المستلم';

  @override
  String get instructionsHint => 'التعليمات / تلميح';

  @override
  String get couldNotUpdateSetting => 'تعذّر تحديث الإعداد';

  @override
  String get requireSystemSubscription => 'اشتراط اشتراك النظام';

  @override
  String get requireSystemOnDesc =>
      'يجب على المتدربين دفع اشتراك النظام ومدربهم معًا.';

  @override
  String get requireSystemOffDesc =>
      'دفع النظام مُعطّل — يكفي أن يدفع المتدربون لمدربهم فقط.';

  @override
  String get manualNeedsApproval => 'يدوي · يحتاج موافقة';

  @override
  String get onlinePaddle => 'إلكتروني (Paddle)';

  @override
  String receiverWithNumber(String number) {
    return 'المستلم: $number';
  }

  @override
  String get usersTitle => 'المستخدمون';

  @override
  String get allUsersSubtitle => 'جميع المستخدمين عبر المنصة';

  @override
  String get searchUsers => 'ابحث عن المستخدمين...';

  @override
  String get noUsersFound => 'لا يوجد مستخدمون';

  @override
  String get deleteAccountQ => 'حذف الحساب؟';

  @override
  String deleteUserConfirmBody(String name) {
    return 'سيؤدي هذا إلى حذف حساب $name نهائيًا. سيتم تسجيل خروجه ولن يتمكن من الدخول. تُحفظ السجلات التاريخية. لا يمكن التراجع عن هذا.';
  }

  @override
  String get userAccountDeleted => 'تم حذف الحساب';

  @override
  String get couldNotDeleteAccount => 'تعذّر حذف الحساب';

  @override
  String failedToUpdateStatus(String error) {
    return 'فشل تحديث الحالة: $error';
  }

  @override
  String get coachProfile => 'ملف المدرب';

  @override
  String get editCoachProfile => 'تعديل الملف';

  @override
  String get viewProfile => 'عرض الملف';

  @override
  String get coachProfileEmpty => 'لم يُضف هذا المدرب تفاصيل ملفه بعد.';

  @override
  String get headlineLabel => 'العنوان المهني';

  @override
  String get headlineHint => 'مثال: مدرب قوة وتغذية معتمد';

  @override
  String get aboutLabel => 'نبذة';

  @override
  String get yearsExperienceLabel => 'سنوات الخبرة';

  @override
  String get specialtiesLabel => 'التخصصات';

  @override
  String get specialtiesHint => 'مفصولة بفواصل (مثال: خسارة وزن، كمال أجسام)';

  @override
  String get instagramLabel => 'إنستغرام';

  @override
  String get whatsappLabel => 'رقم واتساب';

  @override
  String get messageOnWhatsapp => 'مراسلة عبر واتساب';

  @override
  String get certifications => 'الشهادات';

  @override
  String get addCertification => 'إضافة شهادة';

  @override
  String get certTitleLabel => 'اسم الشهادة';

  @override
  String get issuerLabel => 'الجهة المانحة';

  @override
  String get yearLabel => 'السنة';

  @override
  String get transformationsTitle => 'التحولات';

  @override
  String get addTransformation => 'إضافة تحول';

  @override
  String get beforeLabel => 'قبل';

  @override
  String get afterLabel => 'بعد';

  @override
  String get captionLabel => 'وصف';

  @override
  String get durationResultLabel => 'المدة / النتيجة';

  @override
  String get documentsTitle => 'المستندات';

  @override
  String get uploadDocument => 'رفع ملف PDF / مستند';

  @override
  String get reviewsTitle => 'التقييمات';

  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد';

  @override
  String get rateYourCoach => 'قيّم مدربك';

  @override
  String get writeReviewOptional => 'اكتب تقييمًا (اختياري)';

  @override
  String get submitReview => 'إرسال التقييم';

  @override
  String get yourReview => 'تقييمك';

  @override
  String get reviewSubmitted => 'تم إرسال التقييم';

  @override
  String get statTrainees => 'المتدربون';

  @override
  String get statTransformations => 'التحولات';

  @override
  String get statYears => 'سنوات';

  @override
  String get statRating => 'التقييم';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get profileSaved => 'تم حفظ الملف';

  @override
  String registeredOn(String date) {
    return 'مسجَّل في $date';
  }

  @override
  String get nutritionTodayQuestion => 'هل التزمت بنظامك الغذائي اليوم؟';

  @override
  String get followedNutrition => 'التزمت';

  @override
  String get missedNutrition => 'لم ألتزم';

  @override
  String get watchVideo => 'مشاهدة الفيديو';

  @override
  String get exerciseVideo => 'فيديو التمرين';

  @override
  String get videoUrlLabel => 'رابط الفيديو (يوتيوب)';

  @override
  String get uploadVideo => 'رفع فيديو';

  @override
  String videoTooLarge(int mb) {
    return 'حجم الفيديو كبير جدًا (الحد الأقصى $mb ميجابايت).';
  }

  @override
  String get halfYear => '6 أشهر';

  @override
  String get restDayHint => 'يوم استراحة — بدون تمرين';
}
