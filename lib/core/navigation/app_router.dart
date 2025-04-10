import 'package:flutter/material.dart';
import 'package:zhaopingapp/features/shell/presentation/screens/main_screen.dart';
import 'package:zhaopingapp/screens/auth_screen.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case RouteNames.auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('请先登录！'),
            ),
          ),
        );
    }
  }
}
