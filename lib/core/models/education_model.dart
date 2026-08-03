class EducationModel {
  EducationModel({
    this.qualification = '',
    this.qualificationId,
    this.institute = '',
    this.passingYear = '',
    this.percentage = '',
    this.grade = '',
    this.description = '',
    this.isHighest = false,
    this.isNew = false,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      qualification: json['qualification'] as String? ?? '',
      qualificationId: json['qualificationId'] as int?,
      institute: json['institute'] as String? ?? '',
      passingYear: json['passingYear'] as String? ?? '',
      percentage: json['percentage'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isHighest: json['isHighest'] as bool? ?? false,
      isNew: json['isNew'] as bool? ?? false,
    );
  }
  String qualification;
  int? qualificationId;
  String institute;
  String passingYear;
  String percentage;
  String grade;
  String description;
  bool isHighest;
  bool isNew;

  EducationModel copyWith({
    String? qualification,
    int? qualificationId,
    String? institute,
    String? passingYear,
    String? percentage,
    String? grade,
    String? description,
    bool? isHighest,
    bool? isNew,
  }) {
    return EducationModel(
      qualification: qualification ?? this.qualification,
      qualificationId: qualificationId ?? this.qualificationId,
      institute: institute ?? this.institute,
      passingYear: passingYear ?? this.passingYear,
      percentage: percentage ?? this.percentage,
      grade: grade ?? this.grade,
      description: description ?? this.description,
      isHighest: isHighest ?? this.isHighest,
      isNew: isNew ?? this.isNew,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qualification': qualification,
      'qualificationId': qualificationId,
      'institute': institute,
      'passingYear': passingYear,
      'percentage': percentage,
      'grade': grade,
      'description': description,
      'isHighest': isHighest,
      'isNew': isNew,
    };
  }
}
