import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/app_localizations.dart';
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
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
    Locale('uz'),
    Locale('zh')
  ];

  /// No description provided for @accountRegister.
  ///
  /// In en, this message translates to:
  /// **'Account Registration'**
  String get accountRegister;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @add_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get add_a_photo;

  /// No description provided for @add_a_review.
  ///
  /// In en, this message translates to:
  /// **'Add a feedback'**
  String get add_a_review;

  /// No description provided for @add_this_to_the_catalog.
  ///
  /// In en, this message translates to:
  /// **'Add this to the catalog'**
  String get add_this_to_the_catalog;

  /// No description provided for @addreview.
  ///
  /// In en, this message translates to:
  /// **'Add a feedback'**
  String get addreview;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'To answer'**
  String get answer;

  /// No description provided for @answers.
  ///
  /// In en, this message translates to:
  /// **'answers'**
  String get answers;

  /// No description provided for @branch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get branch;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'Branch name'**
  String get branchName;

  /// No description provided for @calculation_formula_each_like_adds.
  ///
  /// In en, this message translates to:
  /// **'Calculation formula: each like adds +0.1 (maximum 5.0).'**
  String get calculation_formula_each_like_adds;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @catalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalog;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @choose_a_city.
  ///
  /// In en, this message translates to:
  /// **'Choose a city'**
  String get choose_a_city;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @complain.
  ///
  /// In en, this message translates to:
  /// **'Complain'**
  String get complain;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @countryAndCity.
  ///
  /// In en, this message translates to:
  /// **'Country and city'**
  String get countryAndCity;

  /// No description provided for @countryName.
  ///
  /// In en, this message translates to:
  /// **'Country name'**
  String get countryName;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountButton;

  /// No description provided for @createYourFirstCard.
  ///
  /// In en, this message translates to:
  /// **'Create your first card and share your impressions'**
  String get createYourFirstCard;

  /// No description provided for @delete_an_account.
  ///
  /// In en, this message translates to:
  /// **'Delete an account'**
  String get delete_an_account;

  /// No description provided for @didnot_find_what_you_needed.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find what you needed?'**
  String get didnot_find_what_you_needed;

  /// No description provided for @doNotHaveFeedback.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any feedback yet. Leave your feedback!'**
  String get doNotHaveFeedback;

  /// No description provided for @doYouHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Do you already have an account?'**
  String get doYouHaveAccount;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @edit_Profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_Profile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPassword;

  /// No description provided for @enterThePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the password'**
  String get enterThePassword;

  /// No description provided for @enterYourCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email'**
  String get enterYourCode;

  /// No description provided for @enterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterYourEmailAddress;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackLittle.
  ///
  /// In en, this message translates to:
  /// **'feedback'**
  String get feedbackLittle;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @findHerHereAndShareYourImpressions.
  ///
  /// In en, this message translates to:
  /// **'Find her here and share your impressions'**
  String get findHerHereAndShareYourImpressions;

  /// No description provided for @findTheSectionYouNeed.
  ///
  /// In en, this message translates to:
  /// **'Find the section you need'**
  String get findTheSectionYouNeed;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// No description provided for @fullname.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullname;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @getCode.
  ///
  /// In en, this message translates to:
  /// **'Get code'**
  String get getCode;

  /// No description provided for @goToCard.
  ///
  /// In en, this message translates to:
  /// **'Go to the card'**
  String get goToCard;

  /// No description provided for @helpDesk.
  ///
  /// In en, this message translates to:
  /// **'Helpdesk'**
  String get helpDesk;

  /// No description provided for @highRating.
  ///
  /// In en, this message translates to:
  /// **'High rating'**
  String get highRating;

  /// No description provided for @historyOfMyReview.
  ///
  /// In en, this message translates to:
  /// **'History of my feedback'**
  String get historyOfMyReview;

  /// No description provided for @how_is_your_rating_calculated.
  ///
  /// In en, this message translates to:
  /// **'How is your rating calculated?'**
  String get how_is_your_rating_calculated;

  /// No description provided for @if_you_have_any_questions_or_suggestions.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions or suggestions, please contact our support team — we are always happy to help!'**
  String get if_you_have_any_questions_or_suggestions;

  /// No description provided for @if_you_havenot_found.
  ///
  /// In en, this message translates to:
  /// **'If you haven\'t found what you need, you can add it to the catalog and leave a review.'**
  String get if_you_havenot_found;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get image;

  /// No description provided for @incorrectNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Incorrect number format'**
  String get incorrectNumberFormat;

  /// No description provided for @joinInSecond.
  ///
  /// In en, this message translates to:
  /// **'Join in seconds, there\'s a lot of useful stuff here!'**
  String get joinInSecond;

  /// No description provided for @kazakh.
  ///
  /// In en, this message translates to:
  /// **'Kazakh'**
  String get kazakh;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @leaveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Leave feedback'**
  String get leaveFeedback;

  /// No description provided for @leave_a_review.
  ///
  /// In en, this message translates to:
  /// **'Leave a feedback'**
  String get leave_a_review;

  /// No description provided for @linkTotheWebsite.
  ///
  /// In en, this message translates to:
  /// **'Link to the website'**
  String get linkTotheWebsite;

  /// No description provided for @log_out_of_your_account.
  ///
  /// In en, this message translates to:
  /// **'Log out of your account?'**
  String get log_out_of_your_account;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginToAcc.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get loginToAcc;

  /// No description provided for @logoutOfAccount.
  ///
  /// In en, this message translates to:
  /// **'Logout of account'**
  String get logoutOfAccount;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// No description provided for @minFiveWords.
  ///
  /// In en, this message translates to:
  /// **'Minimum 15 words required'**
  String get minFiveWords;

  /// No description provided for @minimum_words.
  ///
  /// In en, this message translates to:
  /// **'Minimum 0/15 words'**
  String get minimum_words;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @name_of_the_city.
  ///
  /// In en, this message translates to:
  /// **'Name of the city'**
  String get name_of_the_city;

  /// No description provided for @newOnesFirst.
  ///
  /// In en, this message translates to:
  /// **'New ones first'**
  String get newOnesFirst;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @oldOnesFirst.
  ///
  /// In en, this message translates to:
  /// **'Old ones first'**
  String get oldOnesFirst;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRecovery.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get passwordRecovery;

  /// No description provided for @passwordRecoveryText.
  ///
  /// In en, this message translates to:
  /// **'Please create a new password to recover it.'**
  String get passwordRecoveryText;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @pleaseDescribeWhatIsWrongWithTheReviewSoThatWeCanDealWithFaster.
  ///
  /// In en, this message translates to:
  /// **'Please describe what is wrong with the review so that we can deal with it faster.'**
  String get pleaseDescribeWhatIsWrongWithTheReviewSoThatWeCanDealWithFaster;

  /// No description provided for @popular_reviews.
  ///
  /// In en, this message translates to:
  /// **'Popular feedback'**
  String get popular_reviews;

  /// No description provided for @popularity_bonus.
  ///
  /// In en, this message translates to:
  /// **'Popularity Bonus: \n- 50+ likes: each like adds +0.2. \n- 100+ likes: each like adds +0.3.'**
  String get popularity_bonus;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @pullDownToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull Down To Refresh'**
  String get pullDownToRefresh;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @rateThisPlace.
  ///
  /// In en, this message translates to:
  /// **'Rate this place'**
  String get rateThisPlace;

  /// No description provided for @rate_this_place.
  ///
  /// In en, this message translates to:
  /// **'Rate this place'**
  String get rate_this_place;

  /// No description provided for @rate_this_place_to_keep_a_review.
  ///
  /// In en, this message translates to:
  /// **'Rate this place to keep a feedback.'**
  String get rate_this_place_to_keep_a_review;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @ratings_and_review.
  ///
  /// In en, this message translates to:
  /// **'Ratings and feedback'**
  String get ratings_and_review;

  /// No description provided for @read_all.
  ///
  /// In en, this message translates to:
  /// **'READ ALL'**
  String get read_all;

  /// No description provided for @read_the_entire_review.
  ///
  /// In en, this message translates to:
  /// **'Read the entire feedback'**
  String get read_the_entire_review;

  /// No description provided for @registrationInfo.
  ///
  /// In en, this message translates to:
  /// **'Registration will open access to all the features of the application!'**
  String get registrationInfo;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @required_to_fill.
  ///
  /// In en, this message translates to:
  /// **'Required to fill in'**
  String get required_to_fill;

  /// No description provided for @review_history.
  ///
  /// In en, this message translates to:
  /// **'Feedback history'**
  String get review_history;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Feedbacks'**
  String get reviews;

  /// No description provided for @reviewsLittle.
  ///
  /// In en, this message translates to:
  /// **'feedbacks'**
  String get reviewsLittle;

  /// No description provided for @russian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get russian;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery'**
  String get selectFromGallery;

  /// No description provided for @selectPhoto.
  ///
  /// In en, this message translates to:
  /// **'Select photo'**
  String get selectPhoto;

  /// No description provided for @select_a_branch.
  ///
  /// In en, this message translates to:
  /// **'Select a branch'**
  String get select_a_branch;

  /// No description provided for @select_a_country.
  ///
  /// In en, this message translates to:
  /// **'Select a country'**
  String get select_a_country;

  /// No description provided for @select_a_language.
  ///
  /// In en, this message translates to:
  /// **'Select a language'**
  String get select_a_language;

  /// No description provided for @select_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Select a photo'**
  String get select_a_photo;

  /// No description provided for @selectSupportCategory.
  ///
  /// In en, this message translates to:
  /// **'Select the category of your request'**
  String get selectSupportCategory;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Subcategory'**
  String get subcategory;

  /// No description provided for @successfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully'**
  String get successfully;

  /// No description provided for @successfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Successfully updated!'**
  String get successfullyUpdated;

  /// No description provided for @support_service.
  ///
  /// In en, this message translates to:
  /// **'Support Service'**
  String get support_service;

  /// No description provided for @take_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get take_a_photo;

  /// No description provided for @thank_you_for_contacting_us.
  ///
  /// In en, this message translates to:
  /// **'Thank you for contacting us, you are making the world a better place.'**
  String get thank_you_for_contacting_us;

  /// No description provided for @theRatingUpdate.
  ///
  /// In en, this message translates to:
  /// **'The rating is updated automatically in real time.'**
  String get theRatingUpdate;

  /// No description provided for @the_base_rating_starts_from.
  ///
  /// In en, this message translates to:
  /// **'The base rating starts from 1.0.'**
  String get the_base_rating_starts_from;

  /// No description provided for @they_are_discussing_it_now.
  ///
  /// In en, this message translates to:
  /// **'They\'re discussing it now'**
  String get they_are_discussing_it_now;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update!'**
  String get update;

  /// No description provided for @upload_a_photo.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo of the product in high quality, without extraneous signs and labels.'**
  String get upload_a_photo;

  /// No description provided for @user_photos.
  ///
  /// In en, this message translates to:
  /// **'User photos'**
  String get user_photos;

  /// No description provided for @uzbek.
  ///
  /// In en, this message translates to:
  /// **'Uzbek'**
  String get uzbek;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @weHaveSent.
  ///
  /// In en, this message translates to:
  /// **'We have sent a confirmation code to your email address'**
  String get weHaveSent;

  /// No description provided for @words.
  ///
  /// In en, this message translates to:
  /// **'words'**
  String get words;

  /// No description provided for @writeTheme.
  ///
  /// In en, this message translates to:
  /// **'Subject of the appeal'**
  String get writeTheme;

  /// No description provided for @write.
  ///
  /// In en, this message translates to:
  /// **'Write ...'**
  String get write;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review...'**
  String get writeReview;

  /// No description provided for @write_a_review.
  ///
  /// In en, this message translates to:
  /// **'Write a feedback'**
  String get write_a_review;

  /// No description provided for @yes_get_out.
  ///
  /// In en, this message translates to:
  /// **'Yes, get out'**
  String get yes_get_out;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating increases the credibility and visibility of your reviews! 😊'**
  String get yourRating;

  /// No description provided for @your_rating_depends_on_the_number.
  ///
  /// In en, this message translates to:
  /// **'Your rating depends on the number of likes under your feedback: the more likes, the higher the rating!'**
  String get your_rating_depends_on_the_number;

  /// No description provided for @your_response_to_the_comment.
  ///
  /// In en, this message translates to:
  /// **'Your response to the comment'**
  String get your_response_to_the_comment;

  /// No description provided for @enterYourBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Enter your date of birth'**
  String get enterYourBirthDate;

  /// No description provided for @technicalIssues.
  ///
  /// In en, this message translates to:
  /// **'Technical issues'**
  String get technicalIssues;

  /// No description provided for @accountProblems.
  ///
  /// In en, this message translates to:
  /// **'Account problems'**
  String get accountProblems;

  /// No description provided for @paymentsAndBilling.
  ///
  /// In en, this message translates to:
  /// **'Payments and billing'**
  String get paymentsAndBilling;

  /// No description provided for @featureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature request'**
  String get featureRequest;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBug;

  /// No description provided for @otherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategory;

  /// No description provided for @subjectIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject is required'**
  String get subjectIsRequired;

  /// No description provided for @subjectTooLong.
  ///
  /// In en, this message translates to:
  /// **'Subject must not exceed 200 characters'**
  String get subjectTooLong;

  /// No description provided for @messageIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Message is required'**
  String get messageIsRequired;

  /// No description provided for @messageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Message must not exceed 5000 characters'**
  String get messageTooLong;

  /// No description provided for @categoryIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get categoryIsRequired;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Contact email is required'**
  String get emailIsRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @helperText.
  ///
  /// In en, this message translates to:
  /// **'minimum 9 characters'**
  String get helperText;

  /// No description provided for @translateComment.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translateComment;

  /// No description provided for @routeToCompany.
  ///
  /// In en, this message translates to:
  /// **'Route to company'**
  String get routeToCompany;

  /// No description provided for @showOnMap.
  ///
  /// In en, this message translates to:
  /// **'Show on map'**
  String get showOnMap;
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
      <String>['en', 'kk', 'ru', 'uz', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
