import 'package:flutter/material.dart';

import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 初始化 AnimationController，控制时长和刷新频率
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 2秒的动画时长
    );

    // 定义缩放动画 (0 -> 1)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // 动画完成后，跳转到主页面
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    });

    // 开始播放动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // 记得销毁控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 使用 AnimatedBuilder 结合动画控制器，实现动态效果
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: const FlutterLogo(size: 100), // 替换成自己的 Logo 或组件
            );
          },
        ),
      ),
    );
  }
}