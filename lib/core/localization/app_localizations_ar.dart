// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'كاشيس';

  @override
  String get commonOk => 'حسناً';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonSearch => 'بحث';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonLoading => 'جاري التحميل...';

  @override
  String get commonOffline => 'لا يوجد اتصال بالإنترنت';

  @override
  String get commonReadOnlyMode => 'وضع المشاهدة فقط';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get snackbarLoginSuccess => 'مرحباً بعودتك!';

  @override
  String get snackbarLoginError => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get snackbarLogoutSuccess => 'تم تسجيل الخروج بنجاح';

  @override
  String get snackbarPasswordResetSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور';

  @override
  String get snackbarCompanyAdded => 'تمت إضافة الشركة بنجاح';

  @override
  String get snackbarCompanyUpdated => 'تم تحديث الشركة بنجاح';

  @override
  String get snackbarCompanyDeleted => 'تم حذف الشركة بنجاح';

  @override
  String get snackbarUserAdded => 'تمت إضافة المستخدم بنجاح';

  @override
  String get snackbarUserUpdated => 'تم تحديث المستخدم بنجاح';

  @override
  String get snackbarUserDeleted => 'تم حذف المستخدم بنجاح';

  @override
  String get snackbarProjectAdded => 'تمت إضافة المشروع بنجاح';

  @override
  String get snackbarProjectUpdated => 'تم تحديث المشروع بنجاح';

  @override
  String get snackbarProjectDeleted => 'تم حذف المشروع بنجاح';

  @override
  String get snackbarEntryAdded => 'تمت إضافة القيد بنجاح';

  @override
  String get snackbarEntryUpdated => 'تم تحديث القيد بنجاح';

  @override
  String get snackbarEntryDeleted => 'تم حذف القيد بنجاح';

  @override
  String get snackbarReceiptUploaded => 'تم رفع الإيصال بنجاح';

  @override
  String get snackbarReceiptDeleted => 'تم حذف الإيصال بنجاح';

  @override
  String get snackbarProfileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get snackbarPasswordChanged => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get snackbarAvatarUpdated => 'تم تحديث الصورة الشخصية بنجاح';

  @override
  String get snackbarNotificationRead => 'تم تحديد الإشعار كمقروء';

  @override
  String get snackbarNotificationDeleted => 'تم حذف الإشعار بنجاح';

  @override
  String get snackbarPdfExported => 'تم تصدير ملف PDF بنجاح';

  @override
  String get snackbarAccountDeleted => 'تم حذف حسابك';

  @override
  String get snackbarSessionExpired => 'انتهت جلستك، سجل دخولك مرة أخرى';

  @override
  String get snackbarNoInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get snackbarProjectDeleted_notification => 'هذا المشروع تم حذفه';

  @override
  String get snackbarDuplicateEmail => 'البريد الإلكتروني مستخدم بالفعل';

  @override
  String get snackbarLogoUploadFailed => 'فشل رفع الشعار، يمكنك تحديثه لاحقاً';

  @override
  String get dialogDeleteCompanyTitle => 'حذف الشركة';

  @override
  String get dialogDeleteCompanyBody =>
      'هل أنت متأكد من حذف هذه الشركة؟ سيتم حذف جميع المستخدمين والمشاريع والقيود المرتبطة بها.';

  @override
  String get dialogDeleteUserTitle => 'حذف المستخدم';

  @override
  String get dialogDeleteUserBody =>
      'هل أنت متأكد من حذف هذا المستخدم؟ سيتم حذف جميع مشاريعه وقيوده.';

  @override
  String get dialogDeleteProjectTitle => 'حذف المشروع';

  @override
  String get dialogDeleteProjectBody =>
      'هل أنت متأكد من حذف هذا المشروع؟ سيتم حذف جميع القيود والإيصالات المرتبطة به.';

  @override
  String get dialogDeleteEntryTitle => 'حذف القيد';

  @override
  String get dialogDeleteEntryBody => 'هل أنت متأكد من حذف هذا القيد؟';

  @override
  String get dialogDeleteNotificationTitle => 'حذف الإشعار';

  @override
  String get dialogDeleteNotificationBody => 'هل أنت متأكد من حذف هذا الإشعار؟';

  @override
  String get dialogLogoutTitle => 'تسجيل الخروج';

  @override
  String get dialogLogoutBody => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get dialogUnsavedChangesTitle => 'تغييرات غير محفوظة';

  @override
  String get dialogUnsavedChangesBody =>
      'لديك تغييرات غير محفوظة. هل تريد المغادرة؟';

  @override
  String get dialogPdfNoReceiptsTitle => 'البيانات المالية فقط';

  @override
  String get dialogPdfNoReceiptsBody =>
      'جميع الإيصالات منتهية الصلاحية. هل تريد تصدير ملف PDF يحتوي على البيانات المالية فقط؟';

  @override
  String get emptyCompanies => 'لا توجد شركات حتى الآن';

  @override
  String get emptyUsers => 'لا يوجد مستخدمون في هذه الشركة';

  @override
  String get emptyProjects => 'لا توجد مشاريع حتى الآن';

  @override
  String get emptyEntries => 'لا توجد قيود في هذا المشروع';

  @override
  String get emptyImages => 'لا توجد إيصالات مرفوعة';

  @override
  String get emptyNotifications => 'لا توجد إشعارات';

  @override
  String get emptySearchResults => 'لا توجد نتائج';

  @override
  String get authWelcomeBack => 'مرحباً بعودتك';

  @override
  String get authSubtitle => 'سجّل دخولك للمتابعة';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authResetCta => 'إرسال رابط إعادة التعيين';

  @override
  String get authResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين';

  @override
  String get authEmailSentTitle => 'تم إرسال الرابط';

  @override
  String get authEmailSentSubtitle =>
      'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور';

  @override
  String get authBackToLogin => 'العودة لتسجيل الدخول';

  @override
  String get ownerCompaniesTitle => 'الشركات';

  @override
  String get ownerAddCompany => 'إضافة شركة';

  @override
  String get ownerAddUser => 'إضافة مستخدم';

  @override
  String get ownerTotalCompanies => 'إجمالي الشركات';

  @override
  String get ownerTotalUsers => 'إجمالي المستخدمين';

  @override
  String get ownerCompanyName => 'اسم الشركة';

  @override
  String get ownerCompanyLogo => 'شعار الشركة';

  @override
  String get ownerAddCompanyTitle => 'إضافة شركة جديدة';

  @override
  String get ownerEditCompanyTitle => 'تعديل الشركة';

  @override
  String get ownerUsersTitle => 'المستخدمون';

  @override
  String get ownerCreateUserTitle => 'إضافة مستخدم جديد';

  @override
  String get ownerEditUserTitle => 'تعديل المستخدم';

  @override
  String get ownerUserFullName => 'الاسم الكامل';

  @override
  String get ownerUserEmail => 'البريد الإلكتروني';

  @override
  String get ownerUserPassword => 'كلمة المرور';

  @override
  String get ownerUserConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get ownerUserCompany => 'الشركة';

  @override
  String get ownerDeletingCompany => 'جاري الحذف...';

  @override
  String get adminAllUsers => 'جميع المستخدمين';

  @override
  String get adminAlertsTitle => 'الإشعارات';

  @override
  String get adminAlertsSubtitle => 'آخر التحديثات';

  @override
  String get adminTypeNewAssignment => 'تكليف جديد';

  @override
  String get adminTypeUpdateLog => 'سجل تحديث';

  @override
  String get adminTypeStructuralAlert => 'تنبيه هيكلي';

  @override
  String get adminTypeArchived => 'مؤرشف';

  @override
  String get adminUnreadBadgeOverflow => '99+';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsPersonalInfo => 'المعلومات الشخصية';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsAppVersion => 'إصدار التطبيق';

  @override
  String get settingsDarkMode => 'الوضع الداكن';

  @override
  String get settingsLightMode => 'الوضع الفاتح';

  @override
  String get settingsArabic => 'العربية';

  @override
  String get settingsEnglish => 'الإنجليزية';

  @override
  String get settingsEditProfile => 'تعديل الملف الشخصي';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get settingsNewPassword => 'كلمة المرور الجديدة';

  @override
  String get settingsConfirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get settingsChangeAvatar => 'تغيير الصورة الشخصية';

  @override
  String get settingsEmailConfirmBanner => 'تم إرسال رابط تأكيد لبريدك الجديد';

  @override
  String get projectsWelcome => 'مرحباً';

  @override
  String get projectsCuratedOverview => 'نظرة عامة على مشاريعك';

  @override
  String get projectsActiveDevelopments => 'المشاريع النشطة';

  @override
  String get projectsTotalPortfolio => 'إجمالي قيمة المحفظة';

  @override
  String get projectsCreateTitle => 'إنشاء مشروع جديد';

  @override
  String get projectsCreateSubtitle => 'أدخل اسم المشروع للبدء';

  @override
  String get projectsProjectName => 'اسم المشروع';

  @override
  String get projectsSettingsTitle => 'إعدادات المشروع';

  @override
  String get projectsRenameProject => 'إعادة تسمية المشروع';

  @override
  String get projectsDeleteProject => 'حذف المشروع';

  @override
  String get invoicesTotal => 'إجمالي المصروفات';

  @override
  String get invoicesUpdatedAt => 'آخر تحديث';

  @override
  String get invoicesAddEntry => 'إضافة قيد';

  @override
  String get invoicesEditEntry => 'تعديل القيد';

  @override
  String get invoicesAddEntryTitle => 'إضافة قيد جديد';

  @override
  String get invoicesAmount => 'المبلغ';

  @override
  String get invoicesVendor => 'اسم المورد / الوصف';

  @override
  String get invoicesDate => 'التاريخ';

  @override
  String get invoicesReceipt => 'الإيصال';

  @override
  String get invoicesAttachReceipt => 'إرفاق إيصال (اختياري)';

  @override
  String get invoicesCamera => 'الكاميرا';

  @override
  String get invoicesGallery => 'المعرض';

  @override
  String get invoicesExpiryWarning => 'تنتهي صلاحية بعض الإيصالات خلال 5 أيام';

  @override
  String get invoicesPdfExport => 'تصدير PDF';

  @override
  String get invoicesTabLedger => 'دفتر الأستاذ';

  @override
  String get invoicesTabImages => 'الإيصالات';

  @override
  String invoicesUpdatedMinutesAgo(int minutes) {
    return '$minutes دقيقة مضت';
  }

  @override
  String invoicesUpdatedHoursAgo(int hours) {
    return '$hours ساعة مضت';
  }

  @override
  String get invoicesUpdatedJustNow => 'الآن';

  @override
  String get invoicesProcessingImage => 'جاري معالجة الصورة...';

  @override
  String get invoicesKeepAppOpen => 'اترك التطبيق مفتوحاً حتى يكتمل الرفع';

  @override
  String get errorGeneric => 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';

  @override
  String get errorNetwork => 'تعذر الاتصال بالشبكة';

  @override
  String get errorPermission => 'لا تملك الصلاحية لإجراء هذه العملية';

  @override
  String get errorValidation => 'يرجى التحقق من البيانات المدخلة';

  @override
  String get errorImageProcess => 'فشلت معالجة الصورة، يرجى المحاولة مرة أخرى';

  @override
  String get errorPdfFailed => 'فشل تصدير ملف PDF، يرجى المحاولة مرة أخرى';

  @override
  String get errorAccountDeleted => 'تم حذف حسابك';

  @override
  String get errorSessionExpired => 'انتهت صلاحية الجلسة';

  @override
  String get errorNotFound => 'العنصر المطلوب غير موجود';

  @override
  String get errorTimeout => 'انتهت مهلة الطلب، يرجى التحقق من اتصالك';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

  @override
  String get validationEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get validationPasswordMinLength =>
      'كلمة المرور يجب أن تكون 8 أحرف على الأقل';

  @override
  String get validationAmountPositive => 'المبلغ يجب أن يكون أكبر من صفر';

  @override
  String get validationNameMinLength => 'الاسم يجب أن يكون حرفين على الأقل';

  @override
  String get validationConfirmPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get validationAmountInvalid => 'يرجى إدخال مبلغ صحيح';

  @override
  String get validationFutureDateNotAllowed => 'لا يمكن اختيار تاريخ مستقبلي';
}
