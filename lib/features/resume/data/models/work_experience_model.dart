class WorkExperience {
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final String description;

  WorkExperience({
    required this.company,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.description,
  }) {}

  WorkExperience copyWith({
    String? company,
    String? position,
    String? startDate,
    String? endDate,
    String? description,
  }) {
    return WorkExperience(
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
    );
  }

  factory WorkExperience.fromMap
      (Map<String, dynamic> json) {
    return WorkExperience(
      company: json['company'] ?? '',
      position: json['position'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'position': position,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }
}