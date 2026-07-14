import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/address_model.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/education_model.dart';

class ContactController extends GetxController {
  final defaultAddressTypes = ['Home', 'Office', 'Other'];
  final defaultQualifications = ['Graduate', 'HSC', 'SSC', 'Post Graduate'];
  final addressTypeList = <String>[].obs;
  final qualificationList = <String>[].obs;
  final addressTypeIdMap = <String, int>{}.obs;
  final educationIdMap = <String, int>{}.obs;

  final mobileNo = ''.obs;
  final mobileVerified = false.obs;
  final secondaryMobile = ''.obs;
  final email = ''.obs;
  final entryPersonMobile = ''.obs;
  final emergencyContactName = ''.obs;
  final emergencyContactNo = ''.obs;
  final facebook = ''.obs;
  final whatsapp = ''.obs;
  final instagram = ''.obs;
  final twitter = ''.obs;
  final addresses = <AddressModel>[].obs;
  final educationList = <EducationModel>[].obs;

  late final TextEditingController mobileCtrl;
  late final TextEditingController secondaryMobileCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController emergencyNameCtrl;
  late final TextEditingController emergencyNoCtrl;
  late final TextEditingController entryPersonMobileCtrl;
  late final TextEditingController facebookCtrl;
  late final TextEditingController whatsappCtrl;
  late final TextEditingController instagramCtrl;
  late final TextEditingController twitterCtrl;

  @override
  void onInit() {
    super.onInit();
    mobileCtrl = TextEditingController();
    secondaryMobileCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    emergencyNameCtrl = TextEditingController();
    emergencyNoCtrl = TextEditingController();
    entryPersonMobileCtrl = TextEditingController();
    facebookCtrl = TextEditingController();
    whatsappCtrl = TextEditingController();
    instagramCtrl = TextEditingController();
    twitterCtrl = TextEditingController();

    mobileCtrl.addListener(() => mobileNo.value = mobileCtrl.text);
    secondaryMobileCtrl.addListener(() => secondaryMobile.value = secondaryMobileCtrl.text);
    emailCtrl.addListener(() => email.value = emailCtrl.text);
    emergencyNameCtrl.addListener(() => emergencyContactName.value = emergencyNameCtrl.text);
    emergencyNoCtrl.addListener(() => emergencyContactNo.value = emergencyNoCtrl.text);
    entryPersonMobileCtrl.addListener(() => entryPersonMobile.value = entryPersonMobileCtrl.text);
    facebookCtrl.addListener(() => facebook.value = facebookCtrl.text);
    whatsappCtrl.addListener(() => whatsapp.value = whatsappCtrl.text);
    instagramCtrl.addListener(() => instagram.value = instagramCtrl.text);
    twitterCtrl.addListener(() => twitter.value = twitterCtrl.text);
  }

  @override
  void onClose() {
    mobileCtrl.dispose();
    secondaryMobileCtrl.dispose();
    emailCtrl.dispose();
    emergencyNameCtrl.dispose();
    emergencyNoCtrl.dispose();
    entryPersonMobileCtrl.dispose();
    facebookCtrl.dispose();
    whatsappCtrl.dispose();
    instagramCtrl.dispose();
    twitterCtrl.dispose();
    super.onClose();
  }

  void loadFromMember(Member m) {
    mobileNo.value = m.mobileNo ?? '';
    secondaryMobile.value = m.secondaryMobile ?? '';
    email.value = m.emailAddress ?? '';
    emergencyContactName.value = m.emergencyContactName ?? '';
    emergencyContactNo.value = m.emergencyContactNo ?? '';
    facebook.value = m.facebookUrl ?? '';
    whatsapp.value = m.whatsappUrl ?? '';
    instagram.value = m.instagramUrl ?? '';
    twitter.value = m.twitterUrl ?? '';
    entryPersonMobile.value = m.entryPersonMobileNo ?? '';

    mobileCtrl.text = mobileNo.value;
    entryPersonMobileCtrl.text = entryPersonMobile.value;
    secondaryMobileCtrl.text = secondaryMobile.value;
    emailCtrl.text = email.value;
    emergencyNameCtrl.text = emergencyContactName.value;
    emergencyNoCtrl.text = emergencyContactNo.value;
    facebookCtrl.text = facebook.value;
    whatsappCtrl.text = whatsapp.value;
    instagramCtrl.text = instagram.value;
    twitterCtrl.text = twitter.value;
  }

  void addAddress() {
    addresses.add(
      AddressModel(
        type: '',
        isPrimary: false,
      ),
    );
  }

  void removeAddress(int index) {
    addresses.removeAt(index);
  }

  void addEducation() {
    final hasHighest = educationList.any((e) => e.isHighest);
    educationList.add(
      EducationModel(
        qualification: '',
        isHighest: !hasHighest,
        isNew: true,
      ),
    );
  }

  void removeEducation(int index) {
    educationList.removeAt(index);
  }
}
