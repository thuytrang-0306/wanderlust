import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class InteractivePieChart extends StatefulWidget {
  final List<PieChartData> data;
  final String title;
  final bool showLabels;
  final bool showLegend;
  final bool showPercentage;

  const InteractivePieChart({
    super.key,
    required this.data,
    required this.title,
    this.showLabels = true,
    this.showLegend = true,
    this.showPercentage = true,
  });

  @override
  State<InteractivePieChart> createState() => _InteractivePieChartState();
}

class _InteractivePieChartState extends State<InteractivePieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: const Center(
          child: Text('No data available'),
        ),
      );
    }

    return Container(
      height: 300.h,
      child: Row(
        children: [
          // Pie chart
          Expanded(
            flex: 2,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: PieChartPainter(
                    data: widget.data,
                    progress: _animation.value,
                    hoveredIndex: _hoveredIndex,
                    showLabels: widget.showLabels,
                  ),
                  child: MouseRegion(
                    onHover: _onHover,
                    onExit: _onExit,
                    child: Container(),
                  ),
                );
              },
            ),
          ),
          
          // Legend
          if (widget.showLegend)
            Expanded(
              child: _buildLegend(),
            ),
        ],
      ),
    );
  }

  void _onHover(PointerHoverEvent event) {
    final center = Offset(150.w, 150.h); // Approximate center
    final position = event.localPosition;
    final distance = (position - center).distance;
    
    if (distance <= 100.w && distance >= 40.w) { // Within donut ring
      final angle = math.atan2(position.dy - center.dy, position.dx - center.dx);
      final normalizedAngle = (angle + math.pi * 2) % (math.pi * 2);
      
      double currentAngle = -math.pi / 2; // Start from top
      for (int i = 0; i < widget.data.length; i++) {
        final sweepAngle = widget.data[i].percentage / 100 * 2 * math.pi;
        if (normalizedAngle >= currentAngle && normalizedAngle <= currentAngle + sweepAngle) {
          setState(() {
            _hoveredIndex = i;
          });
          return;
        }
        currentAngle += sweepAngle;
      }
    }
    
    setState(() {
      _hoveredIndex = null;
    });
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _hoveredIndex = null;
    });
  }

  Widget _buildLegend() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Platform Distribution',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 16.h),
          ...widget.data.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final isHovered = _hoveredIndex == index;
            
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hoveredIndex = index),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isHovered ? 8.w : 4.w),
                  decoration: BoxDecoration(
                    color: isHovered ? data.color.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: data.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: isHovered ? FontWeight.w600 : FontWeight.w400,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            if (widget.showPercentage)
                              Text(
                                '${data.percentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        data.value.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: data.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class PieChartData {
  final String label;
  final double value;
  final double percentage;
  final Color color;

  PieChartData({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

class PieChartPainter extends CustomPainter {
  final List<PieChartData> data;
  final double progress;
  final int? hoveredIndex;
  final bool showLabels;

  PieChartPainter({
    required this.data,
    required this.progress,
    this.hoveredIndex,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20.w;
    final innerRadius = radius * 0.4; // Donut chart

    double currentAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = data[i].percentage / 100 * 2 * math.pi * progress;
      final isHovered = hoveredIndex == i;
      final currentRadius = isHovered ? radius + 5.w : radius;
      
      final paint = Paint()
        ..color = data[i].color
        ..style = PaintingStyle.fill;

      // Draw outer arc
      final rect = Rect.fromCircle(center: center, radius: currentRadius);
      canvas.drawArc(rect, currentAngle, sweepAngle, true, paint);

      // Draw inner circle to create donut effect
      final innerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, innerRadius, innerPaint);

      // Draw labels
      if (showLabels && progress > 0.8) {
        final labelAngle = currentAngle + sweepAngle / 2;
        final labelRadius = (currentRadius + innerRadius) / 2;
        final labelPosition = Offset(
          center.dx + math.cos(labelAngle) * labelRadius,
          center.dy + math.sin(labelAngle) * labelRadius,
        );

        final textStyle = TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        );

        final textSpan = TextSpan(
          text: '${data[i].percentage.toStringAsFixed(0)}%',
          style: textStyle,
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelPosition.dx - textPainter.width / 2,
            labelPosition.dy - textPainter.height / 2,
          ),
        );
      }

      currentAngle += sweepAngle;
    }

    // Draw center text
    final centerTextStyle = TextStyle(
      color: const Color(0xFF1E293B),
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
    );

    final totalValue = data.fold<double>(0, (sum, item) => sum + item.value);
    final centerTextSpan = TextSpan(
      text: 'Total\n${totalValue.toInt()}',
      style: centerTextStyle,
    );

    final centerTextPainter = TextPainter(
      text: centerTextSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    centerTextPainter.layout();
    centerTextPainter.paint(
      canvas,
      Offset(
        center.dx - centerTextPainter.width / 2,
        center.dy - centerTextPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}