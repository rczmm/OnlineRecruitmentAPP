import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'package:zhaopingapp/core/utils/snackbar_util.dart';
import 'package:zhaopingapp/features/profile/data/models/user_profile_model.dart';
import 'package:zhaopingapp/features/profile/data/services/user_profile_service.dart';

class UserInfoScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const UserInfoScreen({super.key, this.userData});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {

  late final TextEditingController _idController;
  late final TextEditingController _nameController;

  late final TextEditingController _exJobController;
  late final TextEditingController _exMinSalaryController;
  late final TextEditingController _exMaxSalaryController;
  late final TextEditingController _personIntroductionController;
  late final TextEditingController _cityController;


  List<String> _specialties = [];


  int _workExperienceYears = 0;


  final List<int> _workExperienceOptions = List.generate(21, (index) => index);

  String? _currentAvatarUrl;

  String? _profileUserId;

  String? _profileId;


  final UserProfileService _profileService = UserProfileService();


  bool _isSaving = false;
  bool _isLoadingProfile = true;


  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _fetchUserProfile();

    _idController = TextEditingController();
    _nameController = TextEditingController(text: widget.userData?['name']?.toString() ?? '');
    _exJobController = TextEditingController();
    _exMinSalaryController = TextEditingController();
    _exMaxSalaryController = TextEditingController();
    _personIntroductionController = TextEditingController();
    _cityController = TextEditingController();


