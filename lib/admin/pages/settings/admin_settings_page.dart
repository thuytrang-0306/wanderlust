import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Admin Settings',
      child: Center(
        child: Text('Admin Settings Page - Coming Soon'),
      ),
    );
  }
}