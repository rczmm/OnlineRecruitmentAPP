import 'package:flutter/material.dart';
import 'package:zhaopingapp/screens/home_page.dart';

// 导入 fl_chart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '我的应用',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        // 文本主题
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0), // 修改默认文本大小
        ),
        // AppBar 主题
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue, // 修改 AppBar 背景色
          titleTextStyle:
              TextStyle(color: Colors.white, fontSize: 20), //修改AppBar标题样式
        ),
        // 其他主题属性，例如按钮、卡片、对话框等
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, //修改ElevatedButton的背景色
        )),
      ),
      home: const MyHomePage(),
    );
  }
}

