import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class BusinessDetailPage extends StatelessWidget {
  const BusinessDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Business Details',
      child: Center(
        child: Text('Business Detail Page - Coming Soon'),
      ),
    );
  }
}