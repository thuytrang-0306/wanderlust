import 'package:get/get.dart';
import 'package:wanderlust/app/bindings/initial_binding.dart';
import 'package:wanderlust/presentation/pages/splash/splash_page.dart';
import 'package:wanderlust/presentation/pages/onboarding/onboarding_page.dart';
import 'package:wanderlust/presentation/pages/auth/login/login_page.dart';
import 'package:wanderlust/presentation/pages/auth/register/register_page.dart';
import 'package:wanderlust/presentation/pages/auth/forgot_password/forgot_password_page.dart';
import 'package:wanderlust/presentation/pages/auth/verify_email/verify_email_page.dart';
import 'package:wanderlust/presentation/pages/home/home_page.dart';
import 'package:wanderlust/presentation/pages/main/main_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();
  
  static const INITIAL = Routes.SPLASH;
  
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashPage(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingPage(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginPage(),
      transition: Transition.rightToLeft,
    ),
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
    GetPage(
      name: Routes.MAIN,
      page: () => const MainPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomePage(),
    ),
  ];
}