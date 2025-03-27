import 'package:flutter/material.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/route_names.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme_green.dart';

final storageService = StorageService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? initialToken = await storageService.getAuthToken();
  final String initialRoute = (initialToken != null && initialToken.isNotEmpty)
      ? RouteNames.home
      : RouteNames.auth;
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的应用',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // 使用命名路由
      initialRoute: initialRoute,
      // 设置初始路由
      onGenerateRoute: AppRouter.generateRoute, // 指定路由生成函数
    );
  }
}
