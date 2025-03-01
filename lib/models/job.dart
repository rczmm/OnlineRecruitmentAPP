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

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      salary: json['salary']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      companySize: json['companySize']?.toString() ?? '',
      companyLogo: json['companyLogo']?.toString() ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      hrName: json['hrName']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      workExperience: json['workExperience']?.toString() ?? '',
      education: json['education']?.toString() ?? '',
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description']?.toString() ?? '',
      requirements: (json['requirements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      interviewTime: json['interviewTime'] != null ? DateTime.parse(json['interviewTime'].toString()) : null,
    );
  }

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
