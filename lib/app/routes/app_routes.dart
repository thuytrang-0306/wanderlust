part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const VERIFY_EMAIL = '/verify-email';
  static const MAIN = '/main';
  static const HOME = '/home';
  static const EXPLORE = '/explore';
  static const BOOKINGS = '/bookings';
  static const PROFILE = '/profile';
  static const SEARCH = '/search';
  static const DESTINATION_DETAIL = '/destination-detail';
  static const HOTEL_DETAIL = '/hotel-detail';
  static const CREATE_ITINERARY = '/create-itinerary';
  static const ITINERARY_DETAIL = '/itinerary-detail';
  static const PAYMENT = '/payment';
  static const NOTIFICATIONS = '/notifications';
  static const BLOG = '/blog';
  static const BLOG_DETAIL = '/blog-detail';
  static const SETTINGS = '/settings';
}