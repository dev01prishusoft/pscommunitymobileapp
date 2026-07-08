import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/localization_service.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';

class SamajController extends GetxController with WidgetsBindingObserver{
  SamajController(this._repository);
  final SamajRepository _repository;

  final Rxn<Samaj> samaj = Rxn<Samaj>();
  final RxBool isSamajLoading = false.obs;
  final RxnString samajError = RxnString();

  bool _isFetchingSamaj = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    try {
      final localizationService = Get.find<LocalizationService>();
      ever(localizationService.currentLocale, (_) {
        fetchSamajDetail(updateLanguage: false);
      });
    } catch (_) {
      // Localization service might not be available in some tests or contexts
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (Get.context == null) return;
      await fetchAll();
    }
  }

  Future<void> fetchAll() async {
    await Future.wait([fetchSamajDetail()]);
  }

  Future<void> fetchSamajDetail({bool updateLanguage = true}) async {
    if (_isFetchingSamaj) return;
    _isFetchingSamaj = true;

    isSamajLoading.value = true;
    samajError.value = null;

    try {
      final detail = await _repository.getSamajDetail();
      _isFetchingSamaj = false; // Allow re-fetches triggered by language change
      if (detail != null) {
        samaj.value = detail;
        AppLogger.d('Samaj details loaded: ${samaj.value?.toJson()}');

        if (updateLanguage && detail.languageCode != null && detail.languageCode!.isNotEmpty) {
          try {
            final localizationService = Get.find<LocalizationService>();
            if (localizationService.languages.isEmpty) {
              await localizationService.fetchLanguages();
            }
            final hasSaved = await localizationService.hasSavedLocale();
            if (!hasSaved) {
              final matchedLang = localizationService.languages.firstWhereOrNull(
                (l) => l.code.toUpperCase() == detail.languageCode!.toUpperCase()
              );
              if (matchedLang != null) {
                final code = matchedLang.code.toUpperCase();
                if (code == 'EN') {
                  await localizationService.changeLocale('en', 'US');
                } else if (code == 'GJ' || code == 'GU') {
                  await localizationService.changeLocale('gu', 'IN');
                }
              }
            }
          } catch (e) {
            AppLogger.e('Failed to set default language from samaj', e);
          }
        }
      }
    } catch (e, stack) {
      samajError.value = e.toString();
      AppLogger.e('Failed to fetch samaj details', e, stack);
    } finally {
      isSamajLoading.value = false;
      _isFetchingSamaj = false;
    }
  }

  void clear() {
    samaj.value = null;
    samajError.value = null;
    isSamajLoading.value = false;
    _isFetchingSamaj = false;
  }
}
