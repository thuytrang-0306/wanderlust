import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wanderlust/core/constants/app_colors.dart';

/// Typing indicator animation widget
/// Shows 3 animated dots to indicate AI is processing/typing
class TypingIndicator extends StatefulWidget {
  final Color? dotColor;
  final double? dotSize;

  const TypingIndicator({
    super.key,
    this.dotColor,
    this.dotSize,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        SizedBox(width: 4.w),
        _buildDot(1),
        SizedBox(width: 4.w),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    final delay = index * 0.2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate opacity with staggered delay
        final value = (_controller.value - delay) % 1.0;
        double opacity;

        if (value < 0.5) {
          // Fade in
          opacity = 0.3 + (value * 1.4); // 0.3 -> 1.0
        } else {
          // Fade out
          opacity = 1.0 - ((value - 0.5) * 1.4); // 1.0 -> 0.3
        }

        opacity = opacity.clamp(0.3, 1.0);

        return Container(
          width: widget.dotSize ?? 8.w,
          height: widget.dotSize ?? 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (widget.dotColor ?? AppColors.neutral500).withValues(alpha: opacity),
          ),
        );
      },
    );
  }
}
