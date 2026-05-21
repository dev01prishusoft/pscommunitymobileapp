class EducationModel {
  String qualification;
  String institute;
  String passingYear;
  String percentage;
  String grade;
  String description;
  bool isHighest;

  EducationModel({
    this.qualification = '',
    this.institute = '',
    this.passingYear = '',
    this.percentage = '',
    this.grade = '',
    this.description = '',
    this.isHighest = false,
  });

  EducationModel copyWith({
    String? qualification,
    String? institute,
    String? passingYear,
    String? percentage,
    String? grade,
    String? description,
    bool? isHighest,
  }) {
    return EducationModel(
      qualification: qualification ?? this.qualification,
      institute: institute ?? this.institute,
      passingYear: passingYear ?? this.passingYear,
      percentage: percentage ?? this.percentage,
      grade: grade ?? this.grade,
      description: description ?? this.description,
      isHighest: isHighest ?? this.isHighest,
    );
  }

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      qualification: json['qualification'] as String? ?? '',
      institute: json['institute'] as String? ?? '',
      passingYear: json['passingYear'] as String? ?? '',
      percentage: json['percentage'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isHighest: json['isHighest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qualification': qualification,
      'institute': institute,
      'passingYear': passingYear,
      'percentage': percentage,
      'grade': grade,
      'description': description,
      'isHighest': isHighest,
    };
  }
}
