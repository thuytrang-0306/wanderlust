import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class InteractiveBarChart extends StatefulWidget {
  final List<BarChartData> data;
  final String title;
  final Color barColor;
  final bool showValues;
  final bool showTooltip;
  final bool horizontal;

  const InteractiveBarChart({
    super.key,
    required this.data,
    required this.title,
    this.barColor = const Color(0xFF3B82F6),
    this.showValues = true,
    this.showTooltip = true,
    this.horizontal = false,
  });

  @override
  State<InteractiveBarChart> createState() => _InteractiveBarChartState();
}

class _InteractiveBarChartState extends State<InteractiveBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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
        height: 250.h,
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
      height: 250.h,
      padding: EdgeInsets.all(16.w),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: BarChartPainter(
              data: widget.data,
              barColor: widget.barColor,
              progress: _animation.value,
              hoveredIndex: _hoveredIndex,
              showValues: widget.showValues,
              horizontal: widget.horizontal,
            ),
            child: MouseRegion(
              onHover: _onHover,
              onExit: _onExit,
              child: Container(),
            ),
          );
        },
      ),
    );
  }

  void _onHover(PointerHoverEvent event) {
    if (widget.data.isEmpty) return;

    final position = event.localPosition;
    final padding = 16.w;
    final chartArea = Size(
      250.w - padding * 2,
      250.h - padding * 2,
    );

    if (widget.horizontal) {
      // Horizontal bar chart
      final barHeight = chartArea.height / widget.data.length;
      final hoveredIndex = ((position.dy - padding) / barHeight).floor();
      
      if (hoveredIndex >= 0 && hoveredIndex < widget.data.length) {
        setState(() {
          _hoveredIndex = hoveredIndex;
        });
      }
    } else {
      // Vertical bar chart
      final barWidth = chartArea.width / widget.data.length;
      final hoveredIndex = ((position.dx - padding) / barWidth).floor();
      
      if (hoveredIndex >= 0 && hoveredIndex < widget.data.length) {
        setState(() {
          _hoveredIndex = hoveredIndex;
        });
      }
    }
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _hoveredIndex = null;
    });
  }
}

class BarChartData {
  final String label;
  final double value;
  final Color? color;

  BarChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class BarChartPainter extends CustomPainter {
  final List<BarChartData> data;
  final Color barColor;
  final double progress;
  final int? hoveredIndex;
  final bool showValues;
  final bool horizontal;

  BarChartPainter({
    required this.data,
    required this.barColor,
    required this.progress,
    this.hoveredIndex,
    this.showValues = true,
    this.horizontal = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (maxValue <= 0) return;

    // Draw grid
    _drawGrid(canvas, size);

    if (horizontal) {
      _drawHorizontalBars(canvas, size, maxValue);
    } else {
      _drawVerticalBars(canvas, size, maxValue);
    }

    // Draw labels
    if (showValues) {
      _drawLabels(canvas, size, maxValue);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.5.w;

    if (horizontal) {
      // Horizontal grid lines for horizontal bars
      for (int i = 0; i <= 5; i++) {
        final x = (size.width / 5) * i;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          gridPaint,
        );
      }
    } else {
      // Horizontal grid lines for vertical bars
      for (int i = 0; i <= 4; i++) {
        final y = (size.height / 4) * i;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
    }
  }

  void _drawVerticalBars(Canvas canvas, Size size, double maxValue) {
    final barWidth = size.width / data.length * 0.6;
    final barSpacing = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final isHovered = hoveredIndex == i;
      final barHeight = (data[i].value / maxValue) * size.height * 0.8 * progress;
      
      final barRect = Rect.fromLTWH(
        i * barSpacing + (barSpacing - barWidth) / 2,
        size.height - barHeight,
        barWidth,
        barHeight,
      );

      final paint = Paint()
        ..color = isHovered 
            ? (data[i].color ?? barColor).withValues(alpha: 0.8)
            : (data[i].color ?? barColor)
        ..style = PaintingStyle.fill;

      // Add rounded corners
      final roundedRect = RRect.fromRectAndRadius(
        barRect,
        Radius.circular(4.r),
      );

      canvas.drawRRect(roundedRect, paint);

      // Draw hover effect
      if (isHovered) {
        final hoverPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(roundedRect, hoverPaint);
      }
    }
  }

  void _drawHorizontalBars(Canvas canvas, Size size, double maxValue) {
    final barHeight = size.height / data.length * 0.6;
    final barSpacing = size.height / data.length;

    for (int i = 0; i < data.length; i++) {
      final isHovered = hoveredIndex == i;
      final barWidth = (data[i].value / maxValue) * size.width * 0.8 * progress;
      
      final barRect = Rect.fromLTWH(
        0,
        i * barSpacing + (barSpacing - barHeight) / 2,
        barWidth,
        barHeight,
      );

      final paint = Paint()
        ..color = isHovered 
            ? (data[i].color ?? barColor).withValues(alpha: 0.8)
            : (data[i].color ?? barColor)
        ..style = PaintingStyle.fill;

      // Add rounded corners
      final roundedRect = RRect.fromRectAndRadius(
        barRect,
        Radius.circular(4.r),
      );

      canvas.drawRRect(roundedRect, paint);

      // Draw hover effect
      if (isHovered) {
        final hoverPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(roundedRect, hoverPaint);
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size, double maxValue) {
    final textStyle = TextStyle(
      color: const Color(0xFF64748B),
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
    );

    if (horizontal) {
      final barSpacing = size.height / data.length;
      for (int i = 0; i < data.length; i++) {
        // Label
        final labelSpan = TextSpan(text: data[i].label, style: textStyle);
        final labelPainter = TextPainter(
          text: labelSpan,
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout();
        
        final labelY = i * barSpacing + barSpacing / 2 - labelPainter.height / 2;
        labelPainter.paint(canvas, Offset(-labelPainter.width - 8.w, labelY));

        // Value
        if (progress > 0.8) {
          final barWidth = (data[i].value / maxValue) * size.width * 0.8 * progress;
          final valueSpan = TextSpan(
            text: data[i].value.toStringAsFixed(0),
            style: textStyle.copyWith(color: Colors.white),
          );
          final valuePainter = TextPainter(
            text: valueSpan,
            textDirection: TextDirection.ltr,
          );
          valuePainter.layout();
          
          final valueY = i * barSpacing + barSpacing / 2 - valuePainter.height / 2;
          valuePainter.paint(canvas, Offset(barWidth + 8.w, valueY));
        }
      }
    } else {
      final barSpacing = size.width / data.length;
      for (int i = 0; i < data.length; i++) {
        // Label
        final labelSpan = TextSpan(text: data[i].label, style: textStyle);
        final labelPainter = TextPainter(
          text: labelSpan,
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout();
        
        final labelX = i * barSpacing + barSpacing / 2 - labelPainter.width / 2;
        labelPainter.paint(canvas, Offset(labelX, size.height + 8.h));

        // Value
        if (progress > 0.8) {
          final barHeight = (data[i].value / maxValue) * size.height * 0.8 * progress;
          final valueSpan = TextSpan(
            text: data[i].value.toStringAsFixed(0),
            style: textStyle.copyWith(color: Colors.white),
          );
          final valuePainter = TextPainter(
            text: valueSpan,
            textDirection: TextDirection.ltr,
          );
          valuePainter.layout();
          
          final valueX = i * barSpacing + barSpacing / 2 - valuePainter.width / 2;
          final valueY = size.height - barHeight / 2 - valuePainter.height / 2;
          valuePainter.paint(canvas, Offset(valueX, valueY));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}