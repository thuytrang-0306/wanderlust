abstract class AdminRoutes {
  // Auth routes
  static const LOGIN = '/admin/login';
  
  // Dashboard routes
  static const DASHBOARD = '/admin/dashboard';
  static const ANALYTICS = '/admin/analytics';
  
  // User management routes
  static const USERS = '/admin/users';
  static const USER_DETAIL = '/admin/users/:id';
  
  // Business management routes
  static const BUSINESS = '/admin/business';
  static const BUSINESS_DETAIL = '/admin/business/:id';
  static const BUSINESS_APPROVAL = '/admin/business/approval';
  static const BUSINESS_VERIFICATION = '/admin/business/verification';
  
  // Content moderation routes
  static const CONTENT = '/admin/content';
  static const BLOG_MODERATION = '/admin/content/blogs';
  static const LISTING_MODERATION = '/admin/content/listings';
  static const CONTENT_REPORTS = '/admin/content/reports';
  
  // Settings routes
  static const SETTINGS = '/admin/settings';
  static const SYSTEM_SETTINGS = '/admin/settings/system';
  static const ADMIN_PROFILE = '/admin/settings/profile';
  
  // Report routes
  static const REPORTS = '/admin/reports';
  static const REVENUE_REPORTS = '/admin/reports/revenue';
  static const USER_REPORTS = '/admin/reports/users';
}