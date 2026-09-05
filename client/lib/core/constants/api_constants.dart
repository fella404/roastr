class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:5000/api';
  static const String uploadsUrl = 'http://localhost:5000/uploads';

  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  static const String users = '/users';
  static const String categories = '/categories';
  static const String products = '/products';
  static const String transactions = '/transactions';
  static const String dashboardKeyMetrics = '/dashboard/key-metrics';
  static const String dashboardSalesTrend = '/dashboard/sales-trend';
  static const String dashboardOrderComposition = '/dashboard/order-type-composition';
  static const String dashboardTopProducts = '/dashboard/top-products';
}
