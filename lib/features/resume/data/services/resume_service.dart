import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class ResumeService {
  final Dio _dio;

  ResumeService({Dio? dio}) : _dio = dio ?? DioClient().dio;

  Future<Response> fetchResume() async {
    return await _dio.get('/resume');
  }

  Future<Response> fetchUserResume(String userId) async {
    return await _dio.get('/resume/user', queryParameters: {'userId': userId});
  }

  Future<Response> updateResume(Map<String, dynamic> resumeData) async {
    return await _dio.put('/resume', data: resumeData);
  }

  Future<Response> updateSkills(List<String> skills) async {
    return await _dio.put('/resume/skills', data: {'skills': skills});
  }

  Future<Response> addWorkExperience(Map<String, dynamic> workExperience) async {
    return await _dio.post('/resume/work-experience', data: workExperience);
  }

  Future<Response> updateWorkExperience(String id, Map<String, dynamic> workExperience) async {
    return await _dio.put('/resume/work-experience/$id', data: workExperience);
  }

  Future<Response> deleteWorkExperience(String id) async {
    return await _dio.delete('/resume/work-experience/$id');
  }

  Future<Response> addProjectExperience(Map<String, dynamic> projectExperience) async {
    return await _dio.post('/resume/project-experience', data: projectExperience);
  }

  Future<Response> updateProjectExperience(String id, Map<String, dynamic> projectExperience) async {
    return await _dio.put('/resume/project-experience/$id', data: projectExperience);
  }

  Future<Response> deleteProjectExperience(String id) async {
    return await _dio.delete('/resume/project-experience/$id');
  }

  // 教育经历相关接口
  Future<Response> addEducation(Map<String, dynamic> education) async {
    return await _dio.post('/resume/education', data: education);
  }

  Future<Response> updateEducation(String id, Map<String, dynamic> education) async {
    return await _dio.put('/resume/education/$id', data: education);
  }

  Future<Response> deleteEducation(String id) async {
    return await _dio.delete('/resume/education/$id');
  }

  // 荣誉和证书相关接口
  Future<Response> updateHonors(List<String> honors) async {
    return await _dio.put('/resume/honors', data: {'honors': honors});
  }

  Future<Response> updateCertifications(List<String> certifications) async {
    return await _dio.put('/resume/certifications', data: {'certifications': certifications});
  }
}