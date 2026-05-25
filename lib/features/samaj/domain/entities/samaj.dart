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
    );
  }
  final int samajId;
  final String name;
  final String nameEnglish;
  final String description;
  final String descriptionEnglish;
  final String logoUrl;
  final List<BankAccount> bankAccounts;
}
