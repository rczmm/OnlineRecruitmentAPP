import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/core/network/dio_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zhaopingapp/features/shell/presentation/screens/main_screen.dart';

import 'home_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _storage = FlutterSecureStorage();
  bool _isLogin = true; // 切换登录/注册状态
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _errorMessage = '';
  final Dio _dio = DioClient().dio; // 使用 DioClient 的 Dio 实例
  String? _authToken;
  bool _interceptorAdded = false; // 标记拦截器是否已添加

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'authToken', value: token);
    setState(() {
      _authToken = token;
    });
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'authToken');
  }

  // 显示错误弹窗
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('错误'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = '用户名和密码不能为空';
      });
      _showErrorDialog(context, _errorMessage);
      return;
    }

    try {
      final response = await _dio.post(
        'http://127.0.0.1:8088/auth/login',
        data: {
          'username': username,
          'password': password,
          'userType': 1, // 写死，从客户端登录的默认就是求职者
        },
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        final String token = response.data['data']['token'];
        // 尝试从响应中获取userId，如果没有，则使用用户名作为userId
        final String userId = response.data['data']['userId'].toString();

        setState(() {
          _authToken = token;
        });
        _addAuthInterceptor(); // 添加拦截器

        // 保存token和userId到安全存储
        await saveAuthToken(token);
        await _storage.write(key: 'userId', value: userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        setState(() {
          _errorMessage = response.data['msg'] ?? '登录失败，请检查用户名和密码';
        });
        _showErrorDialog(context, _errorMessage);
      }
    } on DioException catch (error) {
      setState(() {
        if (error.response != null) {
          _errorMessage = error.response!.data['msg'] ?? '登录失败，服务器错误';
        } else {
          _errorMessage = '登录失败，请检查网络连接';
        }
      });
      _showErrorDialog(context, _errorMessage);
    }
  }

  Future<void> _register() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = '用户名、密码和确认密码不能为空';
      });
      _showErrorDialog(context, _errorMessage);
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = '两次输入的密码不一致';
      });
      _showErrorDialog(context, _errorMessage);
      return;
    }

    try {
      final response = await _dio.post(
        'http://localhost:8088/auth/register',
        data: {
          'username': username,
          'password': password,
          'userType': 0,
        },
        options: Options(contentType: 'application/json'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLogin = true; // 注册成功后切换到登录页面
          _errorMessage = '注册成功，请登录';
        });
        _showErrorDialog(context, _errorMessage);
      } else {
        setState(() {
          _errorMessage = response.data['msg'] ?? '注册失败，请稍后重试';
        });
        _showErrorDialog(context, _errorMessage);
      }
    } on DioException catch (error) {
      setState(() {
        if (error.response != null) {
          _errorMessage = error.response!.data['msg'] ?? '注册失败，服务器错误';
        } else {
          _errorMessage = '注册失败，请检查网络连接';
        }
      });
      _showErrorDialog(context, _errorMessage);
    }
  }

  void _addAuthInterceptor() {
    if (_interceptorAdded || _authToken == null) {
      return; // 如果已添加或 Token 为空，则不添加
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 在请求头中添加 Authorization 字段，使用 Bearer 方案
        options.headers['Authorization'] = 'Bearer $_authToken';
        return handler.next(options); // 继续执行请求
      },
      onResponse: (response, handler) {
        return handler.next(response); // 继续执行响应
      },
      onError: (DioException e, handler) {
        return handler.next(e); // 继续执行错误
      },
    ));
    _interceptorAdded = true;
  }

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
                      'https://logo.com/image-cdn/images/kts928pd/production/5f4f0c90d60931ba876fad50c4533c3ec5602a91-7575x2115.webp?w=1920&q=70&fm=webp'),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
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
                  controller: _confirmPasswordController,
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
                    _login();
                  } else {
                    _register();
                  }
                },
                child: Text(_isLogin ? '登录' : '注册'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin; // 切换状态
                    _errorMessage = '';
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
