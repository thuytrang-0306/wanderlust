import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_typography.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/core/services/storage_service.dart';
import 'package:wanderlust/core/utils/logger_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNext();
  }
  
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _animationController.forward();
  }
  
  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Production flow logic
    final storage = Get.find<StorageService>();
    final hasSeenOnboarding = storage.read('hasSeenOnboarding') ?? false;
    final currentUser = FirebaseAuth.instance.currentUser;
    
    LoggerService.d('Navigation Check:');
    LoggerService.d('- Has seen onboarding: $hasSeenOnboarding');
    LoggerService.d('- Current user: ${currentUser?.email}');
    LoggerService.d('- Email verified: ${currentUser?.emailVerified}');
    
    // Decision tree for navigation
    if (!hasSeenOnboarding) {
      // First time user - show onboarding
      LoggerService.i('Navigating to: ONBOARDING (first time)');
      Get.offAllNamed(Routes.ONBOARDING);
    } else if (currentUser != null) {
      // User is logged in
      if (currentUser.emailVerified) {
        // Email is verified - go to main navigation
        LoggerService.i('Navigating to: MAIN_NAVIGATION (authenticated & verified)');
        Get.offAllNamed(Routes.MAIN_NAVIGATION);
      } else {
        // Email not verified - go to verification
        LoggerService.i('Navigating to: VERIFY_EMAIL (not verified)');
        Get.offAllNamed(Routes.VERIFY_EMAIL);
      }
    } else {
      // Not logged in - go to login
      LoggerService.i('Navigating to: LOGIN (not authenticated)');
      Get.offAllNamed(Routes.LOGIN);
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.explore,
                        size: 60.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 30.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Wanderlust',
                style: AppTypography.h1.copyWith(
                  color: AppColors.white,
                  fontSize: 40.sp,
                  fontWeight: AppTypography.bold,
                  letterSpacing: -1,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Explore the World',
                style: AppTypography.bodyL.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                  fontWeight: AppTypography.medium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}