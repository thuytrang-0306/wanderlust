import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Analytics',
      child: Center(
        child: Text('Analytics Page - Coming Soon'),
      ),
    );
  }
}