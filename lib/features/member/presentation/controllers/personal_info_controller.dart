import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:intl/intl.dart';

class PersonalInfoController extends GetxController {
  final defaultGenders = ['Male', 'Female', 'Other'];
  final defaultMaritalStatuses = ['Married', 'Unmarried', 'Widow', 'Divorced'];
  final defaultBloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final defaultRelations = ['Self', 'Wife', 'Son', 'Daughter', 'Father', 'Mother'];
  final defaultSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio',
    'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
  ];

  final genderList = <String>[].obs;
  final maritalStatusList = <String>[].obs;
  final bloodGroupList = <String>[].obs;
  final relationList = <String>[].obs;
  final signList = <String>[].obs;
  final gotraList = <String>[].obs;
  final mothersGotraList = <String>[].obs;

  final genderIdMap = <String, int>{}.obs;
  final maritalStatusIdMap = <String, int>{}.obs;
  final bloodGroupIdMap = <String, int>{}.obs;
  final relationIdMap = <String, int>{}.obs;
  final signIdMap = <String, int>{}.obs;
  final gotraIdMap = <String, int>{}.obs;
  final mothersGotraIdMap = <String, int>{}.obs;

  final memberNo = ''.obs;
  final firstName = ''.obs;
  final middleName = ''.obs;
  final lastName = ''.obs;
  final firstNameEn = ''.obs;
  final lastNameEn = ''.obs;
  final dob = ''.obs;
  final tob = ''.obs;
  final weight = ''.obs;
  final height = ''.obs;
  final gender = ''.obs;
  final maritalStatus = ''.obs;
  final bloodGroup = ''.obs;
  final sign = ''.obs;
  final isActive = true.obs;
  final isFamilyHead = false.obs;
  final relation = ''.obs;
  final motherFatherName = ''.obs;
  final gotra = ''.obs;
  final mothersGotra = ''.obs;
  final motherState = ''.obs;
  final motherDistrict = ''.obs;
  final motherTaluka = ''.obs;
  final motherArea = ''.obs;
  final openToMarriage = false.obs;
  final relatedToMemberName = ''.obs;
  final ownLand = false.obs;
  final ownHouse = false.obs;
  final twoWheeler = false.obs;
  final fourWheeler = false.obs;
  final monthlyIncome = ''.obs;

  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool isPhotoRemoved = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  late final TextEditingController memberNoCtrl;
  late final TextEditingController tobCtrl;
  late final TextEditingController motherFatherNameCtrl;
  late final TextEditingController firstNameCtrl;
  late final TextEditingController middleNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController firstNameEnCtrl;
  late final TextEditingController lastNameEnCtrl;
  late final TextEditingController dobCtrl;
  late final TextEditingController heightCtrl;
  late final TextEditingController weightCtrl;
  late final TextEditingController monthlyIncomeCtrl;

  @override
  void onInit() {
    super.onInit();
    memberNoCtrl = TextEditingController();
    tobCtrl = TextEditingController();
    motherFatherNameCtrl = TextEditingController();
    firstNameCtrl = TextEditingController();
    middleNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    firstNameEnCtrl = TextEditingController();
    lastNameEnCtrl = TextEditingController();
    dobCtrl = TextEditingController();
    heightCtrl = TextEditingController();
    weightCtrl = TextEditingController();
    monthlyIncomeCtrl = TextEditingController();

    memberNoCtrl.addListener(() => memberNo.value = memberNoCtrl.text);
    tobCtrl.addListener(() => tob.value = tobCtrl.text);
    motherFatherNameCtrl.addListener(() => motherFatherName.value = motherFatherNameCtrl.text);
    firstNameCtrl.addListener(() => firstName.value = firstNameCtrl.text);
    middleNameCtrl.addListener(() => middleName.value = middleNameCtrl.text);
    lastNameCtrl.addListener(() => lastName.value = lastNameCtrl.text);
    firstNameEnCtrl.addListener(() => firstNameEn.value = firstNameEnCtrl.text);
    lastNameEnCtrl.addListener(() => lastNameEn.value = lastNameEnCtrl.text);
    dobCtrl.addListener(() => dob.value = dobCtrl.text);
    heightCtrl.addListener(() => height.value = heightCtrl.text);
    weightCtrl.addListener(() => weight.value = weightCtrl.text);
    monthlyIncomeCtrl.addListener(() => monthlyIncome.value = monthlyIncomeCtrl.text);
  }

  @override
  void onClose() {
    memberNoCtrl.dispose();
    tobCtrl.dispose();
    motherFatherNameCtrl.dispose();
    firstNameCtrl.dispose();
    middleNameCtrl.dispose();
    lastNameCtrl.dispose();
    firstNameEnCtrl.dispose();
    lastNameEnCtrl.dispose();
    dobCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
    monthlyIncomeCtrl.dispose();
    super.onClose();
  }

  void loadFromMember(Member m) {
    String formatDob(String? dobRaw) {
      if (dobRaw == null || dobRaw.isEmpty) return '';
      try {
        final dt = DateTime.parse(dobRaw);
        return DateFormat('dd-MM-yyyy').format(dt);
      } catch (_) {
        return dobRaw;
      }
    }

    isPhotoRemoved.value = false;
    memberNo.value = m.memberNo ?? '';
    firstName.value = m.firstName;
    firstNameEn.value = m.firstNameEnglish ?? '';
    middleName.value = m.middleName ?? '';
    lastName.value = m.lastName;
    lastNameEn.value = m.lastNameEnglish ?? '';
    dob.value = formatDob(m.dateOfBirth);
    tob.value = m.dateOfBirthTime ?? '';
    weight.value = m.weight?.toString().replaceAll(RegExp(r'\.0$'), '') ?? '';
    height.value = m.height?.toString().replaceAll(RegExp(r'\.0$'), '') ?? '';
    gender.value = m.genderName ?? '';
    maritalStatus.value = m.maritalStatusName ?? '';
    bloodGroup.value = m.bloodGroupName ?? '';
    sign.value = m.signName ?? '';
    motherFatherName.value = m.motherFatherName ?? '';
    gotra.value = m.gotraName ?? '';
    motherState.value = m.motherStateName ?? '';
    motherDistrict.value = m.motherDistrictName ?? '';
    motherTaluka.value = m.motherTalukaName ?? '';
    motherArea.value = m.motherAreaName ?? '';
    openToMarriage.value = m.isLookingforMarriage ?? false;
    ownLand.value = m.isOwnLand ?? false;
    ownHouse.value = m.isOwnHouse ?? false;
    twoWheeler.value = m.hasTwoWheeler ?? false;
    fourWheeler.value = m.hasFourWheeler ?? false;
    monthlyIncome.value = m.monthlyIncome?.toString().replaceAll(RegExp(r'\.0$'), '') ?? '';
    isFamilyHead.value = m.isHead ?? false;
    relatedToMemberName.value = m.relatedToMemberName ?? '';

    memberNoCtrl.text = memberNo.value;
    tobCtrl.text = tob.value;
    motherFatherNameCtrl.text = motherFatherName.value;
    firstNameCtrl.text = firstName.value;
    middleNameCtrl.text = middleName.value;
    lastNameCtrl.text = lastName.value;
    firstNameEnCtrl.text = firstNameEn.value;
    lastNameEnCtrl.text = lastNameEn.value;
    dobCtrl.text = dob.value;
    heightCtrl.text = height.value;
    weightCtrl.text = weight.value;
    monthlyIncomeCtrl.text = monthlyIncome.value;
  }

  Future<void> pickProfilePhoto() async {
    await Get.bottomSheet<void>(
      Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back<void>(),
                    ),
                    Text(
                      'Profile picture',
                      style: AppTextStyles.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        removePhoto();
                        Get.back<void>();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(LK.camera.tr),
                onTap: () async {
                  Get.back<void>();
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    await _cropImage(pickedFile.path);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(LK.gallery.tr),
                onTap: () async {
                  Get.back<void>();
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    await _cropImage(pickedFile.path);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Photo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Profile Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile != null) {
      await _compressImage(croppedFile.path);
    }
  }

  Future<void> _compressImage(String path) async {
    try {
      uploadProgress.value = 0.1;
      final file = File(path);
      final size = await file.length();

      if (size <= 500 * 1024) {
        profileImage.value = file;
        isPhotoRemoved.value = false;
        uploadProgress.value = 1.0;
        Future<void>.delayed(
          Duration(milliseconds: 500),
          () => uploadProgress.value = 0.0,
        );
        return;
      }

      uploadProgress.value = 0.5;
      final targetPath =
          '${path.substring(0, path.lastIndexOf('.'))}_compressed.jpg';
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      if (compressedFile != null) {
        profileImage.value = File(compressedFile.path);
      } else {
        profileImage.value = file;
      }

      isPhotoRemoved.value = false;
      uploadProgress.value = 1.0;
      Future<void>.delayed(
        Duration(milliseconds: 500),
        () => uploadProgress.value = 0.0,
      );
    } catch (e) {
      profileImage.value = File(path);
      isPhotoRemoved.value = false;
      uploadProgress.value = 0.0;
    }
  }

  void removePhoto() {
    profileImage.value = null;
    isPhotoRemoved.value = true;
  }
}
