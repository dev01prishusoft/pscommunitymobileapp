import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_environment.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/constants/failures.dart';
import 'package:pscommunitymobileapp/core/models/library_category_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_details_model.dart';
import 'package:pscommunitymobileapp/core/models/library_item_model.dart';
import 'package:pscommunitymobileapp/core/network/api_response.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/utils/crash_reporter.dart';
import 'package:pscommunitymobileapp/core/utils/debouncer.dart';
import 'package:pscommunitymobileapp/core/widgets/app_state_view.dart';
import 'package:pscommunitymobileapp/features/library/repositories/library_repository.dart';

class LibraryController extends GetxController {
  LibraryController([LibraryRepository? repository])
    : _repository = repository ?? Get.find<LibraryRepository>();
  final LibraryRepository _repository;

  final Rx<AppState> categoriesState = AppState.loading.obs;
  final RxList<LibraryCategoryData> categories = <LibraryCategoryData>[].obs;
  final RxString categoryErrorMessage = ''.obs;

  final TextEditingController categorySearchController =
      TextEditingController();
  final RxString categorySearchQuery = ''.obs;
  final Debouncer _categoryDebouncer = Debouncer(milliseconds: 400);
  CancelToken? _categoriesCancelToken;

  final Rxn<LibraryCategoryData> selectedCategory = Rxn<LibraryCategoryData>();

  final Rx<AppState> itemsState = AppState.loading.obs;
  final RxList<LibraryItemData> items = <LibraryItemData>[].obs;
  final RxString itemErrorMessage = ''.obs;

  final TextEditingController itemSearchController = TextEditingController();
  final RxString itemSearchQuery = ''.obs;
  final Debouncer _itemDebouncer = Debouncer(milliseconds: 400);
  CancelToken? _itemsCancelToken;

  final ScrollController itemScrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 20;
  final RxBool hasMore = true.obs;
  final RxBool isNextPageLoading = false.obs;
  final RxBool hasPageError = false.obs;
  int _currentLoadRequestId = 0;

  final Rxn<LibraryItemDetailsData> selectedItemDetails =
      Rxn<LibraryItemDetailsData>();
  final RxBool isLoadingItemDetails = false.obs;
  final RxString itemDetailsError = ''.obs;

  RxBool get isLoading => (categoriesState.value == AppState.loading).obs;

  static Color get primaryColor => AppColors.primary;
  static Color get scaffoldBg => AppColors.sfBackground;

