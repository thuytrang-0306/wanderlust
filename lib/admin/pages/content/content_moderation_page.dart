import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class ContentModerationPage extends StatelessWidget {
  const ContentModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminLayout(
      title: 'Content Moderation',
      child: Center(
        child: Text('Content Moderation Page - Coming Soon'),
      ),
    );
  }
}