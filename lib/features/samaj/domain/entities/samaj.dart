import 'package:pscommunitymobileapp/features/samaj/domain/entities/bank_account.dart';

class Samaj {
  Samaj({
    required this.samajId,
    required this.name,
    required this.nameEnglish,
    required this.description,
    required this.descriptionEnglish,
    required this.logoUrl,
    this.bankAccounts = const [],
    this.searchText,
    this.defaultLanguageId,
    this.languageName,
    this.languageCode,
    this.isActive,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory Samaj.fromJson(Map<String, dynamic> json) {
    return Samaj(
      samajId: json['samajId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      nameEnglish: json['nameenglish'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionEnglish: json['descriptionenglish'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      bankAccounts:
          (json['bankAccounts'] as List<dynamic>?)
              ?.map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      searchText: json['searchText'] as String?,
      defaultLanguageId: json['defaultLanguageId'] as int?,
      languageName: json['languageName'] as String?,
      languageCode: json['languageCode'] as String?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] as String?,
      createdBy: json['createdBy'] as int?,
      updatedAt: json['updatedAt'] as String?,
      updatedBy: json['updatedBy'] as int?,
    );
  }
  final int samajId;
  final String name;
  final String nameEnglish;
  final String description;
  final String descriptionEnglish;
  final String logoUrl;
  final List<BankAccount> bankAccounts;
  final String? searchText;
  final int? defaultLanguageId;
  final String? languageName;
  final String? languageCode;
  final bool? isActive;
  final String? createdAt;
  final int? createdBy;
  final String? updatedAt;
  final int? updatedBy;

  Map<String, dynamic> toJson() {
    return {
      'samajId': samajId,
      'name': name,
      'nameEnglish': nameEnglish,
      'description': description,
      'descriptionEnglish': descriptionEnglish,
      'logoUrl': logoUrl,
      'bankAccounts': bankAccounts.map((e) => e.toJson()).toList(),
      'searchText': searchText,
      'defaultLanguageId': defaultLanguageId,
      'languageName': languageName,
      'languageCode': languageCode,
      'isActive': isActive,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }
}
