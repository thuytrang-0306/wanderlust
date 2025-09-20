import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

class InteractiveLineChart extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final String title;
  final Color lineColor;
  final Color areaColor;
  final bool showArea;
  final bool showPoints;
  final bool showTooltip;

  const InteractiveLineChart({
    super.key,
    required this.data,
    required this.title,
    this.lineColor = const Color(0xFF3B82F6),
    this.areaColor = const Color(0xFF3B82F6),
    this.showArea = true,
    this.showPoints = true,
    this.showTooltip = true,
  });

  @override
  State<InteractiveLineChart> createState() => _InteractiveLineChartState();
}

class _InteractiveLineChartState extends State<InteractiveLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset? _hoverPosition;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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

    return Stack(
      children: [
        Container(
          height: 250.h,
          padding: EdgeInsets.all(16.w),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: InteractiveLineChartPainter(
                  data: widget.data,
                  lineColor: widget.lineColor,
                  areaColor: widget.areaColor,
                  showArea: widget.showArea,
                  showPoints: widget.showPoints,
                  progress: _animation.value,
                  hoveredIndex: _hoveredIndex,
                ),
                size: Size.infinite,
                child: MouseRegion(
                  onHover: _onHover,
                  onExit: _onExit,
                  child: GestureDetector(
                    onPanUpdate: _onPanUpdate,
                    child: Container(),
                  ),
                ),
              );
            },
          ),
        ),
        if (_hoverPosition != null && _hoveredIndex != null && widget.showTooltip)
          _buildTooltip(),
      ],
    );
  }

  void _onHover(PointerHoverEvent event) {
    _updateHoverPosition(event.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _updateHoverPosition(details.localPosition);
  }

  void _onExit(PointerExitEvent event) {
    setState(() {
      _hoverPosition = null;
      _hoveredIndex = null;
    });
  }

  void _updateHoverPosition(Offset position) {
    if (widget.data.isEmpty) return;

    final chartArea = Size(
      250.w - 32.w, // width minus padding
      250.h - 32.h, // height minus padding
    );

    final stepX = chartArea.width / (widget.data.length - 1);
    final hoveredIndex = ((position.dx - 16.w) / stepX).round();

    if (hoveredIndex >= 0 && hoveredIndex < widget.data.length) {
      setState(() {
        _hoverPosition = position;
        _hoveredIndex = hoveredIndex;
      });
    }
  }

  Widget _buildTooltip() {
    if (_hoveredIndex == null || _hoveredIndex! >= widget.data.length) {
      return const SizedBox();
    }

    final data = widget.data[_hoveredIndex!];
    return Positioned(
      left: (_hoverPosition!.dx - 60.w).clamp(0, 250.w - 120.w),
      top: _hoverPosition!.dy - 60.h,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['label'] ?? '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Value: ${data['value']}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InteractiveLineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final Color lineColor;
  final Color areaColor;
  final bool showArea;
  final bool showPoints;
  final double progress;
  final int? hoveredIndex;

  InteractiveLineChartPainter({
    required this.data,
    required this.lineColor,
    required this.areaColor,
    required this.showArea,
    required this.showPoints,
    required this.progress,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0.w
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final areaPaint = Paint()
      ..color = areaColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final hoveredPointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Extract and normalize values
    final values = data.map((e) {
      final value = e['value'];
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }).toList();

    if (values.isEmpty) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;
    
    if (valueRange <= 0) return;

    final stepX = size.width / (values.length - 1);
    final animatedLength = (values.length * progress).floor();

    // Draw grid lines
    _drawGrid(canvas, size);

    // Create path for line and area
    final linePath = Path();
    final areaPath = Path();
    final points = <Offset>[];

    for (int i = 0; i <= animatedLength && i < values.length; i++) {
      final x = i * stepX;
      final normalizedValue = (values[i] - minValue) / valueRange;
      final y = size.height - (normalizedValue * size.height * 0.8) - size.height * 0.1;
      
      points.add(Offset(x, y));
      
      if (i == 0) {
        linePath.moveTo(x, y);
        if (showArea) {
          areaPath.moveTo(x, size.height);
          areaPath.lineTo(x, y);
        }
      } else {
        linePath.lineTo(x, y);
        if (showArea) {
          areaPath.lineTo(x, y);
        }
      }
    }

    // Close area path
    if (showArea && points.isNotEmpty) {
      areaPath.lineTo(points.last.dx, size.height);
      areaPath.close();
      canvas.drawPath(areaPath, areaPaint);
    }

    // Draw line
    canvas.drawPath(linePath, paint);

    // Draw points
    if (showPoints) {
      for (int i = 0; i < points.length; i++) {
        final isHovered = hoveredIndex == i;
        final radius = isHovered ? 6.w : 4.w;
        
        if (isHovered) {
          // Draw outer circle for hovered point
          canvas.drawCircle(
            points[i],
            radius + 2.w,
            hoveredPointPaint..color = lineColor.withValues(alpha: 0.3),
          );
        }
        
        canvas.drawCircle(points[i], radius, pointPaint);
        
        // Draw inner white circle
        canvas.drawCircle(
          points[i],
          radius - 1.w,
          Paint()..color = Colors.white,
        );
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.5.w;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i <= 6; i++) {
      final x = (size.width / 6) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}