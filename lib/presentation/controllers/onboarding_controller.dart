import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/app/routes/app_pages.dart';
import 'package:wanderlust/core/services/storage_service.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  
  // Onboarding data - Vietnamese text as per design
  final List<OnboardingData> onboardingPages = [
    OnboardingData(
      image: 'assets/images/on_boarding_1.png',
      title: 'Hãy đến với chuyến đi mới',
      subtitle: 'Hãy sẵn sàng khám phá thế giới theo cách chưa từng có.',
    ),
    OnboardingData(
      image: 'assets/images/on_boarding_2.png',
      title: 'Lên kế hoạch cho chuyến đi',
      subtitle: 'Tạo lịch trình chi tiết và quản lý mọi booking trong một nơi.',
    ),
    OnboardingData(
      image: 'assets/images/on_boarding_3.png',
      title: 'Khám phá điểm đến tuyệt vời',
      subtitle: 'Tìm kiếm những địa điểm độc đáo và trải nghiệm khó quên.',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // Listen to page changes
    pageController.addListener(() {
      if (pageController.page != null) {
        currentPage.value = pageController.page!.round();
      }
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - go to register
      navigateToRegister();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    navigateToLogin();
  }

  void navigateToRegister() {
    _saveOnboardingComplete();
    Get.offNamed(Routes.REGISTER);
  }

  void navigateToLogin() {
    _saveOnboardingComplete();
    Get.offNamed(Routes.LOGIN);
  }

  void _saveOnboardingComplete() {
    // Save that user has seen onboarding
    StorageService.to.write('hasSeenOnboarding', true);
  }

  bool get isLastPage => currentPage.value == onboardingPages.length - 1;
  bool get isFirstPage => currentPage.value == 0;
}

class OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}