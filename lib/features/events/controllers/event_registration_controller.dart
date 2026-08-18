import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/models/events_details_model.dart';
import 'package:pscommunitymobileapp/core/models/member.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/widgets/app_drawer.dart';
import 'package:pscommunitymobileapp/features/payment/controllers/payment_controller.dart';

class EventRegistrationController extends GetxController {
  final EventDetailsData event;
  EventRegistrationController({required this.event});

  final formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = Get.find<ApiClient>();

  final Rx<Member?> currentUser = Rx<Member?>(null);
  
  final RxList<Member> familyMembers = <Member>[].obs;
  final RxBool isLoadingMembers = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString memberSearchQuery = ''.obs;
  
  final RxList<int> selectedMemberIds = <int>[].obs;
  
  final RxList<TextEditingController> customGuests = <TextEditingController>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    _fetchFamilyMembers();
  }

  List<Member> get filteredFamilyMembers {
    if (memberSearchQuery.value.isEmpty) {
      return familyMembers;
    }
    final query = memberSearchQuery.value.toLowerCase();
    return familyMembers.where((m) => m.fullName.toLowerCase().contains(query)).toList();
  }

  void onSearchChanged(String query) {
    memberSearchQuery.value = query;
  }

  void _loadCurrentUser() {
    if (Get.isRegistered<DrawerUserController>()) {
      currentUser.value = Get.find<DrawerUserController>().member.value;
    }
  }

  Future<void> _fetchFamilyMembers() async {
    isLoadingMembers.value = true;
    try {
      final response = await _apiClient.get(
        '/api/v1/member/mobile/list',
        queryParameters: {
          'Page': 1,
          'PageSize': 100, // Fetch all reasonable members
        },
      );

      if (response.data['succeeded'] == true) {
        final dataObj = response.data['data'];
        if (dataObj is Map<String, dynamic>) {
          final listData = dataObj['data'] as List<dynamic>? ?? [];
          final allMembers = listData
              .map((e) => Member.fromJson(e as Map<String, dynamic>))
              .toList();
          
          // Filter for approved members
          var approvedMembers = allMembers.where((m) => m.approveStatus?.toLowerCase() == 'approved').toList();

          // Add the current user to the list if not already present
          if (currentUser.value != null) {
            final currentUserId = currentUser.value!.memberId;
            if (!approvedMembers.any((m) => m.memberId == currentUserId)) {
              approvedMembers.insert(0, currentUser.value!);
            }
          }

          familyMembers.value = approvedMembers;
        }
      }
    } catch (e) {
      debugPrint('Error fetching family members: $e');
    } finally {
      isLoadingMembers.value = false;
    }
  }

  void toggleMemberSelection(int memberId) {
    if (selectedMemberIds.contains(memberId)) {
      selectedMemberIds.remove(memberId);
    } else {
      selectedMemberIds.add(memberId);
    }
  }

  void addCustomGuest() {
    if (customGuests.length < (event.maximumGuestsPerMember ?? 0)) {
      customGuests.add(TextEditingController());
    } else {
      Get.snackbar('Limit Reached', 'You cannot add more custom guests for this event.');
    }
  }

  void removeCustomGuest(int index) {
    if (index >= 0 && index < customGuests.length) {
      customGuests[index].dispose();
      customGuests.removeAt(index);
    }
  }

  void registerNow() {
    if (formKey.currentState!.validate()) {
      if (event.registrationFee != null && event.registrationFee! > 0) {
        final paymentController = Get.find<PaymentController>();
        paymentController.initiateDirectPayment(event.registrationFee!.toDouble());
      } else {
        _showSuccessDialog();
      }
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Success'),
        content: const Text('You have successfully registered for the event!'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.back(); // close registration page
            },
            child: const Text('OK'),
          )
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    for (var controller in customGuests) {
      controller.dispose();
    }
    super.onClose();
  }
}
