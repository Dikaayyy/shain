import 'package:flutter/material.dart';
import 'package:shain/core/constants/app_strings.dart';
import 'package:shain/core/router/app_router.dart';
import 'package:shain/core/theme/app_theme.dart';

/// Root widget aplikasi Shain yang mengonfigurasi tema dan router.
class ShainApp extends StatelessWidget {
  const ShainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
