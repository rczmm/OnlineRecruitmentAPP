class Job {
  final String id;
  final String title;
  final String salary;
  final String company;
  final String companySize;
  final String companyLogo;
  final List<String> tags;
  final String hrName;
  final String location;
  final String workExperience;
  final String education;
  final List<String> benefits;
  final String description;
  final List<String> requirements;
  final String status;
  final String date;
  final DateTime? interviewTime;

  Job({
    required this.id,
    required this.title,
    required this.salary,
    required this.company,
    required this.companySize,
    this.companyLogo = '',
    required this.tags,
    required this.hrName,
    required this.location,
    required this.workExperience,
    required this.education,
    required this.benefits,
    required this.description,
    required this.requirements,
    required this.status,
    required this.date,
    this.interviewTime,
  });
}
