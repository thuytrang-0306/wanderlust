import 'package:get/get.dart';
import 'package:wanderlust/presentation/pages/onboarding/onboarding_page.dart';
import 'package:wanderlust/presentation/pages/auth/login/login_page.dart';
import 'package:wanderlust/presentation/pages/auth/register/register_page.dart';
import 'package:wanderlust/presentation/pages/auth/forgot_password/forgot_password_page.dart';
import 'package:wanderlust/presentation/pages/auth/verify_email/verify_email_page.dart';
import 'package:wanderlust/presentation/pages/main/main_navigation_page.dart';
import 'package:wanderlust/presentation/pages/planning/trip_edit_page.dart';
import 'package:wanderlust/presentation/bindings/trip_edit_binding.dart';
import 'package:wanderlust/presentation/pages/trip/trip_detail_page.dart';
import 'package:wanderlust/presentation/pages/trip/add_private_location_page.dart';
import 'package:wanderlust/presentation/pages/trip/add_note_page.dart';
import 'package:wanderlust/presentation/pages/trip/search_location_page.dart';
import 'package:wanderlust/presentation/pages/community/create_post_page.dart';
import 'package:wanderlust/presentation/pages/community/blog_detail_page.dart';
import 'package:wanderlust/presentation/pages/community/saved_collections_page.dart';
import 'package:wanderlust/presentation/pages/community/collection_detail_page.dart';
import 'package:wanderlust/presentation/pages/accommodation/accommodation_detail_page.dart';
import 'package:wanderlust/presentation/pages/payment/booking_info_page.dart';
import 'package:wanderlust/presentation/pages/payment/customer_info_page.dart';
import 'package:wanderlust/presentation/pages/payment/payment_method_page.dart';
import 'package:wanderlust/presentation/pages/payment/payment_success_page.dart';
import 'package:wanderlust/presentation/pages/combo/combo_detail_page.dart';
import 'package:wanderlust/presentation/pages/account/user_profile_page.dart';
import 'package:wanderlust/presentation/pages/search/search_filter_page.dart';
import 'package:wanderlust/presentation/pages/settings/settings_page.dart';
import 'package:wanderlust/presentation/pages/trips/my_trips_page.dart';
import 'package:wanderlust/presentation/pages/booking/booking_history_page.dart';
import 'package:wanderlust/presentation/bindings/create_post_binding.dart';
import 'package:wanderlust/presentation/bindings/search_filter_binding.dart';
import 'package:wanderlust/presentation/bindings/settings_binding.dart';
import 'package:wanderlust/presentation/bindings/my_trips_binding.dart';
import 'package:wanderlust/presentation/bindings/booking_history_binding.dart';
import 'package:wanderlust/presentation/bindings/add_private_location_binding.dart';
import 'package:wanderlust/presentation/bindings/combo_detail_binding.dart';
import 'package:wanderlust/presentation/pages/ai/ai_chat_page.dart';
import 'package:wanderlust/presentation/bindings/ai_chat_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(name: Routes.ONBOARDING, page: () => const OnboardingPage()),
    GetPage(name: Routes.LOGIN, page: () => const LoginPage(), transition: Transition.rightToLeft),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.VERIFY_EMAIL,
      page: () => const VerifyEmailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: Routes.MAIN_NAVIGATION, page: () => const MainNavigationPage()),
    GetPage(
      name: Routes.TRIP_EDIT,
      page: () => const TripEditPage(),
      binding: TripEditBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.TRIP_DETAIL,
      page: () => const TripDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ADD_PRIVATE_LOCATION,
      page: () => const AddPrivateLocationPage(),
      binding: AddPrivateLocationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ADD_NOTE,
      page: () => const AddNotePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SEARCH_LOCATION,
      page: () => const SearchLocationPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.CREATE_POST,
      page: () => const CreatePostPage(),
      binding: CreatePostBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.BLOG_DETAIL,
      page: () => const BlogDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SAVED_COLLECTIONS,
      page: () => const SavedCollectionsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.COLLECTION_DETAIL,
      page: () => const CollectionDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ACCOMMODATION_DETAIL,
      page: () => const AccommodationDetailPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.BOOKING_INFO,
      page: () => const BookingInfoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.CUSTOMER_INFO,
      page: () => const CustomerInfoPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PAYMENT_METHOD,
      page: () => const PaymentMethodPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.COMBO_DETAIL,
      page: () => const ComboDetailPage(),
      binding: ComboDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PAYMENT_SUCCESS,
      page: () => const PaymentSuccessPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.USER_PROFILE,
      page: () => const UserProfilePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SEARCH_FILTER,
      page: () => const SearchFilterPage(),
      binding: SearchFilterBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.MY_TRIPS,
      page: () => const MyTripsPage(),
      binding: MyTripsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.BOOKING_HISTORY,
      page: () => const BookingHistoryPage(),
      binding: BookingHistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.AI_CHAT,
      page: () => const AIChatPage(),
      binding: AIChatBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