  static String resolveMediaUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.trim().isEmpty) return '';
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final baseUrl = AppEnvironment.I.apiBaseUrl.endsWith('/')
        ? AppEnvironment.I.apiBaseUrl
            .substring(0, AppEnvironment.I.apiBaseUrl.length - 1)
        : AppEnvironment.I.apiBaseUrl;
    final cleanPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$baseUrl$cleanPath';
  }

  static String formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '';
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else if (bytes >= 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$bytes B';
  }

  static String formatDuration(dynamic seconds) {
    if (seconds == null) return '';
    final sec = seconds is int ? seconds : int.tryParse(seconds.toString());
    if (sec == null || sec <= 0) return '';
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _setupItemPaginationListener();
    loadCategories();
  }

  @override
  void onClose() {
    _categoriesCancelToken?.cancel();
    _itemsCancelToken?.cancel();
    categorySearchController.dispose();
    itemSearchController.dispose();
    itemScrollController.dispose();
    _categoryDebouncer.dispose();
    _itemDebouncer.dispose();
    super.onClose();
  }

  void _setupItemPaginationListener() {
    itemScrollController.addListener(() {
      if (itemScrollController.position.pixels >=
          itemScrollController.position.maxScrollExtent - 200) {
        loadNextPage();
      }
    });
  }

  List<LibraryCategoryData> get filteredCategories {
    final query = categorySearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return categories;
    return categories.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query);
    }).toList();
  }

  void onCategorySearchChanged(String val) {
    categorySearchQuery.value = val;
    _categoryDebouncer.run(() {
      loadCategories(search: val.trim(), isRefresh: true);
    });
  }

  Future<void> loadCategories({String? search, bool isRefresh = false}) async {
    _categoriesCancelToken?.cancel();
    _categoriesCancelToken = CancelToken();

    if (!isRefresh && categories.isEmpty) {
      categoriesState.value = AppState.loading;
    }
    categoryErrorMessage.value = '';

    try {
      final query = search ?? categorySearchQuery.value.trim();
      final result = await _repository.getCategories(
        search: query.isNotEmpty ? query : null,
        cancelToken: _categoriesCancelToken,
      );

      if (result is Success<List<LibraryCategoryData>>) {
        final loaded = result.data;
        categories.assignAll(loaded);

        if (categories.isEmpty) {
          categoriesState.value = AppState.empty;
        } else {
          categoriesState.value = AppState.data;
        }

        if (selectedCategory.value != null) {
          final match = categories.firstWhereOrNull(
            (c) =>
                c.libraryCategoryId ==
                selectedCategory.value!.libraryCategoryId,
          );
          if (match != null) {
            selectedCategory.value = match;
          }
        }
      } else {
        final failure = result.failureOrNull;
        categoryErrorMessage.value =
            failure?.message ?? LK.library_err_load_categories.tr;
        if (categories.isEmpty) {
          categoriesState.value = AppState.error;
        }
      }
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'LibraryController.loadCategories failed',
      );
      categoryErrorMessage.value = e.toString();
      if (categories.isEmpty) {
        categoriesState.value = AppState.error;
      }
    }
  }

  void selectCategory(LibraryCategoryData category) {
    selectedCategory.value = category;
    itemSearchController.clear();
    itemSearchQuery.value = '';
    items.clear();
    loadCategoryItems(isRefresh: true);
    Get.toNamed<void>(AppRouter.libraryItems);
  }

  List<LibraryItemData> get filteredItems {
    final query = itemSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((i) {
      return i.title.toLowerCase().contains(query) ||
          i.description.toLowerCase().contains(query) ||
          i.type.toLowerCase().contains(query);
    }).toList();
  }

  void onItemSearchChanged(String val) {
    itemSearchQuery.value = val;
    _itemDebouncer.run(() {
      loadCategoryItems(isRefresh: true, search: val.trim());
    });
  }

  Future<void> loadCategoryItems({
    bool isRefresh = true,
    String? search,
  }) async {
    final cat = selectedCategory.value;
    if (cat == null || cat.libraryCategoryId == null) return;

    if (!isRefresh && (!hasMore.value || isNextPageLoading.value)) {
      return;
    }

    final requestId = ++_currentLoadRequestId;

    if (isRefresh) {
      _currentPage = 1;
      hasMore.value = true;
      hasPageError.value = false;
      itemsState.value = AppState.loading;
      _itemsCancelToken?.cancel();
      _itemsCancelToken = CancelToken();
    } else {
      isNextPageLoading.value = true;
      hasPageError.value = false;
    }
    itemErrorMessage.value = '';

    final query = search ?? itemSearchQuery.value.trim();

    try {
      final result = await _repository.getCategoryItems(
        categoryId: cat.libraryCategoryId!,
        page: _currentPage,
        pageSize: _pageSize,
        search: query.isNotEmpty ? query : null,
        cancelToken: _itemsCancelToken,
      );

      if (requestId != _currentLoadRequestId) return;

      if (result is Success<PaginatedResponse<LibraryItemData>>) {
        final pageData = result.data;
        final newItems = pageData.data;

        if (isRefresh) {
          items.assignAll(newItems);
        } else {
          items.addAll(newItems);
        }

        if (items.isEmpty) {
          itemsState.value = AppState.empty;
        } else {
          itemsState.value = AppState.data;
        }

        _currentPage++;
        hasMore.value = pageData.totalPages > 0
            ? _currentPage <= pageData.totalPages
            : pageData.totalRecords > 0
            ? items.length < pageData.totalRecords
            : newItems.length >= _pageSize;
        hasPageError.value = false;
      } else {
        itemErrorMessage.value =
            result.failureOrNull?.message ?? LK.library_err_load_items.tr;
        if (isRefresh || items.isEmpty) {
          itemsState.value = AppState.error;
        } else {
          hasPageError.value = true;
        }
      }
    } catch (e, stack) {
      if (requestId != _currentLoadRequestId) return;
      CrashReporter.recordError(
        e,
        stack,
        reason: 'LibraryController.loadCategoryItems failed',
      );
      itemErrorMessage.value = e.toString();
      if (isRefresh || items.isEmpty) {
        itemsState.value = AppState.error;
      } else {
        hasPageError.value = true;
      }
    } finally {
      if (requestId == _currentLoadRequestId) {
        isNextPageLoading.value = false;
      }
    }
  }

  void loadNextPage() {
    if (!isNextPageLoading.value && hasMore.value) {
      loadCategoryItems(isRefresh: false);
    }
  }

  Future<LibraryItemDetailsData?> fetchItemDetails(dynamic id) async {
    if (id == null) return null;
    isLoadingItemDetails.value = true;
    itemDetailsError.value = '';
    try {
      final result = await _repository.getItemDetails(id);
      if (result is Success<LibraryItemDetailsData>) {
        selectedItemDetails.value = result.data;
        return result.data;
      } else {
        itemDetailsError.value =
            result.failureOrNull?.message ?? LK.library_err_load_details.tr;
        return null;
      }
    } catch (e, stack) {
      CrashReporter.recordError(
        e,
        stack,
        reason: 'LibraryController.fetchItemDetails failed',
      );
      itemDetailsError.value = e.toString();
      return null;
    } finally {
      isLoadingItemDetails.value = false;
    }
  }

  void openItem(LibraryItemData item) {
    final type = item.type.toUpperCase();
    switch (type) {
      case 'PDF':
        Get.toNamed<void>(AppRouter.libraryPdf, arguments: item);
        break;
      case 'TEXT':
        Get.toNamed<void>(AppRouter.libraryText, arguments: item);
        break;
      case 'VIDEO':
        Get.toNamed<void>(AppRouter.libraryVideo, arguments: item);
        break;
      case 'IMAGE':
        Get.toNamed<void>(AppRouter.libraryImage, arguments: item);
        break;
      case 'AUDIO':
        Get.toNamed<void>(AppRouter.libraryAudio, arguments: item);
        break;
    }
  }
}
