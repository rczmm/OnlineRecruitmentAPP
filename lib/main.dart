import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/route_names.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

final storageService = StorageService();

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化shared_preferences插件
  await SharedPreferences.getInstance();
  
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
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      // 使用命名路由
      initialRoute: initialRoute,
      // 设置初始路由
      onGenerateRoute: AppRouter.generateRoute, // 指定路由生成函数
    );
  }
}
