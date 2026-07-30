/// All Arabic strings used in the BuzzMaster UI.
/// No Arabic text should appear hardcoded in widget files.
library;

class ArabicStrings {
  ArabicStrings._();

  // ─── App ───────────────────────────────────────────────────────────────────
  static const String appName = 'بازماستر';
  static const String appTagline = 'نظام البازر التفاعلي';

  // ─── General ───────────────────────────────────────────────────────────────
  static const String ok = 'موافق';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String back = 'رجوع';
  static const String next = 'التالي';
  static const String save = 'حفظ';
  static const String close = 'إغلاق';
  static const String retry = 'إعادة المحاولة';
  static const String loading = 'جاري التحميل...';
  static const String error = 'خطأ';
  static const String success = 'نجاح';
  static const String warning = 'تحذير';
  static const String yes = 'نعم';
  static const String no = 'لا';
  static const String search = 'بحث';
  static const String share = 'مشاركة';
  static const String export = 'تصدير';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String done = 'تم';
  static const String skip = 'تخطي';
  static const String start = 'ابدأ';
  static const String stop = 'إيقاف';
  static const String pause = 'إيقاف مؤقت';
  static const String resume = 'استمرار';
  static const String reset = 'إعادة ضبط';

  // ─── Onboarding ────────────────────────────────────────────────────────────
  static const String onboardingTitle1 = 'مرحباً بك في بازماستر';
  static const String onboardingDesc1 =
      'نظام بازر تفاعلي للمسابقات الجماعية بالوقت الفعلي';
  static const String onboardingTitle2 = 'سريع وعادل';
  static const String onboardingDesc2 =
      'يحدد الفائز بدقة أقل من 50 ملي ثانية على الشبكة المحلية';
  static const String onboardingTitle3 = 'بدون إنترنت';
  static const String onboardingDesc3 =
      'يعمل عبر شبكة Wi-Fi المحلية فقط. لا حاجة للإنترنت';

  // ─── Role Selection ────────────────────────────────────────────────────────
  static const String chooseRole = 'اختر دورك';
  static const String hostRole = 'مضيف';
  static const String hostRoleDesc = 'أنشئ غرفة وأدر المسابقة';
  static const String teamRole = 'فريق';
  static const String teamRoleDesc = 'انضم إلى غرفة وشارك في المسابقة';

  // ─── Host – Create Room ────────────────────────────────────────────────────
  static const String createRoom = 'إنشاء غرفة';
  static const String roomCode = 'رمز الغرفة';
  static const String roomCodeHint = 'أدخل اسم المسابقة';
  static const String competitionName = 'اسم المسابقة';
  static const String generateCode = 'توليد رمز';
  static const String shareCode = 'مشاركة الرمز';
  static const String showQR = 'عرض رمز QR';
  static const String scanQR = 'مسح رمز QR';
  static const String copyCode = 'نسخ الرمز';
  static const String codeCopied = 'تم نسخ الرمز';

  // ─── Host – Lobby ──────────────────────────────────────────────────────────
  static const String lobby = 'غرفة الانتظار';
  static const String waitingForTeams = 'في انتظار الفرق...';
  static const String teamsConnected = 'الفرق المتصلة';
  static const String noTeamsYet = 'لم ينضم أي فريق بعد';
  static const String lockRoom = 'قفل الغرفة';
  static const String unlockRoom = 'فتح الغرفة';
  static const String kickTeam = 'طرد الفريق';
  static const String kickTeamConfirm = 'هل تريد طرد هذا الفريق؟';
  static const String startCompetition = 'بدء المسابقة';
  static const String minTeamsRequired = 'يجب أن ينضم فريق واحد على الأقل';

  // ─── Host – Game ───────────────────────────────────────────────────────────
  static const String round = 'الجولة';
  static const String roundNumber = 'الجولة رقم';
  static const String openRound = 'فتح الجولة';
  static const String closeRound = 'إغلاق الجولة';
  static const String resetRound = 'إعادة ضبط الجولة';
  static const String nextRound = 'الجولة التالية';
  static const String endCompetition = 'إنهاء المسابقة';
  static const String pauseCompetition = 'إيقاف مؤقت';
  static const String resumeCompetition = 'استمرار المسابقة';
  static const String acceptAnswer = 'قبول الإجابة';
  static const String rejectAnswer = 'رفض الإجابة';
  static const String reopenBuzz = 'إعادة فتح البازر';
  static const String waitingForBuzz = 'في انتظار الضغط على البازر...';
  static const String roundOpen = 'الجولة مفتوحة!';
  static const String roundClosed = 'الجولة مغلقة';
  static const String competitionPaused = 'المسابقة متوقفة مؤقتاً';

