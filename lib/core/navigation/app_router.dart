import 'package:flutter/material.dart';
import 'package:zhaopingapp/screens/auth_screen.dart';
import 'package:zhaopingapp/screens/home_page.dart';
import 'route_names.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const MyHomePage());
      case RouteNames.auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('请先登录！'),
            ),
          ),
        );
    }
  }
}
