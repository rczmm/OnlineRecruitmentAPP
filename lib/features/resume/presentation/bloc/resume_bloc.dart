import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zhaopingapp/features/resume/data/models/work_experience_model.dart';
import 'package:zhaopingapp/features/resume/data/repositories/resume_repository.dart';
import 'package:zhaopingapp/features/resume/data/models/project_experience_model.dart';
import 'package:zhaopingapp/features/resume/data/models/education_model.dart';
import 'resume_event.dart';
import 'resume_state.dart';

class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final ResumeRepository _repository;

  ResumeBloc({ResumeRepository? repository})
      : _repository = repository ?? ResumeRepository(),
        super(ResumeInitial()) {
    on<LoadResume>(_onLoadResume);
    on<UpdateResume>(_onUpdateResume);
    on<AddWorkExperience>(_onAddWorkExperience);
    on<UpdateWorkExperience>(_onUpdateWorkExperience);
    on<DeleteWorkExperience>(_onDeleteWorkExperience);
    on<UpdateSkills>(_onUpdateSkills);
    on<AddProjectExperience>(_onAddProjectExperience);
    on<AddEducation>(_onAddEducation);
    on<AddHonor>(_onAddHonor);
    on<DeleteHonor>(_onDeleteHonor);
    on<AddCertification>(_onAddCertification);
    on<DeleteCertification>(_onDeleteCertification);
  }

  Future<void> _onLoadResume(
      LoadResume event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      final resume = await _repository.getResume();
      emit(ResumeLoaded(resume));
    } catch (e) {
      emit(ResumeError('Failed to load resume: $e'));
    }
  }

  Future<void> _onUpdateResume(
      UpdateResume event, Emitter<ResumeState> emit) async {
    debugPrint('_onUpdateResume 方法被调用');
    emit(ResumeSaving());
    try {
      debugPrint('尝试保存简历...');
      final success = await _repository.saveResume(event.resume);
      if (success) {
        debugPrint('简历保存成功');
        emit(ResumeLoaded(event.resume));
      } else {
        debugPrint('简历保存失败');
        emit(ResumeError('Failed to update resume'));
      }
    } catch (e) {
      debugPrint('保存简历时出错: $e');
      emit(ResumeError('Error updating resume: $e'));
    }
  }

  Future<void> _onAddWorkExperience(
      AddWorkExperience event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 添加新工作经历
      final updatedProjects = List<WorkExperience>.from(resume.workExperiences)
        ..add(event.workExperience);
      // 创建更新后的简历
      final updatedResume = resume.copyWith(workExperiences: updatedProjects);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('添加工作经历失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateWorkExperience(
      UpdateWorkExperience event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      final success =
          await _repository.updateWorkExperience(event.id, event.updates);
      if (success) {
        emit(ResumeOperationSuccess());
      } else {
        emit(ResumeOperationFailure('更新工作经历失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteWorkExperience(
      DeleteWorkExperience event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 过滤掉要删除的工作经历
      final updatedExperiences = resume.workExperiences
          .where((exp) => exp.company != event.id)
          .toList();
      // 创建更新后的简历
      final updatedResume = resume.copyWith(workExperiences: updatedExperiences);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('删除工作经历失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onUpdateSkills(
      UpdateSkills event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 创建更新后的简历
      final updatedResume = resume.copyWith(skills: event.skills);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('更新技能失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddProjectExperience(
      AddProjectExperience event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 添加新项目经历
      final updatedProjects = List<ProjectExperience>.from(resume.projectExperiences)
        ..add(event.projectExperience);
      // 创建更新后的简历
      final updatedResume = resume.copyWith(projectExperiences: updatedProjects);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('添加项目经历失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddEducation(
      AddEducation event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 添加新教育经历
      final updatedEducation = List<Education>.from(resume.educationExperiences)
        ..add(event.education);
      // 创建更新后的简历
      final updatedResume = resume.copyWith(educationExperiences: updatedEducation);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('添加教育经历失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddHonor(
      AddHonor event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 添加新荣誉
      final updatedHonors = List<String>.from(resume.honors)..add(event.honor);
      // 创建更新后的简历
      final updatedResume = resume.copyWith(honors: updatedHonors);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('添加荣誉失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteHonor(
      DeleteHonor event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 删除荣誉
      final updatedHonors = List<String>.from(resume.honors)
        ..remove(event.honor);
      // 创建更新后的简历
      final updatedResume = resume.copyWith(honors: updatedHonors);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('删除荣誉失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onAddCertification(
      AddCertification event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 添加新证书
      final updatedCertifications = List<String>.from(resume.certifications)
        ..add(event.certification);
      // 创建更新后的简历
      final updatedResume = resume.copyWith(certifications: updatedCertifications);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('添加证书失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }

  Future<void> _onDeleteCertification(
      DeleteCertification event, Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      // 获取当前简历
      final resume = await _repository.getResume();
      // 删除证书
      final updatedCertifications = List<String>.from(resume.certifications)
        ..remove(event.certification);
      // 创建更新后的简历
      final updatedResume = resume.copyWith(certifications: updatedCertifications);
      // 保存更新后的简历
      final success = await _repository.saveResume(updatedResume);
      if (success) {
        emit(ResumeLoaded(updatedResume));
      } else {
        emit(ResumeOperationFailure('删除证书失败'));
      }
    } catch (e) {
      emit(ResumeOperationFailure(e.toString()));
    }
  }
}
