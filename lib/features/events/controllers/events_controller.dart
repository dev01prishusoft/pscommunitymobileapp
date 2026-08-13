import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/models/event_model.dart';

class EventsController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final RxInt selectedTabIndex = 0.obs;

  final RxList<EventModel> allEvents = <EventModel>[].obs;
  
  final RxBool isSearchVisible = false.obs;
  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      selectedTabIndex.value = tabController.index;
    });
    _loadDummyData();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    tabController.dispose();
    super.onClose();
  }

  void _loadDummyData() {
    allEvents.value = [
      EventModel(
        id: '1',
        title: 'Shaikshanik Melavdo 2026',
        gujaratiTitle: 'શૈક્ષણિક મેળાવડો 2026',
        category: EventCategory.educational,
        startTime: DateTime(2026, 8, 16, 9, 30),
        endTime: DateTime(2026, 8, 16, 17, 0),
        location: 'Vidya Bhavan Hall',
        totalPlaces: 450,
        placesTaken: 318,
        isRegistered: true,
        status: 'Upcoming',
        imageUrl: 'https://picsum.photos/600/300?random=1',
      ),
      EventModel(
        id: '2',
        title: 'Free health check-up camp 2026',
        gujaratiTitle: 'નિઃશુલ્ક આરોગ્ય તપાસ કેમ્પ 2026',
        category: EventCategory.medicalCamp,
        startTime: DateTime(2026, 9, 13, 8, 0),
        endTime: DateTime(2026, 9, 13, 14, 0),
        location: 'Samaj Bhavan community hall',
        totalPlaces: 250,
        placesTaken: 231,
        isRegistered: false,
        status: 'Upcoming',
      ),
       EventModel(
        id: '3',
        title: 'Free health check-up camp 2026',
        gujaratiTitle: 'નિઃશુલ્ક આરોગ્ય તપાસ કેમ્પ 2026',
        category: EventCategory.medicalCamp,
        startTime: DateTime(2026, 9, 13, 8, 0),
        endTime: DateTime(2026, 9, 13, 14, 0),
        location: 'Samaj Bhavan community hall',
        totalPlaces: 250,
        placesTaken: 231,
        isRegistered: false,
        status: 'Upcoming',
      ),
       EventModel(
        id: '4',
        title: 'Free health check-up camp 2026',
        gujaratiTitle: 'નિઃશુલ્ક આરોગ્ય તપાસ કેમ્પ 2026',
        category: EventCategory.medicalCamp,
        startTime: DateTime(2026, 9, 13, 8, 0),
        endTime: DateTime(2026, 9, 13, 14, 0),
        location: 'Samaj Bhavan community hall',
        totalPlaces: 250,
        placesTaken: 231,
        isRegistered: false,
        status: 'Upcoming',
      ),
      EventModel(
        id: '3',
        title: 'Sports Tournament 2026',
        gujaratiTitle: 'રમતગમત સ્પર્ધા 2026',
        category: EventCategory.other,
        startTime: DateTime(2026, 10, 5, 10, 0),
        endTime: DateTime(2026, 10, 5, 18, 0),
        location: 'City Sports Ground',
        totalPlaces: 500,
        placesTaken: 120,
        isRegistered: false,
        status: 'Ongoing',
        imageUrl: 'https://picsum.photos/600/300?random=5',
      ),
      EventModel(
        id: '4',
        title: 'Annual General Meeting',
        gujaratiTitle: 'વાર્ષિક સામાન્ય સભા',
        category: EventCategory.other,
        startTime: DateTime(2025, 12, 1, 9, 0),
        endTime: DateTime(2025, 12, 1, 13, 0),
        location: 'Main Auditorium',
        totalPlaces: 300,
        placesTaken: 300,
        isRegistered: true,
        status: 'Past',
        imageUrl: 'https://picsum.photos/600/300?random=6',
      ),
      EventModel(
        id: '5',
        title: 'Blood Donation Camp',
        gujaratiTitle: 'રક્તદાન શિબિર',
        category: EventCategory.medicalCamp,
        startTime: DateTime(2025, 11, 15, 8, 0),
        endTime: DateTime(2025, 11, 15, 15, 0),
        location: 'Community Center',
        totalPlaces: 100,
        placesTaken: 85,
        isRegistered: false,
        status: 'Past',
        imageUrl: 'https://picsum.photos/600/300?random=7',
      ),
    ];
  }

  List<EventModel> get _filteredEvents {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return allEvents;
    return allEvents.where((e) => 
      e.title.toLowerCase().contains(query) || 
      e.gujaratiTitle.toLowerCase().contains(query)
    ).toList();
  }

  List<EventModel> get upcomingEvents =>
      _filteredEvents.where((e) => e.status == 'Upcoming').toList();
  List<EventModel> get ongoingEvents =>
      _filteredEvents.where((e) => e.status == 'Ongoing').toList();
  List<EventModel> get pastEvents =>
      _filteredEvents.where((e) => e.status == 'Past').toList();
}