import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zhaopingapp/features/resume/data/models/education_model.dart';
import '../models/resume_model.dart';
import '../models/work_experience_model.dart';
import '../models/project_experience_model.dart';

class ResumeRepository {
  static const String _resumeKey = 'resume_data';

  Future<ResumeModel> getResume() async {
    final prefs = await SharedPreferences.getInstance();
    final resumeJson = prefs.getString(_resumeKey);

    if (resumeJson != null) {
      return ResumeModel.fromJson(json.decode(resumeJson));
    } else {
      return ResumeModel(
        name: '',
        phone: '',
        email: '',
        address: '',
        jobStatus: '',
        strengths: '',
        expectations: '',
        workExperiences: [],
        projectExperiences: [],
        educationExperiences: [],
        honors: [],
        certifications: [],
        skills: [],
        personality: '',
      );
    }
  }

  Future<bool> updateResume(ResumeModel resume) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_resumeKey, json.encode(resume.toJson()));
  }

  Future<bool> updateSkills(List<String> skills) async {
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

  Future<bool> addWorkExperience(Map<String, dynamic> workExperience) async {
    final resume = await getResume();
    final updatedWorkExperiences = List<WorkExperience>.from(resume.workExperiences);
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

  Future<bool> updateWorkExperience(String id, Map<String, dynamic> workExperience) async {
    final resume = await getResume();
    final updatedWorkExperiences = List<WorkExperience>.from(resume.workExperiences);
    final index = updatedWorkExperiences.indexWhere((exp) => exp.company == id); // 使用公司名称作为临时ID
    
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

  Future<bool> deleteWorkExperience(String id) async {
    final resume = await getResume();
    final updatedWorkExperiences = List<WorkExperience>.from(resume.workExperiences)
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

  Future<bool> addEducation(Map<String, dynamic> education) async {
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
  
  Future<bool> addProjectExperience(Map<String, dynamic> project) async {
    final resume = await getResume();
    final updatedProjects = List<ProjectExperience>.from(resume.projectExperiences);
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

  Future<bool> addHonor(String honor) async {
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

  Future<bool> deleteHonor(String honor) async {
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

  Future<bool> addCertification(String certification) async {
    final resume = await getResume();
    final updatedCertifications = List<String>.from(resume.certifications)..add(certification);

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

  Future<bool> deleteCertification(String certification) async {
    final resume = await getResume();
    final updatedCertifications = List<String>.from(resume.certifications)..remove(certification);

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