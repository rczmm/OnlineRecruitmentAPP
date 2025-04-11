import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zhaopingapp/core/services/AuthService.dart';
import 'package:zhaopingapp/features/resume/data/models/education_model.dart';
import '../models/resume_model.dart';
import '../models/work_experience_model.dart';
import '../models/project_experience_model.dart';
import '../models/api_resume_model.dart';
import '../services/resume_service.dart';

class ResumeRepository {
  static const String _resumeKey = 'resume_data';
  final ResumeService _resumeService;

  ResumeRepository({ResumeService? resumeService})
      : _resumeService = resumeService ?? ResumeService();

  Future<ResumeModel> getResume() async {
    try {
      // 首先尝试从API获取数据
      return await fetchResumeFromApi();
    } catch (e) {
      // 如果API获取失败，回退到本地存储
      final prefs = await SharedPreferences.getInstance();
      final resumeJson = prefs.getString(_resumeKey);

      if (resumeJson != null) {
        return ResumeModel.fromJson(json.decode(resumeJson));
      } else {
        // 如果本地存储也没有数据，返回模拟数据
        return ResumeModel.getMockData();
      }
    }
  }

  Future<ResumeModel> fetchResumeFromApi({String? userId}) async {
    try {
      var currentUserId = await AuthService().getCurrentUserId();

      final response = await _resumeService.fetchUserResume(
          userId ?? currentUserId!); // 默认用户ID为1，实际应用中应该从用户会话中获取

      if (response.statusCode == 200) {
        final List<dynamic> resumeList = response.data;
        if (resumeList.isNotEmpty) {
          // 获取第一个简历数据
          final ApiResumeModel apiResume =
              ApiResumeModel.fromJson(resumeList[0]);
          // 转换为应用内使用的ResumeModel
          final resumeModel = apiResume.toResumeModel();
          // 保存到本地存储以便离线使用
          await saveResume(resumeModel);
          return resumeModel;
        }
      }
      throw Exception('Failed to load resume from API');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> saveResume(ResumeModel resume) async {
    try {

      debugPrint('Saving resume to API: $resume');

      final userId = await AuthService().getCurrentUserId();

      // 转换数据格式 - 先创建requestData以保留用户的所有修改
      final requestData = resume.toJson();
      
      // 确保userId正确设置
      requestData['userId'] = userId;

      // 添加调试信息，查看即将保存的数据
      debugPrint('Request data to be saved: $requestData');
      
      // 获取用户简历列表并取第一个ID
      final resumeList = await _resumeService.fetchUserResume(userId!);

      // 修改访问方式，根据实际数据结构获取ID
      if (resumeList.data is List) {
        final List dataList = resumeList.data as List;
        requestData['id'] = dataList.isNotEmpty ? dataList[0]['id'] : null;
      } else if (resumeList.data is Map) {
        // 处理_JsonMap类型
        final Map dataMap = resumeList.data as Map;
        // 尝试直接获取id
        if (dataMap.containsKey('id')) {
          requestData['id'] = dataMap['id'];
        } else if (dataMap.containsKey('data') && dataMap['data'] is List && (dataMap['data'] as List).isNotEmpty) {
          // 尝试从嵌套的data字段获取id
          requestData['id'] = (dataMap['data'] as List)[0]['id'];
        } else {
          debugPrint('无法从Map中获取id: ${resumeList.data}');
          requestData['id'] = null;
        }
      } else {
        debugPrint('Resume list data类型未知: ${resumeList.data}');
        requestData['id'] = null;
      }

      debugPrint("2222222");

      final response = await _resumeService.saveResume(requestData);

      debugPrint('API response: $response');

      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(resume.toJson()));
      }
      throw Exception('Failed to update resume on API');
    } catch (e) {
      // 如果API更新失败，仍然更新本地存储
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(_resumeKey, json.encode(resume.toJson()));
    }
  }

  Future<bool> updateWorkExperience(String id, Map<String, dynamic> updates) async {
    try {
      final resume = await getResume();
      final index = resume.workExperiences.indexWhere((exp) => exp.company == updates['companyName']);
      if (index == -1) return false;

      final updatedExperience = resume.workExperiences[index].copyWith(
        company: updates['companyName'],
        position: updates['position'],
        startDate: updates['startDate'],
        endDate: updates['endDate'],
        description: updates['responsibilities'],
      );

      final newExperiences = List<WorkExperience>.from(resume.workExperiences);
      newExperiences[index] = updatedExperience;
      
      final updatedResume = resume.copyWith(workExperiences: newExperiences);
      return await saveResume(updatedResume);
    } catch (e) {
      debugPrint('更新工作经历失败: $e');
      return false;
    }
  }

  Future<bool> addWorkExperience(Map<String, dynamic> workExperienceMap) async {
    try {
      final resume = await getResume();
      final newExperience = WorkExperience.fromMap(workExperienceMap);
      // 添加到工作经历列表并创建新的简历对象
      final updatedResume = resume.copyWith(workExperiences: [...resume.workExperiences, newExperience]);
      // 保存更新后的简历
      return await saveResume(updatedResume);
    } catch (e) {
      debugPrint('添加工作经历失败: $e');
      return false;
    }
  }
}
