import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'User Management',
      child: Center(
        child: Text('User Management Page - Coming Soon'),
      ),
    );
  }
}