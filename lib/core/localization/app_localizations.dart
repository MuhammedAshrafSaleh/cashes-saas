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
/// import 'localization/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
  ];

  /// Application name
  ///
  /// In ar, this message translates to:
  /// **'كاشيس'**
  String get appName;

  /// OK button label
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get commonOk;

  /// Cancel button label
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// Save button label
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// Delete button label
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// Edit button label
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get commonEdit;

  /// Add button label
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get commonAdd;

  /// Retry button label
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// Search hint
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get commonSearch;

  /// Refresh label
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get commonRefresh;

  /// Loading indicator text
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get commonLoading;

  /// Offline banner message
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get commonOffline;

  /// Read-only mode banner
  ///
  /// In ar, this message translates to:
  /// **'وضع المشاهدة فقط'**
  String get commonReadOnlyMode;

  /// Confirm button label
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// Close button label
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get commonClose;

  /// Back button label
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// Yes label
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get commonYes;

  /// No label
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get commonNo;

  /// Snackbar on successful login
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك!'**
  String get snackbarLoginSuccess;

  /// Snackbar on login failure
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة'**
  String get snackbarLoginError;

  /// Snackbar on logout
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الخروج بنجاح'**
  String get snackbarLogoutSuccess;

  /// Snackbar on password reset email sent
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط إعادة تعيين كلمة المرور'**
  String get snackbarPasswordResetSent;

  /// Snackbar on company created
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة الشركة بنجاح'**
  String get snackbarCompanyAdded;

  /// Snackbar on company updated
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الشركة بنجاح'**
  String get snackbarCompanyUpdated;

  /// Snackbar on company deleted
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الشركة بنجاح'**
  String get snackbarCompanyDeleted;

  /// Snackbar on user created
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة المستخدم بنجاح'**
  String get snackbarUserAdded;

  /// Snackbar on user updated
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المستخدم بنجاح'**
  String get snackbarUserUpdated;

  /// Snackbar on user deleted
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المستخدم بنجاح'**
  String get snackbarUserDeleted;

  /// Snackbar on project created
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة المشروع بنجاح'**
  String get snackbarProjectAdded;

  /// Snackbar on project updated
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المشروع بنجاح'**
  String get snackbarProjectUpdated;

  /// Snackbar on project deleted
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المشروع بنجاح'**
  String get snackbarProjectDeleted;

  /// Snackbar on cash entry created
  ///
  /// In ar, this message translates to:
  /// **'تمت إضافة القيد بنجاح'**
  String get snackbarEntryAdded;

  /// Snackbar on cash entry updated
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث القيد بنجاح'**
  String get snackbarEntryUpdated;

  /// Snackbar on cash entry deleted
  ///
  /// In ar, this message translates to:
  /// **'تم حذف القيد بنجاح'**
  String get snackbarEntryDeleted;

  /// Snackbar on receipt uploaded
  ///
  /// In ar, this message translates to:
  /// **'تم رفع الإيصال بنجاح'**
  String get snackbarReceiptUploaded;

  /// Snackbar on receipt deleted
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الإيصال بنجاح'**
  String get snackbarReceiptDeleted;

  /// Snackbar on profile updated
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي بنجاح'**
  String get snackbarProfileUpdated;

  /// Snackbar on password changed
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get snackbarPasswordChanged;

  /// Snackbar on avatar updated
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الصورة الشخصية بنجاح'**
  String get snackbarAvatarUpdated;

  /// Snackbar on notification marked read
  ///
  /// In ar, this message translates to:
  /// **'تم تحديد الإشعار كمقروء'**
  String get snackbarNotificationRead;

  /// Snackbar on notification deleted
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الإشعار بنجاح'**
  String get snackbarNotificationDeleted;

  /// Snackbar on PDF exported
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير ملف PDF بنجاح'**
  String get snackbarPdfExported;

  /// Snackbar when account is deleted mid-session
  ///
  /// In ar, this message translates to:
  /// **'تم حذف حسابك'**
  String get snackbarAccountDeleted;

  /// Snackbar when JWT refresh fails
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك، سجل دخولك مرة أخرى'**
  String get snackbarSessionExpired;

  /// Snackbar on network failure
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get snackbarNoInternet;

  /// Snackbar when notification project is gone
  ///
  /// In ar, this message translates to:
  /// **'هذا المشروع تم حذفه'**
  String get snackbarProjectDeleted_notification;

  /// Snackbar on duplicate email
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني مستخدم بالفعل'**
  String get snackbarDuplicateEmail;

  /// Snackbar when logo upload fails but company was created
  ///
  /// In ar, this message translates to:
  /// **'فشل رفع الشعار، يمكنك تحديثه لاحقاً'**
  String get snackbarLogoUploadFailed;

  /// Delete company dialog title
  ///
  /// In ar, this message translates to:
  /// **'حذف الشركة'**
  String get dialogDeleteCompanyTitle;

  /// Delete company dialog body
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه الشركة؟ سيتم حذف جميع المستخدمين والمشاريع والقيود المرتبطة بها.'**
  String get dialogDeleteCompanyBody;

  /// Delete user dialog title
  ///
  /// In ar, this message translates to:
  /// **'حذف المستخدم'**
  String get dialogDeleteUserTitle;

  /// Delete user dialog body
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المستخدم؟ سيتم حذف جميع مشاريعه وقيوده.'**
  String get dialogDeleteUserBody;

  /// Delete project dialog title
  ///
  /// In ar, this message translates to:
  /// **'حذف المشروع'**
  String get dialogDeleteProjectTitle;

  /// Delete project dialog body
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المشروع؟ سيتم حذف جميع القيود والإيصالات المرتبطة به.'**
  String get dialogDeleteProjectBody;

  /// Delete entry dialog title
  ///
  /// In ar, this message translates to:
  /// **'حذف القيد'**
  String get dialogDeleteEntryTitle;

  /// Delete entry dialog body
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا القيد؟'**
  String get dialogDeleteEntryBody;

  /// Delete notification dialog title
  ///
  /// In ar, this message translates to:
  /// **'حذف الإشعار'**
  String get dialogDeleteNotificationTitle;

  /// Delete notification dialog body
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الإشعار؟'**
  String get dialogDeleteNotificationBody;

  /// Logout dialog title
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get dialogLogoutTitle;

  /// Logout dialog body
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get dialogLogoutBody;

  /// Unsaved changes dialog title
  ///
  /// In ar, this message translates to:
  /// **'تغييرات غير محفوظة'**
  String get dialogUnsavedChangesTitle;

  /// Unsaved changes dialog body
  ///
  /// In ar, this message translates to:
  /// **'لديك تغييرات غير محفوظة. هل تريد المغادرة؟'**
  String get dialogUnsavedChangesBody;

  /// PDF export without receipts dialog title
  ///
  /// In ar, this message translates to:
  /// **'البيانات المالية فقط'**
  String get dialogPdfNoReceiptsTitle;

  /// PDF export without receipts dialog body
  ///
  /// In ar, this message translates to:
  /// **'جميع الإيصالات منتهية الصلاحية. هل تريد تصدير ملف PDF يحتوي على البيانات المالية فقط؟'**
  String get dialogPdfNoReceiptsBody;

  /// Empty state for companies list
  ///
  /// In ar, this message translates to:
  /// **'لا توجد شركات حتى الآن'**
  String get emptyCompanies;

  /// Empty state for users list
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مستخدمون في هذه الشركة'**
  String get emptyUsers;

  /// Empty state for projects list
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشاريع حتى الآن'**
  String get emptyProjects;

  /// Empty state for entries list
  ///
  /// In ar, this message translates to:
  /// **'لا توجد قيود في هذا المشروع'**
  String get emptyEntries;

  /// Empty state for images tab
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إيصالات مرفوعة'**
  String get emptyImages;

  /// Empty state for notifications
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات'**
  String get emptyNotifications;

  /// Empty state for search results
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get emptySearchResults;

  /// Auth screen welcome heading
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get authWelcomeBack;

  /// Auth screen subtitle
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك للمتابعة'**
  String get authSubtitle;

  /// Email field label
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get authEmail;

  /// Password field label
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPassword;

  /// Login button label
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLogin;

  /// Forgot password link
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// Send reset link button
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط إعادة التعيين'**
  String get authResetCta;

  /// Forgot password screen title
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get authResetTitle;

  /// Forgot password screen subtitle
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين'**
  String get authResetSubtitle;

  /// Email sent screen title
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الرابط'**
  String get authEmailSentTitle;

  /// Email sent screen subtitle
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني واتبع التعليمات لإعادة تعيين كلمة المرور'**
  String get authEmailSentSubtitle;

  /// Back to login link
  ///
  /// In ar, this message translates to:
  /// **'العودة لتسجيل الدخول'**
  String get authBackToLogin;

  /// Owner companies screen title
  ///
  /// In ar, this message translates to:
  /// **'الشركات'**
  String get ownerCompaniesTitle;

  /// Add company button
  ///
  /// In ar, this message translates to:
  /// **'إضافة شركة'**
  String get ownerAddCompany;

  /// Add user button
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم'**
  String get ownerAddUser;

  /// Total companies stat label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الشركات'**
  String get ownerTotalCompanies;

  /// Total users stat label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المستخدمين'**
  String get ownerTotalUsers;

  /// Company name field label
  ///
  /// In ar, this message translates to:
  /// **'اسم الشركة'**
  String get ownerCompanyName;

  /// Company logo field label
  ///
  /// In ar, this message translates to:
  /// **'شعار الشركة'**
  String get ownerCompanyLogo;

  /// Add company screen title
  ///
  /// In ar, this message translates to:
  /// **'إضافة شركة جديدة'**
  String get ownerAddCompanyTitle;

  /// Edit company screen title
  ///
  /// In ar, this message translates to:
  /// **'تعديل الشركة'**
  String get ownerEditCompanyTitle;

  /// Owner users list screen title
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون'**
  String get ownerUsersTitle;

  /// Create user screen title
  ///
  /// In ar, this message translates to:
  /// **'إضافة مستخدم جديد'**
  String get ownerCreateUserTitle;

  /// Edit user screen title
  ///
  /// In ar, this message translates to:
  /// **'تعديل المستخدم'**
  String get ownerEditUserTitle;

  /// Full name field label
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get ownerUserFullName;

  /// User email field label
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get ownerUserEmail;

  /// User password field label
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get ownerUserPassword;

  /// Confirm password field label
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get ownerUserConfirmPassword;

  /// Company dropdown label
  ///
  /// In ar, this message translates to:
  /// **'الشركة'**
  String get ownerUserCompany;

  /// Full-screen loader during company deletion
  ///
  /// In ar, this message translates to:
  /// **'جاري الحذف...'**
  String get ownerDeletingCompany;

  /// Admin users tab title
  ///
  /// In ar, this message translates to:
  /// **'جميع المستخدمين'**
  String get adminAllUsers;

  /// Admin notifications tab title
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get adminAlertsTitle;

  /// Admin notifications subtitle
  ///
  /// In ar, this message translates to:
  /// **'آخر التحديثات'**
  String get adminAlertsSubtitle;

  /// Notification type: new_assignment
  ///
  /// In ar, this message translates to:
  /// **'تكليف جديد'**
  String get adminTypeNewAssignment;

  /// Notification type: update_log
  ///
  /// In ar, this message translates to:
  /// **'سجل تحديث'**
  String get adminTypeUpdateLog;

  /// Notification type: structural_alert
  ///
  /// In ar, this message translates to:
  /// **'تنبيه هيكلي'**
  String get adminTypeStructuralAlert;

  /// Notification type: archived
  ///
  /// In ar, this message translates to:
  /// **'مؤرشف'**
  String get adminTypeArchived;

  /// Unread notifications overflow badge
  ///
  /// In ar, this message translates to:
  /// **'99+'**
  String get adminUnreadBadgeOverflow;

  /// Settings screen title
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// Settings section: personal info
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get settingsPersonalInfo;

  /// Settings: language toggle
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// Settings: theme toggle
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsAppearance;

  /// Settings: logout button
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get settingsLogout;

  /// Settings: app version label
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق'**
  String get settingsAppVersion;

  /// Dark mode toggle label
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get settingsDarkMode;

  /// Light mode toggle label
  ///
  /// In ar, this message translates to:
  /// **'الوضع الفاتح'**
  String get settingsLightMode;

  /// Arabic language option
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settingsArabic;

  /// English language option
  ///
  /// In ar, this message translates to:
  /// **'الإنجليزية'**
  String get settingsEnglish;

  /// Edit profile button
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get settingsEditProfile;

  /// Change password section
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get settingsChangePassword;

  /// Current password field
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get settingsCurrentPassword;

  /// New password field
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get settingsNewPassword;

  /// Confirm new password field
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get settingsConfirmNewPassword;

  /// Change avatar button
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة الشخصية'**
  String get settingsChangeAvatar;

  /// Banner shown after email change pending verification
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط تأكيد لبريدك الجديد'**
  String get settingsEmailConfirmBanner;

  /// Projects screen welcome prefix
  ///
  /// In ar, this message translates to:
  /// **'مرحباً'**
  String get projectsWelcome;

  /// Projects screen subtitle
  ///
  /// In ar, this message translates to:
  /// **'نظرة عامة على مشاريعك'**
  String get projectsCuratedOverview;

  /// Projects list heading
  ///
  /// In ar, this message translates to:
  /// **'المشاريع النشطة'**
  String get projectsActiveDevelopments;

  /// Portfolio total footer label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي قيمة المحفظة'**
  String get projectsTotalPortfolio;

  /// Create project sheet title
  ///
  /// In ar, this message translates to:
  /// **'إنشاء مشروع جديد'**
  String get projectsCreateTitle;

  /// Create project sheet subtitle
  ///
  /// In ar, this message translates to:
  /// **'أدخل اسم المشروع للبدء'**
  String get projectsCreateSubtitle;

  /// Project name field label
  ///
  /// In ar, this message translates to:
  /// **'اسم المشروع'**
  String get projectsProjectName;

  /// Project settings sheet title
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المشروع'**
  String get projectsSettingsTitle;

  /// Rename project option
  ///
  /// In ar, this message translates to:
  /// **'إعادة تسمية المشروع'**
  String get projectsRenameProject;

  /// Delete project option
  ///
  /// In ar, this message translates to:
  /// **'حذف المشروع'**
  String get projectsDeleteProject;

  /// Total invoiced label
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المصروفات'**
  String get invoicesTotal;

  /// Last updated label
  ///
  /// In ar, this message translates to:
  /// **'آخر تحديث'**
  String get invoicesUpdatedAt;

  /// Add cash entry button
  ///
  /// In ar, this message translates to:
  /// **'إضافة قيد'**
  String get invoicesAddEntry;

  /// Edit cash entry screen title
  ///
  /// In ar, this message translates to:
  /// **'تعديل القيد'**
  String get invoicesEditEntry;

  /// Add cash entry screen title
  ///
  /// In ar, this message translates to:
  /// **'إضافة قيد جديد'**
  String get invoicesAddEntryTitle;

  /// Amount field label
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get invoicesAmount;

  /// Entry name/vendor field label
  ///
  /// In ar, this message translates to:
  /// **'اسم المورد / الوصف'**
  String get invoicesVendor;

  /// Entry date field label
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get invoicesDate;

  /// Receipt section label
  ///
  /// In ar, this message translates to:
  /// **'الإيصال'**
  String get invoicesReceipt;

  /// Attach receipt button
  ///
  /// In ar, this message translates to:
  /// **'إرفاق إيصال (اختياري)'**
  String get invoicesAttachReceipt;

  /// Camera option in picker sheet
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get invoicesCamera;

  /// Gallery option in picker sheet
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get invoicesGallery;

  /// Receipt expiry warning banner
  ///
  /// In ar, this message translates to:
  /// **'تنتهي صلاحية بعض الإيصالات خلال 5 أيام'**
  String get invoicesExpiryWarning;

  /// PDF export button
  ///
  /// In ar, this message translates to:
  /// **'تصدير PDF'**
  String get invoicesPdfExport;

  /// Invoices ledger tab label
  ///
  /// In ar, this message translates to:
  /// **'دفتر الأستاذ'**
  String get invoicesTabLedger;

  /// Images tab label
  ///
  /// In ar, this message translates to:
  /// **'الإيصالات'**
  String get invoicesTabImages;

  /// Relative time minutes ago
  ///
  /// In ar, this message translates to:
  /// **'{minutes} دقيقة مضت'**
  String invoicesUpdatedMinutesAgo(int minutes);

  /// Relative time hours ago
  ///
  /// In ar, this message translates to:
  /// **'{hours} ساعة مضت'**
  String invoicesUpdatedHoursAgo(int hours);

  /// Relative time just now
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get invoicesUpdatedJustNow;

  /// Image compression overlay text
  ///
  /// In ar, this message translates to:
  /// **'جاري معالجة الصورة...'**
  String get invoicesProcessingImage;

  /// Upload in progress overlay message
  ///
  /// In ar, this message translates to:
  /// **'اترك التطبيق مفتوحاً حتى يكتمل الرفع'**
  String get invoicesKeepAppOpen;

  /// Generic error message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى'**
  String get errorGeneric;

  /// Network error message
  ///
  /// In ar, this message translates to:
  /// **'تعذر الاتصال بالشبكة'**
  String get errorNetwork;

  /// Permission error message
  ///
  /// In ar, this message translates to:
  /// **'لا تملك الصلاحية لإجراء هذه العملية'**
  String get errorPermission;

  /// Validation error message
  ///
  /// In ar, this message translates to:
  /// **'يرجى التحقق من البيانات المدخلة'**
  String get errorValidation;

  /// Image processing error
  ///
  /// In ar, this message translates to:
  /// **'فشلت معالجة الصورة، يرجى المحاولة مرة أخرى'**
  String get errorImageProcess;

  /// PDF export error
  ///
  /// In ar, this message translates to:
  /// **'فشل تصدير ملف PDF، يرجى المحاولة مرة أخرى'**
  String get errorPdfFailed;

  /// Account deleted error
  ///
  /// In ar, this message translates to:
  /// **'تم حذف حسابك'**
  String get errorAccountDeleted;

  /// Session expired error
  ///
  /// In ar, this message translates to:
  /// **'انتهت صلاحية الجلسة'**
  String get errorSessionExpired;

  /// Not found error
  ///
  /// In ar, this message translates to:
  /// **'العنصر المطلوب غير موجود'**
  String get errorNotFound;

  /// Request timeout error
  ///
  /// In ar, this message translates to:
  /// **'انتهت مهلة الطلب، يرجى التحقق من اتصالك'**
  String get errorTimeout;

  /// Required field validation error
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get validationRequired;

  /// Email validation error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get validationEmail;

  /// Password min length validation error
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون 8 أحرف على الأقل'**
  String get validationPasswordMinLength;

  /// Amount positive validation error
  ///
  /// In ar, this message translates to:
  /// **'المبلغ يجب أن يكون أكبر من صفر'**
  String get validationAmountPositive;

  /// Name min length validation error
  ///
  /// In ar, this message translates to:
  /// **'الاسم يجب أن يكون حرفين على الأقل'**
  String get validationNameMinLength;

  /// Confirm password mismatch error
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get validationConfirmPasswordMismatch;

  /// Invalid amount format error
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال مبلغ صحيح'**
  String get validationAmountInvalid;

  /// Future date not allowed error
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن اختيار تاريخ مستقبلي'**
  String get validationFutureDateNotAllowed;
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
    'that was used.',
  );
}
