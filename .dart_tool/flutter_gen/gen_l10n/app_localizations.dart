
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations returned
/// by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'gen_l10n/app_localizations.dart';
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
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Please, wait a moment'**
  String get wait;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent you a email verification. Please open it to verify your account.'**
  String get sendEmail;

  /// No description provided for @emailWasNotSent.
  ///
  /// In en, this message translates to:
  /// **'If you haven\'t received a verification email yet, press the button below'**
  String get emailWasNotSent;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmail;

  /// No description provided for @sendEmailVerification.
  ///
  /// In en, this message translates to:
  /// **'Send email verification'**
  String get sendEmailVerification;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cannotFindUser.
  ///
  /// In en, this message translates to:
  /// **'Cannot find a user with the entered credentials'**
  String get cannotFindUser;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong credentials'**
  String get wrongCredentials;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authenticationError;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email here'**
  String get enterEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password here'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @notRegisterYet.
  ///
  /// In en, this message translates to:
  /// **'Not register yet? Register here'**
  String get notRegisterYet;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get weakPassword;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @failedToRegister.
  ///
  /// In en, this message translates to:
  /// **'Falied to register'**
  String get failedToRegister;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered? Login here!'**
  String get alreadyRegistered;

  /// No description provided for @listRun.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get listRun;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @couldNotProcesssRequest.
  ///
  /// In en, this message translates to:
  /// **'We could not process your request. Please make sure you are a registered user, or if not, register a user now by going to the login screen'**
  String get couldNotProcesssRequest;

  /// No description provided for @forgotPasswordText.
  ///
  /// In en, this message translates to:
  /// **'If you forgot your password, enter your email and we will send you a email to reset your password'**
  String get forgotPasswordText;

  /// No description provided for @sendPasswordResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send me the password reset link'**
  String get sendPasswordResetLink;

  /// No description provided for @backToLoginPage.
  ///
  /// In en, this message translates to:
  /// **'Back to login page'**
  String get backToLoginPage;

  /// No description provided for @couldNotDeleteRun.
  ///
  /// In en, this message translates to:
  /// **'Could not delete run'**
  String get couldNotDeleteRun;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @detailView.
  ///
  /// In en, this message translates to:
  /// **'Run Details'**
  String get detailView;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @takePic.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get takePic;

  /// No description provided for @intevals.
  ///
  /// In en, this message translates to:
  /// **'Intervals'**
  String get intevals;

  /// No description provided for @activateIntervals.
  ///
  /// In en, this message translates to:
  /// **'Activate Intervals'**
  String get activateIntervals;

  /// No description provided for @enterWalkTime.
  ///
  /// In en, this message translates to:
  /// **'Interval Time: Walk'**
  String get enterWalkTime;

  /// No description provided for @enterRunTime.
  ///
  /// In en, this message translates to:
  /// **'Interval Time: Run'**
  String get enterRunTime;

  /// No description provided for @enterRepeat.
  ///
  /// In en, this message translates to:
  /// **'Enter number of repetion'**
  String get enterRepeat;

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get passwordReset;

  /// No description provided for @linkEmailForInformation.
  ///
  /// In en, this message translates to:
  /// **'We have sent you a password reset link. Please check your email for more information.'**
  String get linkEmailForInformation;

  /// No description provided for @sureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get sureLogout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @errorOcurred.
  ///
  /// In en, this message translates to:
  /// **'An error ocurred'**
  String get errorOcurred;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this run?'**
  String get deleteItem;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @ttsPhrase.
  ///
  /// In en, this message translates to:
  /// **'You\'ve ran one kilometer'**
  String get ttsPhrase;

  /// No description provided for @yourRuns.
  ///
  /// In en, this message translates to:
  /// **'Your runs'**
  String get yourRuns;

  /// No description provided for @run.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get run;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @runFrom.
  ///
  /// In en, this message translates to:
  /// **'Run From'**
  String get runFrom;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @couldntSaveImage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save Image'**
  String get couldntSaveImage;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image Saved'**
  String get imageSaved;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get disabled;

  /// No description provided for @waitLogin.
  ///
  /// In en, this message translates to:
  /// **'Please wait while I log you in'**
  String get waitLogin;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'pt': return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
