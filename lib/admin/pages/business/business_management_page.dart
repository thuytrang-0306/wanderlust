import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class BusinessManagementPage extends StatelessWidget {
  const BusinessManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Business Management',
      child: Center(
        child: Text('Business Management Page - Coming Soon'),
      ),
    );
  }
}