import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/app/routes/app_pages.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Onboarding Page'),
            ElevatedButton(
              onPressed: () => Get.offNamed(Routes.LOGIN),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}