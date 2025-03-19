import 'package:flutter/material.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  bool _isEditing = false;
  final TextEditingController _nameController =
      TextEditingController(text: '张三');
  final TextEditingController _phoneController =
      TextEditingController(text: '13800138000');
  final TextEditingController _emailController =
      TextEditingController(text: 'zhangsan@example.com');
  final TextEditingController _addressController =
      TextEditingController(text: '北京市');
  final TextEditingController _jobStatusController =
      TextEditingController(text: '目前正在积极寻找Java后端开发相关工作。');
  final TextEditingController _strengthsController = TextEditingController(
      text: '• 扎实的Java基础，熟悉常用框架（Spring、MyBatis等）。\n• 良好的编码习惯和团队合作精神。');
  final TextEditingController _expectationsController =
      TextEditingController(text: '期望职位：Java后端开发工程师\n期望地点：北京、上海\n期望薪资：面议');
  final TextEditingController _workExperienceController = TextEditingController(
      text: 'XX公司  Java开发工程师  2020.07 - 至今\n• 负责XXX项目的开发和维护。');
  final TextEditingController _projectExperienceController =
      TextEditingController(
          text: 'XXX项目  2021.01 - 2021.06\n• 使用XXX技术完成了XXX功能。');
  final TextEditingController _educationExperienceController =
      TextEditingController(text: 'XX大学  计算机科学与技术  本科  2016.09 - 2020.06');
  final TextEditingController _honorsController =
      TextEditingController(text: '• 获得XX奖学金。');
  final TextEditingController _certificationsController =
      TextEditingController(text: '• 获得XXX认证。');
  final TextEditingController _skillsController =
      TextEditingController(text: 'Java, Spring, MySQL');
  final TextEditingController _personalityController =
      TextEditingController(text: '• 具有较强的学习能力和适应能力，能够快速掌握新技术。');

  // 为了方便管理技能标签
  List<String> _skillsList = ['Java', 'Spring', 'MySQL'];
  final TextEditingController _newSkillController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _jobStatusController.dispose();
    _strengthsController.dispose();
    _expectationsController.dispose();
    _workExperienceController.dispose();
    _projectExperienceController.dispose();
    _educationExperienceController.dispose();
    _honorsController.dispose();
    _certificationsController.dispose();
    _skillsController.dispose();
    _personalityController.dispose();
    _newSkillController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // 在编辑结束后，可以保存数据到数据库或进行其他处理
        print('保存数据：');
        print('姓名: ${_nameController.text}');
        print('电话: ${_phoneController.text}');
        // ... 其他数据的保存
      }
    });
  }

  void _addSkill() {
    if (_newSkillController.text.isNotEmpty) {
      setState(() {
        _skillsList.add(_newSkillController.text.trim());
        _newSkillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skillsList.remove(skill);
    });
  }

  // 构建section标题的通用方法
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  // 以下是各个部分的具体内容构建方法，根据编辑状态显示不同的Widget

  Widget _buildPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEditableText(_isEditing, '姓名', _nameController),
        _buildEditableText(_isEditing, '电话', _phoneController),
        _buildEditableText(_isEditing, '邮箱', _emailController),
        _buildEditableText(_isEditing, '地址', _addressController),
        // 可以添加头像等编辑功能
      ],
    );
  }

  Widget _buildJobStatus() {
    return _buildEditableText(_isEditing, '求职状态', _jobStatusController,
        maxLines: null);
  }

  Widget _buildPersonalStrengths() {
    return _buildEditableText(_isEditing, '个人优势', _strengthsController,
        maxLines: null);
  }

  Widget _buildJobExpectations() {
    return _buildEditableText(_isEditing, '求职期望', _expectationsController,
        maxLines: null);
  }

  Widget _buildWorkExperience() {
    return _buildEditableText(_isEditing, '工作经历', _workExperienceController,
        maxLines: null);
  }

  Widget _buildProjectExperience() {
    return _buildEditableText(_isEditing, '项目经历', _projectExperienceController,
        maxLines: null);
  }

  Widget _buildEducationExperience() {
    return _buildEditableText(
        _isEditing, '教育经历', _educationExperienceController,
        maxLines: null);
  }

  Widget _buildHonors() {
    return _buildEditableText(_isEditing, '所获荣誉', _honorsController,
        maxLines: null);
  }

  Widget _buildCertifications() {
    return _buildEditableText(_isEditing, '资格证书', _certificationsController,
        maxLines: null);
  }

  Widget _buildSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newSkillController,
                  decoration: const InputDecoration(labelText: '添加技能'),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addSkill,
              ),
            ],
          ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _skillsList
              .map((skill) => Chip(
                    label: Text(skill),
                    deleteIcon: _isEditing ? const Icon(Icons.cancel) : null,
                    onDeleted: _isEditing ? () => _removeSkill(skill) : null,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPersonality() {
    return _buildEditableText(_isEditing, '职业性格', _personalityController,
        maxLines: null);
  }

  // 根据编辑状态构建Text或TextFormField
  Widget _buildEditableText(
      bool isEditing, String label, TextEditingController controller,
      {int? maxLines = 1}) {
    if (isEditing) {
      return Row(
        children: [
          SizedBox(
            width: 80, // 可以调整标签的宽度
            child: Text('$label：',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              // 可以添加边框使其更清晰
              maxLines: maxLines,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label：', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(controller.text),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑我的简历' : '我的简历'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('个人信息'),
            _buildPersonalInfo(),
            const SizedBox(height: 16),
            _buildSectionTitle('求职状态'),
            _buildJobStatus(),
            const SizedBox(height: 16),
            _buildSectionTitle('个人优势'),
            _buildPersonalStrengths(),
            const SizedBox(height: 16),
            _buildSectionTitle('求职期望'),
            _buildJobExpectations(),
            const SizedBox(height: 16),
            _buildSectionTitle('工作经历'),
            _buildWorkExperience(),
            const SizedBox(height: 16),
            _buildSectionTitle('项目经历'),
            _buildProjectExperience(),
            const SizedBox(height: 16),
            _buildSectionTitle('教育经历'),
            _buildEducationExperience(),
            const SizedBox(height: 16),
            _buildSectionTitle('所获荣誉'),
            _buildHonors(),
            const SizedBox(height: 16),
            _buildSectionTitle('资格证书'),
            _buildCertifications(),
            const SizedBox(height: 16),
            _buildSectionTitle('专业技能'),
            _buildSkills(),
            const SizedBox(height: 16),
            _buildSectionTitle('职业性格'),
            _buildPersonality(),
          ],
        ),
      ),
    );
  }
}
