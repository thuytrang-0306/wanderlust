import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'shared/core/services/storage_service.dart';
import 'shared/core/services/firebase_service.dart';
import 'shared/core/utils/logger_service.dart';
import 'shared/core/services/saved_blogs_service.dart';
import 'admin/routes/admin_routes.dart';
import 'admin/routes/admin_pages.dart';
import 'admin/bindings/admin_initial_binding.dart';
import 'admin/theme/admin_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to landscape for admin (desktop-optimized)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp, // Allow portrait for tablets
  ]);

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize GetStorage for local persistence
  await GetStorage.init();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Logger first before any other services
  LoggerService.init();
  
  // Small delay to ensure logger is ready
  await Future.delayed(const Duration(milliseconds: 100));

  // Initialize core services
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => FirebaseService().init());
  
  // Register SavedBlogsService as permanent
  Get.put(SavedBlogsService(), permanent: true);

  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080), // Desktop design size
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Wanderlust Admin Dashboard',
          theme: AdminTheme.lightTheme,
          darkTheme: AdminTheme.darkTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          initialRoute: AdminRoutes.LOGIN, // Will auto-redirect to SETUP if needed
          getPages: AdminPages.routes,
          initialBinding: AdminInitialBinding(),
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}