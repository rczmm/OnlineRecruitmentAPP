import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zhaopingapp/core/services/AuthService.dart';
import '../../data/models/resume_model.dart';
import '../../data/models/work_experience_model.dart';
import '../../data/models/project_experience_model.dart';
import '../../data/models/education_model.dart';
import '../bloc/resume_bloc.dart';
import '../bloc/resume_event.dart';
import '../bloc/resume_state.dart';
import '../widgets/resume_section.dart';
import '../widgets/editable_text_field.dart';
import '../widgets/list_item_card.dart';
import '../widgets/skill_chip.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  bool _isEditing = false;
  late ResumeBloc _resumeBloc;
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for basic info
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _jobStatusController = TextEditingController();
  final _strengthsController = TextEditingController();
  final _expectationsController = TextEditingController();
  final _personalityController = TextEditingController();
  final _newSkillController = TextEditingController();

  // Form field variables
  String company = '';
  String position = '';
  String startDate = '';
  String endDate = '';
  String description = '';

  @override
  void initState() {
    super.initState();
    _resumeBloc = ResumeBloc();
    _resumeBloc.add(LoadResume());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _jobStatusController.dispose();
    _strengthsController.dispose();
    _expectationsController.dispose();
    _personalityController.dispose();
    _newSkillController.dispose();
    _resumeBloc.close();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing && _formKey.currentState?.validate() == true) {
        _saveResume();
      }
    });
  }

  Future<void> _saveResume() async {
    debugPrint('_saveResume 方法被调用');
    final currentState = _resumeBloc.state;

    String userId = await AuthService().getCurrentUserId() ?? '0';

    if (currentState is ResumeLoaded) {
      debugPrint('创建更新后的简历模型');
      final updatedResume = ResumeModel(
        id: currentState.resume.id,
        userId: userId,
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        address: _addressController.text,
        jobStatus: _jobStatusController.text,
        strengths: _strengthsController.text,
        expectations: _expectationsController.text,
        workExperiences: currentState.resume.workExperiences,
        projectExperiences: currentState.resume.projectExperiences,
        educationExperiences: currentState.resume.educationExperiences,
        honors: currentState.resume.honors,
        certifications: currentState.resume.certifications,
        skills: currentState.resume.skills,
        personality: _personalityController.text,
      );
      debugPrint(updatedResume.name);
      _resumeBloc.add(UpdateResume(updatedResume));
    }
  }

  void _updateControllers(ResumeModel resume) {
    _nameController.text = resume.name;
    _phoneController.text = resume.phone;
    _emailController.text = resume.email;
    _addressController.text = resume.address;
    _jobStatusController.text = resume.jobStatus;
    _strengthsController.text = resume.strengths;
    _expectationsController.text = resume.expectations;
    _personalityController.text = resume.personality;
  }

  Widget _buildBasicInfo() {
    return ResumeSection(
      title: '个人信息',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditableTextField(
            isEditing: _isEditing,
            label: '姓名',
            controller: _nameController,
            validator: (value) => value?.isEmpty == true ? '请输入姓名' : null,
          ),
          const SizedBox(height: 8),
          EditableTextField(
            isEditing: _isEditing,
            label: '电话',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? '请输入电话' : null,
          ),
          const SizedBox(height: 8),
          EditableTextField(
            isEditing: _isEditing,
            label: '邮箱',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value?.isEmpty == true ? '请输入邮箱' : null,
          ),
          const SizedBox(height: 8),
          EditableTextField(
            isEditing: _isEditing,
            label: '地址',
            controller: _addressController,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkExperiences(List<WorkExperience> experiences) {
    return ResumeSection(
      title: '工作经历',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Variables to hold the state *within* the dialog
                  String company = '';
                  String position = '';
                  String startDate = '';
                  String endDate = '';
                  String description = '';

                  showDialog(
                    context: context,
                    // Use StatefulBuilder to manage the dialog's internal state
                    builder: (dialogContext) =>
                        StatefulBuilder(builder: (stfContext, stfSetState) {
                      return AlertDialog(
                        title: const Text('添加工作经历'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '公司名称',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                // Update local variable on change
                                onChanged: (value) => company = value,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '职位',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                onChanged: (value) => position = value,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '开始日期',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                onChanged: (value) => startDate = value,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '结束日期',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                onChanged: (value) => endDate = value,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '工作描述',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                maxLines: 3,
                                onChanged: (value) => description = value,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            // Use dialogContext to pop the dialog
                            onPressed: () {
                              // 先移除焦点，避免指针绑定错误
                              FocusScope.of(dialogContext).unfocus();
                              Navigator.pop(dialogContext);
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 先移除焦点，避免指针绑定错误
                              FocusScope.of(dialogContext).unfocus();

                              // Basic validation
                              if (company.isNotEmpty && position.isNotEmpty) {
                                final newExperience = WorkExperience(
                                  company: company,
                                  position: position,
                                  startDate: startDate,
                                  endDate: endDate,
                                  description: description,
                                );

                                // 使用Future.delayed确保在对话框关闭后再添加事件
                                Future.delayed(Duration.zero, () {
                                  _resumeBloc
                                      .add(AddWorkExperience(newExperience));
                                });

                                // 关闭对话框
                                Navigator.pop(dialogContext);
                              } else {
                                // Optional: Show an error message if fields are empty
                                ScaffoldMessenger.of(stfContext).showSnackBar(
                                  const SnackBar(content: Text('公司名称和职位不能为空！')),
                                );
                              }
                            },
                            child: const Text('添加'),
                          ),
                        ],
                      );
                    }),
                  );
                },
                child: const Text('添加工作经历'),
              ),
            ),
          ...experiences.map((exp) => ListItemCard(
                isEditing: _isEditing,
                onEdit: () {
                  debugPrint('Edit ${exp.company}');
                },
                onDelete: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text('请确认'),
                          content: Text('确定要删除 "${exp.company}" 的工作经历吗？'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('取消')),
                            TextButton(
                                onPressed: () {
                                  _resumeBloc
                                      .add(DeleteWorkExperience(exp.company));
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('删除',
                                    style: TextStyle(color: Colors.red)))
                          ],
                        );
                      });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exp.company,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${exp.position} (${exp.startDate} - ${exp.endDate})'),
                    const SizedBox(height: 4),
                    Text(exp.description),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProjectExperiences(List<ProjectExperience> projects) {
    return ResumeSection(
      title: '项目经历',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  String name = '';
                  String startDate = '';
                  String endDate = '';
                  String description = '';

                  showDialog(
                    context: context,
                    builder: (context) =>
                        StatefulBuilder(builder: (stfContext, stfSetState) {
                      return AlertDialog(
                        title: const Text('添加项目经历'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '项目名称',
                                  border: OutlineInputBorder(),
                                  // Added styling
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8), // Added styling
                                ),
                                onChanged: (value) => name = value,
                              ),
                              const SizedBox(height: 12),
                              // Added spacing
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '开始日期',
                                  border: OutlineInputBorder(),
                                  // Added styling
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8), // Added styling
                                ),
                                onChanged: (value) => startDate = value,
                              ),
                              const SizedBox(height: 12),
                              // Added spacing
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '结束日期',
                                  border: OutlineInputBorder(),
                                  // Added styling
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8), // Added styling
                                ),
                                onChanged: (value) => endDate = value,
                              ),
                              const SizedBox(height: 12),
                              // Added spacing
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: '项目描述',
                                  border: OutlineInputBorder(),
                                  // Added styling
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8), // Added styling
                                ),
                                maxLines: 3,
                                onChanged: (value) => description = value,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // 先移除焦点，避免指针绑定错误
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            },
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 先移除焦点，避免指针绑定错误
                              FocusScope.of(context).unfocus();

                              if (name.isNotEmpty) {
                                final newProject = ProjectExperience(
                                  name: name,
                                  startDate: startDate,
                                  endDate: endDate,
                                  description: description,
                                );

                                // 使用Future.delayed确保在对话框关闭后再添加事件
                                Future.delayed(Duration.zero, () {
                                  _resumeBloc
                                      .add(AddProjectExperience(newProject));
                                });

                                // 关闭对话框
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(stfContext).showSnackBar(
                                  const SnackBar(content: Text('项目名称不能为空！')),
                                );
                              }
                            },
                            child: const Text('添加'),
                          ),
                        ],
                      );
                    }),
                  );
                },
                child: const Text('添加项目经历'),
              ),
            ),
          ...projects.map((project) => ListItemCard(
                isEditing: _isEditing,
                onEdit: () {
                  // Show edit dialog
                },
                onDelete: () {
                  // Delete project
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${project.startDate} - ${project.endDate}'),
                    const SizedBox(height: 4),
                    Text(project.description),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEducationExperiences(List<Education> educations) {
    return ResumeSection(
      title: '教育经历',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  String school = '';
                  String major = '';
                  String degree = '';
                  String startDate = '';
                  String endDate = '';

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('添加教育经历'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              decoration:
                                  const InputDecoration(labelText: '学校名称'),
                              onChanged: (value) => school = value,
                            ),
                            TextField(
                              decoration:
                                  const InputDecoration(labelText: '专业'),
                              onChanged: (value) => major = value,
                            ),
                            TextField(
                              decoration:
                                  const InputDecoration(labelText: '学位'),
                              onChanged: (value) => degree = value,
                            ),
                            TextField(
                              decoration:
                                  const InputDecoration(labelText: '开始日期'),
                              onChanged: (value) => startDate = value,
                            ),
                            TextField(
                              decoration:
                                  const InputDecoration(labelText: '结束日期'),
                              onChanged: (value) => endDate = value,
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // 先移除焦点，避免指针绑定错误
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            // 先移除焦点，避免指针绑定错误
                            FocusScope.of(context).unfocus();

                            if (school.isNotEmpty && major.isNotEmpty) {
                              final newEducation = Education(
                                school: school,
                                major: major,
                                degree: degree,
                                startDate: startDate,
                                endDate: endDate,
                              );

                              // 使用Future.delayed确保在对话框关闭后再添加事件
                              Future.delayed(Duration.zero, () {
                                _resumeBloc.add(AddEducation(newEducation));
                              });

                              // 关闭对话框
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('添加'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('添加教育经历'),
              ),
            ),
          ...educations.map((edu) => ListItemCard(
                isEditing: _isEditing,
                onEdit: () {
                  // Show edit dialog
                },
                onDelete: () {
                  // Delete education
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(edu.school,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${edu.major} - ${edu.degree}'),
                    Text('${edu.startDate} - ${edu.endDate}'),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildHonors(List<String> honors) {
    return ResumeSection(
      title: '所获荣誉',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  String honor = '';

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('添加荣誉'),
                      content: TextField(
                        decoration: const InputDecoration(
                          labelText: '荣誉名称',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) => honor = value,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // 先移除焦点，避免指针绑定错误
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (honor.isNotEmpty) {
                              _resumeBloc.add(AddHonor(honor));
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('添加'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('添加荣誉'),
              ),
            ),
          ...honors.map((honor) => ListItemCard(
                isEditing: _isEditing,
                onEdit: () {
                  // Show edit dialog
                },
                onDelete: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text('请确认'),
                          content: Text('确定要删除 "$honor" 吗？'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('取消')),
                            TextButton(
                                onPressed: () {
                                  _resumeBloc.add(DeleteHonor(honor));
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('删除',
                                    style: TextStyle(color: Colors.red)))
                          ],
                        );
                      });
                },
                child: Text(honor),
              )),
        ],
      ),
    );
  }

  Widget _buildCertifications(List<String> certifications) {
    return ResumeSection(
      title: '资格证书',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  String certification = '';

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('添加证书'),
                      content: TextField(
                        decoration: const InputDecoration(
                          labelText: '证书名称',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) => certification = value,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            // 先移除焦点，避免指针绑定错误
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (certification.isNotEmpty) {
                              _resumeBloc.add(AddCertification(certification));
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('添加'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('添加证书'),
              ),
            ),
          ...certifications.map((cert) => ListItemCard(
                isEditing: _isEditing,
                onEdit: () {
                  // Show edit dialog
                },
                onDelete: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return AlertDialog(
                          title: const Text('请确认'),
                          content: Text('确定要删除 "$cert" 吗？'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('取消')),
                            TextButton(
                                onPressed: () {
                                  _resumeBloc.add(DeleteCertification(cert));
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('删除',
                                    style: TextStyle(color: Colors.red)))
                          ],
                        );
                      });
                },
                child: Text(cert),
              )),
        ],
      ),
    );
  }

  Widget _buildSkills(List<String> skills) {
    return ResumeSection(
      title: '专业技能',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newSkillController,
                      decoration: const InputDecoration(
                        labelText: '添加技能',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSkill,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: skills
                .map((skill) => SkillChip(
                      skill: skill,
                      isEditing: _isEditing,
                      onDelete: () {
                        final currentState = _resumeBloc.state;
                        if (currentState is ResumeLoaded) {
                          final updatedSkills = List<String>.from(skills)
                            ..remove(skill);
                          _resumeBloc.add(UpdateSkills(updatedSkills));
                        }
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  void _addSkill() {
    if (_newSkillController.text.isNotEmpty) {
      final currentState = _resumeBloc.state;
      if (currentState is ResumeLoaded) {
        final updatedSkills = List<String>.from(currentState.resume.skills)
          ..add(_newSkillController.text.trim());
        _resumeBloc.add(UpdateSkills(updatedSkills));
        _newSkillController.clear();
      }
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
      body: BlocConsumer<ResumeBloc, ResumeState>(
        bloc: _resumeBloc,
        listener: (context, state) {
          debugPrint('BlocConsumer listener: $state');
          if (state is ResumeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ResumeSaving) {
            debugPrint('正在保存简历...');
          } else if (state is ResumeLoaded) {
            debugPrint('简历已加载/更新');
            if (_isEditing) {
              // 如果是从编辑状态加载的，说明保存成功，退出编辑模式
              setState(() {
                _isEditing = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('简历已保存')),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ResumeLoading || state is ResumeSaving) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ResumeLoaded) {
            _updateControllers(state.resume);
            return SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBasicInfo(),
                    const SizedBox(height: 16),
                    ResumeSection(
                      title: '求职信息',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditableTextField(
                            isEditing: _isEditing,
                            label: '求职状态',
                            controller: _jobStatusController,
                            maxLines: null,
                          ),
                          const SizedBox(height: 12),
                          EditableTextField(
                            isEditing: _isEditing,
                            label: '个人优势',
                            controller: _strengthsController,
                            maxLines: null,
                          ),
                          const SizedBox(height: 12),
                          EditableTextField(
                            isEditing: _isEditing,
                            label: '求职期望',
                            controller: _expectationsController,
                            maxLines: null,
                          ),
                        ],
                      ),
                    ),
                    _buildWorkExperiences(state.resume.workExperiences),
                    _buildProjectExperiences(state.resume.projectExperiences),
                    _buildEducationExperiences(
                        state.resume.educationExperiences),
                    _buildHonors(state.resume.honors),
                    _buildCertifications(state.resume.certifications),
                    _buildSkills(state.resume.skills),
                    ResumeSection(
                      title: '职业性格',
                      child: EditableTextField(
                        isEditing: _isEditing,
                        label: '描述',
                        controller: _personalityController,
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  '加载失败，请重试',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