  // ─── Host – Winner ─────────────────────────────────────────────────────────
  static const String winner = 'الفائز';
  static const String winnerIs = 'الفائز هو';
  static const String reactionTime = 'وقت الاستجابة';
  static const String milliseconds = 'ملي ثانية';
  static const String noWinner = 'لا يوجد فائز';

  // ─── Team – Join ───────────────────────────────────────────────────────────
  static const String joinRoom = 'الانضمام إلى غرفة';
  static const String enterRoomCode = 'أدخل رمز الغرفة';
  static const String roomCodeLabel = 'رمز الغرفة';
  static const String joinNow = 'انضم الآن';
  static const String orScanQR = 'أو امسح رمز QR';
  static const String invalidCode = 'الرمز غير صحيح';
  static const String roomNotFound = 'الغرفة غير موجودة';
  static const String roomFull = 'الغرفة ممتلئة';
  static const String roomLocked = 'الغرفة مقفلة';
  static const String alreadyJoined = 'أنت موجود بالفعل في هذه الغرفة';
  static const String connectingToRoom = 'جاري الاتصال بالغرفة...';

  // ─── Team – Setup ──────────────────────────────────────────────────────────
  static const String teamSetup = 'إعداد الفريق';
  static const String teamName = 'اسم الفريق';
  static const String teamNameHint = 'أدخل اسم فريقك';
  static const String teamColor = 'لون الفريق';
  static const String teamAvatar = 'صورة الفريق';
  static const String chooseAvatar = 'اختر الصورة';
  static const String chooseColor = 'اختر اللون';
  static const String teamNameRequired = 'اسم الفريق مطلوب';
  static const String teamNameTooLong = 'اسم الفريق طويل جداً (20 حرف كحد أقصى)';

  // ─── Team – Waiting ────────────────────────────────────────────────────────
  static const String waitingForHost = 'في انتظار المضيف...';
  static const String connectedToRoom = 'متصل بالغرفة';
  static const String ready = 'جاهز';
  static const String notReady = 'غير جاهز';
  static const String youAreConnected = 'أنت متصل';
  static const String disconnected = 'انقطع الاتصال';
  static const String reconnecting = 'جاري إعادة الاتصال...';

  // ─── Team – Buzz ───────────────────────────────────────────────────────────
  static const String pressTheBuzzer = 'اضغط البازر!';
  static const String buzzerLocked = 'البازر مقفل';
  static const String buzzSent = 'تم الإرسال!';
  static const String youWon = 'أنت الفائز! 🏆';
  static const String youLost = 'سبقك أحد! حاول مجدداً';
  static const String waitingForRound = 'انتظر فتح الجولة';
  static const String roundIsOpen = 'الجولة مفتوحة - اضغط الآن!';

  // ─── Statistics ────────────────────────────────────────────────────────────
  static const String statistics = 'الإحصائيات';
  static const String leaderboard = 'لوحة المتصدرين';
  static const String fastestReaction = 'أسرع استجابة';
  static const String averageReaction = 'متوسط الاستجابة';
  static const String totalWins = 'إجمالي الانتصارات';
  static const String totalBuzzAttempts = 'إجمالي محاولات البازر';
  static const String rank = 'الترتيب';
  static const String reactionGraph = 'رسم الاستجابة';
  static const String perRoundStats = 'إحصائيات كل جولة';
  static const String teamStatistics = 'إحصائيات الفريق';
  static const String overallRanking = 'الترتيب العام';
  static const String winRate = 'نسبة الفوز';
  static const String noStatistics = 'لا توجد إحصائيات بعد';

  // ─── History ───────────────────────────────────────────────────────────────
  static const String history = 'السجل';
  static const String competitionHistory = 'سجل المسابقات';
  static const String noHistory = 'لا توجد مسابقات سابقة';
  static const String dateTime = 'التاريخ والوقت';
  static const String duration = 'المدة';
  static const String totalRounds = 'إجمالي الجولات';
  static const String champion = 'البطل';

  // ─── Export ────────────────────────────────────────────────────────────────
  static const String exportResults = 'تصدير النتائج';
  static const String exportPDF = 'تصدير PDF';
  static const String exportCSV = 'تصدير CSV';
  static const String exportJSON = 'تصدير JSON';
  static const String shareResults = 'مشاركة النتائج';
  static const String exportSuccess = 'تم التصدير بنجاح';
  static const String exportError = 'فشل التصدير';
  static const String generatingReport = 'جاري إنشاء التقرير...';

