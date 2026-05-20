// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Cashes';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonOffline => 'No internet connection';

  @override
  String get commonReadOnlyMode => 'View Only Mode';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get snackbarLoginSuccess => 'Welcome back!';

  @override
  String get snackbarLoginError => 'Incorrect email or password';

  @override
  String get snackbarLogoutSuccess => 'Logged out successfully';

  @override
  String get snackbarPasswordResetSent => 'Password reset link sent';

  @override
  String get snackbarCompanyAdded => 'Company added successfully';

  @override
  String get snackbarCompanyUpdated => 'Company updated successfully';

  @override
  String get snackbarCompanyDeleted => 'Company deleted successfully';

  @override
  String get snackbarUserAdded => 'User added successfully';

  @override
  String get snackbarUserUpdated => 'User updated successfully';

  @override
  String get snackbarUserDeleted => 'User deleted successfully';

  @override
  String get snackbarProjectAdded => 'Project added successfully';

  @override
  String get snackbarProjectUpdated => 'Project updated successfully';

  @override
  String get snackbarProjectDeleted => 'Project deleted successfully';

  @override
  String get snackbarEntryAdded => 'Entry added successfully';

  @override
  String get snackbarEntryUpdated => 'Entry updated successfully';

  @override
  String get snackbarEntryDeleted => 'Entry deleted successfully';

  @override
  String get snackbarReceiptUploaded => 'Receipt uploaded successfully';

  @override
  String get snackbarReceiptDeleted => 'Receipt deleted successfully';

  @override
  String get snackbarProfileUpdated => 'Profile updated successfully';

  @override
  String get snackbarPasswordChanged => 'Password changed successfully';

  @override
  String get snackbarAvatarUpdated => 'Avatar updated successfully';

  @override
  String get snackbarNotificationRead => 'Notification marked as read';

  @override
  String get snackbarNotificationDeleted => 'Notification deleted successfully';

  @override
  String get snackbarPdfExported => 'PDF exported successfully';

  @override
  String get snackbarAccountDeleted => 'Your account has been deleted';

  @override
  String get snackbarSessionExpired =>
      'Your session has expired, please log in again';

  @override
  String get snackbarNoInternet => 'No internet connection';

  @override
  String get snackbarProjectDeleted_notification =>
      'This project has been deleted';

  @override
  String get snackbarDuplicateEmail => 'Email is already in use';

  @override
  String get snackbarLogoUploadFailed =>
      'Logo upload failed, you can update it later';

  @override
  String get dialogDeleteCompanyTitle => 'Delete Company';

  @override
  String get dialogDeleteCompanyBody =>
      'Are you sure you want to delete this company? All users, projects, and entries will be deleted.';

  @override
  String get dialogDeleteUserTitle => 'Delete User';

  @override
  String get dialogDeleteUserBody =>
      'Are you sure you want to delete this user? All their projects and entries will be deleted.';

  @override
  String get dialogDeleteProjectTitle => 'Delete Project';

  @override
  String get dialogDeleteProjectBody =>
      'Are you sure you want to delete this project? All entries and receipts will be deleted.';

  @override
  String get dialogDeleteEntryTitle => 'Delete Entry';

  @override
  String get dialogDeleteEntryBody =>
      'Are you sure you want to delete this entry?';

  @override
  String get dialogDeleteNotificationTitle => 'Delete Notification';

  @override
  String get dialogDeleteNotificationBody =>
      'Are you sure you want to delete this notification?';

  @override
  String get dialogLogoutTitle => 'Log Out';

  @override
  String get dialogLogoutBody => 'Are you sure you want to log out?';

  @override
  String get dialogUnsavedChangesTitle => 'Unsaved Changes';

  @override
  String get dialogUnsavedChangesBody =>
      'You have unsaved changes. Do you want to leave?';

  @override
  String get dialogPdfNoReceiptsTitle => 'Financial Data Only';

  @override
  String get dialogPdfNoReceiptsBody =>
      'All receipts have expired. Do you want to export a PDF with financial data only?';

  @override
  String get emptyCompanies => 'No companies yet';

  @override
  String get emptyUsers => 'No users in this company';

  @override
  String get emptyProjects => 'No projects yet';

  @override
  String get emptyEntries => 'No entries in this project';

  @override
  String get emptyImages => 'No receipts uploaded';

  @override
  String get emptyNotifications => 'No notifications';

  @override
  String get emptySearchResults => 'No results found';

  @override
  String get authWelcomeBack => 'Welcome Back';

  @override
  String get authSubtitle => 'Sign in to continue';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authLogin => 'Log In';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authResetCta => 'Send Reset Link';

  @override
  String get authResetTitle => 'Reset Password';

  @override
  String get authResetSubtitle =>
      'Enter your email and we\'ll send you a reset link';

  @override
  String get authEmailSentTitle => 'Link Sent';

  @override
  String get authEmailSentSubtitle =>
      'Check your email and follow the instructions to reset your password';

  @override
  String get authBackToLogin => 'Back to Login';

  @override
  String get ownerCompaniesTitle => 'Companies';

  @override
  String get ownerAddCompany => 'Add Company';

  @override
  String get ownerAddUser => 'Add User';

  @override
  String get ownerTotalCompanies => 'Total Companies';

  @override
  String get ownerTotalUsers => 'Total Users';

  @override
  String get ownerCompanyName => 'Company Name';

  @override
  String get ownerCompanyLogo => 'Company Logo';

  @override
  String get ownerAddCompanyTitle => 'Add New Company';

  @override
  String get ownerEditCompanyTitle => 'Edit Company';

  @override
  String get ownerUsersTitle => 'Users';

  @override
  String get ownerCreateUserTitle => 'Add New User';

  @override
  String get ownerEditUserTitle => 'Edit User';

  @override
  String get ownerUserFullName => 'Full Name';

  @override
  String get ownerUserEmail => 'Email';

  @override
  String get ownerUserPassword => 'Password';

  @override
  String get ownerUserConfirmPassword => 'Confirm Password';

  @override
  String get ownerUserCompany => 'Company';

  @override
  String get ownerDeletingCompany => 'Deleting...';

  @override
  String get adminAllUsers => 'All Users';

  @override
  String get adminAlertsTitle => 'Notifications';

  @override
  String get adminAlertsSubtitle => 'Latest updates';

  @override
  String get adminTypeNewAssignment => 'New Assignment';

  @override
  String get adminTypeUpdateLog => 'Update Log';

  @override
  String get adminTypeStructuralAlert => 'Structural Alert';

  @override
  String get adminTypeArchived => 'Archived';

  @override
  String get adminUnreadBadgeOverflow => '99+';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPersonalInfo => 'Personal Information';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLogout => 'Log Out';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLightMode => 'Light Mode';

  @override
  String get settingsArabic => 'Arabic';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsEditProfile => 'Edit Profile';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsCurrentPassword => 'Current Password';

  @override
  String get settingsNewPassword => 'New Password';

  @override
  String get settingsConfirmNewPassword => 'Confirm New Password';

  @override
  String get settingsChangeAvatar => 'Change Avatar';

  @override
  String get settingsEmailConfirmBanner =>
      'A confirmation link has been sent to your new email';

  @override
  String get projectsWelcome => 'Hello';

  @override
  String get projectsCuratedOverview => 'Overview of your projects';

  @override
  String get projectsActiveDevelopments => 'Active Projects';

  @override
  String get projectsTotalPortfolio => 'Total Portfolio Value';

  @override
  String get projectsCreateTitle => 'Create New Project';

  @override
  String get projectsCreateSubtitle => 'Enter a project name to get started';

  @override
  String get projectsProjectName => 'Project Name';

  @override
  String get projectsSettingsTitle => 'Project Settings';

  @override
  String get projectsRenameProject => 'Rename Project';

  @override
  String get projectsDeleteProject => 'Delete Project';

  @override
  String get invoicesTotal => 'Total Expenses';

  @override
  String get invoicesUpdatedAt => 'Last Updated';

  @override
  String get invoicesAddEntry => 'Add Entry';

  @override
  String get invoicesEditEntry => 'Edit Entry';

  @override
  String get invoicesAddEntryTitle => 'Add New Entry';

  @override
  String get invoicesAmount => 'Amount';

  @override
  String get invoicesVendor => 'Vendor / Description';

  @override
  String get invoicesDate => 'Date';

  @override
  String get invoicesReceipt => 'Receipt';

  @override
  String get invoicesAttachReceipt => 'Attach Receipt (optional)';

  @override
  String get invoicesCamera => 'Camera';

  @override
  String get invoicesGallery => 'Gallery';

  @override
  String get invoicesExpiryWarning => 'Some receipts expire within 5 days';

  @override
  String get invoicesPdfExport => 'Export PDF';

  @override
  String get invoicesTabLedger => 'Ledger';

  @override
  String get invoicesTabImages => 'Receipts';

  @override
  String invoicesUpdatedMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String invoicesUpdatedHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get invoicesUpdatedJustNow => 'Just now';

  @override
  String get invoicesProcessingImage => 'Processing image...';

  @override
  String get invoicesKeepAppOpen => 'Keep the app open until upload completes';

  @override
  String get errorGeneric => 'An unexpected error occurred, please try again';

  @override
  String get errorNetwork => 'Unable to connect to the network';

  @override
  String get errorPermission =>
      'You don\'t have permission to perform this action';

  @override
  String get errorValidation => 'Please check the entered data';

  @override
  String get errorImageProcess => 'Image processing failed, please try again';

  @override
  String get errorPdfFailed => 'PDF export failed, please try again';

  @override
  String get errorAccountDeleted => 'Your account has been deleted';

  @override
  String get errorSessionExpired => 'Session expired';

  @override
  String get errorNotFound => 'The requested item was not found';

  @override
  String get errorTimeout => 'Request timed out, please check your connection';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Please enter a valid email address';

  @override
  String get validationPasswordMinLength =>
      'Password must be at least 8 characters';

  @override
  String get validationAmountPositive => 'Amount must be greater than zero';

  @override
  String get validationNameMinLength => 'Name must be at least 2 characters';

  @override
  String get validationConfirmPasswordMismatch => 'Passwords do not match';

  @override
  String get validationAmountInvalid => 'Please enter a valid amount';

  @override
  String get validationFutureDateNotAllowed => 'Future dates are not allowed';
}
