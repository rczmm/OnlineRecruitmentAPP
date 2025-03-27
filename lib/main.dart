import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/screens/auth_screen.dart';
import 'package:zhaopingapp/screens/home_page.dart';
import 'core/theme/app_theme_green.dart';

final _storage = FlutterSecureStorage();

Future<String?> getAuthToken() async {
  final token = await _storage.read(key: 'authToken');
  return token;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? initialToken = await getAuthToken();
  Widget initialScreen = initialToken != null ? MyHomePage() : AuthScreen();
  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required Widget initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的应用',
      theme: AppTheme.lightTheme,
      home: const MyHomePage(),
    );
  }
}
