class Education {
  final String school;
  final String major;
  final String degree;
  final String startDate;
  final String endDate;

  Education({
    required this.school,
    required this.major,
    required this.degree,
    required this.startDate,
    required this.endDate,
  });

  factory Education.fromMap(Map<String, dynamic> json) {
    return Education(
      school: json['school'] ?? '',
      major: json['major'] ?? '',
      degree: json['degree'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'major': major,
      'degree': degree,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}