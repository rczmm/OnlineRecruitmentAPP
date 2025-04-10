class ProjectExperience {
  final String name;
  final String startDate;
  final String endDate;
  final String description;

  ProjectExperience({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory ProjectExperience.fromJson(Map<String, dynamic> json) {
    return ProjectExperience(
      name: json['name'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }
}