import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';

class ProfileFormController extends GetxController {
  // Fallback defaults
  final defaultGenders = ['Male', 'Female', 'Other'];
  final defaultMaritalStatuses = ['Married', 'Unmarried', 'Widow', 'Divorced'];
  final defaultBloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final defaultRelations = ['Self', 'Wife', 'Son', 'Daughter', 'Father', 'Mother'];
  final defaultAddressTypes = ['Home', 'Office', 'Other'];
  final defaultQualifications = ['Graduate', 'HSC', 'SSC', 'Post Graduate'];
  final defaultOccupationTypes = ['Agriculture', 'Business', 'Job', 'Profession'];
  final defaultSigns = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];

  // Reactive dropdown lists
  final genderList = <String>[].obs;
  final maritalStatusList = <String>[].obs;
  final bloodGroupList = <String>[].obs;
  final relationList = <String>[].obs;
  final addressTypeList = <String>[].obs;
  final qualificationList = <String>[].obs;
  final occupationTypeList = <String>[].obs;
  final signList = <String>[].obs;

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

  @override
  void onInit() {
    super.onInit();
    loadAllDropdowns();
  }

  Future<void> loadAllDropdowns() async {
    await Future.wait([
      _fetchDropdown('/gender/dropdown', genderList, defaultGenders),
      _fetchDropdown('/MaritalStatus/dropdown', maritalStatusList, defaultMaritalStatuses),
      _fetchDropdown('/BloodGroup/dropdown', bloodGroupList, defaultBloodGroups),
      _fetchDropdown('/RelationType/dropdown', relationList, defaultRelations),
      _fetchDropdown('/AddressType/dropdown', addressTypeList, defaultAddressTypes),
      _fetchDropdown('/EducationalQualification/list/dropdown', qualificationList, defaultQualifications),
      _fetchDropdown('/Occupation/dropdown', occupationTypeList, defaultOccupationTypes),
      _fetchDropdown('/Sign/dropdown', signList, defaultSigns),
    ]);
    
    // Ensure currently selected values are present in the list, if not, add them or select first
    _ensureSelectionValue(gender, genderList);
    _ensureSelectionValue(maritalStatus, maritalStatusList);
    _ensureSelectionValue(bloodGroup, bloodGroupList);
    _ensureSelectionValue(relation, relationList);
    _ensureSelectionValue(occupationType, occupationTypeList);
    _ensureSelectionValue(sign, signList);
  }

  void _ensureSelectionValue(RxString selected, List<String> list) {
    if (list.isNotEmpty && !list.contains(selected.value)) {
      selected.value = list.first;
    }
  }

  Future<void> _fetchDropdown(String path, RxList<String> targetList, List<String> fallbacks) async {
    try {
      final ApiClient apiClient = Get.find<ApiClient>();
      final response = await apiClient.get('/api/v1$path');
      if (response.data != null) {
        final json = response.data as Map<String, dynamic>;
        if (json['succeeded'] == true) {
          final rawData = json['data'];
          List<dynamic> list = [];
          if (rawData is List) {
            list = rawData;
          } else if (rawData is Map<String, dynamic>) {
            list = (rawData['data'] ?? rawData['list'] ?? <dynamic>[]) as List? ?? [];
          }
          final items = list.map((e) {
            final map = e as Map<String, dynamic>;
            // Extract text/name safely
            final textKeys = ['text', 'Text', 'name', 'Name', 'value', 'Value'];
            for (final key in textKeys) {
              if (map.containsKey(key) && map[key] != null) {
                return map[key].toString().trim();
              }
            }
            // Fallback to first non-id value
            for (final entry in map.entries) {
              if (!entry.key.toLowerCase().contains('id')) {
                return entry.value.toString().trim();
              }
            }
            return '';
          }).where((s) => s.isNotEmpty).toList();
          
          if (items.isNotEmpty) {
            targetList.assignAll(items);
            return;
          }
        }
      }
    } catch (e) {
      // Fail silently and use fallback
    }
    targetList.assignAll(fallbacks);
  }

  void addAddress() {
    addresses.add(AddressModel(type: addressTypeList.isNotEmpty ? addressTypeList.first : 'Home', isPrimary: false));
  }

  void removeAddress(int index) {
    addresses.removeAt(index);
  }

  void addEducation() {
    educationList.add(EducationModel(qualification: qualificationList.isNotEmpty ? qualificationList.first : 'Graduate', isHighest: false));
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
