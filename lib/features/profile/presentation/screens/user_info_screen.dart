import 'package:flutter/material.dart';

class UserInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const UserInfoScreen({super.key, this.userData});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  String? _initialName;
  String? _initialAvatarUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initialName = widget.userData?['name']?.toString();
    _initialAvatarUrl = widget.userData?['avatarUrl']?.toString();

    _nameController = TextEditingController(text: _initialName ?? '');
    _emailController = TextEditingController(text: widget.userData?['email']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('姓名不能为空'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('个人信息已更新'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changeAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('更换头像功能待实现')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentAvatarUrl = _initialAvatarUrl ??
        'https://via.placeholder.com/150/cccccc/FFFFFF?text=User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          // Save button
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveProfile,
                  tooltip: '保存',
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _changeAvatar,
              child: Stack(
                // Use Stack to overlay an edit icon
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(currentAvatarUrl),
                    onBackgroundImageError: (_, __) {}, // Handle error
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(10),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: '邮箱',
                hintText: widget.userData?['email'] ?? '未设置',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
