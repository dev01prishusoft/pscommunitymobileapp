class BankAccount {
  final String bankName;
  final String branchName;
  final String accountHolderName;
  final String accountNumber;
  final String accountType;
  final String ifscCode;
  final String micrCode;
  final String swiftCode;
  final String upiId;
  final bool isPrimary;

  const BankAccount({
    required this.bankName,
    required this.branchName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.accountType,
    required this.ifscCode,
    required this.micrCode,
    required this.swiftCode,
    required this.upiId,
    this.isPrimary = false,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      bankName: json['bankName'] as String? ?? '',
      branchName: json['branchName'] as String? ?? '',
      accountHolderName: json['accountHolderName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      accountType: json['accountType'] as String? ?? '',
      ifscCode: json['ifscCode'] as String? ?? '',
      micrCode: json['micrCode'] as String? ?? '',
      swiftCode: json['swiftCode'] as String? ?? '',
      upiId: json['upiId'] as String? ?? '',
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }
}
