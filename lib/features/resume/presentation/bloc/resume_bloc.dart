import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zhaopingapp/features/resume/data/models/education_model.dart';
import 'package:zhaopingapp/features/resume/data/models/project_experience_model.dart';
import 'package:zhaopingapp/features/resume/data/models/resume_model.dart';
import 'package:zhaopingapp/features/resume/data/models/work_experience_model.dart';
import 'package:zhaopingapp/features/resume/data/repositories/resume_repository.dart';
import 'resume_event.dart';
import 'resume_state.dart';

class ResumeBloc extends Bloc<ResumeEvent, ResumeState> {
  final ResumeRepository _repository;

  ResumeBloc({ResumeRepository? repository})
      : _repository = repository ?? ResumeRepository(),
        super(ResumeInitial()) {
    on<LoadResume>(_onLoadResume);
    on<UpdateResume>(_onUpdateResume);
    on<UpdateSkills>(_onUpdateSkills);
    on<AddWorkExperience>(_onAddWorkExperience);
    on<UpdateWorkExperience>(_onUpdateWorkExperience);
    on<DeleteWorkExperience>(_onDeleteWorkExperience);
    on<AddProjectExperience>(_onAddProjectExperience);
    on<AddEducation>(_onAddEducation);
    on<AddHonor>(_onAddHonor);
    on<DeleteHonor>(_onDeleteHonor);
    on<AddCertification>(_onAddCertification);
    on<DeleteCertification>(_onDeleteCertification);
  }

  Future<void> _onLoadResume(LoadResume event,
      Emitter<ResumeState> emit) async {
    emit(ResumeLoading());
    try {
      final resume = await _repository.getResume();
      emit(ResumeLoaded(resume));
    } catch (e) {
      emit(ResumeError('Failed to load resume: $e'));
    }
  }

  Future<void> _onUpdateResume(UpdateResume event,
      Emitter<ResumeState> emit) async {
    emit(ResumeSaving());
    try {
      final success = await _repository.updateResume(event.resume);
      if (success) {
        emit(ResumeLoaded(event.resume));
      } else {
        emit(ResumeError('Failed to update resume'));
      }
    } catch (e) {
      emit(ResumeError('Error updating resume: $e'));
    }
  }

