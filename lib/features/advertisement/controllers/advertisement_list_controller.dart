import 'package:get/get.dart';
import '../models/advertisement.dart';
import '../repositories/advertisement_repository.dart';

class AdvertisementListController extends GetxController {
  final AdvertisementRepository _repository;

  AdvertisementListController(this._repository);

  final RxList<Advertisement> advertisements = <Advertisement>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool hasMore = true.obs;

  int _currentPage = 1;
  static const int _pageSize = 20;

  @override
  void onInit() {
    super.onInit();
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    isLoading.value = true;
    _currentPage = 1;
    hasMore.value = true;

    try {
      final result = await _repository.getList(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (result.isSuccess) {
        final paginated = result.dataOrNull;
        final list = paginated?.data ?? [];
        advertisements.assignAll(list);
        hasMore.value = list.length >= _pageSize &&
            _currentPage < (paginated?.totalPages ?? 1);
      } else {
        advertisements.clear();
        hasMore.value = false;
      }
    } catch (_) {
      advertisements.clear();
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchNextPage() async {
    if (isMoreLoading.value || !hasMore.value) return;

    isMoreLoading.value = true;
    _currentPage++;

    try {
      final result = await _repository.getList(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (result.isSuccess) {
        final paginated = result.dataOrNull;
        final list = paginated?.data ?? [];
        if (list.isNotEmpty) {
          advertisements.addAll(list);
        }
        hasMore.value = list.length >= _pageSize &&
            _currentPage < (paginated?.totalPages ?? 1);
      } else {
        hasMore.value = false;
      }
    } catch (_) {
      hasMore.value = false;
    } finally {
      isMoreLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await fetchFirstPage();
  }
}
