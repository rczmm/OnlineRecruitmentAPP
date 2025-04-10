import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
      final response = await _resumeService.fetchUserResume(userId ?? '1'); // 默认用户ID为1，实际应用中应该从用户会话中获取
      
      if (response.statusCode == 200) {
        final List<dynamic> resumeList = response.data;
        if (resumeList.isNotEmpty) {
          // 获取第一个简历数据
          final ApiResumeModel apiResume = ApiResumeModel.fromJson(resumeList[0]);
          // 转换为应用内使用的ResumeModel
          final resumeModel = apiResume.toResumeModel();
          // 保存到本地存储以便离线使用
          await updateResume(resumeModel);
          return resumeModel;
        }
      }
      throw Exception('Failed to load resume from API');
    } catch (e) {
      print('Error in fetchResumeFromApi: $e');
      rethrow;
    }
  }

  Future<bool> updateResume(ResumeModel resume) async {
    try {
      // 首先尝试更新API
      final response = await _resumeService.updateResume(resume.toJson());
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(resume.toJson()));
      }
      throw Exception('Failed to update resume on API');
    } catch (e) {
      print('Error updating resume on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(_resumeKey, json.encode(resume.toJson()));
    }
  }

  Future<bool> updateSkills(List<String> skills) async {
    try {
      // 首先尝试通过API更新技能
      final response = await _resumeService.updateSkills(skills);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final resume = await getResume();
        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: resume.workExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: resume.educationExperiences,
          honors: resume.honors,
          certifications: resume.certifications,
          skills: skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to update skills on API');
    } catch (e) {
      print('Error updating skills on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: resume.workExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: resume.educationExperiences,
        honors: resume.honors,
        certifications: resume.certifications,
        skills: skills,
        personality: resume.personality,
      );
      return updateResume(updatedResume);
    }
  }

  Future<bool> addWorkExperience(Map<String, dynamic> workExperience) async {
    try {
      // 首先尝试通过API添加工作经验
      final response = await _resumeService.addWorkExperience(workExperience);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final resume = await getResume();
        final updatedWorkExperiences =
            List<WorkExperience>.from(resume.workExperiences);
        updatedWorkExperiences.add(WorkExperience.fromJson(workExperience));

        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: updatedWorkExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: resume.educationExperiences,
          honors: resume.honors,
          certifications: resume.certifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to add work experience on API');
    } catch (e) {
      print('Error adding work experience on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedWorkExperiences =
          List<WorkExperience>.from(resume.workExperiences);
      updatedWorkExperiences.add(WorkExperience.fromJson(workExperience));

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: updatedWorkExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: resume.educationExperiences,
        honors: resume.honors,
        certifications: resume.certifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }

  Future<bool> updateWorkExperience(
      String id, Map<String, dynamic> workExperience) async {
    try {
      // 首先尝试通过API更新工作经验
      final response = await _resumeService.updateWorkExperience(id, workExperience);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final resume = await getResume();
        final updatedWorkExperiences =
            List<WorkExperience>.from(resume.workExperiences);
        final index = updatedWorkExperiences
            .indexWhere((exp) => exp.company == id); // 使用公司名称作为临时ID

        if (index != -1) {
          updatedWorkExperiences[index] = WorkExperience.fromJson(workExperience);
        }

        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: updatedWorkExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: resume.educationExperiences,
          honors: resume.honors,
          certifications: resume.certifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to update work experience on API');
    } catch (e) {
      print('Error updating work experience on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedWorkExperiences =
          List<WorkExperience>.from(resume.workExperiences);
      final index = updatedWorkExperiences
          .indexWhere((exp) => exp.company == id); // 使用公司名称作为临时ID

      if (index != -1) {
        updatedWorkExperiences[index] = WorkExperience.fromJson(workExperience);
      }

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: updatedWorkExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: resume.educationExperiences,
        honors: resume.honors,
        certifications: resume.certifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }

  Future<bool> deleteWorkExperience(String id) async {
    try {
      // 首先尝试通过API删除工作经验
      final response = await _resumeService.deleteWorkExperience(id);
      if (response.statusCode == 200) {
        // API删除成功后，同步更新本地简历数据
        final resume = await getResume();
        final updatedWorkExperiences =
            List<WorkExperience>.from(resume.workExperiences)
              ..removeWhere((exp) => exp.company == id); // 使用公司名称作为临时ID

        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: updatedWorkExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: resume.educationExperiences,
          honors: resume.honors,
          certifications: resume.certifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to delete work experience on API');
    } catch (e) {
      print('Error deleting work experience on API: $e');
      // 如果API删除失败，仍然更新本地存储
      final resume = await getResume();
      final updatedWorkExperiences =
          List<WorkExperience>.from(resume.workExperiences)
            ..removeWhere((exp) => exp.company == id); // 使用公司名称作为临时ID

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: updatedWorkExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: resume.educationExperiences,
        honors: resume.honors,
        certifications: resume.certifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }

  Future<bool> addEducation(Map<String, dynamic> education) async {
    try {
      // 首先尝试通过API添加教育经历
      final response = await _resumeService.addEducation(education);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final resume = await getResume();
        final updatedEducations = List<Education>.from(resume.educationExperiences);
        updatedEducations.add(Education.fromJson(education));

        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: resume.workExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: updatedEducations,
          honors: resume.honors,
          certifications: resume.certifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to add education on API');
    } catch (e) {
      print('Error adding education on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedEducations = List<Education>.from(resume.educationExperiences);
      updatedEducations.add(Education.fromJson(education));

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: resume.workExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: updatedEducations,
        honors: resume.honors,
        certifications: resume.certifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }

  Future<bool> addProjectExperience(Map<String, dynamic> project) async {
    try {
      // 首先尝试通过API添加项目经验
      final response = await _resumeService.addProjectExperience(project);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final resume = await getResume();
        final updatedProjects =
            List<ProjectExperience>.from(resume.projectExperiences);
        updatedProjects.add(ProjectExperience.fromJson(project));

        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: resume.workExperiences,
          projectExperiences: updatedProjects,
          educationExperiences: resume.educationExperiences,
          honors: resume.honors,
          certifications: resume.certifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to add project experience on API');
    } catch (e) {
      print('Error adding project experience on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedProjects =
          List<ProjectExperience>.from(resume.projectExperiences);
      updatedProjects.add(ProjectExperience.fromJson(project));

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: resume.workExperiences,
        projectExperiences: updatedProjects,
        educationExperiences: resume.educationExperiences,
        honors: resume.honors,
        certifications: resume.certifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }

  Future<bool> addHonor(String honor) async {
    try {
      // 获取当前简历数据
      final resume = await getResume();
      final updatedHonors = List<String>.from(resume.honors)..add(honor);
      
      // 首先尝试通过API更新荣誉列表
      final response = await _resumeService.updateHonors(updatedHonors);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: resume.workExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: resume.educationExperiences,
          honors: updatedHonors,
          certifications: resume.certifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to add honor on API');
    } catch (e) {
      print('Error adding honor on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedHonors = List<String>.from(resume.honors)..add(honor);

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: resume.workExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: resume.educationExperiences,
        honors: updatedHonors,
        certifications: resume.certifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }

  Future<bool> deleteHonor(String honor) async {
    try {
      // 获取当前简历数据
      final resume = await getResume();
      final updatedHonors = List<String>.from(resume.honors)..remove(honor);
      
      // 首先尝试通过API更新荣誉列表
      final response = await _resumeService.updateHonors(updatedHonors);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: resume.workExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: resume.educationExperiences,
          honors: updatedHonors,
          certifications: resume.certifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to delete honor on API');
    } catch (e) {
      print('Error deleting honor on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedHonors = List<String>.from(resume.honors)..remove(honor);

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: resume.workExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: resume.educationExperiences,
        honors: updatedHonors,
        certifications: resume.certifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }

  Future<bool> addCertification(String certification) async {
    try {
      // 获取当前简历数据
      final resume = await getResume();
      final updatedCertifications = List<String>.from(resume.certifications)
        ..add(certification);
      
      // 首先尝试通过API更新证书列表
      final response = await _resumeService.updateCertifications(updatedCertifications);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: resume.workExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: resume.educationExperiences,
          honors: resume.honors,
          certifications: updatedCertifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to add certification on API');
    } catch (e) {
      print('Error adding certification on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedCertifications = List<String>.from(resume.certifications)
        ..add(certification);

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: resume.workExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: resume.educationExperiences,
        honors: resume.honors,
        certifications: updatedCertifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }

  Future<bool> deleteCertification(String certification) async {
    try {
      // 获取当前简历数据
      final resume = await getResume();
      final updatedCertifications = List<String>.from(resume.certifications)
        ..remove(certification);
      
      // 首先尝试通过API更新证书列表
      final response = await _resumeService.updateCertifications(updatedCertifications);
      if (response.statusCode == 200) {
        // API更新成功后，同步更新本地简历数据
        final updatedResume = ResumeModel(
          name: resume.name,
          phone: resume.phone,
          email: resume.email,
          address: resume.address,
          jobStatus: resume.jobStatus,
          strengths: resume.strengths,
          expectations: resume.expectations,
          workExperiences: resume.workExperiences,
          projectExperiences: resume.projectExperiences,
          educationExperiences: resume.educationExperiences,
          honors: resume.honors,
          certifications: updatedCertifications,
          skills: resume.skills,
          personality: resume.personality,
        );
        // 更新本地存储
        final prefs = await SharedPreferences.getInstance();
        return prefs.setString(_resumeKey, json.encode(updatedResume.toJson()));
      }
      throw Exception('Failed to delete certification on API');
    } catch (e) {
      print('Error deleting certification on API: $e');
      // 如果API更新失败，仍然更新本地存储
      final resume = await getResume();
      final updatedCertifications = List<String>.from(resume.certifications)
        ..remove(certification);

      final updatedResume = ResumeModel(
        name: resume.name,
        phone: resume.phone,
        email: resume.email,
        address: resume.address,
        jobStatus: resume.jobStatus,
        strengths: resume.strengths,
        expectations: resume.expectations,
        workExperiences: resume.workExperiences,
        projectExperiences: resume.projectExperiences,
        educationExperiences: resume.educationExperiences,
        honors: resume.honors,
        certifications: updatedCertifications,
        skills: resume.skills,
        personality: resume.personality,
      );

      return updateResume(updatedResume);
    }
  }
}
