import 'package:zhaopingapp/features/resume/data/models/project_experience_model.dart';
import 'package:zhaopingapp/features/resume/data/models/work_experience_model.dart';

import 'education_model.dart';

class ResumeModel {
  final String name;
  final String phone;
  final String email;
  final String address;
  final String jobStatus;
  final String strengths;
  final String expectations;
  final List<WorkExperience> workExperiences;
  final List<ProjectExperience> projectExperiences;
  final List<Education> educationExperiences;
  final List<String> honors;
  final List<String> certifications;
  final List<String> skills;
  final String personality;

  ResumeModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.jobStatus,
    required this.strengths,
    required this.expectations,
    required this.workExperiences,
    required this.projectExperiences,
    required this.educationExperiences,
    required this.honors,
    required this.certifications,
    required this.skills,
    required this.personality,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    return ResumeModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      jobStatus: json['jobStatus'] ?? '',
      strengths: json['strengths'] ?? '',
      expectations: json['expectations'] ?? '',
      workExperiences: (json['workExperiences'] as List?)
          ?.map((e) => WorkExperience.fromJson(e))
          .toList() ?? [],
      projectExperiences: (json['projectExperiences'] as List?)
          ?.map((e) => ProjectExperience.fromJson(e))
          .toList() ?? [],
      educationExperiences: (json['educationExperiences'] as List?)
          ?.map((e) => Education.fromJson(e))
          .toList() ?? [],
      honors: List<String>.from(json['honors'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      personality: json['personality'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'jobStatus': jobStatus,
      'strengths': strengths,
      'expectations': expectations,
      'workExperiences': workExperiences.map((e) => e.toJson()).toList(),
      'projectExperiences': projectExperiences.map((e) => e.toJson()).toList(),
      'educationExperiences': educationExperiences.map((e) => e.toJson()).toList(),
      'honors': honors,
      'certifications': certifications,
      'skills': skills,
      'personality': personality,
    };
  }

  // Mock data for testing
  static ResumeModel getMockData() {
    return ResumeModel(
      name: '张三',
      phone: '13800138000',
      email: 'zhangsan@example.com',
      address: '北京市',
      jobStatus: '目前正在积极寻找Java后端开发相关工作。',
      strengths: '• 扎实的Java基础，熟悉常用框架（Spring、MyBatis等）。\n• 良好的编码习惯和团队合作精神。',
      expectations: '期望职位：Java后端开发工程师\n期望地点：北京、上海\n期望薪资：面议',
      workExperiences: [
        WorkExperience(
          company: 'XX公司',
          position: 'Java开发工程师',
          startDate: '2020.07',
          endDate: '至今',
          description: '负责XXX项目的开发和维护。',
        ),
      ],
      projectExperiences: [
        ProjectExperience(
          name: 'XXX项目',
          startDate: '2021.01',
          endDate: '2021.06',
          description: '使用XXX技术完成了XXX功能。',
        ),
      ],
      educationExperiences: [
        Education(
          school: 'XX大学',
          major: '计算机科学与技术',
          degree: '本科',
          startDate: '2016.09',
          endDate: '2020.06',
        ),
      ],
      honors: ['获得XX奖学金。'],
      certifications: ['获得XXX认证。'],
      skills: ['Java', 'Spring', 'MySQL'],
      personality: '具有较强的学习能力和适应能力，能够快速掌握新技术。',
    );
  }

  copyWith({required List<Education> educationExperiences, required List<ProjectExperience> projectExperiences}) {}
}