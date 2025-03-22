import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/screens/auth_screen.dart';
import 'package:zhaopingapp/screens/home_page.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
        // 文本主题
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        // AppBar 主题
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        // 其他主题属性,按钮
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        )),
        // 卡片统一样式：现代化简洁风格
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.grey.withAlpha(50),
        ),
        // 文本框样式
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        // 图标主题 默认协调绿
        iconTheme: const IconThemeData(color: Color(0xFF4CAF50)),
        // Chip标签主题，美观便利
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFDFF2BF),
          labelStyle: const TextStyle(color: Color(0xFF4CAF50)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}
