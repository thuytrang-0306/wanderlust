import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'System Settings',
      child: Center(
        child: Text('System Settings Page - Coming Soon'),
      ),
    );
  }
}