  Future<void> _onUpdateSkills(UpdateSkills event,
      Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success = await _repository.updateSkills(event.skills);
        if (success) {
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: currentState.resume.workExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: currentState.resume.educationExperiences,
            honors: currentState.resume.honors,
            certifications: currentState.resume.certifications,
            skills: event.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error updating skills: $e'));
      }
    }
  }

  Future<void> _onAddWorkExperience(AddWorkExperience event,
      Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success =
        await _repository.addWorkExperience(event.workExperience.toJson());
        if (success) {
          final updatedWorkExperiences =
          List<WorkExperience>.from(currentState.resume.workExperiences)
            ..add(event.workExperience);
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: updatedWorkExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: currentState.resume.educationExperiences,
            honors: currentState.resume.honors,
            certifications: currentState.resume.certifications,
            skills: currentState.resume.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error adding work experience: $e'));
      }
    }
  }

  Future<void> _onUpdateWorkExperience(UpdateWorkExperience event, Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success = await _repository.updateWorkExperience(
            event.id, event.workExperience.toJson());
        if (success) {
          final updatedWorkExperiences =
              List<WorkExperience>.from(currentState.resume.workExperiences);
          final index = updatedWorkExperiences
              .indexWhere((exp) => exp.company == event.id); // 使用公司名称作为临时ID
          if (index != -1) {
            updatedWorkExperiences[index] = event.workExperience;
          }
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: updatedWorkExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: currentState.resume.educationExperiences,
            honors: currentState.resume.honors,
            certifications: currentState.resume.certifications,
            skills: currentState.resume.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error updating work experience: $e'));
      }
    }
  }

  Future<void> _onDeleteWorkExperience(DeleteWorkExperience event,
      Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success = await _repository.deleteWorkExperience(event.id);
        if (success) {
          final updatedWorkExperiences =
          List<WorkExperience>.from(currentState.resume.workExperiences)
            ..removeWhere((exp) => exp.company == event.id); // 使用公司名称作为临时ID
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: updatedWorkExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: currentState.resume.educationExperiences,
            honors: currentState.resume.honors,
            certifications: currentState.resume.certifications,
            skills: currentState.resume.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error deleting work experience: $e'));
      }
    }
  }

  Future<void> _onAddProjectExperience(AddProjectExperience event,
      Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success = await _repository
            .addProjectExperience(event.projectExperience.toJson());
        if (success) {
          final updatedProjects =
          List<ProjectExperience>.from(currentState.resume.projectExperiences)
            ..add(event.projectExperience);
          final updatedResume = currentState.resume.copyWith(
              projectExperiences: updatedProjects, educationExperiences: []);
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error adding project experience: $e'));
      }
    }
  }

  Future<void> _onAddEducation(AddEducation event,
      Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success = await _repository.addEducation(
            event.education.toJson());
        if (success) {
          final updatedEducations =
          List<Education>.from(currentState.resume.educationExperiences)
            ..add(event.education);
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: currentState.resume.workExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: updatedEducations,
            honors: currentState.resume.honors,
            certifications: currentState.resume.certifications,
            skills: currentState.resume.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error adding education: $e'));
      }
    }
  }

  Future<void> _onAddHonor(AddHonor event, Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success = await _repository.addHonor(event.honor);
        if (success) {
          final updatedHonors = List<String>.from(currentState.resume.honors)
            ..add(event.honor);
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: currentState.resume.workExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: currentState.resume.educationExperiences,
            honors: updatedHonors,
            certifications: currentState.resume.certifications,
            skills: currentState.resume.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error adding honor: $e'));
      }
    }
  }

  Future<void> _onDeleteHonor(DeleteHonor event,
      Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success = await _repository.deleteHonor(event.honor);
        if (success) {
          final updatedHonors = List<String>.from(currentState.resume.honors)
            ..remove(event.honor);
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: currentState.resume.workExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: currentState.resume.educationExperiences,
            honors: updatedHonors,
            certifications: currentState.resume.certifications,
            skills: currentState.resume.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error deleting honor: $e'));
      }
    }
  }

  Future<void> _onAddCertification(AddCertification event,
      Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success = await _repository.addCertification(event.certification);
        if (success) {
          final updatedCertifications =
          List<String>.from(currentState.resume.certifications)
            ..add(event.certification);
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: currentState.resume.workExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: currentState.resume.educationExperiences,
            honors: currentState.resume.honors,
            certifications: updatedCertifications,
            skills: currentState.resume.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error adding certification: $e'));
      }
    }
  }

  Future<void> _onDeleteCertification(DeleteCertification event,
      Emitter<ResumeState> emit) async {
    if (state is ResumeLoaded) {
      final currentState = state as ResumeLoaded;
      try {
        final success =
        await _repository.deleteCertification(event.certification);
        if (success) {
          final updatedCertifications =
          List<String>.from(currentState.resume.certifications)
            ..remove(event.certification);
          final updatedResume = ResumeModel(
            name: currentState.resume.name,
            phone: currentState.resume.phone,
            email: currentState.resume.email,
            address: currentState.resume.address,
            jobStatus: currentState.resume.jobStatus,
            strengths: currentState.resume.strengths,
            expectations: currentState.resume.expectations,
            workExperiences: currentState.resume.workExperiences,
            projectExperiences: currentState.resume.projectExperiences,
            educationExperiences: currentState.resume.educationExperiences,
            honors: currentState.resume.honors,
            certifications: updatedCertifications,
            skills: currentState.resume.skills,
            personality: currentState.resume.personality,
          );
          emit(ResumeLoaded(updatedResume));
        }
      } catch (e) {
        emit(ResumeError('Error deleting certification: $e'));
      }
    }
  }
}