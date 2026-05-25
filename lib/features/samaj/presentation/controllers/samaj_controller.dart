import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/logging/app_logger.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/entities/samaj.dart';
import 'package:pscommunitymobileapp/features/samaj/domain/repositories/samaj_repository.dart';

class SamajController extends GetxController {
  SamajController(this._repository);
  final SamajRepository _repository;

  final Rxn<Samaj> samaj = Rxn<Samaj>();
  final RxBool isSamajLoading = false.obs;
  final RxnString samajError = RxnString();

  bool _isFetchingSamaj = false;

  Future<void> fetchAll() async {
    await Future.wait([fetchSamajDetail()]);
  }

  Future<void> fetchSamajDetail() async {
    if (_isFetchingSamaj) return;
    _isFetchingSamaj = true;

    isSamajLoading.value = true;
    samajError.value = null;

    try {
      final detail = await _repository.getSamajDetail();
      if (detail != null) {
        samaj.value = detail;
        AppLogger.d('Samaj details loaded: ${samaj.value?.name}');
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
