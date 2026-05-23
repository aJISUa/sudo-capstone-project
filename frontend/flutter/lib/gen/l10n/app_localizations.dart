import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

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
    Locale('en'),
    Locale('ko'),
  ];

  /// Application name shown in window/AppBar titles.
  ///
  /// In en, this message translates to:
  /// **'Oncare'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get navDiet;

  /// No description provided for @navExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get navExercise;

  /// No description provided for @navMyHealth.
  ///
  /// In en, this message translates to:
  /// **'My Health'**
  String get navMyHealth;

  /// No description provided for @pageDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get pageDashboardTitle;

  /// No description provided for @pageDietTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet Record'**
  String get pageDietTitle;

  /// No description provided for @pageExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get pageExerciseTitle;

  /// No description provided for @pageMyHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'My Health'**
  String get pageMyHealthTitle;

  /// No description provided for @pageAiCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get pageAiCoachTitle;

  /// No description provided for @pageNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get pageNotificationTitle;

  /// No description provided for @pagePlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get pagePlaceTitle;

  /// No description provided for @pageSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get pageSignInTitle;

  /// No description provided for @actionOpenAiCoach.
  ///
  /// In en, this message translates to:
  /// **'Open AI Coach'**
  String get actionOpenAiCoach;

  /// No description provided for @actionFindPlace.
  ///
  /// In en, this message translates to:
  /// **'Find a place'**
  String get actionFindPlace;

  /// No description provided for @actionSignInPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Sign in (placeholder)'**
  String get actionSignInPlaceholder;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @placeholderDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard (placeholder)'**
  String get placeholderDashboard;

  /// No description provided for @placeholderDiet.
  ///
  /// In en, this message translates to:
  /// **'Diet Record (placeholder)'**
  String get placeholderDiet;

  /// No description provided for @placeholderExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise (placeholder)'**
  String get placeholderExercise;

  /// No description provided for @placeholderMyHealth.
  ///
  /// In en, this message translates to:
  /// **'My Health (placeholder)'**
  String get placeholderMyHealth;

  /// No description provided for @placeholderAiCoach.
  ///
  /// In en, this message translates to:
  /// **'AI Coach (placeholder, mock responses)'**
  String get placeholderAiCoach;

  /// No description provided for @placeholderNotification.
  ///
  /// In en, this message translates to:
  /// **'Notifications (placeholder)'**
  String get placeholderNotification;

  /// No description provided for @placeholderPlace.
  ///
  /// In en, this message translates to:
  /// **'Place (placeholder, Google Maps in Stage 4)'**
  String get placeholderPlace;

  /// No description provided for @placeholderSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in (placeholder, social SDKs in Stage 4)'**
  String get placeholderSignIn;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network problem'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get errorServer;

  /// No description provided for @errorCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get errorCancelled;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknown;

  /// No description provided for @dashboardSectionToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashboardSectionToday;

  /// No description provided for @dashboardMetricCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get dashboardMetricCalories;

  /// No description provided for @dashboardMetricExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get dashboardMetricExercise;

  /// No description provided for @dashboardMetricWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get dashboardMetricWeight;

  /// No description provided for @dashboardChartWeightWeek.
  ///
  /// In en, this message translates to:
  /// **'Weekly weight'**
  String get dashboardChartWeightWeek;

  /// No description provided for @dashboardCaloriesProgress.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of {goal}'**
  String dashboardCaloriesProgress(int pct, int goal);

  /// No description provided for @dashboardWeightDelta.
  ///
  /// In en, this message translates to:
  /// **'{sign}{delta} vs last week'**
  String dashboardWeightDelta(String sign, String delta);

  /// No description provided for @unitKcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @unitMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get unitMinutes;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;
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
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
