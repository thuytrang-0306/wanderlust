import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'User Details',
      child: Center(
        child: Text('User Detail Page - Coming Soon'),
      ),
    );
  }
}