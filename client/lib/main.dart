import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_service.dart';
import 'core/network/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'routing/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final apiService = ApiService(storageService);
  final authService = AuthService(apiService, storageService);
  final authProvider = AuthProvider(authService);

  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: const RoastrApp(),
    ),
  );
}

class RoastrApp extends StatelessWidget {
  const RoastrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Roastr POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
