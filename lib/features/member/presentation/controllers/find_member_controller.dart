import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';

class FindMemberController extends GetxController {
  final Rx<AppState> state = AppState.data.obs;
  final RxList<Map<String, String>> filteredMembers = <Map<String, String>>[].obs;
  final RxString searchQuery = ''.obs;

  static const List<Map<String, String>> allMembers = [
    {
      'name': 'Rajesh Kumar Patel',
      'info': 'Male • Self • Married • Engineer',
      'location': 'Satellite, Daskroi',
    },
    {
      'name': 'Priya Rajesh Patel',
      'info': 'Female • Wife • Married • Teacher',
      'location': 'Satellite, Daskroi',
    },
    {
      'name': 'Amit Mehta',
      'info': 'Male • Self • Married • Business',
      'location': 'Naranpura, Daskroi',
    },
    {
      'name': 'Neha Mehta',
      'info': 'Female • Wife • Married • Doctor',
      'location': 'Naranpura, Daskroi',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    filteredMembers.assignAll(allMembers);
  }

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredMembers.assignAll(allMembers);
      state.value = AppState.data;
    } else {
      final results = allMembers.where((m) {
        final name = m['name']?.toLowerCase() ?? '';
        final info = m['info']?.toLowerCase() ?? '';
        final location = m['location']?.toLowerCase() ?? '';
        final search = query.toLowerCase();
        return name.contains(search) || info.contains(search) || location.contains(search);
      }).toList();
      
      filteredMembers.assignAll(results);
      state.value = results.isEmpty ? AppState.empty : AppState.data;
    }
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredMembers.assignAll(allMembers);
    state.value = AppState.data;
  }
}
