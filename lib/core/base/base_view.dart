import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wanderlust/core/base/base_controller.dart';
import 'package:wanderlust/core/widgets/loading_widget.dart';
import 'package:wanderlust/core/widgets/error_state_widget.dart';
import 'package:wanderlust/core/widgets/empty_state_widget.dart';

class BaseView<T extends BaseController> extends StatelessWidget {
  final Widget Function(T controller) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final bool showAppBar;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final bool safeArea;
  final FloatingActionButton? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  
  const BaseView({
    super.key,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.showAppBar = true,
    this.appBar,
    this.backgroundColor,
    this.safeArea = true,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      builder: (controller) {
        Widget body = _buildBody(controller);
        
        if (safeArea && !extendBodyBehindAppBar) {
          body = SafeArea(child: body);
        }
        
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: showAppBar ? appBar : null,
          body: body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          endDrawer: endDrawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          extendBodyBehindAppBar: extendBodyBehindAppBar,
        );
      },
    );
  }
  
  Widget _buildBody(T controller) {
    return Obx(() {
      // Handle refresh indicator if refreshing
      if (controller.isRefreshing) {
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: _buildContent(controller),
        );
      }
      
      return _buildContent(controller);
    });
  }
  
  Widget _buildContent(T controller) {
    // Loading state
    if (controller.isLoading) {
      return loadingWidget ?? const LoadingWidget();
    }
    
    // Error state
    if (controller.isError) {
      return errorWidget ?? 
        ErrorStateWidget(
          error: controller.errorMessage,
          onRetry: controller.loadData,
        );
    }
    
    // Empty state
    if (controller.isEmpty) {
      return emptyWidget ?? 
        EmptyStateWidget(
          title: 'No Data',
          subtitle: 'No data available at the moment',
          buttonText: 'Refresh',
          onButtonPressed: controller.loadData,
        );
    }
    
    // Success/Idle state - show actual content
    return builder(controller);
  }
}

// Simplified version for pages that don't need all features
class SimpleBaseView<T extends BaseController> extends StatelessWidget {
  final Widget Function(T controller) builder;
  final String? title;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final Widget? bottomNavigationBar;
  
  const SimpleBaseView({
    super.key,
    required this.builder,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });
  
  @override
  Widget build(BuildContext context) {
    return BaseView<T>(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              actions: actions,
            )
          : null,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      builder: builder,
    );
  }
}

// Base view with custom loading/error/empty states
class CustomStateBaseView<T extends BaseController> extends StatelessWidget {
  final Widget Function(T controller) builder;
  final Widget Function(T controller)? loadingBuilder;
  final Widget Function(T controller, String error)? errorBuilder;
  final Widget Function(T controller)? emptyBuilder;
  final PreferredSizeWidget? appBar;
  
  const CustomStateBaseView({
    super.key,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.appBar,
  });
  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      builder: (controller) {
        return Scaffold(
          appBar: appBar,
          body: Obx(() {
            if (controller.isLoading && loadingBuilder != null) {
              return loadingBuilder!(controller);
            } else if (controller.isLoading) {
              return const LoadingWidget();
            }
            
            if (controller.isError && errorBuilder != null) {
              return errorBuilder!(controller, controller.errorMessage);
            } else if (controller.isError) {
              return ErrorStateWidget(
                error: controller.errorMessage,
                onRetry: controller.loadData,
              );
            }
            
            if (controller.isEmpty && emptyBuilder != null) {
              return emptyBuilder!(controller);
            } else if (controller.isEmpty) {
              return EmptyStates.noData(onRetry: controller.loadData);
            }
            
            return builder(controller);
          }),
        );
      },
    );
  }
}