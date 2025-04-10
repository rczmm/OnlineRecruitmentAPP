import '../../data/models/resume_model.dart';

abstract class ResumeState {}

class ResumeInitial extends ResumeState {}

class ResumeLoading extends ResumeState {}

class ResumeSaving extends ResumeState {}

class ResumeLoaded extends ResumeState {
  final ResumeModel resume;

  ResumeLoaded(this.resume);
}

class ResumeError extends ResumeState {
  final String message;

  ResumeError(this.message);
}