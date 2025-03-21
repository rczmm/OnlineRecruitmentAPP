import 'package:flutter/material.dart';
import 'package:zhaopingapp/screens/collect_screen.dart';

import '../AttachmentResumePage.dart';
import '../ResumePage.dart';
import '../screens/PendingInterviewScreen.dart';
import '../screens/PersonalityTestScreen.dart';
import '../screens/QuizScreen.dart';
import '../screens/RecruitmentFair.dart';
import '../screens/application_history_screen.dart';
import 'StatusCounter.dart';

class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // 添加 SingleChildScrollView 以防止内容超出屏幕
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像框
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
            child: const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://i1.hdslb.com/bfs/archive/f9744141e26fe4010860b6cef6ccfb149791b4b7.jpg'),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 状态统计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ApplicationHistoryScreen(initialTabIndex: 1),
                    ),
                  );
                },
                child: const StatusCounter(label: '沟通过', count: 12),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ApplicationHistoryScreen(initialTabIndex: 0),
                    ),
                  );
                },
                child: const StatusCounter(label: '已投递', count: 5),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PendingInterviewScreen(),
                    ),
                  );
                },
                child: const StatusCounter(label: '待面试', count: 2),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CollectScreen(),
                    ),
                  );
                },
                child: const StatusCounter(label: '收藏', count: 2),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 常用功能卡片
          const Text('常用功能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description), // 在线简历图标
                  title: const Text('在线简历'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ResumePage()),
                    );
                  },
                ),
                const Divider(height: 1), // 分割线
                ListTile(
                  leading: const Icon(Icons.attach_file), // 附件简历图标
                  title: const Text('附件简历'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AttachmentResumePage()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 其他功能列表
          const Text('其他功能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView(
            shrinkWrap: true, // 非常重要，防止 ListView 无限扩展
            physics: const NeverScrollableScrollPhysics(), // 禁止 ListView 自身滚动
            children: [
              ListTile(
                leading: const Icon(Icons.event), // 招聘会图标
                title: const Text('招聘会'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecruitmentFairPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school), // 面试刷题图标
                title: const Text('面试刷题'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => QuizScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.psychology), // 人格测试图标
                title: const Text('人格测试'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PersonalityTestScreen()));
                },
              ),
              // 可以添加更多功能
            ],
          ),
        ],
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true; // 切换登录/注册状态

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? '登录' : '注册')),
      body: Center(
        child: SingleChildScrollView(
          // 防止键盘遮挡
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50?s=200'),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true, // 隐藏密码
                decoration: InputDecoration(
                  labelText: '密码',
                  border: OutlineInputBorder(),
                ),
              ),
              if (!_isLogin) // 注册时显示确认密码
                const SizedBox(height: 10),
              if (!_isLogin) // 注册时显示确认密码
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '确认密码',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // 处理登录/注册逻辑
                  if (_isLogin) {
                    print('执行登录操作');
                  } else {
                    print('执行注册操作');
                  }
                },
                child: Text(_isLogin ? '登录' : '注册'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin; // 切换状态
                  });
                },
                child: Text(_isLogin ? '没有账号？去注册' : '已有账号？去登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