    _currentAvatarUrl = widget.userData?['avatarUrl']?.toString();
    _profileUserId = widget.userData?['id']?.toString();
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    _idController.dispose();
    _nameController.dispose();
    _exJobController.dispose();
    _exMinSalaryController.dispose();
    _exMaxSalaryController.dispose();
    _personIntroductionController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoadingProfile = true;
    });

    try {
      final profile = await _profileService.getUserProfile();

      if (profile != null && mounted) {
        setState(() {
          _updateControllersAndState(profile);
        });
      } else if (mounted) {
        SnackbarUtil.showInfo(context, '未找到详细个人信息，请填写。');
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) {
        SnackbarUtil.showError(context, '获取个人信息失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _updateControllersAndState(UserProfile profile) {
    _profileId = profile.id;
    _profileUserId = profile.userId ?? _profileUserId;

    _idController.text = _profileId ?? '';
    _nameController.text = profile.name ?? _nameController.text;
    _exJobController.text = profile.exJob ?? '';
    _exMinSalaryController.text = profile.exMinSalary ?? '';
    _exMaxSalaryController.text = profile.exMaxSalary ?? '';
    _personIntroductionController.text = profile.personIntroduction ?? '';
    _cityController.text = profile.city ?? '';

    _specialties = profile.specialty ?? [];

    _workExperienceYears = _parseWorkExperience(profile.workExperience);

    _currentAvatarUrl = profile.avatarUrl ?? _currentAvatarUrl;
  }

  int _parseWorkExperience(String? experienceString) {
    if (experienceString == null || experienceString.isEmpty || experienceString == '无工作经验') {
      return 0;
    }
    try {
      // Extract digits from the string
      final yearsMatch = RegExp(r'(\d+)').firstMatch(experienceString);
      if (yearsMatch != null) {
        final years = int.parse(yearsMatch.group(1)!);
        // Find the closest valid option in the dropdown list
        return _findClosestExperienceOption(years);
      }
    } catch (e) {
      debugPrint('解析工作经验年限失败: "$experienceString", Error: $e');
    }
    // Default to 0 if parsing fails or format is unexpected
    return 0;
  }

  int _findClosestExperienceOption(int years) {
    if (years <= 0) return 0;
    if (years >= _workExperienceOptions.last) return _workExperienceOptions.last;

    // Since options are sequential integers, the closest option is the number itself if within range.
    if (_workExperienceOptions.contains(years)) {
      return years;
    }

    // Fallback logic (though less likely needed with sequential options)
    int closest = _workExperienceOptions[0];
    int minDiff = (years - closest).abs();

    for (int option in _workExperienceOptions) {
      int diff = (years - option).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = option;
      } else if (diff == minDiff && option > closest) {
        // Prefer the higher option in case of a tie if needed, or keep lower
        closest = option;
      }
    }
    return closest;
  }

  void _addSpecialty(String specialty) {
    final trimmedSpecialty = specialty.trim();
    if (trimmedSpecialty.isNotEmpty && !_specialties.contains(trimmedSpecialty)) {
      setState(() {
        _specialties.add(trimmedSpecialty);
      });
    } else if (_specialties.contains(trimmedSpecialty)) {
      SnackbarUtil.showInfo(context, '技能 "$trimmedSpecialty" 已存在');
    }
  }

  void _removeSpecialty(String specialty) {
    setState(() {
      _specialties.remove(specialty);
    });
  }

  Future<void> _saveProfile() async {

    if (_nameController.text.trim().isEmpty) {
      SnackbarUtil.showError(context, '姓名不能为空');
      return;
    }

    final minSalary = int.tryParse(_exMinSalaryController.text);
    final maxSalary = int.tryParse(_exMaxSalaryController.text);
    if (minSalary != null && maxSalary != null && minSalary > maxSalary) {
      SnackbarUtil.showError(context, '最低薪资不能高于最高薪资');
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSaving = true;
    });

    try {
      final String? userIdForUpdate = _profileUserId;
      if (userIdForUpdate == null) {
        throw Exception('无法确定用户ID，无法保存。');
      }

      final updatedProfile = UserProfile(
        id: _profileId,
        userId: userIdForUpdate,
        name: _nameController.text.trim(),
        exJob: _exJobController.text.trim(),
        exMinSalary: _exMinSalaryController.text.trim(),
        exMaxSalary: _exMaxSalaryController.text.trim(),
        personIntroduction: _personIntroductionController.text.trim(),
        workExperience: _workExperienceYears == 0
            ? '无工作经验'
            : '$_workExperienceYears',
        specialty: _specialties,
        city: _cityController.text.trim(),
        avatarUrl: _currentAvatarUrl,
      );

      final success = await _profileService.updateUserProfile(updatedProfile);

      if (success && mounted) {
        SnackbarUtil.showSuccess(context, '个人信息已更新');
        // Optionally pass back updated data if needed by the previous screen
        Navigator.of(context).pop(true); // Pop with a success indicator
      } else if (!success && mounted) {
        // Use a generic message or potentially parse specific error from service
        SnackbarUtil.showError(context, '更新个人信息失败');
      }
    } catch (e) {
      debugPrint("Error saving profile: $e");
      if (mounted) {
        SnackbarUtil.showError(context, '更新失败: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _changeAvatar() {
    // TODO: Implement image picker and upload logic
    SnackbarUtil.showInfo(context,'更换头像功能待实现');
    // Example:
    // 1. Use image_picker to select an image.
    // 2. Upload the image to your backend/storage.
    // 3. Get the new URL.
    // 4. Update _currentAvatarUrl state.
    // 5. Potentially call a specific avatar update API endpoint or include in _saveProfile.
  }

  void _showAddSkillDialog() {
    final TextEditingController skillController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加专业技能'),
        content: TextField(
          controller: skillController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入专业技能',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) { // Allow adding by pressing Enter/Done
            _addSpecialty(skillController.text);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              _addSpecialty(skillController.text);
              Navigator.pop(context);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final String displayAvatarUrl = (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty)
        ? _currentAvatarUrl!
        : 'https://via.placeholder.com/150/cccccc/FFFFFF?text=User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          // Save button with loading indicator
          _isSaving
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0), // Match IconButton padding
            child: SizedBox(
                width: 24, // Standard icon size
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5)),
          )
              : IconButton(
            icon: const Icon(Icons.save_alt_outlined), // Slightly different save icon
            onPressed: _isSaving ? null : _saveProfile, // Disable while saving
            tooltip: '保存',
          ),
        ],
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Form( // Wrap content in a Form for potential validation
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section
              GestureDetector(
                onTap: _changeAvatar,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50, // Slightly smaller radius
                      backgroundImage: NetworkImage(displayAvatarUrl),
                      // Handle image loading errors gracefully
                      onBackgroundImageError: (exception, stackTrace) {
                        debugPrint("Error loading avatar: $exception");
                        // Optionally update state to show a placeholder if needed
                      },
                      // Placeholder background color
                      backgroundColor: Colors.grey[300],
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.black54, // Darker background for better contrast
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit,
                          color: Colors.white, size: 16), // Smaller icon
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField( // Use TextFormField for validation integration
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名 *', // Indicate required field
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入姓名';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // City Field
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: '所在城市',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20), // Increased spacing

              // Professional Skills Section
              _buildSectionHeader('专业技能'),
              Wrap(
                spacing: 8.0, // Horizontal space between chips
                runSpacing: 4.0, // Vertical space between lines of chips
                children: [
                  ..._specialties.map((skill) => Chip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeSpecialty(skill),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  )).toList(),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: const Text('添加技能'),
                    onPressed: _showAddSkillDialog, // Show dialog on press
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Expected Job Field
              _buildSectionHeader('求职期望'),
              TextFormField(
                controller: _exJobController,
                decoration: const InputDecoration(
                  labelText: '期望职位',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work_outline),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Salary Range Fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align tops
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _exMinSalaryController,
                      decoration: const InputDecoration(
                        labelText: '最低月薪 (元)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      // Only allow digits
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      // Optional: Add validation for numeric format
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return '请输入有效数字';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _exMaxSalaryController,
                      decoration: const InputDecoration(
                        labelText: '最高月薪 (元)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money), // Keep consistent icon
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                          return '请输入有效数字';
                        }
                        // Add cross-field validation in _saveProfile or here if needed
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Work Experience Section
              _buildSectionHeader('工作经验'),
              DropdownButtonFormField<int>(
                value: _workExperienceYears,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_center_outlined),
                  // Remove labelText if using a separate header
                ),
                items: _workExperienceOptions.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year == 0 ? '无工作经验' : '$year 年'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _workExperienceYears = value;
                    });
                  }
                },
                // Make dropdown expand to fill width
                isExpanded: true,
              ),
              const SizedBox(height: 20),


              // Personal Introduction Field
              _buildSectionHeader('个人介绍'),
              TextFormField(
                controller: _personIntroductionController,
                decoration: const InputDecoration(
                  hintText: '选填，介绍一下你的优势和经历...', // Use hintText
                  border: OutlineInputBorder(),
                  // prefixIcon: Icon(Icons.description_outlined), // Alternative icon
                  alignLabelWithHint: true, // Good for multi-line fields
                ),
                maxLines: 4, // Allow more lines
                minLines: 2,
                textInputAction: TextInputAction.done, // Last field
              ),
              const SizedBox(height: 32), // Extra space at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600, // Bolder
          ),
        ),
      ),
    );
  }
}