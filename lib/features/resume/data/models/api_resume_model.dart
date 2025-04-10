import 'dart:convert';

import '../models/resume_model.dart';
import '../models/work_experience_model.dart';
import '../models/project_experience_model.dart';
import '../models/education_model.dart';

class ApiResumeModel {
  final int userId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String jobSeekingStatus;
  final String personalStrengths;
  final String jobExpectations;
  final String personalityTraits;
  final String workExperience;
  final String projectExperience;
  final String educationHistory;
  final String honorsAwards;
  final String certificates;
  final String professionalSkills;

  ApiResumeModel({
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.jobSeekingStatus,
    required this.personalStrengths,
    required this.jobExpectations,
    required this.personalityTraits,
    required this.workExperience,
    required this.projectExperience,
    required this.educationHistory,
    required this.honorsAwards,
    required this.certificates,
    required this.professionalSkills,
  });

  factory ApiResumeModel.fromJson(Map<String, dynamic> json) {
    return ApiResumeModel(
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      jobSeekingStatus: json['jobSeekingStatus'] ?? '',
      personalStrengths: json['personalStrengths'] ?? '',
      jobExpectations: json['jobExpectations'] ?? '',
      personalityTraits: json['personalityTraits'] ?? '',
      workExperience: json['workExperience'] ?? '',
      projectExperience: json['projectExperience'] ?? '',
      educationHistory: json['educationHistory'] ?? '',
      honorsAwards: json['honorsAwards'] ?? '',
      certificates: json['certificates'] ?? '',
      professionalSkills: json['professionalSkills'] ?? '',
    );
  }

  // 将API模型转换为应用内使用的ResumeModel
  ResumeModel toResumeModel() {
    // 尝试解析工作经验字符串为WorkExperience对象列表
    List<WorkExperience> workExperiencesList = [];
    try {
      if (workExperience.isNotEmpty) {
        final List<dynamic> workExpJson = json.decode(workExperience);
        workExperiencesList = workExpJson
            .map((item) => WorkExperience.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error parsing workExperience: $e');
    }

    // 尝试解析项目经验字符串为ProjectExperience对象列表
    List<ProjectExperience> projectExperiencesList = [];
    try {
      if (projectExperience.isNotEmpty) {
        final List<dynamic> projectExpJson = json.decode(projectExperience);
        projectExperiencesList = projectExpJson
            .map((item) => ProjectExperience.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error parsing projectExperience: $e');
    }

    // 尝试解析教育经历字符串为Education对象列表
    List<Education> educationList = [];
    try {
      if (educationHistory.isNotEmpty) {
        final List<dynamic> educationJson = json.decode(educationHistory);
        educationList = educationJson
            .map((item) => Education.fromJson(item))
            .toList();
      }
    } catch (e) {
      print('Error parsing educationHistory: $e');
    }

    // 解析荣誉、证书和技能字符串为字符串列表
    List<String> honorsList = [];
    List<String> certList = [];
    List<String> skillsList = [];
    
    try {
      if (honorsAwards.isNotEmpty) {
        honorsList = honorsAwards.split(',').map((e) => e.trim()).toList();
      }
      if (certificates.isNotEmpty) {
        certList = certificates.split(',').map((e) => e.trim()).toList();
      }
      if (professionalSkills.isNotEmpty) {
        skillsList = professionalSkills.split(',').map((e) => e.trim()).toList();
      }
    } catch (e) {
      print('Error parsing string lists: $e');
    }

    return ResumeModel(
      name: name,
      phone: phone,
      email: email,
      address: address,
      jobStatus: jobSeekingStatus,
      strengths: personalStrengths,
      expectations: jobExpectations,
      workExperiences: workExperiencesList,
      projectExperiences: projectExperiencesList,
      educationExperiences: educationList,
      honors: honorsList,
      certifications: certList,
      skills: skillsList,
      personality: personalityTraits,
    );
  }
}