import 'package:get/get.dart';

class ProfileFormController extends GetxController {
  // Personal Tab
  final memberNo = 'PSC-2026-0512160358'.obs;
  final firstName = 'Ajay'.obs;
  final middleName = 'Kumar'.obs;
  final lastName = 'Parmar'.obs;
  final firstNameEn = 'Ajay'.obs;
  final lastNameEn = 'Parmar'.obs;
  final dob = '15-06-1995'.obs;
  final tob = '10:30'.obs;
  final weight = '70'.obs;
  final height = '175'.obs;
  final gender = 'Male'.obs;
  final maritalStatus = 'Married'.obs;
  final bloodGroup = 'A+'.obs;
  final sign = 'Aquarius'.obs;
  final isActive = true.obs;

  // Contact & Verify
  final mobileNo = '9876543216'.obs;
  final mobileVerified = false.obs;
  final secondaryMobile = '9876501234'.obs;
  final email = 'ajay.parmar@yopmail.com'.obs;
  final entryPersonMobile = '9876512345'.obs;
  final emergencyContactName = 'Ajay Sharma'.obs;
  final emergencyContactNo = '9876523456'.obs;

  // Family & Parents
  final isFamilyHead = true.obs;
  final relation = 'Self'.obs;
  final motherFatherName = 'Rajiv Parmar'.obs;
  final gotra = 'Parmar'.obs;
  final mothersGotra = 'Parmar'.obs;
  final openToMarriage = false.obs;

  // Assets & Life
  final ownLand = true.obs;
  final ownHouse = true.obs;
  final twoWheeler = true.obs;
  final fourWheeler = false.obs;
  final monthlyIncome = '50000'.obs;

  // Social Media
  final facebook = 'https://facebook.com/dummy'.obs;
  final whatsapp = 'https://wa.me/919876543210'.obs;
  final instagram = 'https://instagram.com/dummy'.obs;
  final twitter = 'https://twitter.com/dummy'.obs;

  // Addresses (List of addresses)
  final addresses = <AddressModel>[
    AddressModel(
      type: 'Home',
      state: 'Gujarat',
      district: 'Ahmedabad',
      taluka: 'Ahmedabad City',
      area: 'Bapunagar',
      pincode: '380001',
      line1: '123, MG Road',
      line2: 'Near City Mall',
      landmark: 'Opp. Bus Stand',
      isPrimary: true,
    )
  ].obs;

  // Education (List of education)
  final educationList = <EducationModel>[
    EducationModel(
      qualification: 'Graduate',
      institute: 'Gujarat University',
      passingYear: '2017',
      percentage: '78',
      grade: 'A',
      description: 'Bachelor of Computer Applications',
      isHighest: true,
    ),
    EducationModel(
      qualification: 'HSC',
      institute: "St. Xavier's High School",
      passingYear: '2013',
      percentage: '82',
      grade: 'A+',
      description: 'Science Stream',
      isHighest: false,
    ),
  ].obs;

  // Work History
  final occupationType = 'Agriculture'.obs;
  final occupation = 'Dairy Farming'.obs;
  final jobPosition = 'Senior Developer'.obs;
  final otherJobPosition = 'Senior Engineer'.obs;
  final otherOccupation = 'Software Developer'.obs;
  final companyName = 'Prishusoft'.obs;
  final businessName = 'Prishusoft'.obs;
  final workMonthlyIncome = '50000'.obs;
  final occupationDescription = 'Full-stack web developer'.obs;
  final workState = 'Gujarat'.obs;
  final workDistrict = 'Ahmedabad'.obs;
  final workTaluka = 'Barwala'.obs;
  final workArea = ''.obs;
  final workAddressLine1 = ''.obs;
  final workAddressLine2 = ''.obs;

  void addAddress() {
    addresses.add(AddressModel(type: 'Home', isPrimary: false));
  }

  void removeAddress(int index) {
    addresses.removeAt(index);
  }

  void addEducation() {
    educationList.add(EducationModel(qualification: 'Graduate', isHighest: false));
  }

  void removeEducation(int index) {
    educationList.removeAt(index);
  }
}

class AddressModel {
  String type;
  String state;
  String district;
  String taluka;
  String area;
  String pincode;
  String line1;
  String line2;
  String landmark;
  bool isPrimary;

  AddressModel({
    this.type = '',
    this.state = '',
    this.district = '',
    this.taluka = '',
    this.area = '',
    this.pincode = '',
    this.line1 = '',
    this.line2 = '',
    this.landmark = '',
    this.isPrimary = false,
  });
}

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
}
