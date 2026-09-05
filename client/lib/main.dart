import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_service.dart';
import 'core/network/storage_service.dart';
import 'routing/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final apiService = ApiService(storageService);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ApiService>.value(value: apiService),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006241),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
