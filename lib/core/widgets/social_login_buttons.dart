import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';
import 'package:wanderlust/core/constants/app_spacing.dart';

enum SocialPlatform {
  google,
  facebook,
  apple,
  twitter,
}

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onFacebookPressed;
  final VoidCallback? onApplePressed;
  final VoidCallback? onTwitterPressed;
  final List<SocialPlatform> platforms;
  final bool isLoading;
  final MainAxisAlignment alignment;
  final double spacing;
  final double buttonSize;

  const SocialLoginButtons({
    super.key,
    this.onGooglePressed,
    this.onFacebookPressed,
    this.onApplePressed,
    this.onTwitterPressed,
    this.platforms = const [
      SocialPlatform.google,
      SocialPlatform.facebook,
      SocialPlatform.apple,
    ],
    this.isLoading = false,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 24,
    this.buttonSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];

    for (var platform in platforms) {
      switch (platform) {
        case SocialPlatform.google:
          if (onGooglePressed != null) {
            buttons.add(
              SocialLoginButton(
                platform: SocialPlatform.google,
                onPressed: isLoading ? null : onGooglePressed,
                size: buttonSize,
              ),
            );
          }
          break;
        case SocialPlatform.facebook:
          if (onFacebookPressed != null) {
            buttons.add(
              SocialLoginButton(
                platform: SocialPlatform.facebook,
                onPressed: isLoading ? null : onFacebookPressed,
                size: buttonSize,
              ),
            );
          }
          break;
        case SocialPlatform.apple:
          if (onApplePressed != null) {
            buttons.add(
              SocialLoginButton(
                platform: SocialPlatform.apple,
                onPressed: isLoading ? null : onApplePressed,
                size: buttonSize,
              ),
            );
          }
          break;
        case SocialPlatform.twitter:
          if (onTwitterPressed != null) {
            buttons.add(
              SocialLoginButton(
                platform: SocialPlatform.twitter,
                onPressed: isLoading ? null : onTwitterPressed,
                size: buttonSize,
              ),
            );
          }
          break;
      }
    }

    // Add spacing between buttons
    List<Widget> spacedButtons = [];
    for (int i = 0; i < buttons.length; i++) {
      spacedButtons.add(buttons[i]);
      if (i < buttons.length - 1) {
        spacedButtons.add(SizedBox(width: spacing.w));
      }
    }

    return Row(
      mainAxisAlignment: alignment,
      children: spacedButtons,
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final SocialPlatform platform;
  final VoidCallback? onPressed;
  final double size;
  final bool showBorder;

  const SocialLoginButton({
    super.key,
    required this.platform,
    required this.onPressed,
    this.size = 48,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget icon;
    String tooltip;

    switch (platform) {
      case SocialPlatform.google:
        icon = Image.asset(
          'assets/icons/google.png',
          width: size * 0.5,
          height: size * 0.5,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.g_mobiledata,
              size: size * 0.6,
              color: Colors.red,
            );
          },
        );
        tooltip = 'Đăng nhập với Google';
        break;
      
      case SocialPlatform.facebook:
        icon = Icon(
          Icons.facebook,
          size: size * 0.6,
          color: const Color(0xFF1877F2),
        );
        tooltip = 'Đăng nhập với Facebook';
        break;
      
      case SocialPlatform.apple:
        icon = Icon(
          Icons.apple,
          size: size * 0.6,
          color: AppColors.black,
        );
        tooltip = 'Đăng nhập với Apple';
        break;
      
      case SocialPlatform.twitter:
        icon = Icon(
          Icons.close, // Replace with Twitter icon when available
          size: size * 0.5,
          color: const Color(0xFF1DA1F2),
        );
        tooltip = 'Đăng nhập với Twitter';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(
                      color: AppColors.neutral200,
                      width: 1,
                    )
                  : null,
            ),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}