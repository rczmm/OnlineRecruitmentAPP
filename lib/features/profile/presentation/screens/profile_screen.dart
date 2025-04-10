import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
import 'package:zhaopingapp/core/services/api_service.dart'; // Import ApiService
import 'package:zhaopingapp/core/utils/snackbar_util.dart'; // Import SnackbarUtil

// Import navigation targets
import 'package:zhaopingapp/AttachmentResumePage.dart';
import 'package:zhaopingapp/features/profile/presentation/screens/user_info_screen.dart';
import 'package:zhaopingapp/features/resume/presentation/pages/resume_page.dart';
import 'package:zhaopingapp/screens/PendingInterviewScreen.dart';
import 'package:zhaopingapp/screens/PersonalityTestScreen.dart';
import 'package:zhaopingapp/screens/QuizScreen.dart';
import 'package:zhaopingapp/screens/RecruitmentFair.dart';
import 'package:zhaopingapp/screens/application_history_screen.dart';
import 'package:zhaopingapp/screens/collect_screen.dart';
import 'package:zhaopingapp/widgets/StatusCounter.dart';

// Convert to StatefulWidget
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Add state variables
  final _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData; // To store user data like name, avatar

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData(); // Check auth status on init
  }

  Future<void> _checkAuthAndLoadData() async {
    if (!mounted) return; // Ensure widget is still mounted
    setState(() {
      _isLoading = true;
    });
    String? token;
    try {
      token =
          await _storage.read(key: 'authToken'); // Use your actual storage key

      if (token != null && token.isNotEmpty) {
        // Token exists, try fetching profile
        try {
          final userData = await _apiService.fetchUserProfile();
          if (mounted) {
            setState(() {
              _isLoggedIn = true;
              _userData = userData;
              _isLoading = false;
            });
          }
        } catch (e) {
          debugPrint("Failed to fetch profile, treating as logged out: $e");
          if (mounted) {
            setState(() {
              _isLoggedIn = false;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error checking auth status: $e");
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        SnackbarUtil.showError(context, "检查登录状态时出错");
      }
    }
  }

  void _handleAvatarTap() {
    if (_isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserInfoScreen(userData: _userData)),
      ).then((_) => _checkAuthAndLoadData());
    } else {
      Navigator.pushNamed(context, '/auth')
          .then((_) => _checkAuthAndLoadData());
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('您确定要退出登录吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('确定')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _storage.delete(key: 'authToken'); // Use your actual key
      setState(() {
        _isLoggedIn = false;
        _userData = null;
        _isLoading = false; // Ensure loading is off
      });
      SnackbarUtil.showSuccess(context, "已退出登录");
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking auth
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Determine display values based on login state
    final String avatarUrl = _isLoggedIn
        ? (_userData?['avatarUrl'] ??
            'https://via.placeholder.com/150/cccccc/FFFFFF?text=User')
        : 'https://via.placeholder.com/150/cccccc/FFFFFF?text=Login';
    final String displayName =
        _isLoggedIn ? (_userData?['name'] ?? '用户') : '点击登录';

    // Build the main content using the original structure, but with modifications
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header (Avatar & Name) ---
          GestureDetector(
            onTap: _handleAvatarTap, // Use the handler function
            child: Center(
              child: Column(
                // Wrap in Column to add name below avatar
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(avatarUrl),
                    // Use dynamic avatarUrl
                    onBackgroundImageError: (_, __) {
                      /* Handle error */
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayName, // Use dynamic displayName
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Status Counters ---
          // Add checks here if these sections should only be shown when logged in
          // if (_isLoggedIn)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  if (!_isLoggedIn) {
                    _handleAvatarTap();
                    return;
                  } // Prompt login if needed
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ApplicationHistoryScreen(
                              initialTabIndex: 1)));
                },
                child: const StatusCounter(
                    label: '沟通过', count: 12), // Counts should be dynamic
              ),
              GestureDetector(
                onTap: () {
                  if (!_isLoggedIn) {
                    _handleAvatarTap();
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ApplicationHistoryScreen(
                              initialTabIndex: 0)));
                },
                child: const StatusCounter(label: '已投递', count: 5),
              ),
              GestureDetector(
                onTap: () {
                  if (!_isLoggedIn) {
                    _handleAvatarTap();
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const PendingInterviewScreen()));
                },
                child: const StatusCounter(label: '待面试', count: 2),
              ),
              GestureDetector(
                onTap: () {
                  if (!_isLoggedIn) {
                    _handleAvatarTap();
                    return;
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CollectScreen()));
                },
                child: const StatusCounter(label: '收藏', count: 2),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Common Functions Card ---
          // if (_isLoggedIn) // Add check if needed
          const Text('常用功能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('在线简历'),
                  onTap: () {
                    if (!_isLoggedIn) {
                      _handleAvatarTap();
                      return;
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ResumePage()));
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: const Text('附件简历'),
                  onTap: () {
                    if (!_isLoggedIn) {
                      _handleAvatarTap();
                      return;
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AttachmentResumePage()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Other Functions List ---
          const Text('其他功能',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                leading: const Icon(Icons.event),
                title: const Text('招聘会'),
                onTap: () {
                  // Usually public, no login check needed
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecruitmentFairPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('面试刷题'),
                onTap: () {
                  // May or may not need login
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => QuizScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('人格测试'),
                onTap: () {
                  // May or may not need login
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PersonalityTestScreen()));
                },
              ),

              // --- Logout Button (Conditional) ---
              if (_isLoggedIn) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('退出登录', style: TextStyle(color: Colors.red)),
                  onTap: _handleLogout, // Use the handler function
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
