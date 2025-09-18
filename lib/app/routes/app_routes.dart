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
  static const TRIP_DETAIL = '/trip-detail';
  static const ADD_PRIVATE_LOCATION = '/add-private-location';
  static const ADD_NOTE = '/add-note';
  static const SEARCH_LOCATION = '/search-location';

  // Community
  static const CREATE_POST = '/create-post';
  static const BLOG_DETAIL = '/blog-detail';
  static const SAVED_COLLECTIONS = '/saved-collections';
  static const COLLECTION_DETAIL = '/collection-detail';

  // Accommodation
  static const ACCOMMODATION_DETAIL = '/accommodation-detail';

  // Payment
  static const BOOKING_INFO = '/booking-info';
  static const CUSTOMER_INFO = '/customer-info';
  static const PAYMENT_METHOD = '/payment-method';
  static const PAYMENT_SUCCESS = '/payment-success';

  // Combo Tours
  static const COMBO_DETAIL = '/combo-detail';

  // Account/Profile
  static const USER_PROFILE = '/user-profile';

  // Search
  static const SEARCH_FILTER = '/search-filter';

  // Settings
  static const SETTINGS = '/settings';
  static const MY_TRIPS = '/my-trips';

  // Bookings
  static const BOOKING_HISTORY = '/booking-history';

  // Future Implementation
  // static const EXPLORE = '/explore';
  // static const BOOKINGS = '/bookings';
  // static const PROFILE = '/profile';
  // static const SETTINGS = '/settings';
}
