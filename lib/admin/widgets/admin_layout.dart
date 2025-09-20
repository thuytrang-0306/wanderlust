import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'admin_sidebar.dart';
import 'admin_header.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  
  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar - only show on desktop
          if (context.width > 768) const AdminSidebar(),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Header
                AdminHeader(
                  title: title,
                  actions: actions,
                  showMenuButton: context.width <= 768,
                ),
                
                // Content
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Mobile drawer
      drawer: context.width <= 768 ? const Drawer(
        child: AdminSidebar(),
      ) : null,
      
      floatingActionButton: floatingActionButton,
    );
  }
}