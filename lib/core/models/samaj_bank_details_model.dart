class BankAccountDetails {
  BankAccountDetails({
    this.statusCode,
    this.succeeded,
    this.message,
    this.data,
  });

  BankAccountDetails.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'] as int?;
    succeeded = json['succeeded'] as bool?;
    message = json['message'] as String?;
    if (json['data'] != null) {
      data = <SamajBankDetais>[];
      for (var v in (json['data'] as List)) {
        data!.add(SamajBankDetais.fromJson(v as Map<String, dynamic>));
      }
    }
  }

  int? statusCode;
  bool? succeeded;
  String? message;
  List<SamajBankDetais>? data;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['succeeded'] = succeeded;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SamajBankDetais {
  SamajBankDetais({
    this.samajBankAccountId,
    this.samajId,
    this.bankName,
    this.branchName,
    this.accountHolderName,
    this.accountNumber,
    this.ifscCode,
    this.micrCode,
    this.swiftCode,
    this.upiId,
    this.accountType,
    this.isPrimary,
    this.isActive,
    this.qrCodeImagePath,
    this.description,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });
  SamajBankDetais.fromJson(Map<String, dynamic> json) {
    samajBankAccountId = json['samajBankAccountId'] as int?;
    samajId = json['samajId'] as int?;
    bankName = json['bankName'] as String?;
    branchName = json['branchName'] as String?;
    accountHolderName = json['accountHolderName'] as String?;
    accountNumber = json['accountNumber'] as String?;
    ifscCode = json['ifscCode'] as String?;
    micrCode = json['micrCode'] as String?;
    swiftCode = json['swiftCode'] as String?;
    upiId = json['upiId'] as String?;
    accountType = json['accountType'] as String?;
    isPrimary = json['isPrimary'] as bool?;
    isActive = json['isActive'] as bool?;
    qrCodeImagePath = json['qrCodeImagePath'] as String?;
    description = json['description'] as String?;
    createdAt = json['createdAt'] as String?;
    createdBy = json['createdBy'] as int?;
    updatedAt = json['updatedAt'] as String?;
    updatedBy = json['updatedBy'] as int?;
  }
  int? samajBankAccountId;
  int? samajId;
  String? bankName;
  String? branchName;
  String? accountHolderName;
  String? accountNumber;
  String? ifscCode;
  String? micrCode;
  String? swiftCode;
  String? upiId;
  String? accountType;
  bool? isPrimary;
  bool? isActive;
  String? qrCodeImagePath;
  String? description;
  String? createdAt;
  int? createdBy;
  String? updatedAt;
  int? updatedBy;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['samajBankAccountId'] = samajBankAccountId;

    data['samajId'] = samajId;

    data['bankName'] = bankName;

    data['branchName'] = branchName;

    data['accountHolderName'] = accountHolderName;

    data['accountNumber'] = accountNumber;

    data['ifscCode'] = ifscCode;

    data['micrCode'] = micrCode;

    data['swiftCode'] = swiftCode;

    data['upiId'] = upiId;

    data['accountType'] = accountType;

    data['isPrimary'] = isPrimary;

    data['isActive'] = isActive;

    data['qrCodeImagePath'] = qrCodeImagePath;

    data['description'] = description;

    data['createdAt'] = createdAt;

    data['createdBy'] = createdBy;

    data['updatedAt'] = updatedAt;

    data['updatedBy'] = updatedBy;

    return data;
  }
}
