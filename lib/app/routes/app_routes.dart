part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  // Auth Flow
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const VERIFY_EMAIL = '/verify-email';
  
  // Main App
  static const MAIN_NAVIGATION = '/main-navigation';
  
  // Planning
  static const TRIP_EDIT = '/trip-edit';
  
  // Community
  static const CREATE_POST = '/create-post';
  
  // Future Implementation
  // static const EXPLORE = '/explore';
  // static const BOOKINGS = '/bookings';
  // static const PROFILE = '/profile';
  // static const SETTINGS = '/settings';
}