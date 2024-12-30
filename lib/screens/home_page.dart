import 'package:flutter/material.dart';

import '../widgets/ProfileScreenContent.dart';
import 'chat_screen.dart';
import 'home_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // 当前选中的导航栏索引

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreenContent(), // 首页内容
    ChatScreenContent(), // 聊天页面内容
    ProfileScreenContent(), // 我的页面内容
  ];

  late AnimationController _controller;
  late Animation<double> _opacity;
  bool _visible = true;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _controller.forward().whenComplete(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _visible = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主要内容
        Scaffold(
          appBar: AppBar(
            title: const Text('首页'),
          ),
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '首页',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: '聊天',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '我的',
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        ),
        // 开屏动画
        if (_visible)
          FadeTransition(
            opacity: _opacity,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: const Center(
                child: FlutterLogo(size: 100), // 你可以替换成你的 Logo 或其他 Widget
              ),
            ),
          ),
      ],
    );
  }
}