  // ─── Settings ──────────────────────────────────────────────────────────────
  static const String settings = 'الإعدادات';
  static const String language = 'اللغة';
  static const String arabic = 'العربية';
  static const String english = 'الإنجليزية';
  static const String darkMode = 'الوضع الداكن';
  static const String lightMode = 'الوضع الفاتح';
  static const String theme = 'المظهر';
  static const String sound = 'الصوت';
  static const String vibration = 'الاهتزاز';
  static const String animations = 'الحركات';
  static const String autoReconnect = 'إعادة الاتصال التلقائي';
  static const String about = 'حول التطبيق';
  static const String version = 'الإصدار';

  // ─── Network ───────────────────────────────────────────────────────────────
  static const String networkStatus = 'حالة الشبكة';
  static const String signalQuality = 'جودة الإشارة';
  static const String ping = 'زمن الاستجابة';
  static const String latency = 'التأخير';
  static const String battery = 'البطارية';
  static const String connectionState = 'حالة الاتصال';
  static const String connected = 'متصل';
  static const String connecting = 'جاري الاتصال';
  static const String excellent = 'ممتاز';
  static const String good = 'جيد';
  static const String fair = 'مقبول';
  static const String poor = 'ضعيف';
  static const String networkError = 'خطأ في الشبكة';
  static const String checkNetwork = 'تحقق من الشبكة';
  static const String sameNetworkRequired = 'يجب أن تكون على نفس شبكة Wi-Fi';

  // ─── Errors ────────────────────────────────────────────────────────────────
  static const String unknownError = 'حدث خطأ غير معروف';
  static const String connectionFailed = 'فشل الاتصال';
  static const String timeout = 'انتهت مهلة الاتصال';
  static const String serverError = 'خطأ في الخادم';
  static const String permissionRequired = 'الإذن مطلوب';
  static const String wifiRequired = 'يجب تفعيل Wi-Fi';
  static const String locationRequired = 'يجب تفعيل الموقع للبحث عن الأجهزة';

  // ─── Avatars ───────────────────────────────────────────────────────────────
  static const Map<String, String> avatarNames = {
    'lion': 'الأسد',
    'eagle': 'النسر',
    'wolf': 'الذئب',
    'fox': 'الثعلب',
    'bear': 'الدب',
    'tiger': 'النمر',
    'shark': 'القرش',
    'falcon': 'الصقر',
    'dragon': 'التنين',
    'phoenix': 'العنقاء',
    'panther': 'الفهد',
    'bull': 'الثور',
  };

  // ─── Color Names ───────────────────────────────────────────────────────────
  static const List<String> colorNames = [
    'أحمر', 'أزرق', 'أخضر', 'برتقالي',
    'بنفسجي', 'سماوي', 'ذهبي', 'وردي',
  ];

  // ─── Date Format ───────────────────────────────────────────────────────────
  static const String dateFormat = 'yyyy/MM/dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy/MM/dd – HH:mm';

  // ─── PDF Report ────────────────────────────────────────────────────────────
  static const String pdfTitle = 'تقرير المسابقة';
  static const String pdfSubtitle = 'بازماستر – نظام البازر التفاعلي';
  static const String pdfGeneratedAt = 'تاريخ الإنشاء';
  static const String pdfCompetitionDetails = 'تفاصيل المسابقة';
  static const String pdfRoundResults = 'نتائج الجولات';
  static const String pdfTeamStatistics = 'إحصائيات الفرق';

  // ─── CSV Headers ───────────────────────────────────────────────────────────
  static const String csvTeam = 'الفريق';
  static const String csvRound = 'الجولة';
  static const String csvWinner = 'الفائز';
  static const String csvReactionTime = 'وقت الاستجابة (مللي ثانية)';
  static const String csvBuzzAttempts = 'محاولات البازر';
  static const String csvWins = 'الانتصارات';
  static const String csvRank = 'الترتيب';

  // ─── End Competition ───────────────────────────────────────────────────────
  static const String competitionOver = 'انتهت المسابقة';
  static const String finalResults = 'النتائج النهائية';
  static const String congratulations = 'مبروك!';
  static const String champion2 = 'البطل';
  static const String viewStats = 'عرض الإحصائيات';
  static const String newCompetition = 'مسابقة جديدة';
  static const String endCompetitionConfirm =
      'هل تريد إنهاء المسابقة؟ لا يمكن التراجع عن هذا القرار.';
}
