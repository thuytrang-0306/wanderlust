import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/app/config/app_theme.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/app/bindings/initial_binding.dart';
import 'package:wanderlust/core/services/firebase_service.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:wanderlust/core/services/connectivity_service.dart';
import 'package:wanderlust/core/services/image_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wanderlust/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Logger
  LoggerService.init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => FirebaseService().init());
  Get.put(ConnectivityService());
  Get.put(ImageService());
  
  // Determine initial route based on app state
  final String initialRoute = _getInitialRoute();
  
  runApp(WanderlustApp(initialRoute: initialRoute));
}

String _getInitialRoute() {
  final storage = Get.find<StorageService>();
  final hasSeenOnboarding = storage.read('hasSeenOnboarding') ?? false;
  final currentUser = FirebaseAuth.instance.currentUser;
  
  LoggerService.d('App Initialization Check:');
  LoggerService.d('- Has seen onboarding: $hasSeenOnboarding');
  LoggerService.d('- Current user: ${currentUser?.email}');
  LoggerService.d('- Email verified: ${currentUser?.emailVerified}');
  
  // Decision tree for initial route
  if (!hasSeenOnboarding) {
    // First time user - show onboarding
    LoggerService.i('Initial route: ONBOARDING (first time)');
    return Routes.ONBOARDING;
  } else if (currentUser != null) {
    // User is logged in
    if (currentUser.emailVerified) {
      // Email is verified - go to home
      LoggerService.i('Initial route: HOME (authenticated & verified)');
      return Routes.HOME;
    } else {
      // Email not verified - go to verification
      LoggerService.i('Initial route: VERIFY_EMAIL (not verified)');
      return Routes.VERIFY_EMAIL;
    }
  } else {
    // Not logged in - go to login
    LoggerService.i('Initial route: LOGIN (not authenticated)');
    return Routes.LOGIN;
  }
}

class WanderlustApp extends StatelessWidget {
  final String initialRoute;
  
  const WanderlustApp({super.key, required this.initialRoute});
  
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Wanderlust',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          initialBinding: InitialBinding(),
          initialRoute: initialRoute,
          getPages: AppPages.routes,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}