import 'package:zhaopingapp/features/resume/data/models/education_model.dart';
import 'package:zhaopingapp/features/resume/data/models/project_experience_model.dart';

import '../../data/models/resume_model.dart';
import '../../data/models/work_experience_model.dart';

abstract class ResumeEvent {}

class LoadResume extends ResumeEvent {}

class UpdateResume extends ResumeEvent {
  final ResumeModel resume;

  UpdateResume(this.resume);
}

class UpdateSkills extends ResumeEvent {
  final List<String> skills;

  UpdateSkills(this.skills);
}

class AddWorkExperience extends ResumeEvent {
  final WorkExperience workExperience;

  AddWorkExperience(this.workExperience);
}

class UpdateWorkExperience extends ResumeEvent {
  final String id;
  final Map<String, dynamic> updates;

  UpdateWorkExperience(this.id, this.updates);
}

class DeleteWorkExperience extends ResumeEvent {
  final String id;

  DeleteWorkExperience(this.id);
}

class AddProjectExperience extends ResumeEvent {
  final ProjectExperience projectExperience;

  AddProjectExperience(this.projectExperience);
}

class AddEducation extends ResumeEvent {
  final Education education;

  AddEducation(this.education);
}

class AddHonor extends ResumeEvent {
  final String honor;

  AddHonor(this.honor);
}

class DeleteHonor extends ResumeEvent {
  final String honor;

  DeleteHonor(this.honor);
}

class AddCertification extends ResumeEvent {
  final String certification;

  AddCertification(this.certification);
}

class DeleteCertification extends ResumeEvent {
  final String certification;

  DeleteCertification(this.certification);
}